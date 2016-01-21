/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module dwtx.draw2d.LabeledContainer;

import dwt.dwthelper.utils;

import dwt.graphics.Font;
import dwtx.draw2d.Figure;
import dwtx.draw2d.Border;
import dwtx.draw2d.LabeledBorder;
import dwtx.draw2d.GroupBoxBorder;
import dwtx.draw2d.CompoundBorder;

/**
 * A Container with a title bar describing the contents of the container. The frame is
 * generated by a {@link LabeledBorder}.
 */
public class LabeledContainer
    : Figure
{

/**
 * Constructs a default container with a {@link GroupBoxBorder}.
 *
 * @since 2.0
 */
public this() {
    this(new GroupBoxBorder());
}

/**
 * Constructs a labeled container with the border given as input.
 *
 * @param border the border
 * @since 2.0
 */
public this(Border border) {
    setBorder(border);
    setOpaque(true);
}

private static LabeledBorder findLabeledBorder(Border border) {
    if ( auto b = cast(LabeledBorder)border )
        return b;
    if ( auto cb = cast(CompoundBorder)border ) {
        LabeledBorder labeled = findLabeledBorder(cb.getInnerBorder());
        if (labeled is null)
            labeled = findLabeledBorder(cb.getOuterBorder());
        return labeled;
    }
    return null;
}

/**
 * Returns the text of the LabeledContainer's label.
 *
 * @return the label text
 * @since 2.0
 */
public String getLabel() {
    return getLabeledBorder().getLabel();
}

/**
 * Returns the LabeledBorder of this container.
 *
 * @return the border
 * @since 2.0
 */
protected LabeledBorder getLabeledBorder() {
    return findLabeledBorder(getBorder());
}

/**
 * Sets the title of the container.
 *
 * @param s the new title text
 * @since 2.0
 */
public void setLabel(String s) {
    getLabeledBorder().setLabel(s);
    revalidate();
    repaint();
}

/**
 * Sets the font to be used for the container title.
 *
 * @param f the new font
 * @since 2.0
 */
public void setLabelFont(Font f) {
    getLabeledBorder().setFont(f);
    revalidate();
    repaint();
}

}