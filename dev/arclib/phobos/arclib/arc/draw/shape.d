/******************************************************************************* 

    Drawing of different primitive shapes 

    Authors:       ArcLib team, see AUTHORS file 
    Maintainer:    Clay Smith (clayasaurus at gmail dot com) 
    License:       zlib/libpng license: $(LICENSE) 
    Copyright:     ArcLib team 
    
    Description:    
		drawPixel, drawLine, drawCircle, drawRectangle
		Different functions for drawing of primitive shapes. 

	Examples:
	--------------------
	import arc.types;

	int main() 
	{
		while (gameloop)
		{
			drawPixel(point, color);
			drawLine(line1, line2, color);
			drawCirlce(point, radius, detail, color, fill); 
			drawRectangle(pos, size, color, fill);
		}

		return 0;
	}
	--------------------

*******************************************************************************/

module arc.draw.shape; 

import 
	arc.types,
	arc.draw.color,
	arc.math.angle,
	arc.math.point; 
	
import std.math; 

import derelict.opengl.gl; 

/// draw pixel at position and color
void drawPixel(Point pos, Color color)
{
	// disable gl textures
	glDisable(GL_TEXTURE_2D);

	// set color to one given
	color.setGLColor(); 

	// make sure the line width is only 1 pixel wide
	glLineWidth(1);

	// draw line
	glBegin(GL_LINE_LOOP);

	glVertex2f(pos.x, pos.y);
	glVertex2f(pos.x+1, pos.y); 

	glEnd();
}

/// draw line with color
void drawLine(	Point pos1, Point pos2, Color color )
{
	// disable gl textures
	glDisable(GL_TEXTURE_2D);

	// set color to one given
	color.setGLColor(); 

	// draw line
	glBegin(GL_LINE_LOOP);

	glVertex2f(pos1.x, pos1.y);
	glVertex2f(pos2.x, pos2.y); 

	glEnd();
}

/// draw circle at position, size (radius), detail (vertex's), and color
void drawCircle(Point pos, arcfl radius, int detail, Color color, bool fill)
{
	// primitives can only be drawn once textures are disabled
	glDisable(GL_TEXTURE_2D); 

	// set color to one given
	color.setGLColor(); 

	// we will be drawing lines
	if (fill)
	{
		glBegin(GL_POLYGON);
	}
	else
	{		
		glBegin(GL_LINE_LOOP);
	}

	arcfl px, py; 

	for (arcfl i = 0; i < 360; i+= 360.0/detail)
	{
		// create polar coordinate
		px = radius;
		py = i; 

		// translate it to rectangular
		py = degreesToRadians(py); // convert degrees to radian
   
		arcfl x_save = px;
   
		px = x_save * cos(py); // i know, polar->y is used too much, but i'd like to eliminate the need
		py = x_save * sin(py); // for too many variables

		// and draw it
		glVertex2f(pos.x+px, pos.y+py);
      }
      
	glEnd(); 
}

/// draw rectange with given position, size, and color
void drawRectangle(Point pos, Size size, Color color, bool fill)
{
	// disable images
	glDisable(GL_TEXTURE_2D); 

	// set color to one given
	color.setGLColor(); 
	
	// draw a box line of border
	if (fill)
	{
		glBegin(GL_POLYGON);
	}
	else
	{
		glBegin(GL_LINE_LOOP);
   	// make sure the line width is only 1 pixel wide
		glLineWidth(1);
	}     

	// draw box to the screen
	glVertex2f(pos.x+size.w, pos.y); 
      
	glVertex2f(pos.x+size.w, pos.y+size.h);
      
	glVertex2f(pos.x, pos.y + size.h);
      
	glVertex2f(pos.x, pos.y);     
      
	glEnd(); 
}

/// draw polygon
void drawPolygon(Point[] polygon, Color color, bool fill)
{
	// disable images
	glDisable(GL_TEXTURE_2D); 

	// set color to one given
	color.setGLColor(); 
      
	// draw a box line of border
	if (fill)
	{
		glBegin(GL_POLYGON);
	}
	else
	{
		glBegin(GL_LINE_LOOP);
		glLineWidth(1);
	}     

	foreach(Point p; polygon)
		glVertex2f(p.x, p.y);
	
	glEnd(); 
}