/*******************************************************************************
 * Copyright (c) 2003, 2006 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM - Initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module dwtx.core.internal.jobs.OrderedLock;

import tango.text.convert.Format;
import dwtx.dwtxhelper.JThread;
import tango.io.Stdout;
import dwt.dwthelper.utils;

import dwtx.core.runtime.Assert;
import dwtx.core.runtime.jobs.ILock;
import dwtx.core.runtime.jobs.ISchedulingRule;

import dwtx.core.internal.jobs.LockManager;
import dwtx.core.internal.jobs.Queue;
import dwtx.core.internal.jobs.Semaphore;

/**
 * A lock used to control write access to an exclusive resource.
 *
 * The lock avoids circular waiting deadlocks by detecting the deadlocks
 * and resolving them through the suspension of all locks owned by one
 * of the threads involved in the deadlock. This makes it impossible for n such
 * locks to deadlock while waiting for each other.  The downside is that this means
 * that during an interval when a process owns a lock, it can be forced
 * to give the lock up and wait until all locks it requires become
 * available.  This removes the feature of exclusive access to the
 * resource in contention for the duration between acquire() and
 * release() calls.
 *
 * The lock implementation prevents starvation by granting the
 * lock in the same order in which acquire() requests arrive. In
 * this scheme, starvation is only possible if a thread retains
 * a lock indefinitely.
 */
public class OrderedLock : ILock, ISchedulingRule {

    private static const bool DEBUG = false;
    /**
     * Locks are sequentially ordered for debugging purposes.
     */
    private static int nextLockNumber = 0;
    /**
     * The thread of the operation that currently owns the lock.
     */
    private /+volatile+/ JThread currentOperationThread;
    /**
     * Records the number of successive acquires in the same
     * thread. The lock is released only when the depth
     * reaches zero.
     */
    private int depth;
    /**
     * The manager that implements the deadlock detection and resolution protocol.
     */
    private const LockManager manager;
    private const int number;

    /**
     * Queue of semaphores for threads currently waiting
     * on the lock. This queue is not thread-safe, so access
     * to this queue must be synchronized on the lock instance.
     */
    private const Queue operations;

    /**
     * Creates a new workspace lock.
     */
    this(LockManager manager) {

        operations = new Queue();

        this.manager = manager;
        this.number = nextLockNumber++;
    }

    /* (non-Javadoc)
     * @see Locks.ILock#acquire()
     */
    public void acquire() {
        //spin until the lock is successfully acquired
        //NOTE: spinning here allows the UI thread to service pending syncExecs
        //if the UI thread is waiting to acquire a lock.
        while (true) {
            try {
                if (acquire(Long.MAX_VALUE))
                    return;
            } catch (InterruptedException e) {
                //ignore and loop
            }
        }
    }

    /* (non-Javadoc)
     * @see Locks.ILock#acquire(long)
     */
    public bool acquire(long delay) {
        implMissing(__FILE__, __LINE__ );
//         if (Thread.interrupted())
//             throw new InterruptedException();

        bool success = false;
        if (delay <= 0)
            return attempt();
        Semaphore semaphore = createSemaphore();
        if (semaphore is null)
            return true;
        if (DEBUG)
            Stdout.formatln("[{}] Operation waiting to be executed... ", JThread.currentThread(), this); //$NON-NLS-1$ //$NON-NLS-2$
        success = doAcquire(semaphore, delay);
        manager.resumeSuspendedLocks(JThread.currentThread());
        if (DEBUG && success)
            Stdout.formatln("[{}] Operation started... ", JThread.currentThread(), this); //$NON-NLS-1$ //$NON-NLS-2$
        else if (DEBUG)
            Stdout.formatln("[{}] Operation timed out... ", JThread.currentThread(), this); //$NON-NLS-1$ //$NON-NLS-2$
        return success;
    }

    /**
     * Attempts to acquire the lock.  Returns false if the lock is not available and
     * true if the lock has been successfully acquired.
     */
    private synchronized bool attempt() {
        //return true if we already own the lock
        //also, if nobody is waiting, grant the lock immediately
        if ((currentOperationThread is JThread.currentThread()) || (currentOperationThread is null && operations.isEmpty())) {
            depth++;
            setCurrentOperationThread(JThread.currentThread());
            return true;
        }
        return false;
    }

    /* (non-Javadoc)
     * @see dwtx.core.runtime.jobs.ISchedulingRule#contains(dwtx.core.runtime.jobs.ISchedulingRule)
     */
    public bool contains(ISchedulingRule rule) {
        return false;
    }

    /**
     * Returns null if acquired and a Semaphore object otherwise. If a
     * waiting semaphore already exists for this thread, it will be returned,
     * otherwise a new semaphore will be created, enqueued, and returned.
     */
    private synchronized Semaphore createSemaphore() {
        return attempt() ? null : enqueue(new Semaphore(JThread.currentThread()));
    }

    /**
     * Attempts to acquire this lock.  Callers will block  until this lock comes available to
     * them, or until the specified delay has elapsed.
     */
    private bool doAcquire(Semaphore semaphore, long delay) {
        bool success = false;
        //notify hook to service pending syncExecs before falling asleep
        if (manager.aboutToWait(this.currentOperationThread)) {
            //hook granted immediate access
            //remove semaphore for the lock request from the queue
            //do not log in graph because this thread did not really get the lock
            removeFromQueue(semaphore);
            depth++;
            manager.addLockThread(currentOperationThread, this);
            return true;
        }
        //Make sure the semaphore is in the queue before we start waiting
        //It might have been removed from the queue while servicing syncExecs
        //This is will return our existing semaphore if it is still in the queue
        semaphore = createSemaphore();
        if (semaphore is null)
            return true;
        manager.addLockWaitThread(JThread.currentThread(), this);
        try {
            success = semaphore.acquire(delay);
        } catch (InterruptedException e) {
            if (DEBUG)
                Stdout.formatln(Format("[{}] Operation interrupted while waiting... :-|", JThread.currentThread())); //$NON-NLS-1$ //$NON-NLS-2$
            throw e;
        }
        if (success) {
            depth++;
            updateCurrentOperation();
        } else {
            removeFromQueue(semaphore);
            manager.removeLockWaitThread(JThread.currentThread(), this);
        }
        return success;
    }

    /**
     * Releases this lock from the thread that used to own it.
     * Grants this lock to the next thread in the queue.
     */
    private synchronized void doRelease() {
        //notify hook
        manager.aboutToRelease();
        depth = 0;
        Semaphore next = cast(Semaphore) operations.peek();
        setCurrentOperationThread(null);
        if (next !is null)
            next.release();
    }

    /**
     * If there is another semaphore with the same runnable in the
     * queue, the other is returned and the new one is not added.
     */
    private synchronized Semaphore enqueue(Semaphore newSemaphore) {
        Semaphore semaphore = cast(Semaphore) operations.get(newSemaphore);
        if (semaphore is null) {
            operations.enqueue(newSemaphore);
            return newSemaphore;
        }
        return semaphore;
    }

    /**
     * Suspend this lock by granting the lock to the next lock in the queue.
     * Return the depth of the suspended lock.
     */
    protected int forceRelease() {
        int oldDepth = depth;
        doRelease();
        return oldDepth;
    }
    package int forceRelease_package() {
        return forceRelease();
    }

    /* (non-Javadoc)
     * @see Locks.ILock#getDepth()
     */
    public int getDepth() {
        return depth;
    }

    /* (non-Javadoc)
     * @see dwtx.core.runtime.jobs.ISchedulingRule#isConflicting(dwtx.core.runtime.jobs.ISchedulingRule)
     */
    public bool isConflicting(ISchedulingRule rule) {
        return rule is this;
    }

    /* (non-Javadoc)
     * @see Locks.ILock#release()
     */
    public void release() {
        if (depth is 0)
            return;
        //only release the lock when the depth reaches zero
        Assert.isTrue(depth >= 0, "Lock released too many times"); //$NON-NLS-1$
        if (--depth is 0)
            doRelease();
        else
            manager.removeLockThread(currentOperationThread, this);
    }

    /**
     * Removes a semaphore from the queue of waiting operations.
     *
     * @param semaphore The semaphore to remove
     */
    private synchronized void removeFromQueue(Semaphore semaphore) {
        operations.remove(semaphore);
    }

    /**
     * If newThread is null, release this lock from its previous owner.
     * If newThread is not null, grant this lock to newThread.
     */
    private void setCurrentOperationThread(JThread newThread) {
        if ((currentOperationThread !is null) && (newThread is null))
            manager.removeLockThread(currentOperationThread, this);
        this.currentOperationThread = newThread;
        if (currentOperationThread !is null)
            manager.addLockThread(currentOperationThread, this);
    }

    /**
     * Forces the lock to be at the given depth.
     * Used when re-acquiring a suspended lock.
     */
    protected void setDepth(int newDepth) {
        for (int i = depth; i < newDepth; i++) {
            manager.addLockThread(currentOperationThread, this);
        }
        this.depth = newDepth;
    }
    package void setDepth_package(int newDepth) {
        return setDepth(newDepth);
    }

    /**
     * For debugging purposes only.
     */
    public String toString() {
        return Format("OrderedLock ({})", number ); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * This lock has just been granted to a new thread (the thread waited for it).
     * Remove the request from the queue and update both the graph and the lock.
     */
    private synchronized void updateCurrentOperation() {
        operations.dequeue();
        setCurrentOperationThread(JThread.currentThread());
    }
}
