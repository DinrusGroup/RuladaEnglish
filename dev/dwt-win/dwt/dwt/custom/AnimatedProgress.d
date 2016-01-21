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
module dwt.custom.AnimatedProgress;


import dwt.DWT;
import dwt.DWTException;
import dwt.events.ControlAdapter;
import dwt.events.ControlEvent;
import dwt.events.DisposeEvent;
import dwt.events.DisposeListener;
import dwt.events.PaintEvent;
import dwt.events.PaintListener;
import dwt.graphics.Color;
import dwt.graphics.GC;
import dwt.graphics.Point;
import dwt.graphics.Rectangle;
import dwt.widgets.Canvas;
import dwt.widgets.Composite;
import dwt.widgets.Display;
import dwt.dwthelper.Runnable;

/**
 * A control for showing progress feedback for a long running operation.
 *
 * @deprecated As of Eclipse 2.1, use ProgressBar with the style DWT.INDETERMINATE
 *
 * <dl>
 * <dt><b>Styles:</b><dd>VERTICAL, HORIZONTAL, BORDER
 * </dl>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class AnimatedProgress : Canvas {

    alias Canvas.computeSize computeSize;

    static const int SLEEP = 70;
    static const int DEFAULT_WIDTH = 160;
    static const int DEFAULT_HEIGHT = 18;
    bool active = false;
    bool showStripes = false;
    int value;
    int orientation = DWT.HORIZONTAL;
    bool showBorder = false;

/**
 * Constructs a new instance of this class given its parent
 * and a style value describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>DWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p>
 *
 * @param parent a widget which will be the parent of the new instance (cannot be null)
 * @param style the style of widget to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception DWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see DWT#VERTICAL
 * @see DWT#HORIZONTAL
 * @see DWT#BORDER
 * @see #getStyle()
 */
public this(Composite parent, int style) {
    super(parent, checkStyle(style));

    if ((style & DWT.VERTICAL) !is 0) {
        orientation = DWT.VERTICAL;
    }
    showBorder = (style & DWT.BORDER) !is 0;

    addControlListener(new class() ControlAdapter {
        public void controlResized(ControlEvent e) {
            redraw();
        }
    });
    addPaintListener(new class() PaintListener {
        public void paintControl(PaintEvent e) {
            paint(e);
        }
    });
    addDisposeListener(new class() DisposeListener {
        public void widgetDisposed(DisposeEvent e){
            stop();
        }
    });
}
private static int checkStyle (int style) {
    int mask = DWT.NONE;
    return style & mask;
}
/**
 * Stop the animation if it is not already stopped and
 * reset the presentation to a blank appearance.
 *
 * @exception DWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public synchronized void clear(){
    checkWidget();
    if (active) stop();
    showStripes = false;
    redraw();
}
public override Point computeSize(int wHint, int hHint, bool changed) {
    checkWidget();
    Point size = null;
    if (orientation is DWT.HORIZONTAL) {
        size = new Point(DEFAULT_WIDTH, DEFAULT_HEIGHT);
    } else {
        size = new Point(DEFAULT_HEIGHT, DEFAULT_WIDTH);
    }
    if (wHint !is DWT.DEFAULT) size.x = wHint;
    if (hHint !is DWT.DEFAULT) size.y = hHint;

    return size;
}
private void drawBevelRect(GC gc, int x, int y, int w, int h, Color topleft, Color bottomright) {
    gc.setForeground(topleft);
    gc.drawLine(x, y, x+w-1, y);
    gc.drawLine(x, y, x, y+h-1);

    gc.setForeground(bottomright);
    gc.drawLine(x+w, y, x+w, y+h);
    gc.drawLine(x, y+h, x+w, y+h);
}
void paint(PaintEvent event) {
    GC gc = event.gc;
    Display disp= getDisplay();

    Rectangle rect= getClientArea();
    gc.fillRectangle(rect);
    if (showBorder) {
        drawBevelRect(gc, rect.x, rect.y, rect.width-1, rect.height-1,
            disp.getSystemColor(DWT.COLOR_WIDGET_NORMAL_SHADOW),
            disp.getSystemColor(DWT.COLOR_WIDGET_HIGHLIGHT_SHADOW));
    }

    paintStripes(gc);
}
void paintStripes(GC gc) {

    if (!showStripes) return;

    Rectangle rect= getClientArea();
    // Subtracted border painted by paint.
    rect = new Rectangle(rect.x+2, rect.y+2, rect.width-4, rect.height-4);

    gc.setLineWidth(2);
    gc.setClipping(rect);
    Color color = getDisplay().getSystemColor(DWT.COLOR_LIST_SELECTION);
    gc.setBackground(color);
    gc.fillRectangle(rect);
    gc.setForeground(this.getBackground());
    int step = 12;
    int foregroundValue = value is 0 ? step - 2 : value - 2;
    if (orientation is DWT.HORIZONTAL) {
        int y = rect.y - 1;
        int w = rect.width;
        int h = rect.height + 2;
        for (int i= 0; i < w; i+= step) {
            int x = i + foregroundValue;
            gc.drawLine(x, y, x, h);
        }
    } else {
        int x = rect.x - 1;
        int w = rect.width + 2;
        int h = rect.height;

        for (int i= 0; i < h; i+= step) {
            int y = i + foregroundValue;
            gc.drawLine(x, y, w, y);
        }
    }

    if (active) {
        value = (value + 2) % step;
    }
}
/**
* Start the animation.
*
* @exception DWTException <ul>
*    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
*    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
* </ul>
*/
public synchronized void start() {
    checkWidget();
    if (active) return;

    active = true;
    showStripes = true;

    Display display = getDisplay();
    Runnable [] timer = new Runnable [1];

    timer [0] = new class( display, timer ) Runnable {
        Display disp;
        Runnable [] runs;
        this( Display disp, Runnable[] runs ){
            this.disp = disp;
            this.runs = runs;
        }
        public void run () {
            if (!active) return;
            GC gc = new GC(this.outer);
            paintStripes(gc);
            gc.dispose();
            disp.timerExec (SLEEP, runs [0]);
        }
    };
    display.timerExec (SLEEP, timer [0]);
}
/**
* Stop the animation.   Freeze the presentation at its current appearance.
*/
public synchronized void stop() {
    //checkWidget();
    active = false;
}
}
