/*******************************************************************************
 * Copyright (c) 2000, 2003 IBM Corporation and others.
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
module dwt.ole.win32.OlePropertyDescription;
import dwt.dwthelper.utils;


public class OlePropertyDescription {
    public int id;
    public String name;
    public int type;
    public int flags;
    public int kind;
    public String description;
    public String helpFile;
}
