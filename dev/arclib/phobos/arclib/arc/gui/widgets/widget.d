/******************************************************************************* 

	The base class for all of the widgets 
	
	Authors:       ArcLib team, see AUTHORS file 
	Maintainer:    Clay Smith (clayasaurus at gmail dot com) 
	License:       zlib/libpng license: $(LICENSE) 
	Copyright:     ArcLib team 
    
    Description:    
		The base class for all of the widgets. This class is not to be used
		by itself. 

	Examples:
	--------------------
		None Provided
	--------------------

*******************************************************************************/

module arc.gui.widgets.widget; 

import 
	std.stream, // fix import conflicts (weird, I know)
	std.signals; 

import 	
	arc.types,
	arc.texture,
	arc.font,
	arc.draw.color,
	arc.sound,
	arc.input,
	arc.log,
	arc.math.collision,
	arc.math.point,
	arc.gui.widgets.types;

public
{
	/// Text align left, center, and right 
	enum TEXTALIGN 
	{
		LEFTCENTER, 
		LEFTUP,
		LEFTDOWN,
		
		RIGHTCENTER,
		RIGHTUP,
		RIGHTDOWN, 
		
		CENTER, 
		CENTERUP, 
		CENTERDOWN
	}
}

/// Widget class, base class for all of the widgets 
class Widget
{
  public:
	this()
	{
	}

	/// set name of the widget 
	void setSize(Size argSize)
	{
		size = argSize;
	}

	/// set width of widget
	void setWidth(arcfl argW)
	{
		size.w = argW; 
	}

	/// set height of widget
	void setHeight(arcfl argH)
	{
		size.h = argH; 
	}

	/// set parent position of sprite 
	void setPosition(Point argPos)
	{
		position = argPos;
	}

	/// set color of the widget 
	void setColor(Color acolor)
	{
		color = acolor;
	}

	/// process widget 
	void process(Point parentPos = Point(0,0))
	{
		bool mOver = mouseOver(parentPos); 

		action = ACTIONTYPE.DEFAULT;
	
		if (mOver && arc.input.mouseButtonDown(LEFT))
		{
			action = ACTIONTYPE.CLICKON;

			if (arc.input.mouseButtonPressed(LEFT))
			{
				clicked.emit();
				focus = true; 
			}
		}
		else if (arc.input.mouseButtonDown(LEFT))
		{
			action = ACTIONTYPE.CLICKOFF;

			if (arc.input.mouseButtonPressed(LEFT))
			{
				focus = false; 
			}
		}
		else if (mOver)
		{
			action = ACTIONTYPE.MOUSEOVER; 
		}
	}

	/// get width 
	arcfl getWidth() {  return size.w; }

	/// get height 
	arcfl getHeight() { return size.h; } 
	
	/// get size
	Size getSize() { return size; }

	/// get x position 
	arcfl getX() { return position.x; }

	/// get Y position 
	arcfl getY() { return position.y; }
	
	/// get position
	Point getPosition() { return position; }

	/// return true if mouse is over widget 
	bool mouseOver(Point parentPos) 
	{ 
		return boxXYCollision(	arc.input.mousePos, 
								position + parentPos, size); 
	} 

	/// set color of font 
	void setFontColor(Color afontColor)
	{
		fontColor = afontColor;
	}

	/// set text values
	void setText(char[] argText)
	{
		text = argText; 
	}

	/// set font value 
	void setFont(Font argFont)
	{
		font = argFont; 
		fontAlign = getAlignment; 
	}

	/// draw image from position + parent position  
	void draw(Point parentPos = Point(0,0))
	{
		assert(0); 
	}

	/// set maximum amount of lines 
	void setMaxLines(uint argLines)
	{
		assert(0); 
	}

	/// set maximum width  
	void setMaxWidth(uint maxWidth)
	{
		assert(0); 
	}

	/// return focus 
	bool getFocus() { return focus; }

	/// set alignment of text
	void setTextAlign(TEXTALIGN aText)
	{
		alignment = aText; 
		fontAlign = getAlignment(); 
	}
	
	/// get text inside of widget
	char[] getText() { return text; }
	
	/// mixin signals for handling GUI events 
	mixin Signal!() clicked;

  private:
	// get alignment 	
	Point getAlignment()
	{
		Point drawFontPos;
		
		switch(alignment)
		{
			case TEXTALIGN.LEFTCENTER: 
			drawFontPos = position;
			drawFontPos.y += size.h/2 - font.getLineSkip/2; 
			break; 
			
			case TEXTALIGN.LEFTUP: 
			drawFontPos = position;
			break; 
			
			case TEXTALIGN.LEFTDOWN: 
			drawFontPos = position;
			drawFontPos.y += size.h - font.getLineSkip; 
			break; 
			
			case TEXTALIGN.RIGHTCENTER: 
			drawFontPos = position;
			drawFontPos.y += size.h/2 - font.getLineSkip/2;
			drawFontPos.x += size.w - font.getWidth(text); 			
			break;

			case TEXTALIGN.RIGHTUP: 
			drawFontPos = position;
			drawFontPos.x += size.w - font.getWidth(text); 			
			break;

			case TEXTALIGN.RIGHTDOWN: 
			drawFontPos = position;
			drawFontPos.y += size.h - font.getLineSkip;
			drawFontPos.x += size.w - font.getWidth(text); 			
			break;
			
			case TEXTALIGN.CENTER: 
			drawFontPos = position + size/2 - Point(font.getWidth(text), font.getLineSkip)/2;
			break; 
			
			case TEXTALIGN.CENTERUP: 
			drawFontPos = position;
			drawFontPos.x += size.w/2 - font.getWidth(text)/2;
			break; 
			
			case TEXTALIGN.CENTERDOWN: 
			drawFontPos = position;
			drawFontPos.x += size.w/2 - font.getWidth(text)/2;
			drawFontPos.y += size.h - font.getLineSkip;
			break; 
		}

		return drawFontPos; 
	}
	
  protected:
  
	// will hold the position relative to the layout
	Point position;
	Size size;

	// color values 
	Color color;

	// font color values 
	Color fontColor; 

	// font text and alignment 
	char[] text; 
	TEXTALIGN alignment = TEXTALIGN.CENTER; 

	// font 
	Font font; 
	Point fontAlign; 

	// focus value 
	bool focus=false;

	// info signal will emit
	ACTIONTYPE action;  
}

