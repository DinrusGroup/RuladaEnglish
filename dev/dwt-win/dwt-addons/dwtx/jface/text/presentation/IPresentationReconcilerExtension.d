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
module dwtx.jface.text.presentation.IPresentationReconcilerExtension;

import dwtx.jface.text.presentation.IPresentationDamager; // packageimport
import dwtx.jface.text.presentation.IPresentationReconciler; // packageimport
import dwtx.jface.text.presentation.PresentationReconciler; // packageimport
import dwtx.jface.text.presentation.IPresentationRepairer; // packageimport


import dwt.dwthelper.utils;

/**
 * Extension interface for {@link IPresentationReconciler}. Adds awareness of
 * documents with multiple partitions.
 *
 * @since 3.0
 */
public interface IPresentationReconcilerExtension {

    /**
     * Returns the document partitioning this presentation reconciler is using.
     *
     * @return the document partitioning this presentation reconciler is using
     */
    String getDocumentPartitioning();
}