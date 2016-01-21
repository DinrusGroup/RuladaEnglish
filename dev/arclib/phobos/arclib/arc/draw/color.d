/******************************************************************************* 

    Color type

    Authors:       ArcLib team, see AUTHORS file 
    Maintainer:    Clay Smith (clayasaurus at gmail dot com) 
    License:       zlib/libpng license: $(LICENSE) 
    Copyright:     ArcLib team 
    
    Description:    
		Color type, simplifies color for parameter passing. Note that
		the color values are stored as floats in the 0.0 .. 1.0 range.
		

	Examples:
	--------------------
	import arc.types;

	int main() 
	{
		Color c = Color(255,255,255);
		Color c = Color(255,255,255,255);
		Color c = Color(1.0, 0.5, 0.1);
		Color c = Color.Yellow;

		c.setGlColor(); // equivalent to glColor4f(c.r,c.g,c.b,c.a);

		return 0;
	}
	--------------------

*******************************************************************************/

module arc.draw.color; 

import arc.types;
import derelict.opengl.gl; 
import std.string;

/// holds red, green, blue and alpha values in floating point representation
struct Color
{
	/**
		Constructs a color.
	
		If the type of the arguments is implicitly convertible to ubyte,
		the arguments should be in the 0..255 range and the alpha value
		defaults to 255.
		If it is implicitly convertible to float, the colors range from
		0.0 to 1.0 and the default alpha value is 1.0.
	**/
	static Color opCall(T)(T r, T g, T b, T a = DefaultColorValue!(T))
	{
		Color c;
		
		static if(is(T : ubyte))
		{
			c.r = r / 255.;
			c.g = g / 255.;
			c.b = b / 255.;
			c.a = a / 255.;
		}
		else static if(is(T : float))
		{
			c.r = r;
			c.g = g;
			c.b = b;
			c.a = a;
		}
		else
			static assert(false, "Colors can only be constructed from values implicitly convertible to ubyte or float.");
		
		return c;
	}
	
	/// predefined white color
	const static Color White = {1.,1.,1.};
	/// predefined black color
	const static Color Black = {0.,0.,0.};
	/// predefined red color
	const static Color Red = {1.,0.,0.};
	/// predefined green color
	const static Color Green = {0.,1.,0.};
	/// predefined blue color
	const static Color Blue = {0.,0.,1.};
	/// predefined yellow color
	const static Color Yellow = {1.,1.,0.};

	/// get Red value
	float getR() {return r;}
	
	/// get Green value
	float getG() {return g;}
	
	/// get Blue value 
	float getB() {return b;}
	
	/// set Alpha value
	float getA() {return a;}

	/// set Red value
	void setR(float argV) {r = argV;}
	
	/// set Green value
	void setG(float argV) {g = argV;}
	
	/// set Blue value 
	void setB(float argV) {b = argV;}
	
	/// set Alpha value
	void setA(float argV) {a = argV;}
	
	/// performs the OpenGL call required to set a color
	void setGLColor()
	{
		glColor4f(r, g, b, a);
	}
	
	float cell(int index)
	{
		switch(index)
		{
			case 0:
				return r;
				break; 
			case 1:
				return g;
				break; 
			case 2:
				return b;
				break; 
			case 3:
				return a;
				break; 
			default:
				assert(false, "Error: parameter of Color.cell must be in 0..3, but was " ~ .toString(index)); 
		}
	}
	
	float r=1.0, g=1.0, b=1.0, a=1.0;
	
private:
	// see the constructor for details
	template DefaultColorValue(T)
	{
		static if(is(T : ubyte))
			const T DefaultColorValue = 255;
		else static if(is(T : float))
			const T DefaultColorValue = 1.;
		else
			const T DefaultColorValue = T.init;
	}	
}