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
module dwtx.core.internal.jobs.Deadlock;

import dwtx.dwtxhelper.JThread;

import dwt.dwthelper.utils;

import dwtx.core.runtime.jobs.ISchedulingRule;

/**
 * The deadlock class stores information about a deadlock that just occurred.
 * It contains an array of the threads that were involved in the deadlock
 * as well as the thread that was chosen to be suspended and an array of locks
 * held by that thread that are going to be suspended to resolve the deadlock.
 */
class Deadlock {
    //all the threads which are involved in the deadlock
    private JThread[] threads;
    //the thread whose locks will be suspended to resolve deadlock
    private JThread candidate;
    //the locks that will be suspended
    private ISchedulingRule[] locks;

    public this(JThread[] threads, ISchedulingRule[] locks, JThread candidate) {
        this.threads = threads;
        this.locks = locks;
        this.candidate = candidate;
    }

    public ISchedulingRule[] getLocks() {
        return locks;
    }

    public JThread getCandidate() {
        return candidate;
    }

    public JThread[] getThreads() {
        return threads;
    }
}
