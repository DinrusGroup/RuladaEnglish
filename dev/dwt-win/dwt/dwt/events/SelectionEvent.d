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
module dwt.events.SelectionEvent;


import dwt.widgets.Event;
import dwt.widgets.Widget;
import dwt.events.TypedEvent;

import tango.text.convert.Format;
import dwt.dwthelper.utils;

/**
 * Instances of this class are sent as a result of
 * widgets being selected.
 * <p>
 * Note: The fields that are filled in depend on the widget.
 * </p>
 *
 * @see SelectionListener
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class SelectionEvent : TypedEvent {

    /**
     * The item that was selected.
     */
    public Widget item;

    /**
     * Extra detail information about the selection, depending on the widget.
     *
     * <p><b>Sash</b><ul>
     * <li>{@link dwt.DWT#DRAG}</li>
     * </ul></p><p><b>ScrollBar and Slider</b><ul>
     * <li>{@link dwt.DWT#DRAG}</li>
     * <li>{@link dwt.DWT#HOME}</li>
     * <li>{@link dwt.DWT#END}</li>
     * <li>{@link dwt.DWT#ARROW_DOWN}</li>
     * <li>{@link dwt.DWT#ARROW_UP}</li>
     * <li>{@link dwt.DWT#PAGE_DOWN}</li>
     * <li>{@link dwt.DWT#PAGE_UP}</li>
     * </ul></p><p><b>Table and Tree</b><ul>
     * <li>{@link dwt.DWT#CHECK}</li>
     * </ul></p><p><b>Text</b><ul>
     * <li>{@link dwt.DWT#CANCEL}</li>
     * </ul></p><p><b>CoolItem and ToolItem</b><ul>
     * <li>{@link dwt.DWT#ARROW}</li>
     * </ul></p>
     */
    public int detail;

    /**
     * The x location of the selected area.
     */
    public int x;

    /**
     * The y location of selected area.
     */
    public int y;

    /**
     * The width of selected area.
     */
    public int width;

    /**
     * The height of selected area.
     */
    public int height;

    /**
     * The state of the keyboard modifier keys at the time
     * the event was generated.
     */
    public int stateMask;

    /**
     * The text of the hyperlink that was selected.
     * This will be either the text of the hyperlink or the value of its HREF,
     * if one was specified.
     *
     * @see dwt.widgets.Link#setText(String)
     * @since 3.1
     */
    public String text;

    /**
     * A flag indicating whether the operation should be allowed.
     * Setting this field to <code>false</code> will cancel the
     * operation, depending on the widget.
     */
    public bool doit;

    //static final long serialVersionUID = 3976735856884987953L;

/**
 * Constructs a new instance of this class based on the
 * information in the given untyped event.
 *
 * @param e the untyped event containing the information
 */
public this(Event e) {
    super(e);
    this.item = e.item;
    this.x = e.x;
    this.y = e.y;
    this.width = e.width;
    this.height = e.height;
    this.detail = e.detail;
    this.stateMask = e.stateMask;
    this.text = e.text;
    this.doit = e.doit;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString() {
    return Format( "{} item={} detail={} x={} y={} width={} height={} stateMask={} text={} doit={}}",
        super.toString[ 0 .. $-2 ],
        item,
        detail,
        x,
        y,
        width,
        height,
        stateMask,
        text,
        doit );
}
}

