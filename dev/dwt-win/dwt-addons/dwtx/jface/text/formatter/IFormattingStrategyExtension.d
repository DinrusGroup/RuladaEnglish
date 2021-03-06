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


module dwtx.jface.text.formatter.IFormattingStrategyExtension;

import dwtx.jface.text.formatter.MultiPassContentFormatter; // packageimport
import dwtx.jface.text.formatter.ContextBasedFormattingStrategy; // packageimport
import dwtx.jface.text.formatter.FormattingContext; // packageimport
import dwtx.jface.text.formatter.IFormattingStrategy; // packageimport
import dwtx.jface.text.formatter.IContentFormatterExtension; // packageimport
import dwtx.jface.text.formatter.IContentFormatter; // packageimport
import dwtx.jface.text.formatter.FormattingContextProperties; // packageimport
import dwtx.jface.text.formatter.ContentFormatter; // packageimport
import dwtx.jface.text.formatter.IFormattingContext; // packageimport

import dwt.dwthelper.utils;

/**
 * Extension interface for <code>IFormattingStrategy</code>.
 * <p>
 * Updates formatting strategies to be able to receive a more general <code>IFormattingContext</code>
 * object from its associated content formatters.
 * <p>
 * Each formatting process calls the strategy's methods in the following
 * sequence:
 * <ul>
 * <li><code>formatterStarts</code>
 * <li><code>format</code>
 * <li><code>formatterStops</code>
 * </ul>
 * <p>
 * Note that multiple calls to <code>formatterStarts</code> can be issued to
 * a strategy before launching the formatting process with <code>format</code>.
 * <p>
 * This interface must be implemented by clients. Implementers should be
 * registered with a content formatter in order get involved in the formatting
 * process.
 *
 * @see IFormattingContext
 * @since 3.0
 */
public interface IFormattingStrategyExtension {

    /**
     * Formats the region with the properties indicated in the formatting
     * context previously supplied by <code>formatterStarts(IFormattingContext)</code>.
     */
    void format();

    /**
     * Informs the strategy about the start of a formatting process in which it
     * will participate.
     *
     * @param context
     *                  Formatting context used in the corresponding formatting
     *                  process.
     */
    void formatterStarts(IFormattingContext context);

    /**
     * Informs the strategy that the formatting process in which it has
     * participated has been finished.
     */
    void formatterStops();
}
