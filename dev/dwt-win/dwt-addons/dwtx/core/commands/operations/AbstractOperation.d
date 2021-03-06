/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
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
module dwtx.core.commands.operations.AbstractOperation;

import dwtx.core.commands.ExecutionException;
import dwtx.core.runtime.Assert;
import dwtx.core.runtime.IAdaptable;
import dwtx.core.runtime.IProgressMonitor;
import dwtx.core.runtime.IStatus;

import dwtx.core.commands.operations.IUndoableOperation;
import dwtx.core.commands.operations.IUndoContext;

import dwt.dwthelper.utils;
import dwtx.dwtxhelper.Collection;
static import tango.text.Text;
alias tango.text.Text.Text!(char) StringBuffer;

/**
 * <p>
 * Abstract implementation for an undoable operation. At a minimum, subclasses
 * should implement behavior for
 * {@link IUndoableOperation#execute(dwtx.core.runtime.IProgressMonitor, dwtx.core.runtime.IAdaptable)},
 * {@link IUndoableOperation#redo(dwtx.core.runtime.IProgressMonitor, dwtx.core.runtime.IAdaptable)},
 * and
 * {@link IUndoableOperation#undo(dwtx.core.runtime.IProgressMonitor, dwtx.core.runtime.IAdaptable)}.
 * </p>
 *
 * @see dwtx.core.commands.operations.IUndoableOperation
 *
 * @since 3.1
 */
public abstract class AbstractOperation : IUndoableOperation {
    List contexts;

    private String label = ""; //$NON-NLS-1$

    /**
     * Construct an operation that has the specified label.
     *
     * @param label
     *            the label to be used for the operation. Should never be
     *            <code>null</code>.
     */
    public this(String label) {
        Assert.isNotNull(label);
        this.label = label;
        contexts = new ArrayList();
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#addContext(dwtx.core.commands.operations.IUndoContext)
     *
     * <p> Subclasses may override this method. </p>
     */
    public void addContext(IUndoContext context) {
        if (!contexts.contains(cast(Object)context)) {
            contexts.add(cast(Object)context);
        }
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#canExecute()
     *      <p> Default implementation. Subclasses may override this method.
     *      </p>
     *
     */
    public bool canExecute() {
        return true;
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#canRedo()
     *      <p> Default implementation. Subclasses may override this method.
     *      </p>
     */
    public bool canRedo() {
        return true;
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#canUndo()
     *      <p> Default implementation. Subclasses may override this method.
     *      </p>
     */
    public bool canUndo() {
        return true;
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#dispose()
     *      <p> Default implementation. Subclasses may override this method.
     *      </p>
     */
    public void dispose() {
        // nothing to dispose.
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#execute(dwtx.core.runtime.IProgressMonitor,
     *      dwtx.core.runtime.IAdaptable)
     */
    public abstract IStatus execute(IProgressMonitor monitor, IAdaptable info);

    public final IUndoContext[] getContexts() {
        return arraycast!(IUndoContext)(contexts.toArray());
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#getLabel()
     *      <p> Default implementation. Subclasses may override this method.
     *      </p>
     */
    public String getLabel() {
        return label;
    }

    /**
     * Set the label of the operation to the specified name.
     *
     * @param name
     *            the string to be used for the label. Should never be
     *            <code>null</code>.
     */
    public void setLabel(String name) {
        label = name;
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#hasContext(dwtx.core.commands.operations.IUndoContext)
     */
    public final bool hasContext(IUndoContext context) {
        Assert.isNotNull(cast(Object)context);
        for (int i = 0; i < contexts.size(); i++) {
            IUndoContext otherContext = cast(IUndoContext)contexts.get(i);
            // have to check both ways because one context may be more general
            // in
            // its matching rules than another.
            if (context.matches(otherContext) || otherContext.matches(context)) {
                return true;
            }
        }
        return false;
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#redo(dwtx.core.runtime.IProgressMonitor,
     *      dwtx.core.runtime.IAdaptable)
     */
    public abstract IStatus redo(IProgressMonitor monitor, IAdaptable info);

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#removeContext(dwtx.core.commands.operations.IUndoContext)
     *      <p> Default implementation. Subclasses may override this method.
     *      </p>
     */

    public void removeContext(IUndoContext context) {
        contexts.remove(cast(Object)context);
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.core.commands.operations.IUndoableOperation#undo(dwtx.core.runtime.IProgressMonitor,
     *      dwtx.core.runtime.IAdaptable)
     */
    public abstract IStatus undo(IProgressMonitor monitor, IAdaptable info);

    /**
     * The string representation of this operation. Used for debugging purposes
     * only. This string should not be shown to an end user.
     *
     * @return The string representation.
     */
    public override String toString() {
        StringBuffer stringBuffer = new StringBuffer();
        stringBuffer.append(getLabel());
        stringBuffer.append("("); //$NON-NLS-1$
        IUndoContext[] contexts = getContexts();
        for (int i = 0; i < contexts.length; i++) {
            stringBuffer.append((cast(Object)contexts[i]).toString());
            if (i !is contexts.length - 1) {
                stringBuffer.append(',');
            }
        }
        stringBuffer.append(')');
        return stringBuffer.toString();
    }
}
