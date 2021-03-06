/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module dwt.widgets.Synchronizer;

import dwt.widgets.Display;
import dwt.widgets.RunnableLock;
import dwt.dwthelper.Runnable;
import dwt.dwthelper.System;
import dwt.internal.Compatibility;

import dwt.DWT;
import tango.core.Thread;
import dwt.graphics.Device;
import tango.core.Exception;

/**
 * Instances of this class provide synchronization support
 * for displays. A default instance is created automatically
 * for each display, and this instance is sufficient for almost
 * all applications.
 * <p>
 * <b>IMPORTANT:</b> Typical application code <em>never</em>
 * needs to deal with this class. It is provided only to
 * allow applications which require non-standard
 * synchronization behavior to plug in the support they
 * require. <em>Subclasses which override the methods in
 * this class must ensure that the superclass methods are
 * invoked in their implementations</em>
 * </p>
 *
 * @see Display#setSynchronizer
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Synchronizer {
    Display display;
    int messageCount;
    RunnableLock [] messages;
    Object messageLock;
    Thread syncThread;
    static final int GROW_SIZE = 4;
    static final int MESSAGE_LIMIT = 64;

    //TEMPORARY CODE
    static final bool IS_CARBON = false;//"carbon".equals (DWT.getPlatform ());

/**
 * Constructs a new instance of this class.
 *
 * @param display the display to create the synchronizer on
 */
public this (Display display) {
    this.display = display;
    messageLock = new Object ();
}

void addLast (RunnableLock lock) {
    bool wake = false;
    synchronized (messageLock) {
        if (messages is null) messages = new RunnableLock [GROW_SIZE];
        if (messageCount is messages.length) {
            RunnableLock[] newMessages = new RunnableLock [messageCount + GROW_SIZE];
            System.arraycopy (messages, 0, newMessages, 0, messageCount);
            messages = newMessages;
        }
        messages [messageCount++] = lock;
        wake = messageCount is 1;
    }
    if (wake) display.wakeThread ();
}

/**
 * Causes the <code>run()</code> method of the runnable to
 * be invoked by the user-interface thread at the next
 * reasonable opportunity. The caller of this method continues
 * to run in parallel, and is not notified when the
 * runnable has completed.
 *
 * @param runnable code to run on the user-interface thread.
 *
 * @see #syncExec
 */
public void asyncExec (Runnable runnable) {
    if (runnable is null) {
        //TEMPORARY CODE
        if (!IS_CARBON) {
            display.wake ();
            return;
        }
    }
    addLast (new RunnableLock (runnable));
}

int getMessageCount () {
    synchronized (messageLock) {
        return messageCount;
    }
}

void releaseSynchronizer () {
    display = null;
    messages = null;
    messageLock = null;
    syncThread = null;
}

RunnableLock removeFirst () {
    synchronized (messageLock) {
        if (messageCount is 0) return null;
        RunnableLock lock = messages [0];
        System.arraycopy (messages, 1, messages, 0, --messageCount);
        messages [messageCount] = null;
        if (messageCount is 0) {
            if (messages.length > MESSAGE_LIMIT) messages = null;
        }
        return lock;
    }
}

bool runAsyncMessages () {
    return runAsyncMessages (false);
}

bool runAsyncMessages (bool all) {
    bool run = false;
    do {
        RunnableLock lock = removeFirst ();
        if (lock is null) return run;
        run = true;
        synchronized (lock) {
            syncThread = lock.thread;
            try {
                lock.run ();
            } catch (Exception t) {
                lock.throwable = t;
                DWT.error (DWT.ERROR_FAILED_EXEC, t);
            } finally {
                syncThread = null;
                lock.notifyAll ();
            }
        }
    } while (all);
    return run;
}

/**
 * Causes the <code>run()</code> method of the runnable to
 * be invoked by the user-interface thread at the next
 * reasonable opportunity. The thread which calls this method
 * is suspended until the runnable completes.
 *
 * @param runnable code to run on the user-interface thread.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_FAILED_EXEC - if an exception occurred when executing the runnable</li>
 * </ul>
 *
 * @see #asyncExec
 */
public void syncExec (Runnable runnable) {
    RunnableLock lock = null;
    synchronized (Device.classinfo) {
        if (display is null || display.isDisposed ()) DWT.error (DWT.ERROR_DEVICE_DISPOSED);
        if (!display.isValidThread ()) {
            if (runnable is null) {
                display.wake ();
                return;
            }
            lock = new RunnableLock (runnable);
            /*
             * Only remember the syncThread for syncExec.
             */
            lock.thread = Thread.getThis();
            addLast (lock);
        }
    }
    if (lock is null) {
        if (runnable !is null) runnable.run ();
        return;
    }
    synchronized (lock) {
        bool interrupted = false;
        while (!lock.done ()) {
            try {
                lock.wait ();
            } catch (SyncException e) {
                interrupted = true;
            }
        }
        if (interrupted) {
            Compatibility.interrupt();
        }
        if (lock.throwable !is null) {
            DWT.error (DWT.ERROR_FAILED_EXEC, lock.throwable);
        }
    }
}

}
