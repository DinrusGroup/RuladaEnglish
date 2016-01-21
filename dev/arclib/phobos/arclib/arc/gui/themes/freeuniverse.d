/******************************************************************************* 

    FreeUniverse Theme for the GUI  

    Authors:       ArcLib team, see AUTHORS file 
    Maintainer:    Clay Smith (clayasaurus at gmail dot com) 
    License:       zlib/libpng license: $(LICENSE) 
    Copyright:     ArcLib team 
    
    Description:    
		FreeUniverse Theme for the GUI  


	Examples:
	--------------------
		Not provided.
	--------------------

*******************************************************************************/

module arc.gui.themes.freeuniverse; 

import 
	arc.gui.widgets.types,
	arc.draw.shape,
	arc.draw.color,
	arc.math.point,
	arc.types;
	
import derelict.opengl.gl; 

/// Draw button FreeUniverse Style
void drawFreeUnivereButton(ACTIONTYPE type, bool focus, Point pos, Size size, Color color)
{
	drawBorder(type, focus, pos, size, color);
}

/// Draw label FreeUniverse Style
void drawFreeUnivereLabel(ACTIONTYPE type, bool focus, Point pos, Size size, Color color)
{
	drawBorder(type, focus, pos, size, color);
}

/// Draw textfield FreeUniverse Style
void drawFreeUnivereTextField(ACTIONTYPE type, bool focus, Point pos, Size size, Color color)
{
	drawBorder(type, focus, pos, size, color);
}

/// draw a nice rectangle border
private void drawBorder(ACTIONTYPE type, bool focus, Point pos, Size size, Color color)
{
	if (focus)
	{
		glEnable(GL_LINE_STIPPLE);
		glLineStipple(3, 0xAAAA);
	}

	drawRectangle(pos, size, color, false);
	
	switch(type)
	{
		case ACTIONTYPE.DEFAULT:
			drawRectangle(pos + Point(1,1), size - Size(2,2), Color(0, 50, 0, 150),  true);
		break;

		case ACTIONTYPE.MOUSEOVER:
			drawRectangle(pos + Point(1, 1), size - Size(2, 2), Color(0, 100, 0, 150),  true);
		break; 

		case ACTIONTYPE.CLICKON:
			drawRectangle(pos + Point(1, 1), size - Size(2, 2), Color(0, 150, 0, 150),  true);
		break; 

		case ACTIONTYPE.CLICKOFF:
			drawRectangle(pos + Point(1, 1), size - Size(2, 2), Color(0, 50, 0, 150),  true);
		break; 
	}

	if (focus)
		glDisable(GL_LINE_STIPPLE); 
}