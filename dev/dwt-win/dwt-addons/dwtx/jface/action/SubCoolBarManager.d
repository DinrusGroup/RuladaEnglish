/*******************************************************************************
 * Copyright (c) 2003, 2006 IBM Corporation and others.
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
module dwtx.jface.action.SubCoolBarManager;

import dwtx.jface.action.ICoolBarManager;
import dwtx.jface.action.SubContributionManager;
import dwtx.jface.action.IToolBarManager;
import dwtx.jface.action.IMenuManager;
import dwtx.jface.action.ToolBarContributionItem;

import dwtx.core.runtime.Assert;

import dwt.dwthelper.utils;

/**
 * A <code>SubCoolBarManager</code> monitors the additional and removal of
 * items from a parent manager so that visibility of the entire set can be changed as a
 * unit.
 *
 * @since 3.0
 */
public class SubCoolBarManager : SubContributionManager,
        ICoolBarManager {
    alias SubContributionManager.add add;

    /**
     * Constructs a new manager.
     *
     * @param mgr the parent manager.  All contributions made to the
     *      <code>SubCoolBarManager</code> are forwarded and appear in the
     *      parent manager.
     */
    public this(ICoolBarManager mgr) {
        super(mgr);
        Assert.isNotNull(cast(Object)mgr);
    }

    /* (non-Javadoc)
     * @see dwtx.jface.action.ICoolBarManager#add(dwtx.jface.action.IToolBarManager)
     */
    public void add(IToolBarManager toolBarManager) {
        Assert.isNotNull(cast(Object)toolBarManager);
        super.add(new ToolBarContributionItem(toolBarManager));
    }

    /* (non-Javadoc)
     * @see dwtx.jface.action.ICoolBarManager#getStyle()
     */
    public int getStyle() {
        // It is okay to cast down since we only accept coolBarManager objects in the
        // constructor
        return (cast(ICoolBarManager) getParent()).getStyle();
    }

    /**
     * Returns the parent cool bar manager that this sub-manager contributes to.
     *
     * @return the parent cool bar manager
     */
    protected final ICoolBarManager getParentCoolBarManager() {
        // Cast is ok because that's the only
        // thing we accept in the construtor.
        return cast(ICoolBarManager) getParent();
    }

    /* (non-Javadoc)
     * @see dwtx.jface.action.ICoolBarManager#isLayoutLocked()
     */
    public bool getLockLayout() {
        return getParentCoolBarManager().getLockLayout();
    }

    /* (non-Javadoc)
     * @see dwtx.jface.action.ICoolBarManager#lockLayout(bool)
     */
    public void setLockLayout(bool value) {
    }

    /* (non-Javadoc)
     * SubCoolBarManagers do not have control of the global context menu.
     */
    public IMenuManager getContextMenuManager() {
        return null;
    }

    /* (non-Javadoc)
     * In SubCoolBarManager we do nothing.
     */
    public void setContextMenuManager(IMenuManager menuManager) {
        // do nothing
    }

    /* (non-Javadoc)
     * @see dwtx.jface.action.IContributionManager#update(bool)
     */
    public void update(bool force) {
        // This method is not governed by visibility.  The client may
        // call <code>setVisible</code> and then force an update.  At that
        // point we need to update the parent.
        getParentCoolBarManager().update(force);
    }

}
