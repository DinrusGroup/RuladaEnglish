/******************************************************************************* 

	Allows user to set the theme style used by Arc's GUI mechanism. 
	
    Authors:       ArcLib team, see AUTHORS file 
    Maintainer:    Clay Smith (clayasaurus at gmail dot com) 
    License:       zlib/libpng license: $(LICENSE) 
    Copyright:     ArcLib team 
    
    Description:    
		Allows user to set the theme style used by Arc's GUI mechanism. 
	Currently only the FreeUniverse theme is supported. 

	Examples:
	--------------------
		import arc.gui.themes.theme; 
		
		// set the theme 
		setTheme(FREEUNIVERSE); 
		
		// return type of theme
		THEME theme = getTheme(); 
	--------------------

*******************************************************************************/

module arc.gui.themes.theme; 

import 
	arc.types,
	arc.draw.color,
	arc.gui.widgets.types,
	arc.gui.themes.freeuniverse;

public  
{
	/// different themes the gui currently supports 
	enum THEME
	{
		FREEUNIVERSE,
		QT,
		WIN32
	}
}

private 
{	
	THEME currTheme; 
}

/// set theme of gui 
void setTheme(THEME theme)
{
	currTheme = theme; 
}

/// get theme of gui 
THEME getTheme()
{
	return currTheme; 
}

/// draw button with current theme
void drawButton(ACTIONTYPE type, bool focus, Point pos, Size size, Color color)
{
	switch(currTheme)
	{
		case THEME.FREEUNIVERSE:
			drawFreeUnivereButton(type,focus,pos,size,color); 
		break;

		case THEME.QT:
		//	drawQTButton(type,x,y,width,height,r,g,b,a); 
		break;

		case THEME.WIN32:
		//	drawWin32Button(type,x,y,width,height,r,g,b,a); 
		break;
	}
}

/// draw label with current theme
void drawLabel(ACTIONTYPE type, bool focus, Point pos, Size size, Color color)
{
	switch(currTheme)
	{
		case THEME.FREEUNIVERSE:
			drawFreeUnivereLabel(type,focus,pos,size,color); 
		break;

		case THEME.QT:
		//	drawQTLabel(type,x,y,width,height,r,g,b,a); 
		break;

		case THEME.WIN32:
		//	drawWin32Label(type,x,y,width,height,r,g,b,a); 
		break;
	}
}

/// draw textfields with current theme
void drawTextField(ACTIONTYPE type, bool focus, Point pos, Size size, Color color)
{
	switch(currTheme)
	{
		case THEME.FREEUNIVERSE:
			drawFreeUnivereTextField(type,focus,pos,size,color); 
		break;

		case THEME.QT:
		//	drawQTTextField(type,x,y,width,height,r,g,b,a); 
		break;

		case THEME.WIN32:
		//	drawWin32TextField(type,x,y,width,height,r,g,b,a); 
		break;
	}
}




