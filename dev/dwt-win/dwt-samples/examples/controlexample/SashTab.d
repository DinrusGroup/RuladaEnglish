﻿/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module examples.controlexample.SashTab;



import dwt.DWT;
import dwt.events.ControlAdapter;
import dwt.events.ControlEvent;
import dwt.events.SelectionAdapter;
import dwt.events.SelectionEvent;
import dwt.graphics.Rectangle;
import dwt.layout.FillLayout;
import dwt.layout.GridData;
import dwt.widgets.Button;
import dwt.widgets.Composite;
import dwt.widgets.Group;
import dwt.widgets.List;
import dwt.widgets.Sash;
import dwt.widgets.Text;
import dwt.widgets.Widget;

import examples.controlexample.Tab;
import examples.controlexample.ControlExample;

class SashTab : Tab {
    /* Example widgets and groups that contain them */
    Sash hSash, vSash;
    Composite sashComp;
    Group sashGroup;
    List list1, list2, list3;
    Text text;
    Button smoothButton;

    static char[] [] ListData0;
    static char[] [] ListData1;

    /* Constants */
    static final int SASH_WIDTH = 3;
    static final int SASH_LIMIT = 20;

    /**
     * Creates the Tab within a given instance of ControlExample.
     */
    this(ControlExample instance) {
        super(instance);
        if( ListData0.length is 0 ){
            ListData0 = [
                ControlExample.getResourceString("ListData0_0"),
                ControlExample.getResourceString("ListData0_1"),
                ControlExample.getResourceString("ListData0_2"),
                ControlExample.getResourceString("ListData0_3"),
                ControlExample.getResourceString("ListData0_4"),
                ControlExample.getResourceString("ListData0_5"),
                ControlExample.getResourceString("ListData0_6"),
                ControlExample.getResourceString("ListData0_7"),
                ControlExample.getResourceString("ListData0_8")];
        }
        if( ListData1.length is 0 ){
            ListData1 = [
                ControlExample.getResourceString("ListData1_0"),
                ControlExample.getResourceString("ListData1_1"),
                ControlExample.getResourceString("ListData1_2"),
                ControlExample.getResourceString("ListData1_3"),
                ControlExample.getResourceString("ListData1_4"),
                ControlExample.getResourceString("ListData1_5"),
                ControlExample.getResourceString("ListData1_6"),
                ControlExample.getResourceString("ListData1_7"),
                ControlExample.getResourceString("ListData1_8")];
        }
    }

    /**
     * Creates the "Example" group.
     */
    void createExampleGroup () {
        super.createExampleGroup ();
        exampleGroup.setLayoutData (new GridData (DWT.FILL, DWT.FILL, true, true));
        exampleGroup.setLayout(new FillLayout());

        /* Create a group for the sash widgets */
        sashGroup = new Group (exampleGroup, DWT.NONE);
        FillLayout layout = new FillLayout();
        layout.marginHeight = layout.marginWidth = 5;
        sashGroup.setLayout(layout);
        sashGroup.setText ("Sash");
    }

    /**
     * Creates the "Example" widgets.
     */
    void createExampleWidgets () {
        /*
         * Create the page.  This example does not use layouts.
         */
        sashComp = new Composite(sashGroup, DWT.BORDER);

        /* Create the list and text widgets */
        list1 = new List (sashComp, DWT.V_SCROLL | DWT.H_SCROLL | DWT.BORDER);
        list1.setItems (ListData0);
        list2 = new List (sashComp, DWT.V_SCROLL | DWT.H_SCROLL | DWT.BORDER);
        list2.setItems (ListData1);
        text = new Text (sashComp, DWT.MULTI | DWT.BORDER);
        text.setText (ControlExample.getResourceString("Multi_line"));

        /* Create the sashes */
        int style = getDefaultStyle();
        if (smoothButton.getSelection()) style |= DWT.SMOOTH;
        vSash = new Sash (sashComp, DWT.VERTICAL | style);
        hSash = new Sash (sashComp, DWT.HORIZONTAL | style);

        /* Add the listeners */
        hSash.addSelectionListener (new class() SelectionAdapter {
            public void widgetSelected (SelectionEvent event) {
                Rectangle rect = vSash.getParent().getClientArea();
                event.y = Math.min (Math.max (event.y, SASH_LIMIT), rect.height - SASH_LIMIT);
                if (event.detail !is DWT.DRAG) {
                    hSash.setBounds (event.x, event.y, event.width, event.height);
                    layout ();
                }
            }
        });
        vSash.addSelectionListener (new class() SelectionAdapter {
            public void widgetSelected (SelectionEvent event) {
                Rectangle rect = vSash.getParent().getClientArea();
                event.x = Math.min (Math.max (event.x, SASH_LIMIT), rect.width - SASH_LIMIT);
                if (event.detail !is DWT.DRAG) {
                    vSash.setBounds (event.x, event.y, event.width, event.height);
                    layout ();
                }
            }
        });
        sashComp.addControlListener (new class() ControlAdapter {
            public void controlResized (ControlEvent event) {
                resized ();
            }
        });
    }

    /**
     * Creates the "Size" group.  The "Size" group contains
     * controls that allow the user to change the size of
     * the example widgets.
     */
    void createSizeGroup () {
    }

    /**
     * Creates the "Style" group.
     */
    void createStyleGroup() {
        super.createStyleGroup ();

        /* Create the extra widgets */
        smoothButton = new Button (styleGroup, DWT.CHECK);
        smoothButton.setText("DWT.SMOOTH");
    }

    void disposeExampleWidgets () {
        sashComp.dispose();
        sashComp = null;
    }

    /**
     * Gets the "Example" widget children.
     */
    Widget [] getExampleWidgets () {
        return [ cast(Widget) hSash, vSash ];
    }

    /**
     * Returns a list of set/get API method names (without the set/get prefix)
     * that can be used to set/get values in the example control(s).
     */
    char[][] getMethodNames() {
        return ["ToolTipText"];
    }

    /**
     * Gets the text for the tab folder item.
     */
    char[] getTabText () {
        return "Sash";
    }

    /**
     * Layout the list and text widgets according to the new
     * positions of the sashes..events.SelectionEvent
     */
    void layout () {

        Rectangle clientArea = sashComp.getClientArea ();
        Rectangle hSashBounds = hSash.getBounds ();
        Rectangle vSashBounds = vSash.getBounds ();

        list1.setBounds (0, 0, vSashBounds.x, hSashBounds.y);
        list2.setBounds (vSashBounds.x + vSashBounds.width, 0, clientArea.width - (vSashBounds.x + vSashBounds.width), hSashBounds.y);
        text.setBounds (0, hSashBounds.y + hSashBounds.height, clientArea.width, clientArea.height - (hSashBounds.y + hSashBounds.height));

        /**
        * If the horizontal sash has been moved then the vertical
        * sash is either too long or too short and its size must
        * be adjusted.
        */
        vSashBounds.height = hSashBounds.y;
        vSash.setBounds (vSashBounds);
    }
    /**
     * Sets the size of the "Example" widgets.
     */
    void setExampleWidgetSize () {
        sashGroup.layout (true);
    }

    /**
     * Sets the state of the "Example" widgets.
     */
    void setExampleWidgetState () {
        super.setExampleWidgetState ();
        smoothButton.setSelection ((hSash.getStyle () & DWT.SMOOTH) !is 0);
    }

    /**
     * Handle the shell resized event.
     */
    void resized () {

        /* Get the client area for the shell */
        Rectangle clientArea = sashComp.getClientArea ();

        /*
        * Make list 1 half the width and half the height of the tab leaving room for the sash.
        * Place list 1 in the top left quadrant of the tab.
        */
        Rectangle list1Bounds = new Rectangle (0, 0, (clientArea.width - SASH_WIDTH) / 2, (clientArea.height - SASH_WIDTH) / 2);
        list1.setBounds (list1Bounds);

        /*
        * Make list 2 half the width and half the height of the tab leaving room for the sash.
        * Place list 2 in the top right quadrant of the tab.
        */
        list2.setBounds (list1Bounds.width + SASH_WIDTH, 0, clientArea.width - (list1Bounds.width + SASH_WIDTH), list1Bounds.height);

        /*
        * Make the text area the full width and half the height of the tab leaving room for the sash.
        * Place the text area in the bottom half of the tab.
        */
        text.setBounds (0, list1Bounds.height + SASH_WIDTH, clientArea.width, clientArea.height - (list1Bounds.height + SASH_WIDTH));

        /* Position the sashes */
        vSash.setBounds (list1Bounds.width, 0, SASH_WIDTH, list1Bounds.height);
        hSash.setBounds (0, list1Bounds.height, clientArea.width, SASH_WIDTH);
    }
}
