﻿/**
 * D header file for OSX.
 *
 * Copyright: Copyright Sean Kelly 2008 - 2009.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Sean Kelly
 *
 *          Copyright Sean Kelly 2008 - 2009.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE_1_0.txt or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module rt.core.os.osx.mach.semaphore;

public import rt.core.os.osx.mach.kern_return;
public import rt.core.os.osx.mach.port;

extern  (C):

alias mach_port_t   task_t;
alias mach_port_t   thread_t;
alias mach_port_t   semaphore_t;
alias int           sync_policy_t;

alias int clock_res_t;
struct mach_timespec_t
{
	uint	    tv_sec;
	clock_res_t	tv_nsec;
}

enum
{
    SYNC_POLICY_FIFO            = 0x0,
    SYNC_POLICY_FIXED_PRIORITY  = 0x1,
    SYNC_POLICY_REVERSED        = 0x2,
    SYNC_POLICY_ORDER_MASK      = 0x3,
    SYNC_POLICY_LIFO            = (SYNC_POLICY_FIFO | SYNC_POLICY_REVERSED),
    SYNC_POLICY_MAX			    = 0x7,
}

task_t        mach_task_self();
kern_return_t semaphore_create(task_t, semaphore_t*, int, int);
kern_return_t semaphore_destroy(task_t, semaphore_t);
    
kern_return_t semaphore_signal(semaphore_t);
kern_return_t semaphore_signal_all(semaphore_t);
kern_return_t semaphore_signal_thread(semaphore_t, thread_t);

kern_return_t semaphore_wait(semaphore_t);
kern_return_t semaphore_wait_signal(semaphore_t, semaphore_t);

kern_return_t semaphore_timedwait(semaphore_t, mach_timespec_t);
kern_return_t semaphore_timedwait_signal(semaphore_t, semaphore_t, mach_timespec_t);
