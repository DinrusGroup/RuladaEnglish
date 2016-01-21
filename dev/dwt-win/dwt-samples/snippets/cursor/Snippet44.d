/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * D Port:
 *     Thomas Demmer <t_demmer AT web DOT de>
 *******************************************************************************/
module cursor.Snippet44;

/*
 * Cursor example snippet: set the hand cursor into a control
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import dwt.DWT;
import dwt.graphics.Cursor;
import dwt.widgets.Button;
import dwt.widgets.Display;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.Shell;

import dwt.dwthelper.utils;

void main (String [] args) {
    Display display = new Display ();
    Cursor cursor = new Cursor (display, DWT.CURSOR_HAND);
    Shell shell = new Shell (display);
    shell.open ();
    Button b = new Button (shell, 0);
    b.setBounds (10, 10, 200, 200);
    b.addListener (DWT.Selection, new class() Listener{
        public void handleEvent (Event e) {
            b.setCursor (cursor);
        }
    });
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    cursor.dispose ();
    display.dispose ();
}

