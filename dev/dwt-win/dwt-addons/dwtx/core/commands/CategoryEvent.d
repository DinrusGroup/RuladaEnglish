/*******************************************************************************
 * Copyright (c) 2004, 2006 IBM Corporation and others.
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
module dwtx.core.commands.CategoryEvent;

import dwtx.core.commands.common.AbstractNamedHandleEvent;
import dwtx.core.commands.Category;

import dwt.dwthelper.utils;

/**
 * An instance of this class describes changes to an instance of
 * <code>Category</code>.
 * <p>
 * This class is not intended to be extended by clients.
 * </p>
 *
 * @since 3.1
 * @see ICategoryListener#categoryChanged(CategoryEvent)
 */
public final class CategoryEvent : AbstractNamedHandleEvent {

    /**
     * The category that has changed; this value is never <code>null</code>.
     */
    private final Category category;

    /**
     * Creates a new instance of this class.
     *
     * @param category
     *            the instance of the interface that changed.
     * @param definedChanged
     *            true, iff the defined property changed.
     * @param descriptionChanged
     *            true, iff the description property changed.
     * @param nameChanged
     *            true, iff the name property changed.
     */
    public this(Category category, bool definedChanged,
            bool descriptionChanged, bool nameChanged) {
        super(definedChanged, descriptionChanged, nameChanged);

        if (category is null) {
            throw new NullPointerException();
        }
        this.category = category;
    }

    /**
     * Returns the instance of the interface that changed.
     *
     * @return the instance of the interface that changed. Guaranteed not to be
     *         <code>null</code>.
     */
    public final Category getCategory() {
        return category;
    }
}
