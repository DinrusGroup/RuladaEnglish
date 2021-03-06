/*******************************************************************************
 * Copyright (c) 2006 IBM Corporation and others.
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
module dwtx.jface.viewers.IDecorationContext;

import dwt.dwthelper.utils;


/**
 * A decoration context provides additional information to
 * a label decorator.
 * <p>
 * This interface is not intended to be implemented by clients
 *
 * @see LabelDecorator
 *
 * @since 3.2
 */
public interface IDecorationContext {

    /**
     * Get the value of the given property or <code>null</code>
     * if the property does not exist in this context.
     * @param property the property
     * @return the value of the given property or <code>null</code>
     */
    Object getProperty(String property);

    /**
     * Return the properties that exist in this context
     * (i.e. the set of properties that have values associated
     * with them.
     * @return the properties that exist in this context
     */
    String[] getProperties();

}
