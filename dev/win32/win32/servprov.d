﻿/***********************************************************************\
*                               servprov.d                              *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*             Translated from MinGW API for MS-Windows 3.10             *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module os.win32.servprov;

private import os.win32.basetyps, os.win32.unknwn, os.win32.windef, os.win32.wtypes;

interface IServiceProvider : public IUnknown {
	HRESULT QueryService(REFGUID, REFIID, void**);
}
