/***********************************************************************\
*                               isguids.d                               *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*             Translated from MinGW API for MS-Windows 3.10             *
*                           by Stewart Gordon                           *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module os.win32.isguids;

private import os.win32.basetyps;

extern (C) extern const GUID
	CLSID_InternetShortcut,
	IID_IUniformResourceLocator;
