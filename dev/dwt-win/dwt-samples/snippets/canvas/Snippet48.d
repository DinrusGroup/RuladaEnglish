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
 *     Bill Baxter <wbaxter> at gmail com
 *******************************************************************************/
module canvas.Snippet48;
 
/*
 * Canvas example snippet: scroll an image (flicker free, no double buffering)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import dwt.DWT;
import dwt.graphics.GC;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.graphics.Color;
import dwt.graphics.Image;
import dwt.layout.FillLayout;
import dwt.widgets.Display;
import dwt.widgets.Shell;
import dwt.widgets.Event;
import dwt.widgets.Listener;
import dwt.widgets.FileDialog;
import dwt.widgets.Canvas;
import dwt.widgets.ScrollBar;
import dwt.layout.FillLayout;

import dwt.dwthelper.utils;

void main () {
	Display display = new Display ();
	Shell shell = new Shell (display);
	shell.setLayout(new FillLayout());
	Image originalImage = null;
	FileDialog dialog = new FileDialog (shell, DWT.OPEN);
	dialog.setText ("Open an image file or cancel");
	String string = dialog.open ();
	if (string !is null) {
		originalImage = new Image (display, string);
	}
	if (originalImage is null) {
		int width = 150, height = 200;
		originalImage = new Image (display, width, height);
		GC gc = new GC (originalImage);
		gc.fillRectangle (0, 0, width, height);
		gc.drawLine (0, 0, width, height);
		gc.drawLine (0, height, width, 0);
		gc.drawText ("Default Image", 10, 10);
		gc.dispose ();
	}
	final Image image = originalImage;
	final Point origin = new Point (0, 0);
	final Canvas canvas = new Canvas (shell, DWT.NO_BACKGROUND |
			DWT.NO_REDRAW_RESIZE | DWT.V_SCROLL | DWT.H_SCROLL);
	final ScrollBar hBar = canvas.getHorizontalBar ();
    void onHBarSelection (Event e) {
        int hSelection = hBar.getSelection ();
        int destX = -hSelection - origin.x;
        Rectangle rect = image.getBounds ();
        canvas.scroll (destX, 0, 0, 0, rect.width, rect.height, false);
        origin.x = -hSelection;
    }
	final ScrollBar vBar = canvas.getVerticalBar ();
    void onVBarSelection(Event e) {
        int vSelection = vBar.getSelection ();
        int destY = -vSelection - origin.y;
        Rectangle rect = image.getBounds ();
        canvas.scroll (0, destY, 0, 0, rect.width, rect.height, false);
        origin.y = -vSelection;
    }
    void onResize(Event e) {
        Rectangle rect = image.getBounds ();
        Rectangle client = canvas.getClientArea ();
        hBar.setMaximum (rect.width);
        vBar.setMaximum (rect.height);
        hBar.setThumb (Math.min (rect.width, client.width));
        vBar.setThumb (Math.min (rect.height, client.height));
        int hPage = rect.width - client.width;
        int vPage = rect.height - client.height;
        int hSelection = hBar.getSelection ();
        int vSelection = vBar.getSelection ();
        if (hSelection >= hPage) {
            if (hPage <= 0) hSelection = 0;
            origin.x = -hSelection;
        }
        if (vSelection >= vPage) {
            if (vPage <= 0) vSelection = 0;
            origin.y = -vSelection;
        }
        canvas.redraw ();
    }
    void onPaint (Event e) {
        GC gc = e.gc;
        gc.drawImage (image, origin.x, origin.y);
        Rectangle rect = image.getBounds ();
        Rectangle client = canvas.getClientArea ();
        int marginWidth = client.width - rect.width;
        if (marginWidth > 0) {
            gc.fillRectangle (rect.width, 0, marginWidth, client.height);
        }
        int marginHeight = client.height - rect.height;
        if (marginHeight > 0) {
            gc.fillRectangle (0, rect.height, client.width, marginHeight);
        }
    }

	hBar.addListener (DWT.Selection, dgListener(&onHBarSelection));
	vBar.addListener (DWT.Selection, dgListener(&onVBarSelection));
	canvas.addListener (DWT.Resize,  dgListener(&onResize));
	canvas.addListener (DWT.Paint, dgListener(&onPaint));

	shell.setSize (200, 150);
	shell.open ();
	while (!shell.isDisposed ()) {
		if (!display.readAndDispatch ()) display.sleep ();
	}
	originalImage.dispose();
	display.dispose ();
}

