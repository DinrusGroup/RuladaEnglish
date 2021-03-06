﻿module dgui.resources;

public import dgui.core.winapi;
public import dgui.core.geometry;
public import dgui.canvas;
public import std.string;

final class Resources
{
	private static Resources _rsrc;
	
	private this()
	{
		
	}	

	public Icon getIcon(ushort id)
	{
		return getIcon(id, NullSize);
	}
	
	public Icon getIcon(ushort id, Size sz)
	{
		HICON hIcon = LoadImageA(getHInstance(), cast(char*)id, IMAGE_ICON, sz.width, sz.height, LR_LOADTRANSPARENT | (sz == NullSize ? LR_DEFAULTSIZE : 0));

		if(!hIcon)
		{
			debug
			{
				throw new Win32Exception(format("Cannot load Icon: '%d'", id), __FILE__, __LINE__);
			}
			else
			{
				throw new Win32Exception(format("Cannot load Icon: '%d'", id));
			}
		}
		
		return Icon.fromHICON(hIcon);
	}

	public Bitmap getBitmap(ushort id)
	{
		HBITMAP hBitmap = LoadImageA(getHInstance(), cast(char*)id, IMAGE_BITMAP, 0, 0, LR_LOADTRANSPARENT | LR_DEFAULTSIZE);

		if(!hBitmap)
		{
			debug
			{
				throw new GdiException(format("Cannot load Bitmap: '%d'", id), __FILE__, __LINE__);
			}
			else
			{
				throw new GdiException(format("Cannot load Bitmap: '%d'", id));
			}
		}

		return Bitmap.fromHBITMAP(hBitmap);
	}

	public T* getRaw(T)(ushort id, char* rt)
	{
		HRSRC hRsrc = FindResourceA(null, MAKEINTRESOURCEA(id), rt);

		if(!hRsrc)
		{
			debug
			{
				throw new GdiException(format("Cannot load Custom Resource: '%d'", id), __FILE__, __LINE__);
			}
			else
			{
				throw new GdiException(format("Cannot load Custom Resource: '%d'", id));
			}
		}

		return cast(T*)LockResource(LoadResource(null, hRsrc));
	}

	public static Resources instance()
	{
		if(!_rsrc)
		{
			_rsrc = new Resources();
		}

		return _rsrc;
	}
}