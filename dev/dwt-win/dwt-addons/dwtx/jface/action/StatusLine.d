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

module dwtx.jface.action.StatusLine;

import dwtx.jface.action.StatusLineLayoutData;

import dwt.DWT;
import dwt.custom.CLabel;
import dwt.events.DisposeEvent;
import dwt.events.DisposeListener;
import dwt.events.SelectionAdapter;
import dwt.events.SelectionEvent;
import dwt.graphics.Cursor;
import dwt.graphics.Font;
import dwt.graphics.Image;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.layout.GridData;
import dwt.layout.GridLayout;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Display;
import dwt.widgets.Layout;
import dwt.widgets.ToolBar;
import dwt.widgets.ToolItem;
import dwtx.core.runtime.IProgressMonitor;
import dwtx.jface.dialogs.ProgressIndicator;
import dwtx.jface.resource.ImageDescriptor;
import dwtx.jface.resource.JFaceColors;
import dwtx.jface.resource.JFaceResources;
import dwtx.jface.util.Util;

import dwt.dwthelper.utils;
import dwt.dwthelper.Runnable;

/**
 * A StatusLine control is a DWT Composite with a horizontal layout which hosts
 * a number of status indication controls. Typically it is situated below the
 * content area of the window.
 * <p>
 * By default a StatusLine has two predefined status controls: a MessageLine and
 * a ProgressIndicator and it provides API for easy access.
 * </p>
 * <p>
 * This is an internal class, not intended to be used outside the JFace
 * framework.
 * </p>
 */
/* package */class StatusLine : Composite, IProgressMonitor {

    /** Horizontal gaps between items. */
    public static const int GAP = 3;

    /** Progress bar creation is delayed by this ms */
    public static const int DELAY_PROGRESS = 500;

    /** visibility state of the progressbar */
    protected bool fProgressIsVisible = false;

    /** visibility state of the cancle button */
    protected bool fCancelButtonIsVisible = false;

    /** enablement state of the cancle button */
    protected bool fCancelEnabled = false;

    /** name of the task */
    protected String fTaskName;

    /** is the task is cancled */
    protected bool fIsCanceled;

    /** the start time of the task */
    protected long fStartTime;

    private Cursor fStopButtonCursor;

    /** the message text */
    protected String fMessageText;

    /** the message image */
    protected Image fMessageImage;

    /** the error text */
    protected String fErrorText;

    /** the error image */
    protected Image fErrorImage;

    /** the message label */
    protected CLabel fMessageLabel;

    /** the composite parent of the progress bar */
    protected Composite fProgressBarComposite;

    /** the progress bar */
    protected ProgressIndicator fProgressBar;

    /** the toolbar */
    protected ToolBar fToolBar;

    /** the cancle button */
    protected ToolItem fCancelButton;

    /** stop image descriptor */
    protected static ImageDescriptor fgStopImage;

    static this() {
        fgStopImage = ImageDescriptor.createFromFile(
            getImportData!("dwtx.jface.action.images.stop.gif"));//$NON-NLS-1$
            //getImportData!("file.png"));//$NON-NLS-1$
    //DWT Note: Not used in jface, but needs Display instance, which is not yet available.
    //    JFaceResources.getImageRegistry().put(
    //    "dwtx.jface.parts.StatusLine.stopImage", fgStopImage);//$NON-NLS-1$
    }

    /**
     * Layout the contribution item controls on the status line.
     */
    public class StatusLineLayout : Layout {
        private const StatusLineLayoutData DEFAULT_DATA;

        this(){
            DEFAULT_DATA = new StatusLineLayoutData();
        }

        public override Point computeSize(Composite composite, int wHint, int hHint,
                bool changed) {

            if (wHint !is DWT.DEFAULT && hHint !is DWT.DEFAULT) {
                return new Point(wHint, hHint);
            }

            Control[] children = composite.getChildren();
            int totalWidth = 0;
            int maxHeight = 0;
            int totalCnt = 0;
            for (int i = 0; i < children.length; i++) {
                bool useWidth = true;
                Control w = children[i];
                if (w is fProgressBarComposite && !fProgressIsVisible) {
                    useWidth = false;
                } else if (w is fToolBar && !fCancelButtonIsVisible) {
                    useWidth = false;
                }
                StatusLineLayoutData data = cast(StatusLineLayoutData) w
                        .getLayoutData();
                if (data is null) {
                    data = DEFAULT_DATA;
                }
                Point e = w.computeSize(data.widthHint, data.heightHint,
                        changed);
                if (useWidth) {
                    totalWidth += e.x;
                    totalCnt++;
                }
                maxHeight = Math.max(maxHeight, e.y);
            }
            if (totalCnt > 0) {
                totalWidth += (totalCnt - 1) * GAP;
            }
            if (totalWidth <= 0) {
                totalWidth = maxHeight * 4;
            }
            return new Point(totalWidth, maxHeight);
        }

        public override void layout(Composite composite, bool flushCache) {

            if (composite is null) {
                return;
            }

            // StatusLineManager skips over the standard status line widgets
            // in its update method. There is thus a dependency
            // between the layout of the standard widgets and the update method.

            // Make sure cancel button and progress bar are before
            // contributions.
            fMessageLabel.moveAbove(null);
            fToolBar.moveBelow(fMessageLabel);
            fProgressBarComposite.moveBelow(fToolBar);

            Rectangle rect = composite.getClientArea();
            Control[] children = composite.getChildren();
            int count = children.length;

            int ws[] = new int[count];

            int h = rect.height;
            int totalWidth = -GAP;
            for (int i = 0; i < count; i++) {
                Control w = children[i];
                if (w is fProgressBarComposite && !fProgressIsVisible) {
                    continue;
                }
                if (w is fToolBar && !fCancelButtonIsVisible) {
                    continue;
                }
                StatusLineLayoutData data = cast(StatusLineLayoutData) w
                        .getLayoutData();
                if (data is null) {
                    data = DEFAULT_DATA;
                }
                int width = w.computeSize(data.widthHint, h, flushCache).x;
                ws[i] = width;
                totalWidth += width + GAP;
            }

            int diff = rect.width - totalWidth;
            ws[0] += diff; // make the first StatusLabel wider

            // Check against minimum recommended width
            final int msgMinWidth = rect.width / 3;
            if (ws[0] < msgMinWidth) {
                diff = ws[0] - msgMinWidth;
                ws[0] = msgMinWidth;
            } else {
                diff = 0;
            }

            // Take space away from the contributions first.
            for (int i = count - 1; i >= 0 && diff < 0; --i) {
                int min = Math.min(ws[i], -diff);
                ws[i] -= min;
                diff += min + GAP;
            }

            int x = rect.x;
            int y = rect.y;
            for (int i = 0; i < count; i++) {
                Control w = children[i];
                /*
                 * Workaround for Linux Motif: Even if the progress bar and
                 * cancel button are not set to be visible ad of width 0, they
                 * still draw over the first pixel of the editor contributions.
                 *
                 * The fix here is to draw the progress bar and cancel button
                 * off screen if they are not visible.
                 */
                if (w is fProgressBarComposite && !fProgressIsVisible
                        || w is fToolBar && !fCancelButtonIsVisible) {
                    w.setBounds(x + rect.width, y, ws[i], h);
                    continue;
                }
                w.setBounds(x, y, ws[i], h);
                if (ws[i] > 0) {
                    x += ws[i] + GAP;
                }
            }
        }
    }

    /**
     * Create a new StatusLine as a child of the given parent.
     *
     * @param parent
     *            the parent for this Composite
     * @param style
     *            the style used to create this widget
     */
    public this(Composite parent, int style) {
        super(parent, style);

        addDisposeListener(new class DisposeListener {
            public void widgetDisposed(DisposeEvent e) {
                handleDispose();
            }
        });

        // StatusLineManager skips over the standard status line widgets
        // in its update method. There is thus a dependency
        // between this code defining the creation and layout of the standard
        // widgets and the update method.

        setLayout(new StatusLineLayout());

        fMessageLabel = new CLabel(this, DWT.NONE);// DWT.SHADOW_IN);
        // Color[] colors = new Color[2];
        // colors[0] =
        // parent.getDisplay().getSystemColor(DWT.COLOR_WIDGET_LIGHT_SHADOW);
        // colors[1] = fMessageLabel.getBackground();
        // int[] gradient = new int[] {JFaceColors.STATUS_PERCENT};
        // fMessageLabel.setBackground(colors, gradient);

        fProgressIsVisible = false;
        fCancelEnabled = false;

        fToolBar = new ToolBar(this, DWT.FLAT);
        fCancelButton = new ToolItem(fToolBar, DWT.PUSH);
        fCancelButton.setImage(fgStopImage.createImage());
        fCancelButton.setToolTipText(JFaceResources
                .getString("Cancel_Current_Operation")); //$NON-NLS-1$
        fCancelButton.addSelectionListener(new class SelectionAdapter {
            public void widgetSelected(SelectionEvent e) {
                setCanceled(true);
            }
        });
        fCancelButton.addDisposeListener(new class DisposeListener {
            public void widgetDisposed(DisposeEvent e) {
                Image i = fCancelButton.getImage();
                if ((i !is null) && (!i.isDisposed())) {
                    i.dispose();
                }
            }
        });

        // We create a composite to create the progress bar in
        // so that it can be centered. See bug #32331
        fProgressBarComposite = new Composite(this, DWT.NONE);
        GridLayout layout = new GridLayout();
        layout.horizontalSpacing = 0;
        layout.verticalSpacing = 0;
        layout.marginHeight = 0;
        layout.marginWidth = 0;
        fProgressBarComposite.setLayout(layout);
        fProgressBar = new ProgressIndicator(fProgressBarComposite);
        fProgressBar.setLayoutData(new GridData(GridData.GRAB_HORIZONTAL
                | GridData.GRAB_VERTICAL));

        fStopButtonCursor = new Cursor(getDisplay(), DWT.CURSOR_ARROW);
    }

    /**
     * Notifies that the main task is beginning.
     *
     * @param name
     *            the name (or description) of the main task
     * @param totalWork
     *            the total number of work units into which the main task is
     *            been subdivided. If the value is 0 or UNKNOWN the
     *            implemenation is free to indicate progress in a way which
     *            doesn't require the total number of work units in advance. In
     *            general users should use the UNKNOWN value if they don't know
     *            the total amount of work units.
     */
    public void beginTask(String name, int totalWork) {
        long timestamp = System.currentTimeMillis();
        fStartTime = timestamp;
        bool animated = (totalWork is UNKNOWN || totalWork is 0);
        // make sure the progress bar is made visible while
        // the task is running. Fixes bug 32198 for the non-animated case.
        Runnable timer = new class(animated,timestamp) Runnable {
            bool animated_;
            long timestamp_;
            this(bool a,long b){
                animated_=a;
                timestamp_=b;
            }
            public void run() {
                this.outer.startTask(timestamp_, animated_);
            }
        };
        if (fProgressBar is null) {
            return;
        }

        fProgressBar.getDisplay().timerExec(DELAY_PROGRESS, timer);
        if (!animated) {
            fProgressBar.beginTask(totalWork);
        }
        if (name is null) {
            fTaskName = Util.ZERO_LENGTH_STRING;
        } else {
            fTaskName = name;
        }
        setMessage(fTaskName);
    }

    /**
     * Notifies that the work is done; that is, either the main task is
     * completed or the user cancelled it. Done() can be called more than once;
     * an implementation should be prepared to handle this case.
     */
    public void done() {

        fStartTime = 0;

        if (fProgressBar !is null) {
            fProgressBar.sendRemainingWork();
            fProgressBar.done();
        }
        setMessage(null);

        hideProgress();
    }

    /**
     * Returns the status line's progress monitor
     * 
     * @return {@link IProgressMonitor} the progress monitor
     */
    public IProgressMonitor getProgressMonitor() {
        return this;
    }

    /**
     * @private
     */
    protected void handleDispose() {
        if (fStopButtonCursor !is null) {
            fStopButtonCursor.dispose();
            fStopButtonCursor = null;
        }
        if (fProgressBar !is null) {
            fProgressBar.dispose();
            fProgressBar = null;
        }
    }

    /**
     * Hides the Cancel button and ProgressIndicator.
     * 
     */
    protected void hideProgress() {

        if (fProgressIsVisible && !isDisposed()) {
            fProgressIsVisible = false;
            fCancelEnabled = false;
            fCancelButtonIsVisible = false;
            if (fToolBar !is null && !fToolBar.isDisposed()) {
                fToolBar.setVisible(false);
            }
            if (fProgressBarComposite !is null
                    && !fProgressBarComposite.isDisposed()) {
                fProgressBarComposite.setVisible(false);
            }
            layout();
        }
    }

    /**
     * @see IProgressMonitor#internalWorked(double)
     */
    public void internalWorked(double work) {
        if (!fProgressIsVisible) {
            if (System.currentTimeMillis() - fStartTime > DELAY_PROGRESS) {
                showProgress();
            }
        }

        if (fProgressBar !is null) {
            fProgressBar.worked(work);
        }
    }

    /**
     * Returns true if the user does some UI action to cancel this operation.
     * (like hitting the Cancel button on the progress dialog). The long running
     * operation typically polls isCanceled().
     */
    public bool isCanceled() {
        return fIsCanceled;
    }

    /**
     * Returns
     * <code>true</true> if the ProgressIndication provides UI for canceling
     * a long running operation.
     * @return <code>true</true> if the ProgressIndication provides UI for canceling
     */
    public bool isCancelEnabled() {
        return fCancelEnabled;
    }

    /**
     * Sets the cancel status. This method is usually called with the argument
     * false if a client wants to abort a cancel action.
     */
    public void setCanceled(bool b) {
        fIsCanceled = b;
        if (fCancelButton !is null) {
            fCancelButton.setEnabled(!b);
        }
    }

    /**
     * Controls whether the ProgressIndication provides UI for canceling a long
     * running operation. If the ProgressIndication is currently visible calling
     * this method may have a direct effect on the layout because it will make a
     * cancel button visible.
     * 
     * @param enabled
     *            <code>true</true> if cancel should be enabled
     */
    public void setCancelEnabled(bool enabled) {
        fCancelEnabled = enabled;
        if (fProgressIsVisible && !fCancelButtonIsVisible && enabled) {
            showButton();
            layout();
        }
        if (fCancelButton !is null && !fCancelButton.isDisposed()) {
            fCancelButton.setEnabled(enabled);
        }
    }

    /**
     * Sets the error message text to be displayed on the status line. The image
     * on the status line is cleared.
     *
     * @param message
     *            the error message, or <code>null</code> for no error message
     */
    public void setErrorMessage(String message) {
        setErrorMessage(null, message);
    }

    /**
     * Sets an image and error message text to be displayed on the status line.
     *
     * @param image
     *            the image to use, or <code>null</code> for no image
     * @param message
     *            the error message, or <code>null</code> for no error message
     */
    public void setErrorMessage(Image image, String message) {
        fErrorText = trim(message);
        fErrorImage = image;
        updateMessageLabel();
    }

    /**
     * Applies the given font to this status line.
     */
    public override void setFont(Font font) {
        super.setFont(font);
        Control[] children = getChildren();
        for (int i = 0; i < children.length; i++) {
            children[i].setFont(font);
        }
    }

    /**
     * Sets the message text to be displayed on the status line. The image on
     * the status line is cleared.
     *
     * @param message
     *            the error message, or <code>null</code> for no error message
     */
    public void setMessage(String message) {
        setMessage(null, message);
    }

    /**
     * Sets an image and a message text to be displayed on the status line.
     *
     * @param image
     *            the image to use, or <code>null</code> for no image
     * @param message
     *            the message, or <code>null</code> for no message
     */
    public void setMessage(Image image, String message) {
        fMessageText = trim(message);
        fMessageImage = image;
        updateMessageLabel();
    }

    /**
     * @see IProgressMonitor#setTaskName(java.lang.String)
     */
    public void setTaskName(String name) {
        if (name is null)
            fTaskName = Util.ZERO_LENGTH_STRING;
        else
            fTaskName = name;
    }

    /**
     * Makes the Cancel button visible.
     * 
     */
    protected void showButton() {
        if (fToolBar !is null && !fToolBar.isDisposed()) {
            fToolBar.setVisible(true);
            fToolBar.setEnabled(true);
            fToolBar.setCursor(fStopButtonCursor);
            fCancelButtonIsVisible = true;
        }
    }

    /**
     * Shows the Cancel button and ProgressIndicator.
     * 
     */
    protected void showProgress() {
        if (!fProgressIsVisible && !isDisposed()) {
            fProgressIsVisible = true;
            if (fCancelEnabled) {
                showButton();
            }
            if (fProgressBarComposite !is null
                    && !fProgressBarComposite.isDisposed()) {
                fProgressBarComposite.setVisible(true);
            }
            layout();
        }
    }

    /**
     * @private
     */
    void startTask(long timestamp, bool animated) {
        if (!fProgressIsVisible && fStartTime is timestamp) {
            showProgress();
            if (animated) {
                if (fProgressBar !is null && !fProgressBar.isDisposed()) {
                    fProgressBar.beginAnimatedTask();
                }
            }
        }
    }

    /**
     * Notifies that a subtask of the main task is beginning. Subtasks are
     * optional; the main task might not have subtasks.
     * 
     * @param name
     *            the name (or description) of the subtask
     * @see IProgressMonitor#subTask(String)
     */
    public void subTask(String name) {

        String newName;
        if (name is null)
            newName = Util.ZERO_LENGTH_STRING;
        else
            newName = name;

        String text;
        if (fTaskName.length is 0) {
            text = newName;
        } else {
            text = JFaceResources.format(
                    "Set_SubTask", [ fTaskName, newName ]);//$NON-NLS-1$
        }
        setMessage(text);
    }

    /**
     * Trims the message to be displayable in the status line. This just pulls
     * out the first line of the message. Allows null.
     */
    String trim(String message) {
        if (message is null) {
            return null;
        }
        message = Util.replaceAll(message, "&", "&&"); //$NON-NLS-1$//$NON-NLS-2$
        int cr = message.indexOf('\r');
        int lf = message.indexOf('\n');
        if (cr is -1 && lf is -1) {
            return message;
        }
        int len;
        if (cr is -1) {
            len = lf;
        } else if (lf is -1) {
            len = cr;
        } else {
            len = Math.min(cr, lf);
        }
        return message.substring(0, len);
    }

    /**
     * Updates the message label widget.
     */
    protected void updateMessageLabel() {
        if (fMessageLabel !is null && !fMessageLabel.isDisposed()) {
            Display display = fMessageLabel.getDisplay();
            if ((fErrorText !is null && fErrorText.length > 0)
                    || fErrorImage !is null) {
                fMessageLabel.setForeground(JFaceColors.getErrorText(display));
                fMessageLabel.setText(fErrorText);
                fMessageLabel.setImage(fErrorImage);
            } else {
                fMessageLabel.setForeground(display
                        .getSystemColor(DWT.COLOR_WIDGET_FOREGROUND));
                fMessageLabel.setText(fMessageText is null ? "" : fMessageText); //$NON-NLS-1$
                fMessageLabel.setImage(fMessageImage);
            }
        }
    }

    /**
     * @see IProgressMonitor#worked(int)
     */
    public void worked(int work) {
        internalWorked(work);
    }
}
