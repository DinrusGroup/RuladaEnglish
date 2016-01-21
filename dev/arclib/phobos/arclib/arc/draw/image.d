/******************************************************************************* 

    Allows drawing of images

    Authors:       ArcLib team, see AUTHORS file 
    Maintainer:    Clay Smith (clayasaurus at gmail dot com) 
    License:       zlib/libpng license: $(LICENSE) 
    Copyright:     ArcLib team 
    
    Description:    
		Code that will allow different ways to render an image with arc. 

	Examples:
	--------------------
	import arc.types;

	int main() 
	{
		Texture t = Texture("texture.png"); 
		
		Point pos, pivot;
		Size size;
		Color color; 
		arcfl angle; 
	
		while (gameloop)
		{
			drawImage(t, pos, size, color, pivot, angle);
		}

		return 0;
	}
	--------------------

*******************************************************************************/

module arc.draw.image; 

import
	arc.types,
	arc.texture,
	arc.draw.color,
	arc.math.point,
	arc.math.angle;

import derelict.opengl.gl; 

/// simply draw image to screen with given image ID from the center with pivot points 
void drawImage(Texture texture,
				Point pos, Size size = Size(float.nan,float.nan), 
				Point pivot = Point(0,0),
				Radians angle = 0,
				Color color = Color.White)
{
	// if no size is specified, use texture size
	if(isnan(size.w) && isnan(size.h))
		size = texture.getSize();
	
	// center calculations
	arcfl halfWidth = size.w/2;
	arcfl halfHeight = size.h/2;
	
	arcfl texw = (texture.getSize.w / texture.getTextureSize.w);
	arcfl texh = (texture.getSize.h / texture.getTextureSize.h);
	
	// enable 2d textures and bind texture
	glEnable(GL_TEXTURE_2D);
	
	// bind texture ID to this tex
	glBindTexture(GL_TEXTURE_2D, texture.getID);  

	// set color to one given
	color.setGLColor(); 
      
	glPushMatrix();

	// rotate and translate
	glTranslatef(pos.x,pos.y,0);
	glRotatef(radiansToDegrees(angle), 0, 0, 1);

	// draw image at given coords, binding texture appropriately   
	glBegin(GL_QUADS);
	  
	// -halfWidth and -halfHeight act as ancors to rotate from the center
	glTexCoord2d(0,0); glVertex2f(-halfWidth + pivot.x, -halfHeight + pivot.y); 
      
	glTexCoord2d(0,texh); glVertex2f(	-halfWidth + pivot.x, 
									-halfHeight + size.h + pivot.y);
      
	glTexCoord2d(texw,texh); glVertex2f(	-halfWidth + size.w + pivot.x, 
									-halfHeight + size.h + pivot.y);
      
	glTexCoord2d(texw,0); glVertex2f(	-halfWidth + size.w + pivot.x, 
									-halfHeight + pivot.y);     
      
	glEnd(); 

	glPopMatrix();
}


/// draw image from the top left location 
void drawImageTopLeft(Texture texture, Point pos, Size size = Size(float.nan,float.nan), Color color = Color.White)
{
	// if no size is specified, use texture size
	if(isnan(size.w) && isnan(size.h))
		size = texture.getSize();
	
	// enable 2d textures and bind texture
	glEnable(GL_TEXTURE_2D);
	
	// bind texture ID to this tex
	glBindTexture(GL_TEXTURE_2D, texture.getID);  

	// set color to one given
	color.setGLColor(); 
      
	glPushMatrix();

	// rotate and translate
	glTranslatef(pos.x,pos.y,0);

	arcfl texw = texture.getSize.w / texture.getTextureSize.w;
	arcfl texh = texture.getSize.h / texture.getTextureSize.h;
	
	// draw image at given coords, binding texture appropriately   
	glBegin(GL_QUADS);
	  
	// -halfWidth and -halfHeight act as ancors to rotate from the center
	glTexCoord2d(0,0); glVertex2f(0 , 0); 
      
	glTexCoord2d(0,texh); glVertex2f(0, size.h);
      
	glTexCoord2d(texw,texh); glVertex2f(size.w , size.h);
      
	glTexCoord2d(texw,0); glVertex2f(size.w , 0);     
      
	glEnd(); 

	glPopMatrix();
}

/// draw a subsection of an image with the top-left at 0,0
void drawImageSubsection(Texture texture, Point topLeft, Point rightBottom, Color color = Color.White)
{
	// enable 2d textures and bind texture
	glEnable(GL_TEXTURE_2D);
	
	// bind texture ID to this tex
	glBindTexture(GL_TEXTURE_2D, texture.getID);

	// set color
	color.setGLColor(); 
      
	// draw image at given coords, binding texture appropriately   
	glBegin(GL_QUADS);
	
	arcfl width = texture.getTextureSize.w;
	arcfl height = texture.getTextureSize.h;
	
	arcfl 
		tLeft = topLeft.x / width,
		tTop = topLeft.y / height,
		tRight = rightBottom.x / width,
		tBottom = rightBottom.y / height;
	
	glTexCoord2d(tLeft, tTop); 
	glVertex2f(0, 0); 
      
	glTexCoord2d(tLeft, tBottom); 
	glVertex2f(0, rightBottom.y - topLeft.y);
      
	glTexCoord2d(tRight, tBottom); 
	glVertex2f(rightBottom.x - topLeft.x , rightBottom.y - topLeft.y);
      
	glTexCoord2d(tRight, tTop); 
	glVertex2f(rightBottom.x - topLeft.x , 0);     
      
	glEnd(); 
}
