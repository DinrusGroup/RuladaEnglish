/*******************************************************************************
 * Copyright (c) 2008 IBM Corporation and others.
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
module dwtx.jface.text.hyperlink.IHyperlinkPresenterExtension;

import dwtx.jface.text.hyperlink.MultipleHyperlinkPresenter; // packageimport
import dwtx.jface.text.hyperlink.HyperlinkManager; // packageimport
import dwtx.jface.text.hyperlink.URLHyperlink; // packageimport
import dwtx.jface.text.hyperlink.IHyperlinkDetectorExtension2; // packageimport
import dwtx.jface.text.hyperlink.IHyperlinkDetector; // packageimport
import dwtx.jface.text.hyperlink.IHyperlinkPresenter; // packageimport
import dwtx.jface.text.hyperlink.URLHyperlinkDetector; // packageimport
import dwtx.jface.text.hyperlink.DefaultHyperlinkPresenter; // packageimport
import dwtx.jface.text.hyperlink.AbstractHyperlinkDetector; // packageimport
import dwtx.jface.text.hyperlink.IHyperlinkDetectorExtension; // packageimport
import dwtx.jface.text.hyperlink.HyperlinkMessages; // packageimport
import dwtx.jface.text.hyperlink.IHyperlink; // packageimport


import dwt.dwthelper.utils;


/**
 * Extends {@link IHyperlinkPresenter} with ability
 * to query whether the currently shown hyperlinks
 * can be hidden.
 * <p>
 * Clients may implement this interface.
 * </p>
 * 
 * @since 3.4
 */
public interface IHyperlinkPresenterExtension {

    /**
     * Tells whether the currently shown hyperlinks
     * can be hidden.
     * 
     * @return <code>true</code> if the hyperlink manager can hide the current hyperlinks
     */
    bool canHideHyperlinks();

}
