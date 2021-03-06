/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Stefan Xenos, IBM - bug 156790: Adopt GridLayoutFactory within JFace
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module dwtx.jface.dialogs.PopupDialog;

import dwtx.jface.dialogs.IDialogConstants;
import dwtx.jface.dialogs.IDialogSettings;
import dwtx.jface.dialogs.Dialog;


import dwt.DWT;
import dwt.events.DisposeEvent;
import dwt.events.DisposeListener;
import dwt.events.MouseAdapter;
import dwt.events.MouseEvent;
import dwt.events.SelectionAdapter;
import dwt.events.SelectionEvent;
import dwt.graphics.Color;
import dwt.graphics.Font;
import dwt.graphics.FontData;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.widgets.Composite;
import dwt.widgets.Control;
import dwt.widgets.Event;
import dwt.widgets.Label;
import dwt.widgets.Listener;
import dwt.widgets.Menu;
import dwt.widgets.Shell;
import dwt.widgets.ToolBar;
import dwt.widgets.ToolItem;
import dwt.widgets.Tracker;
import dwtx.jface.action.Action;
import dwtx.jface.action.GroupMarker;
import dwtx.jface.action.IAction;
import dwtx.jface.action.IMenuManager;
import dwtx.jface.action.MenuManager;
import dwtx.jface.action.Separator;
import dwtx.jface.layout.GridDataFactory;
import dwtx.jface.layout.GridLayoutFactory;
import dwtx.jface.resource.JFaceResources;
import dwtx.jface.window.Window;

import dwt.dwthelper.utils;
import dwtx.dwtxhelper.Collection;
import dwt.dwthelper.Runnable;

/**
 * A lightweight, transient dialog that is popped up to show contextual or
 * temporal information and is easily dismissed. Clients control whether the
 * dialog should be able to receive input focus. An optional title area at the
 * top and an optional info area at the bottom can be used to provide additional
 * information.
 * <p>
 * Because the dialog is short-lived, most of the configuration of the dialog is
 * done in the constructor. Set methods are only provided for those values that
 * are expected to be dynamically computed based on a particular instance's
 * internal state.
 * <p>
 * Clients are expected to override the creation of the main dialog area, and
 * may optionally override the creation of the title area and info area in order
 * to add content. In general, however, the creation of stylistic features, such
 * as the dialog menu, separator styles, and fonts, is kept private so that all
 * popup dialogs will have a similar appearance.
 *
 * @since 3.2
 */
public class PopupDialog : Window {

    /**
     *
     */
    private static GridDataFactory LAYOUTDATA_GRAB_BOTH_;
    private static GridDataFactory LAYOUTDATA_GRAB_BOTH(){
        if( LAYOUTDATA_GRAB_BOTH_ is null ){
            synchronized( PopupDialog.classinfo ){
                if( LAYOUTDATA_GRAB_BOTH_ is null ){
                    LAYOUTDATA_GRAB_BOTH_ = GridDataFactory.fillDefaults().grab(true,true);
                }
            }
        }
        return LAYOUTDATA_GRAB_BOTH_;
    }

    /**
     * The dialog settings key name for stored dialog x location.
     */
    private static const String DIALOG_ORIGIN_X = "DIALOG_X_ORIGIN"; //$NON-NLS-1$

    /**
     * The dialog settings key name for stored dialog y location.
     */
    private static const String DIALOG_ORIGIN_Y = "DIALOG_Y_ORIGIN"; //$NON-NLS-1$

    /**
     * The dialog settings key name for stored dialog width.
     */
    private static const String DIALOG_WIDTH = "DIALOG_WIDTH"; //$NON-NLS-1$

    /**
     * The dialog settings key name for stored dialog height.
     */
    private static const String DIALOG_HEIGHT = "DIALOG_HEIGHT"; //$NON-NLS-1$

    /**
     * The dialog settings key name for remembering if the persisted bounds
     * should be accessed.
     *
     * @deprecated Since 3.4, this is retained only for backward compatibility.
     */
    private static final String DIALOG_USE_PERSISTED_BOUNDS = "DIALOG_USE_PERSISTED_BOUNDS"; //$NON-NLS-1$

    /**
     * The dialog settings key name for remembering if the bounds persisted
     * prior to 3.4 have been migrated to the 3.4 settings.
     *
     * @since 3.4
     * @deprecated This is marked deprecated at its introduction to discourage
     *             future dependency
     */
    private static final String DIALOG_VALUE_MIGRATED_TO_34 = "hasBeenMigratedTo34"; //$NON-NLS-1$

    /**
     * The dialog settings key name for remembering if the persisted size should
     * be accessed.
     */
    private static final String DIALOG_USE_PERSISTED_SIZE = "DIALOG_USE_PERSISTED_SIZE"; //$NON-NLS-1$

    /**
     * The dialog settings key name for remembering if the persisted location
     * should be accessed.
     */
    private static final String DIALOG_USE_PERSISTED_LOCATION = "DIALOG_USE_PERSISTED_LOCATION"; //$NON-NLS-1$

    /**
     * Move action for the dialog.
     */
    private class MoveAction : Action {

        this() {
            super(JFaceResources.getString("PopupDialog.move"), //$NON-NLS-1$
                    IAction.AS_PUSH_BUTTON);
        }

        /*
         * (non-Javadoc)
         *
         * @see dwtx.jface.action.IAction#run()
         */
        public override void run() {
            performTrackerAction(DWT.NONE);
        }

    }

    /**
     * Resize action for the dialog.
     */
    private class ResizeAction : Action {

        this() {
            super(JFaceResources.getString("PopupDialog.resize"), //$NON-NLS-1$
                    IAction.AS_PUSH_BUTTON);
        }

        /*
         * @see dwtx.jface.action.Action#run()
         */
        public override void run() {
            performTrackerAction(DWT.RESIZE);
        }
    }

    /**
     *
     * Remember bounds action for the dialog.
     */
    private class PersistBoundsAction : Action {

        this() {
            super(JFaceResources.getString("PopupDialog.persistBounds"), //$NON-NLS-1$
                    IAction.AS_CHECK_BOX);
            setChecked(persistLocation && persistSize);
        }

        /*
         * (non-Javadoc)
         *
         * @see dwtx.jface.action.IAction#run()
         */
        public override void run() {
            persistSize = isChecked();
            persistLocation = persistSize;
        }
    }

    /**
     *
     * Remember bounds action for the dialog.
     */
    private class PersistSizeAction : Action {

        this() {
            super(JFaceResources.getString("PopupDialog.persistSize"), //$NON-NLS-1$
                    IAction.AS_CHECK_BOX);
            setChecked(persistSize);
        }

        /*
         * (non-Javadoc)
         *
         * @see dwtx.jface.action.IAction#run()
         */
        public void run() {
            persistSize = isChecked();
        }
    }

    /**
     *
     * Remember location action for the dialog.
     */
    private class PersistLocationAction : Action {

        this() {
            super(JFaceResources.getString("PopupDialog.persistLocation"), //$NON-NLS-1$
                    IAction.AS_CHECK_BOX);
            setChecked(persistLocation);
        }

        /*
         * (non-Javadoc)
         *
         * @see dwtx.jface.action.IAction#run()
         */
        public void run() {
            persistLocation = isChecked();
        }
    }

    /**
     * Shell style appropriate for a simple hover popup that cannot get focus.
     *
     */
    public const static int HOVER_SHELLSTYLE = DWT.NO_FOCUS | DWT.ON_TOP
            | DWT.TOOL;

    /**
     * Shell style appropriate for an info popup that can get focus.
     */
    public const static int INFOPOPUP_SHELLSTYLE = DWT.TOOL;

    /**
     * Shell style appropriate for a resizable info popup that can get focus.
     */
    public const static int INFOPOPUPRESIZE_SHELLSTYLE = DWT.RESIZE;

    /**
     * Margin width (in pixels) to be used in layouts inside popup dialogs
     * (value is 0).
     */
    public const static int POPUP_MARGINWIDTH = 0;

    /**
     * Margin height (in pixels) to be used in layouts inside popup dialogs
     * (value is 0).
     */
    public const static int POPUP_MARGINHEIGHT = 0;

    /**
     * Vertical spacing (in pixels) between cells in the layouts inside popup
     * dialogs (value is 1).
     */
    public const static int POPUP_VERTICALSPACING = 1;

    /**
     * Vertical spacing (in pixels) between cells in the layouts inside popup
     * dialogs (value is 1).
     */
    public const static int POPUP_HORIZONTALSPACING = 1;

    /**
     * Image registry key for menu image.
     *
     * @since 3.4
     */
    public static const String POPUP_IMG_MENU = "popup_menu_image"; //$NON-NLS-1$

    /**
     * Image registry key for disabled menu image.
     *
     * @since 3.4
     */
    public static const String POPUP_IMG_MENU_DISABLED = "popup_menu_image_diabled"; //$NON-NLS-1$

    /**
     *
     */
    private static GridLayoutFactory POPUP_LAYOUT_FACTORY_;
    private static GridLayoutFactory POPUP_LAYOUT_FACTORY() {
        if( POPUP_LAYOUT_FACTORY_ is null ){
            synchronized( PopupDialog.classinfo ){
                if( POPUP_LAYOUT_FACTORY_ is null ){
                    POPUP_LAYOUT_FACTORY_ = GridLayoutFactory
                        .fillDefaults().margins(POPUP_MARGINWIDTH, POPUP_MARGINHEIGHT)
                        .spacing(POPUP_HORIZONTALSPACING, POPUP_VERTICALSPACING);
                }
            }
        }
        return POPUP_LAYOUT_FACTORY_;
    }

    /**
     * The dialog's toolbar for the move and resize capabilities.
     */
    private ToolBar toolBar = null;

    /**
     * The dialog's menu manager.
     */
    private MenuManager menuManager = null;

    /**
     * The control representing the main dialog area.
     */
    private Control dialogArea;

    /**
     * Labels that contain title and info text. Cached so they can be updated
     * dynamically if possible.
     */
    private Label titleLabel, infoLabel;

    /**
     * Separator controls. Cached so they can be excluded from color changes.
     */
    private Control titleSeparator, infoSeparator;

    /**
     * Font to be used for the info area text. Computed based on the dialog's
     * font.
     */
    private Font infoFont;

    /**
     * Font to be used for the title area text. Computed based on the dialog's
     * font.
     */
    private Font titleFont;

    /**
     * Flags indicating whether we are listening for shell deactivate events,
     * either those or our parent's. Used to prevent closure when a menu command
     * is chosen or a secondary popup is launched.
     */
    private bool listenToDeactivate;

    private bool listenToParentDeactivate;

    private Listener parentDeactivateListener;

    /**
     * Flag indicating whether focus should be taken when the dialog is opened.
     */
    private bool takeFocusOnOpen = false;

    /**
     * Flag specifying whether a menu should be shown that allows the user to
     * move and resize.
     */
    private bool showDialogMenu_ = false;

    /**
     * Flag specifying whether menu actions allowing the user to choose whether
     * the dialog bounds and location should be persisted are to be shown.
     */
    private bool showPersistActions = false;

    /**
     * Flag specifying whether the size of the popup should be persisted. This
     * flag is used as initial default and updated by the menu if it is shown.
     */
    private bool persistSize = false;

    /**
     * Flag specifying whether the location of the popup should be persisted.
     * This flag is used as initial default and updated by the menu if it is
     * shown.
     */
    private bool persistLocation = false;
    /**
     * Flag specifying whether to use new 3.4 API instead of the old one.
     *
     * @since 3.4
     */
    private bool isUsing34API = true;

    /**
     * Text to be shown in an optional title area (on top).
     */
    private String titleText;

    /**
     * Text to be shown in an optional info area (at the bottom).
     */
    private String infoText;

    /**
     * Constructs a new instance of <code>PopupDialog</code>.
     *
     * @param parent
     *            The parent shell.
     * @param shellStyle
     *            The shell style.
     * @param takeFocusOnOpen
     *            A bool indicating whether focus should be taken by this
     *            popup when it opens.
     * @param persistBounds
     *            A bool indicating whether the bounds (size and location) of
     *            the dialog should be persisted upon close of the dialog. The
     *            bounds can only be persisted if the dialog settings for
     *            persisting the bounds are also specified. If a menu action
     *            will be provided that allows the user to control this feature,
     *            then the last known value of the user's setting will be used
     *            instead of this flag.
     * @param showDialogMenu
     *            A bool indicating whether a menu for moving and resizing
     *            the popup should be provided.
     * @param showPersistActions
     *            A bool indicating whether actions allowing the user to
     *            control the persisting of the dialog size and location should
     *            be shown in the dialog menu. This parameter has no effect if
     *            <code>showDialogMenu</code> is <code>false</code>.
     * @param titleText
     *            Text to be shown in an upper title area, or <code>null</code>
     *            if there is no title.
     * @param infoText
     *            Text to be shown in a lower info area, or <code>null</code>
     *            if there is no info area.
     *
     * @see PopupDialog#getDialogSettings()
     * @deprecated As of 3.4, replaced by
     *             {@link #PopupDialog(Shell, int, bool, bool, bool, bool, bool, String, String)}
     */
    public this(Shell parent, int shellStyle, bool takeFocusOnOpen,
            bool persistBounds, bool showDialogMenu,
            bool showPersistActions, String titleText, String infoText) {
        this(parent, shellStyle, takeFocusOnOpen, persistBounds, persistBounds,
                showDialogMenu, showPersistActions, titleText, infoText, false);
    }

    /**
     * Constructs a new instance of <code>PopupDialog</code>.
     *
     * @param parent
     *            The parent shell.
     * @param shellStyle
     *            The shell style.
     * @param takeFocusOnOpen
     *            A bool indicating whether focus should be taken by this
     *            popup when it opens.
     * @param persistSize
     *            A bool indicating whether the size should be persisted upon
     *            close of the dialog. The size can only be persisted if the
     *            dialog settings for persisting the bounds are also specified.
     *            If a menu action will be provided that allows the user to
     *            control this feature and the user hasn't changed that setting,
     *            then this flag is used as initial default for the menu.
     * @param persistLocation
     *            A bool indicating whether the location should be persisted
     *            upon close of the dialog. The location can only be persisted
     *            if the dialog settings for persisting the bounds are also
     *            specified. If a menu action will be provided that allows the
     *            user to control this feature and the user hasn't changed that
     *            setting, then this flag is used as initial default for the
     *            menu. default for the menu until the user changed it.
     * @param showDialogMenu
     *            A bool indicating whether a menu for moving and resizing
     *            the popup should be provided.
     * @param showPersistActions
     *            A bool indicating whether actions allowing the user to
     *            control the persisting of the dialog bounds and location
     *            should be shown in the dialog menu. This parameter has no
     *            effect if <code>showDialogMenu</code> is <code>false</code>.
     * @param titleText
     *            Text to be shown in an upper title area, or <code>null</code>
     *            if there is no title.
     * @param infoText
     *            Text to be shown in a lower info area, or <code>null</code>
     *            if there is no info area.
     *
     * @see PopupDialog#getDialogSettings()
     *
     * @since 3.4
     */
    public this(Shell parent, int shellStyle, bool takeFocusOnOpen,
            bool persistSize, bool persistLocation,
            bool showDialogMenu, bool showPersistActions,
            String titleText, String infoText) {
        this(parent, shellStyle, takeFocusOnOpen, persistSize, persistLocation,
                showDialogMenu, showPersistActions, titleText, infoText, true);

    }

    /**
     * Constructs a new instance of <code>PopupDialog</code>.
     *
     * @param parent
     *            The parent shell.
     * @param shellStyle
     *            The shell style.
     * @param takeFocusOnOpen
     *            A bool indicating whether focus should be taken by this
     *            popup when it opens.
     * @param persistSize
     *            A bool indicating whether the size should be persisted upon
     *            close of the dialog. The size can only be persisted if the
     *            dialog settings for persisting the bounds are also specified.
     *            If a menu action will be provided that allows the user to
     *            control this feature and the user hasn't changed that setting,
     *            then this flag is used as initial default for the menu.
     * @param persistLocation
     *            A bool indicating whether the location should be persisted
     *            upon close of the dialog. The location can only be persisted
     *            if the dialog settings for persisting the bounds are also
     *            specified. If a menu action will be provided that allows the
     *            user to control this feature and the user hasn't changed that
     *            setting, then this flag is used as initial default for the
     *            menu. default for the menu until the user changed it.
     * @param showDialogMenu
     *            A bool indicating whether a menu for moving and resizing
     *            the popup should be provided.
     * @param showPersistActions
     *            A bool indicating whether actions allowing the user to
     *            control the persisting of the dialog bounds and location
     *            should be shown in the dialog menu. This parameter has no
     *            effect if <code>showDialogMenu</code> is <code>false</code>.
     * @param titleText
     *            Text to be shown in an upper title area, or <code>null</code>
     *            if there is no title.
     * @param infoText
     *            Text to be shown in a lower info area, or <code>null</code>
     *            if there is no info area.
     * @param use34API
     *            <code>true</code> if 3.4 API should be used
     *
     * @see PopupDialog#getDialogSettings()
     *
     * @since 3.4
     */
    private this(Shell parent, int shellStyle, bool takeFocusOnOpen,
            bool persistSize, bool persistLocation,
            bool showDialogMenu, bool showPersistActions,
            String titleText, String infoText, bool use34API) {
        super(parent);
        // Prior to 3.4, we encouraged use of DWT.NO_TRIM and provided a
        // border using a black composite background and margin. Now we
        // use DWT.TOOL to get the border for some cases and this conflicts
        // with DWT.NO_TRIM. Clients who previously have used DWT.NO_TRIM
        // and still had a border drawn for them would find their border go
        // away unless we do the following:
        // see https://bugs.eclipse.org/bugs/show_bug.cgi?id=219743
        if ((shellStyle & DWT.NO_TRIM) !is 0) {
            shellStyle &= ~(DWT.NO_TRIM | DWT.SHELL_TRIM);
        }

        setShellStyle(shellStyle);
        this.takeFocusOnOpen = takeFocusOnOpen;
        this.showDialogMenu_ = showDialogMenu_;
        this.showPersistActions = showPersistActions;
        this.titleText = titleText;
        this.infoText = infoText;

        setBlockOnOpen(false);

        this.isUsing34API = use34API;

        this.persistSize = persistSize;
        this.persistLocation = persistLocation;

        migrateBoundsSetting();

        initializeWidgetState();
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.jface.window.Window#configureShell(Shell)
     */
    protected override void configureShell(Shell shell) {
        GridLayoutFactory.fillDefaults().margins(0, 0).spacing(5, 5).applyTo(
                shell);

        shell.addListener(DWT.Deactivate, new class Listener {
            public void handleEvent(Event event) {
                /*
                 * Close if we are deactivating and have no child shells. If we
                 * have child shells, we are deactivating due to their opening.
                 * On X, we receive this when a menu child (such as the system
                 * menu) of the shell opens, but I have not found a way to
                 * distinguish that case here. Hence bug #113577 still exists.
                 */
                if (listenToDeactivate && event.widget is getShell()
                        && getShell().getShells().length is 0) {
                    asyncClose();
                } else {
                    /*
                     * We typically ignore deactivates to work around
                     * platform-specific event ordering. Now that we've ignored
                     * whatever we were supposed to, start listening to
                     * deactivates. Example issues can be found in
                     * https://bugs.eclipse.org/bugs/show_bug.cgi?id=123392
                     */
                    listenToDeactivate = true;
                }
            }
        });
        // Set this true whenever we activate. It may have been turned
        // off by a menu or secondary popup showing.
        shell.addListener(DWT.Activate, new class Listener {
            public void handleEvent(Event event) {
                // ignore this event if we have launched a child
                if (event.widget is getShell()
                        && getShell().getShells().length is 0) {
                    listenToDeactivate = true;
                    // Typically we start listening for parent deactivate after
                    // we are activated, except on the Mac, where the deactivate
                    // is received after activate.
                    // See https://bugs.eclipse.org/bugs/show_bug.cgi?id=100668
                    listenToParentDeactivate = !"carbon".equals(DWT.getPlatform()); //$NON-NLS-1$
                }
            }
        });

        if ((getShellStyle() & DWT.ON_TOP) !is 0 && shell.getParent() !is null) {
            parentDeactivateListener = new class Listener {
                public void handleEvent(Event event) {
                    if (listenToParentDeactivate) {
                        asyncClose();
                    } else {
                        // Our first deactivate, now start listening on the Mac.
                        listenToParentDeactivate = listenToDeactivate;
                    }
                }
            };
            shell.getParent().addListener(DWT.Deactivate,
                    parentDeactivateListener);
        }

        shell.addDisposeListener(new class DisposeListener {
            public void widgetDisposed(DisposeEvent event) {
                handleDispose();
            }
        });
    }

    private void asyncClose() {
        // workaround for https://bugs.eclipse.org/bugs/show_bug.cgi?id=152010
        getShell().getDisplay().asyncExec(new class Runnable {
            public void run() {
                close();
            }
        });
    }

    /**
     * The <code>PopupDialog</code> implementation of this <code>Window</code>
     * method creates and lays out the top level composite for the dialog. It
     * then calls the <code>createTitleMenuArea</code>,
     * <code>createDialogArea</code>, and <code>createInfoTextArea</code>
     * methods to create an optional title and menu area on the top, a dialog
     * area in the center, and an optional info text area at the bottom.
     * Overriding <code>createDialogArea</code> and (optionally)
     * <code>createTitleMenuArea</code> and <code>createTitleMenuArea</code>
     * are recommended rather than overriding this method.
     *
     * @param parent
     *            the composite used to parent the contents.
     *
     * @return the control representing the contents.
     */
    protected override Control createContents(Composite parent) {
        Composite composite = new Composite(parent, DWT.NONE);
        POPUP_LAYOUT_FACTORY.applyTo(composite);
        LAYOUTDATA_GRAB_BOTH.applyTo(composite);

        // Title area
        if (hasTitleArea()) {
            createTitleMenuArea(composite);
            titleSeparator = createHorizontalSeparator(composite);
        }
        // Content
        dialogArea = createDialogArea(composite);
        // Create a grid data layout data if one was not provided.
        // See https://bugs.eclipse.org/bugs/show_bug.cgi?id=118025
        if (dialogArea.getLayoutData() is null) {
            LAYOUTDATA_GRAB_BOTH.applyTo(dialogArea);
        }

        // Info field
        if (hasInfoArea()) {
            infoSeparator = createHorizontalSeparator(composite);
            createInfoTextArea(composite);
        }

        applyColors(composite);
        applyFonts(composite);
        return composite;
    }

    /**
     * Creates and returns the contents of the dialog (the area below the title
     * area and above the info text area.
     * <p>
     * The <code>PopupDialog</code> implementation of this framework method
     * creates and returns a new <code>Composite</code> with standard margins
     * and spacing.
     * <p>
     * The returned control's layout data must be an instance of
     * <code>GridData</code>. This method must not modify the parent's
     * layout.
     * <p>
     * Subclasses must override this method but may call <code>super</code> as
     * in the following example:
     *
     * <pre>
     * Composite composite = (Composite) super.createDialogArea(parent);
     * //add controls to composite as necessary
     * return composite;
     * </pre>
     *
     * @param parent
     *            the parent composite to contain the dialog area
     * @return the dialog area control
     */
    protected Control createDialogArea(Composite parent) {
        Composite composite = new Composite(parent, DWT.NONE);
        POPUP_LAYOUT_FACTORY.applyTo(composite);
        LAYOUTDATA_GRAB_BOTH.applyTo(composite);
        return composite;
    }

    /**
     * Returns the control that should get initial focus. Subclasses may
     * override this method.
     *
     * @return the Control that should receive focus when the popup opens.
     */
    protected Control getFocusControl() {
        return dialogArea;
    }

    /**
     * Sets the tab order for the popup. Clients should override to introduce
     * specific tab ordering.
     *
     * @param composite
     *            the composite in which all content, including the title area
     *            and info area, was created. This composite's parent is the
     *            shell.
     */
    protected void setTabOrder(Composite composite) {
        // default is to do nothing
    }

    /**
     * Returns a bool indicating whether the popup should have a title area
     * at the top of the dialog. Subclasses may override. Default behavior is to
     * have a title area if there is to be a menu or title text.
     *
     * @return <code>true</code> if a title area should be created,
     *         <code>false</code> if it should not.
     */
    protected bool hasTitleArea() {
        return titleText !is null || showDialogMenu_;
    }

    /**
     * Returns a bool indicating whether the popup should have an info area
     * at the bottom of the dialog. Subclasses may override. Default behavior is
     * to have an info area if info text was provided at the time of creation.
     *
     * @return <code>true</code> if a title area should be created,
     *         <code>false</code> if it should not.
     */
    protected bool hasInfoArea() {
        return infoText !is null;
    }

    /**
     * Creates the title and menu area. Subclasses typically need not override
     * this method, but instead should use the constructor parameters
     * <code>showDialogMenu</code> and <code>showPersistAction</code> to
     * indicate whether a menu should be shown, and
     * <code>createTitleControl</code> to to customize the presentation of the
     * title.
     *
     * <p>
     * If this method is overridden, the returned control's layout data must be
     * an instance of <code>GridData</code>. This method must not modify the
     * parent's layout.
     *
     * @param parent
     *            The parent composite.
     * @return The Control representing the title and menu area.
     */
    protected Control createTitleMenuArea(Composite parent) {

        Composite titleAreaComposite = new Composite(parent, DWT.NONE);
        POPUP_LAYOUT_FACTORY.copy().numColumns(2).applyTo(titleAreaComposite);
        GridDataFactory.fillDefaults().align_(DWT.FILL, DWT.CENTER).grab(true,
                false).applyTo(titleAreaComposite);

        createTitleControl(titleAreaComposite);

        if (showDialogMenu_) {
            createDialogMenu(titleAreaComposite);
        }
        return titleAreaComposite;
    }

    /**
     * Creates the control to be used to represent the dialog's title text.
     * Subclasses may override if a different control is desired for
     * representing the title text, or if something different than the title
     * should be displayed in location where the title text typically is shown.
     *
     * <p>
     * If this method is overridden, the returned control's layout data must be
     * an instance of <code>GridData</code>. This method must not modify the
     * parent's layout.
     *
     * @param parent
     *            The parent composite.
     * @return The Control representing the title area.
     */
    protected Control createTitleControl(Composite parent) {
        titleLabel = new Label(parent, DWT.NONE);

        GridDataFactory.fillDefaults().align_(DWT.FILL, DWT.CENTER).grab(true,
                false).span(showDialogMenu_ ? 1 : 2, 1).applyTo(titleLabel);

        if (titleText !is null) {
            titleLabel.setText(titleText);
        }
        return titleLabel;
    }

    /**
     * Creates the optional info text area. This method is only called if the
     * <code>hasInfoArea()</code> method returns true. Subclasses typically
     * need not override this method, but may do so.
     *
     * <p>
     * If this method is overridden, the returned control's layout data must be
     * an instance of <code>GridData</code>. This method must not modify the
     * parent's layout.
     *
     *
     * @param parent
     *            The parent composite.
     * @return The control representing the info text area.
     *
     * @see PopupDialog#hasInfoArea()
     * @see PopupDialog#createTitleControl(Composite)
     */
    protected Control createInfoTextArea(Composite parent) {
        // Status label
        infoLabel = new Label(parent, DWT.RIGHT);
        infoLabel.setText(infoText);

        GridDataFactory.fillDefaults().grab(true, false).align_(DWT.FILL,
                DWT.BEGINNING).applyTo(infoLabel);
        infoLabel.setForeground(parent.getDisplay().getSystemColor(
                DWT.COLOR_WIDGET_DARK_SHADOW));
        return infoLabel;
    }

    /**
     * Create a horizontal separator for the given parent.
     *
     * @param parent
     *            The parent composite.
     * @return The Control representing the horizontal separator.
     */
    private Control createHorizontalSeparator(Composite parent) {
        Label separator = new Label(parent, DWT.SEPARATOR | DWT.HORIZONTAL
                | DWT.LINE_DOT);
        GridDataFactory.fillDefaults().align_(DWT.FILL, DWT.CENTER).grab(true,
                false).applyTo(separator);
        return separator;
    }

    /**
     * Create the dialog's menu for the move and resize actions.
     *
     * @param parent
     *            The parent composite.
     */
    private void createDialogMenu(Composite parent) {

        toolBar = new ToolBar(parent, DWT.FLAT);
        ToolItem viewMenuButton = new ToolItem(toolBar, DWT.PUSH, 0);

        GridDataFactory.fillDefaults().align_(DWT.END, DWT.CENTER).applyTo(
                toolBar);
        viewMenuButton.setImage(JFaceResources.getImage(POPUP_IMG_MENU));
        viewMenuButton.setDisabledImage(JFaceResources
                .getImage(POPUP_IMG_MENU_DISABLED));
        viewMenuButton.setToolTipText(JFaceResources
                .getString("PopupDialog.menuTooltip")); //$NON-NLS-1$
        viewMenuButton.addSelectionListener(new class SelectionAdapter {
            public void widgetSelected(SelectionEvent e) {
                showDialogMenu();
            }
        });
        // See https://bugs.eclipse.org/bugs/show_bug.cgi?id=177183
        toolBar.addMouseListener(new class MouseAdapter {
            public void mouseDown(MouseEvent e) {
                showDialogMenu();
            }
        });
    }

    /**
     * Fill the dialog's menu. Subclasses may extend or override.
     *
     * @param dialogMenu
     *            The dialog's menu.
     */
    protected void fillDialogMenu(IMenuManager dialogMenu) {
        dialogMenu.add(new GroupMarker("SystemMenuStart")); //$NON-NLS-1$
        dialogMenu.add(new MoveAction());
        dialogMenu.add(new ResizeAction());
        if (showPersistActions) {
            if (isUsing34API) {
                dialogMenu.add(new PersistLocationAction());
                dialogMenu.add(new PersistSizeAction());
            } else {
                dialogMenu.add(new PersistBoundsAction());
            }
        }
        dialogMenu.add(new Separator("SystemMenuEnd")); //$NON-NLS-1$
    }

    /**
     * Perform the requested tracker action (resize or move).
     *
     * @param style
     *            The track style (resize or move).
     */
    private void performTrackerAction(int style) {
        Shell shell = getShell();
        if (shell is null || shell.isDisposed()) {
            return;
        }

        Tracker tracker = new Tracker(shell.getDisplay(), style);
        tracker.setStippled(true);
        Rectangle[] r = [ shell.getBounds() ];
        tracker.setRectangles(r);

        // Ignore any deactivate events caused by opening the tracker.
        // See https://bugs.eclipse.org/bugs/show_bug.cgi?id=120656
        bool oldListenToDeactivate = listenToDeactivate;
        listenToDeactivate = false;
        if (tracker.open()) {
            if (shell !is null && !shell.isDisposed()) {
                shell.setBounds(tracker.getRectangles()[0]);
            }
        }
        listenToDeactivate = oldListenToDeactivate;
    }

    /**
     * Show the dialog's menu. This message has no effect if the receiver was
     * not configured to show a menu. Clients may call this method in order to
     * trigger the menu via keystrokes or other gestures. Subclasses typically
     * do not override method.
     */
    protected void showDialogMenu() {
        if (!showDialogMenu_) {
            return;
        }

        if (menuManager is null) {
            menuManager = new MenuManager();
            fillDialogMenu(menuManager);
        }
        // Setting this flag works around a problem that remains on X only,
        // whereby activating the menu deactivates our shell.
        listenToDeactivate = !"gtk".equals(DWT.getPlatform()); //$NON-NLS-1$

        Menu menu = menuManager.createContextMenu(getShell());
        Rectangle bounds = toolBar.getBounds();
        Point topLeft = new Point(bounds.x, bounds.y + bounds.height);
        topLeft = getShell().toDisplay(topLeft);
        menu.setLocation(topLeft.x, topLeft.y);
        menu.setVisible(true);
    }

    /**
     * Set the text to be shown in the popup's info area. This message has no
     * effect if there was no info text supplied when the dialog first opened.
     * Subclasses may override this method.
     *
     * @param text
     *            the text to be shown when the info area is displayed.
     *
     */
    protected void setInfoText(String text) {
        infoText = text;
        if (infoLabel !is null) {
            infoLabel.setText(text);
        }
    }

    /**
     * Set the text to be shown in the popup's title area. This message has no
     * effect if there was no title label specified when the dialog was
     * originally opened. Subclasses may override this method.
     *
     * @param text
     *            the text to be shown when the title area is displayed.
     *
     */
    protected void setTitleText(String text) {
        titleText = text;
        if (titleLabel !is null) {
            titleLabel.setText(text);
        }
    }

    /**
     * Return a bool indicating whether this dialog will persist its bounds.
     * This value is initially set in the dialog's constructor, but can be
     * modified if the persist bounds action is shown on the menu and the user
     * has changed its value. Subclasses may override this method.
     *
     * @return <code>true</code> if the dialog's bounds will be persisted,
     *         <code>false</code> if it will not.
     *
     * @deprecated As of 3.4, please use {@link #getPersistLocation()} or
     *             {@link #getPersistSize()} to determine separately whether
     *             size or location should be persisted.
     */
    protected bool getPersistBounds() {
        return persistLocation && persistSize;
    }

    /**
     * Return a bool indicating whether this dialog will persist its
     * location. This value is initially set in the dialog's constructor, but
     * can be modified if the persist location action is shown on the menu and
     * the user has changed its value. Subclasses may override this method.
     *
     * @return <code>true</code> if the dialog's location will be persisted,
     *         <code>false</code> if it will not.
     *
     * @see #getPersistSize()
     * @since 3.4
     */
    protected bool getPersistLocation() {
        return persistLocation;
    }

    /**
     * Return a bool indicating whether this dialog will persist its size.
     * This value is initially set in the dialog's constructor, but can be
     * modified if the persist size action is shown on the menu and the user has
     * changed its value. Subclasses may override this method.
     *
     * @return <code>true</code> if the dialog's size will be persisted,
     *         <code>false</code> if it will not.
     *
     * @see #getPersistLocation()
     * @since 3.4
     */
    protected bool getPersistSize() {
        return persistSize;
    }

    /**
     * Opens this window, creating it first if it has not yet been created.
     * <p>
     * This method is reimplemented for special configuration of PopupDialogs.
     * It never blocks on open, immediately returning <code>OK</code> if the
     * open is successful, or <code>CANCEL</code> if it is not. It provides
     * framework hooks that allow subclasses to set the focus and tab order, and
     * avoids the use of <code>shell.open()</code> in cases where the focus
     * should not be given to the shell initially.
     *
     * @return the return code
     *
     * @see dwtx.jface.window.Window#open()
     */
    public override int open() {

        Shell shell = getShell();
        if (shell is null || shell.isDisposed()) {
            shell = null;
            // create the window
            create();
            shell = getShell();
        }

        // provide a hook for adjusting the bounds. This is only
        // necessary when there is content driven sizing that must be
        // adjusted each time the dialog is opened.
        adjustBounds();

        // limit the shell size to the display size
        constrainShellSize();

        // set up the tab order for the dialog
        setTabOrder(cast(Composite) getContents());

        // initialize flags for listening to deactivate
        listenToDeactivate = false;
        listenToParentDeactivate = false;

        // open the window
        if (takeFocusOnOpen) {
            shell.open();
            getFocusControl().setFocus();
        } else {
            shell.setVisible(true);
        }

        return OK;

    }

    /**
     * Closes this window, disposes its shell, and removes this window from its
     * window manager (if it has one).
     * <p>
     * This method is extended to save the dialog bounds and initialize widget
     * state so that the widgets can be recreated if the dialog is reopened.
     * This method may be extended (<code>super.close</code> must be called).
     * </p>
     *
     * @return <code>true</code> if the window is (or was already) closed, and
     *         <code>false</code> if it is still open
     */
    public override bool close() {
        // If already closed, there is nothing to do.
        // See https://bugs.eclipse.org/bugs/show_bug.cgi?id=127505
        if (getShell() is null || getShell().isDisposed()) {
            return true;
        }

        saveDialogBounds(getShell());
        // Widgets are about to be disposed, so null out any state
        // related to them that was not handled in dispose listeners.
        // We do this before disposal so that any received activate or
        // deactivate events are duly ignored.
        initializeWidgetState();

        if (parentDeactivateListener !is null) {
            getShell().getParent().removeListener(DWT.Deactivate,
                    parentDeactivateListener);
            parentDeactivateListener = null;
        }

        return super.close();
    }

    /**
     * Gets the dialog settings that should be used for remembering the bounds
     * of the dialog. Subclasses should override this method when they wish to
     * persist the bounds of the dialog.
     *
     * @return settings the dialog settings used to store the dialog's location
     *         and/or size, or <code>null</code> if the dialog's bounds should
     *         never be stored.
     */
    protected IDialogSettings getDialogSettings() {
        return null;
    }

    /**
     * Saves the bounds of the shell in the appropriate dialog settings. The
     * bounds are recorded relative to the parent shell, if there is one, or
     * display coordinates if there is no parent shell. Subclasses typically
     * need not override this method, but may extend it (calling
     * <code>super.saveDialogBounds</code> if additional bounds information
     * should be stored. Clients may also call this method to persist the bounds
     * at times other than closing the dialog.
     *
     * @param shell
     *            The shell whose bounds are to be stored
     */
    protected void saveDialogBounds(Shell shell) {
        IDialogSettings settings = getDialogSettings();
        if (settings !is null) {
            Point shellLocation = shell.getLocation();
            Point shellSize = shell.getSize();
            Shell parent = getParentShell();
            if (parent !is null) {
                Point parentLocation = parent.getLocation();
                shellLocation.x -= parentLocation.x;
                shellLocation.y -= parentLocation.y;
            }
            String prefix = this.classinfo.name;
            if (persistSize) {
                settings.put(prefix ~ DIALOG_WIDTH, shellSize.x);
                settings.put(prefix ~ DIALOG_HEIGHT, shellSize.y);
            }
            if (persistLocation) {
                settings.put(prefix ~ DIALOG_ORIGIN_X, shellLocation.x);
                settings.put(prefix ~ DIALOG_ORIGIN_Y, shellLocation.y);
            }
            if (showPersistActions && showDialogMenu_) {
                settings.put(this.classinfo.name ~ DIALOG_USE_PERSISTED_SIZE,
                        persistSize);
                settings.put(this.classinfo.name
                        ~ DIALOG_USE_PERSISTED_LOCATION, persistLocation);

            }
        }
    }

    /*
     * (non-Javadoc)
     *
     * @see dwtx.jface.window.Window#getInitialSize()
     */
    protected override Point getInitialSize() {
        Point result = getDefaultSize();
        if (persistSize) {
            IDialogSettings settings = getDialogSettings();
            if (settings !is null) {
                try {
                    int width = settings.getInt(this.classinfo.name
                            ~ DIALOG_WIDTH);
                    int height = settings.getInt(this.classinfo.name
                            ~ DIALOG_HEIGHT);
                    result = new Point(width, height);

                } catch (NumberFormatException e) {
                }
            }
        }
        // No attempt is made to constrain the bounds. The default
        // constraining behavior in Window will be used.
        return result;
    }

    /**
     * Return the default size to use for the shell. This default size is used
     * if the dialog does not have any persisted size to restore. The default
     * implementation returns the preferred size of the shell. Subclasses should
     * override this method when an alternate default size is desired, rather
     * than overriding {@link #getInitialSize()}.
     *
     * @return the initial size of the shell
     *
     * @see #getPersistSize()
     * @since 3.4
     */
    protected Point getDefaultSize() {
        return super.getInitialSize();
    }

    /**
     * Returns the default location to use for the shell. This default location
     * is used if the dialog does not have any persisted location to restore.
     * The default implementation uses the location computed by
     * {@link dwtx.jface.window.Window#getInitialLocation(Point)}.
     * Subclasses should override this method when an alternate default location
     * is desired, rather than overriding {@link #getInitialLocation(Point)}.
     *
     * @param initialSize
     *            the initial size of the shell, as returned by
     *            <code>getInitialSize</code>.
     * @return the initial location of the shell
     *
     * @see #getPersistLocation()
     * @since 3.4
     */
    protected Point getDefaultLocation(Point initialSize) {
        return super.getInitialLocation(initialSize);
    }

    /**
     * Adjust the bounds of the popup as necessary prior to opening the dialog.
     * Default is to do nothing, which honors any bounds set directly by clients
     * or those that have been saved in the dialog settings. Subclasses should
     * override this method when there are bounds computations that must be
     * checked each time the dialog is opened.
     */
    protected void adjustBounds() {
    }

    /**
     * (non-Javadoc)
     *
     * @see dwtx.jface.window.Window#getInitialLocation(dwt.graphics.Point)
     */
    protected override Point getInitialLocation(Point initialSize) {
        Point result = getDefaultLocation(initialSize);
        if (persistLocation) {
            IDialogSettings settings = getDialogSettings();
            if (settings !is null) {
                try {
                    int x = settings.getInt(this.classinfo.name
                            ~ DIALOG_ORIGIN_X);
                    int y = settings.getInt(this.classinfo.name
                            ~ DIALOG_ORIGIN_Y);
                    result = new Point(x, y);
                    // The coordinates were stored relative to the parent shell.
                    // Convert to display coordinates.
                    Shell parent = getParentShell();
                    if (parent !is null) {
                        Point parentLocation = parent.getLocation();
                        result.x += parentLocation.x;
                        result.y += parentLocation.y;
                    }
                } catch (NumberFormatException e) {
                }
            }
        }
        // No attempt is made to constrain the bounds. The default
        // constraining behavior in Window will be used.
        return result;
    }

    /**
     * Apply any desired color to the specified composite and its children.
     *
     * @param composite
     *            the contents composite
     */
    private void applyColors(Composite composite) {
        // The getForeground() and getBackground() methods
        // should not answer null, but IColorProvider clients
        // are accustomed to null meaning use the default, so we guard
        // against this assumption.
        Color color = getForeground();
        if (color is null)
            color = getDefaultForeground();
        applyForegroundColor(color, composite, getForegroundColorExclusions());
        color = getBackground();
        if (color is null)
            color = getDefaultBackground();
        applyBackgroundColor(color, composite, getBackgroundColorExclusions());
    }

    /**
     * Get the foreground color that should be used for this popup. Subclasses
     * may override.
     *
     * @return the foreground color to be used. Should not be <code>null</code>.
     *
     * @since 3.4
     *
     * @see #getForegroundColorExclusions()
     */
    protected Color getForeground() {
        return getDefaultForeground();
    }

    /**
     * Get the background color that should be used for this popup. Subclasses
     * may override.
     *
     * @return the background color to be used. Should not be <code>null</code>.
     *
     * @since 3.4
     *
     * @see #getBackgroundColorExclusions()
     */
    protected Color getBackground() {
        return getDefaultBackground();
    }

    /**
     * Return the default foreground color used for popup dialogs.
     *
     * @return the default foreground color.
     */
    private Color getDefaultForeground() {
        return getShell().getDisplay()
                .getSystemColor(DWT.COLOR_INFO_FOREGROUND);
    }

    /**
     * Return the default background color used for popup dialogs.
     *
     * @return the default background color
     */
    private Color getDefaultBackground() {
        return getShell().getDisplay()
                .getSystemColor(DWT.COLOR_INFO_BACKGROUND);
    }

    /**
     * Apply any desired fonts to the specified composite and its children.
     *
     * @param composite
     *            the contents composite
     */
    private void applyFonts(Composite composite) {
        Dialog.applyDialogFont(composite);

        if (titleLabel !is null) {
            Font font = titleLabel.getFont();
            FontData[] fontDatas = font.getFontData();
            for (int i = 0; i < fontDatas.length; i++) {
                fontDatas[i].setStyle(DWT.BOLD);
            }
            titleFont = new Font(titleLabel.getDisplay(), fontDatas);
            titleLabel.setFont(titleFont);
        }

        if (infoLabel !is null) {
            Font font = infoLabel.getFont();
            FontData[] fontDatas = font.getFontData();
            for (int i = 0; i < fontDatas.length; i++) {
                fontDatas[i].setHeight(fontDatas[i].getHeight() * 9 / 10);
            }
            infoFont = new Font(infoLabel.getDisplay(), fontDatas);
            infoLabel.setFont(infoFont);
        }
    }

    /**
     * Set the specified foreground color for the specified control and all of
     * its children, except for those specified in the list of exclusions.
     *
     * @param color
     *            the color to use as the foreground color
     * @param control
     *            the control whose color is to be changed
     * @param exclusions
     *            a list of controls who are to be excluded from getting their
     *            color assigned
     */
    private void applyForegroundColor(Color color, Control control,
            List exclusions) {
        if (!exclusions.contains(control)) {
            control.setForeground(color);
        }
        if ( auto comp = cast(Composite)control ) {
            Control[] children = comp.getChildren();
            for (int i = 0; i < children.length; i++) {
                applyForegroundColor(color, children[i], exclusions);
            }
        }
    }

    /**
     * Set the specified background color for the specified control and all of
     * its children, except for those specified in the list of exclusions.
     *
     * @param color
     *            the color to use as the background color
     * @param control
     *            the control whose color is to be changed
     * @param exclusions
     *            a list of controls who are to be excluded from getting their
     *            color assigned
     */
    private void applyBackgroundColor(Color color, Control control,
            List exclusions) {
        if (!exclusions.contains(control)) {
            control.setBackground(color);
        }
        if (auto comp = cast(Composite)control ) {
            Control[] children = comp.getChildren();
            for (int i = 0; i < children.length; i++) {
                applyBackgroundColor(color, children[i], exclusions);
            }
        }
    }

    /**
     * Set the specified foreground color for the specified control and all of
     * its children. Subclasses may override this method, but typically do not.
     * If a subclass wishes to exclude a particular control in its contents from
     * getting the specified foreground color, it may instead override
     * {@link #getForegroundColorExclusions()}.
     *
     * @param color
     *            the color to use as the foreground color
     * @param control
     *            the control whose color is to be changed
     * @see PopupDialog#getForegroundColorExclusions()
     */
    protected void applyForegroundColor(Color color, Control control) {
        applyForegroundColor(color, control, getForegroundColorExclusions());
    }

    /**
     * Set the specified background color for the specified control and all of
     * its children. Subclasses may override this method, but typically do not.
     * If a subclass wishes to exclude a particular control in its contents from
     * getting the specified background color, it may instead override
     * {@link #getBackgroundColorExclusions()}
     *
     * @param color
     *            the color to use as the background color
     * @param control
     *            the control whose color is to be changed
     * @see PopupDialog#getBackgroundColorExclusions()
     */
    protected void applyBackgroundColor(Color color, Control control) {
        applyBackgroundColor(color, control, getBackgroundColorExclusions());
    }

    /**
     * Return a list of controls which should never have their foreground color
     * reset. Subclasses may extend this method, but should always call
     * <code>super.getForegroundColorExclusions</code> to aggregate the list.
     *
     *
     * @return the List of controls
     */
    protected List getForegroundColorExclusions() {
        List list = new ArrayList(3);
        if (infoLabel !is null) {
            list.add(infoLabel);
        }
        if (titleSeparator !is null) {
            list.add(titleSeparator);
        }
        if (infoSeparator !is null) {
            list.add(infoSeparator);
        }
        return list;
    }

    /**
     * Return a list of controls which should never have their background color
     * reset. Subclasses may extend this method, but should always call
     * <code>super.getBackgroundColorExclusions</code> to aggregate the list.
     *
     * @return the List of controls
     */
    protected List getBackgroundColorExclusions() {
        List list = new ArrayList(2);
        if (titleSeparator !is null) {
            list.add(titleSeparator);
        }
        if (infoSeparator !is null) {
            list.add(infoSeparator);
        }
        return list;
    }

    /**
     * Initialize any state related to the widgetry that should be set up each
     * time widgets are created.
     */
    private void initializeWidgetState() {
        menuManager = null;
        dialogArea = null;
        titleLabel = null;
        titleSeparator = null;
        infoSeparator = null;
        infoLabel = null;
        toolBar = null;

        // If the menu item for persisting bounds is displayed, use the stored
        // value to determine whether any persisted bounds should be honored at
        // all.
        if (showDialogMenu_ && showPersistActions) {
            IDialogSettings settings = getDialogSettings();
            if (settings !is null) {
                String key = this.classinfo.name ~ DIALOG_USE_PERSISTED_SIZE;
                if (settings.get(key) !is null || !isUsing34API)
                    persistSize = settings.getBoolean(key);
                key = this.classinfo.name ~ DIALOG_USE_PERSISTED_LOCATION;
                if (settings.get(key) !is null || !isUsing34API)
                    persistLocation = settings.getBoolean(key);
            }
        }
    }

    private void migrateBoundsSetting() {
        IDialogSettings settings = getDialogSettings();
        if (settings is null)
            return;

        final String className = this.classinfo.name;

        String key = className ~ DIALOG_USE_PERSISTED_BOUNDS;
        String value = settings.get(key);
        if (value is null || DIALOG_VALUE_MIGRATED_TO_34.equals(value))
            return;

        bool storeBounds = settings.getBoolean(key);
        settings.put(className ~ DIALOG_USE_PERSISTED_LOCATION, storeBounds);
        settings.put(className ~ DIALOG_USE_PERSISTED_SIZE, storeBounds);
        settings.put(key, DIALOG_VALUE_MIGRATED_TO_34);
    }

    /**
     * The dialog is being disposed. Dispose of any resources allocated.
     *
     */
    private void handleDispose() {
        if (infoFont !is null && !infoFont.isDisposed()) {
            infoFont.dispose();
        }
        infoFont = null;
        if (titleFont !is null && !titleFont.isDisposed()) {
            titleFont.dispose();
        }
        titleFont = null;
    }
}
