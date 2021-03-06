/*******************************************************************************
 * Copyright (c) 2005 IBM Corporation and others.
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
module dwtx.core.internal.jobs.StringPool;

import dwt.dwthelper.utils;
import dwtx.dwtxhelper.Collection;

/**
 * A string pool is used for sharing strings in a way that eliminates duplicate
 * equal strings.  A string pool instance can be maintained over a long period
 * of time, or used as a temporary structure during a string sharing pass over
 * a data structure.
 * <p>
 * This class is not intended to be subclassed by clients.
 * </p>
 *
 * Note: This class is copied from dwtx.core.resources
 *
 * @since 3.1
 */
public final class StringPool {
    private int savings;
    private const HashMap map;

    public this(){
        map = new HashMap();
    }

    /**
     * Adds a <code>String</code> to the pool.  Returns a <code>String</code>
     * that is equal to the argument but that is unique within this pool.
     * @param string The string to add to the pool
     * @return A string that is equal to the argument.
     */
    public String add(String string) {
        if (string is null)
            return string;
        Object result = map.get(string);
        if (result !is null) {
            if (stringcast(result) !is string)
                savings += 44 + 2 * string.length;
            return stringcast( result );
        }
        map.put(string, string);
        return string;
    }

    /**
     * Returns an estimate of the size in bytes that was saved by sharing strings in
     * the pool.  In particular, this returns the size of all strings that were added to the
     * pool after an equal string had already been added.  This value can be used
     * to estimate the effectiveness of a string sharing operation, in order to
     * determine if or when it should be performed again.
     *
     * In some cases this does not precisely represent the number of bytes that
     * were saved.  For example, say the pool already contains string S1.  Now
     * string S2, which is equal to S1 but not identical, is added to the pool five
     * times. This method will return the size of string S2 multiplied by the
     * number of times it was added, even though the actual savings in this case
     * is only the size of a single copy of S2.
     */
    public int getSavedStringCount() {
        return savings;
    }
}
