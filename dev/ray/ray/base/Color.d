/**
	Copyright: Copyright (c) 2007, Artyom Shalkhakov. All rights reserved.
	License: BSD

	Structures to represent colors.

	FIXME: byte-order selection should be done in compile-time.

	Version: Aug 2007: initial release
	Authors: Artyom Shalkhakov
*/
module auxd.ray.base.Color;

import Math = auxd.ray.base.Math;

/// byte-order conventions (for uint conversion)
enum BYTEORDER {
	ARGB8,
	ABGR8,
	RGBA8,
	BGRA8
}

const {
	Col3	col3_zero		= { r : 0.0f, g : 0.0f, b : 0.0f };
	Col3	col3_identity	= { r : 1.0f, g : 1.0f, b : 1.0f };
	Col4	col4_zero		= { r : 0.0f, g : 0.0f, b : 0.0f, a : 0.0f };
	Col4	col4_identity	= { r : 1.0f, g : 1.0f, b : 1.0f, a : 1.0f };
}

/**
	This structure represents RGB color. Red, green and blue components are stored in RGB order.
	Note that alpha component is assumed to be 1.0f.
	The color components can be accessed in array style, e.g.:

	---
		Col3	ambient;
		float	red;

		ambient.set( 0.5f, 1.0f, 0.0f );
		red = ambient[0];					// red contains 0.5f now
	---

	Basic operations (addition, subtraction, multiplication) are supported.

	---
		Col3	a, b, c;

		a.set( 1.0f, 0.0f, 0.4f );
		b.set( 0.0f, 1.0f, 0.5f );

		c = a + b;							// c is ( 1.0f, 1.0f, 0.9f )
		c = a * b;							// c is ( 0.0f, 0.0f, 0.2f )
	---
*/
struct Col3 {
	static Col3 opCall( float r, float g, float b ) {
		Col3	dst;

		dst.r = r;
		dst.g = g;
		dst.b = b;

		return dst;
	}

	static Col3 opCall( float[3] rgb ) {
		Col3	dst;

		dst.r = rgb[0];
		dst.g = rgb[1];
		dst.b = rgb[2];

		return dst;
	}

	Col3 opCall( uint rgb, BYTEORDER order = BYTEORDER.RGBA8 ) {
		Col3	dst;
	
		// unpack according to byte-order
		switch ( order ) {
		case BYTEORDER.ARGB8:
			dst.r = ( cast( ubyte * )&rgb )[1] * ( 1.0f / 255.0f );
			dst.g = ( cast( ubyte * )&rgb )[2] * ( 1.0f / 255.0f );
			dst.b = ( cast( ubyte * )&rgb )[3] * ( 1.0f / 255.0f );
			break;
		case BYTEORDER.ABGR8:
			dst.b = ( cast( ubyte * )&rgb )[1] * ( 1.0f / 255.0f );
			dst.g = ( cast( ubyte * )&rgb )[2] * ( 1.0f / 255.0f );
			dst.r = ( cast( ubyte * )&rgb )[3] * ( 1.0f / 255.0f );
			break;
		case BYTEORDER.RGBA8:
			dst.r = ( cast( ubyte * )&rgb )[0] * ( 1.0f / 255.0f );
			dst.g = ( cast( ubyte * )&rgb )[1] * ( 1.0f / 255.0f );
			dst.b = ( cast( ubyte * )&rgb )[2] * ( 1.0f / 255.0f );
			break;
		case BYTEORDER.BGRA8:
			dst.b = ( cast( ubyte * )&rgb )[0] * ( 1.0f / 255.0f );
			dst.g = ( cast( ubyte * )&rgb )[1] * ( 1.0f / 255.0f );
			dst.r = ( cast( ubyte * )&rgb )[2] * ( 1.0f / 255.0f );
			break;
		}
	
		return dst;
	}

	float opIndex( size_t index )
	in {
		assert( index >= 0 && index < 3 );
	}
	body {
		return ( &r )[index];
	}

	float opIndexAssign( size_t index, float f )
	in {
		assert( index >= 0 && index < 3 );
	}
	body {
		return ( &r )[index] = f;
	}

	Col3 opNeg() {
		return Col3( -r, -g, -b );
	}

	Col3 opAdd( ref Col3 c ) {
		return Col3( r + c.r, g + c.g, b + c.b );
	}

	Col3 opSub( ref Col3 c ) {
		return Col3( r - c.r, g - c.g, b - c.b );
	}

	Col3 opMul( float f )
	in {
		debug ( FLOAT_PARANOID ) {
			assert( Math.isValid( f ) );
		}
	}
	body {
		return Col3( r * f, g * f, b * f );
	}

	Col3 opMul( ref Col3 c ) {
		return Col3( r * c.r, g * c.g, b * c.b );
	}

	Col3 opDiv( float f )
	in {
		debug ( FLOAT_PARANOID ) {
			assert( Math.isValid( f ) );
			assert( Math.abs( f - 0.0f ) > 1e-14 );
		}
	}
	body {
		float	invF = 1.0f / f;

		return Col3( r * invF, g * invF, b * invF );
	}

	void opAddAssign( ref Col3 c ) {
		r += c.r;
		g += c.g;
		b += c.b;
	}

	void opSubAssign( ref Col3 c ) {
		r -= c.r;
		g -= c.g;
		b -= c.b;
	}

	void opMulAssign( float f ) {
		r *= f;
		g *= f;
		b *= f;
	}

	void opMulAssign( ref Col3 c ) {
		r *= c.r;
		g *= c.g;
		b *= c.b;
	}

	void opDivAssign( float f ) {
		float	invF = 1.0f / f;

		r *= invF;
		g *= invF;
		b *= invF;
	}

	/// make _zero (black) color
	void zero() {
		*this = col3_zero;
	}

	/// make _identity (white) color
	void identity() {
		*this = col3_identity;
	}

	/// set the new values for components
	void set( float r, float g, float b ) {
		this.r = r;
		this.g = g;
		this.b = b;
	}

	/// clamp the color components to [0,1] range (inclusive)
	void clampSelf() {
		r = Math.clampBiased( r );
		g = Math.clampBiased( g );
		b = Math.clampBiased( b );
	}

	/// _normalize the color, so it's components are in [0,1] range
	void normalize() {
		float	max, scale;

		// catch negative colors
		if ( r < 0.0f ) {
			r = 0.0f;
		}
		if ( g < 0.0f ) {
			g = 0.0f;
		}
		if ( b < 0.0f ) {
			b = 0.0f;
		}

		// determine the brightest of the three color components
		max = r;
		if ( g > max ) {
			max = g;
		}
		if ( b > max ) {
			max = b;
		}

		// rescale all color components if the intensity of the greatest
		// channel exceeds 1.0f
		if ( max > 1.0f ) {
			scale = 1.0f / max;

			r *= scale;
			g *= scale;
			b *= scale;
		}
	}

	/// linearly interpolates color from c1 to c2 by fraction f
	void lerpSelf( ref Col3 c1, Col3 c2, float f ) {
		if ( f <= 0.0f ) {
			*this = c1;
		}
		else if ( f >= 1.0f ) {
			*this = c2;
		}
		else {
			*this = c1 + f * ( c2 - c1 );
		}
	}

	/// returns color linearly interpolated from this to c2 by fraction f
	Col3 lerp( ref Col3 c2, float f ) {
		if ( f <= 0.0f ) {
			return *this;
		}
		else if ( f >= 1.0f ) {
			return c2;
		}
		return ( *this ) + f * ( c2 - ( *this ) );
	}

	/// converts to RGBA color; alpha is assumed to be 1.0f
	Col4 toCol4() {
		return Col4( r, g, b, 1.0f );
	}

	/// returns hash-code for color
	size_t toHash() {
		size_t	red = *cast( size_t * )&r;
		size_t	green = *cast( size_t * )&g;
		size_t	blue = *cast( size_t * )&b;

		return red + ( green * 37 ) + ( blue * 101 );
	}

	/// packs RGB values into uint variable, alpha is assumed to be 1.0f
	uint toUint( BYTEORDER order = BYTEORDER.RGBA8 )
	in {
		assert( r >= 0 && r <= 1.0f );
		assert( g >= 0 && g <= 1.0f );
		assert( b >= 0 && b <= 1.0f );
	}
	body {
		uint	dst;

		// pack according to byte-order
		switch ( order ) {
		case BYTEORDER.ARGB8:
			( cast( ubyte * )&dst )[1] = cast( ubyte )Math.ftoiFast( r * 255.0f );
			( cast( ubyte * )&dst )[2] = cast( ubyte )Math.ftoiFast( g * 255.0f );
			( cast( ubyte * )&dst )[3] = cast( ubyte )Math.ftoiFast( b * 255.0f );
			break;
		case BYTEORDER.ABGR8:
			( cast( ubyte * )&dst )[1] = cast( ubyte )Math.ftoiFast( b * 255.0f );
			( cast( ubyte * )&dst )[2] = cast( ubyte )Math.ftoiFast( g * 255.0f );
			( cast( ubyte * )&dst )[3] = cast( ubyte )Math.ftoiFast( r * 255.0f );
			break;
		case BYTEORDER.RGBA8:
			( cast( ubyte * )&dst )[0] = cast( ubyte )Math.ftoiFast( r * 255.0f );
			( cast( ubyte * )&dst )[1] = cast( ubyte )Math.ftoiFast( g * 255.0f );
			( cast( ubyte * )&dst )[2] = cast( ubyte )Math.ftoiFast( b * 255.0f );
			break;
		case BYTEORDER.BGRA8:
			( cast( ubyte * )&dst )[0] = cast( ubyte )Math.ftoiFast( b * 255.0f );
			( cast( ubyte * )&dst )[1] = cast( ubyte )Math.ftoiFast( g * 255.0f );
			( cast( ubyte * )&dst )[2] = cast( ubyte )Math.ftoiFast( r * 255.0f );
			break;
		}
		( cast( ubyte * )&dst )[3] = 0xFF;

		return dst;
	}

	/// returns string, just a convenience function
	char[] toUtf8() {
		return Math.toUtf8( "( r:{0:E} g:{1:E} b:{2:E} )", r, g, b );
	}

	/// returns the number of components
	size_t length() {
		return 3;
	}

	/// returns raw pointer
	float *ptr() {
		return &r;
	}

	debug ( FLOAT_PARANOID ) {
		invariant() {
			assert( Math.isValid( r ) );
			assert( Math.isValid( g ) );
			assert( Math.isValid( b ) );
		}
	}

	float	r, g, b;		/// color components: red, green and blue
}

/**
	This structure represents RGBA color. Red, green, blue and alpha components are stored in RGB order.
	The color components can be accessed in array style, e.g.:

	---
		Col4	ambient;
		float	red;

		ambient.set( 0.5f, 1.0f, 0.0f, 1.0f );
		red = ambient[0];					// red contains 0.5f now
	---

	Basic operations (addition, subtraction, multiplication) are supported.

	---
		Col4	a, b, c;

		a.set( 1.0f, 0.0f, 0.4f );
		b.set( 0.0f, 1.0f, 0.5f );

		c = a + b;							// c is ( 1.0f, 1.0f, 0.9f )
		c = a * b;							// c is ( 0.0f, 0.0f, 0.2f )
	---
*/
struct Col4 {
	static Col4 opCall( float r, float g, float b, float a ) {
		Col4	dst;

		dst.r = r;
		dst.g = g;
		dst.b = b;
		dst.a = 1.0f;

		return dst;
	}

	static Col4 opCall( ref Col3 rgb, float a ) {
		Col4	dst;

		dst.r = rgb.r;
		dst.g = rgb.g;
		dst.b = rgb.b;
		dst.a = a;

		return dst;
	}

	static Col4 opCall( float[4] rgba ) {
		Col4	dst;

		dst.r = rgba[0];
		dst.g = rgba[1];
		dst.b = rgba[2];
		dst.a = rgba[3];

		return dst;
	}

	static Col4 opCall( uint rgba, BYTEORDER order = BYTEORDER.RGBA8 ) {
		Col4	dst;

		// unpack according to byte-order
		switch ( order ) {
		case BYTEORDER.ARGB8:
			dst.a = ( cast( ubyte * )&rgba )[0] * ( 1.0f / 255.0f );
			dst.r = ( cast( ubyte * )&rgba )[1] * ( 1.0f / 255.0f );
			dst.g = ( cast( ubyte * )&rgba )[2] * ( 1.0f / 255.0f );
			dst.b = ( cast( ubyte * )&rgba )[3] * ( 1.0f / 255.0f );
			break;
		case BYTEORDER.ABGR8:
			dst.a = ( cast( ubyte * )&rgba )[0] * ( 1.0f / 255.0f );
			dst.b = ( cast( ubyte * )&rgba )[1] * ( 1.0f / 255.0f );
			dst.g = ( cast( ubyte * )&rgba )[2] * ( 1.0f / 255.0f );
			dst.r = ( cast( ubyte * )&rgba )[3] * ( 1.0f / 255.0f );
			break;
		case BYTEORDER.RGBA8:
			dst.r = ( cast( ubyte * )&rgba )[0] * ( 1.0f / 255.0f );
			dst.g = ( cast( ubyte * )&rgba )[1] * ( 1.0f / 255.0f );
			dst.b = ( cast( ubyte * )&rgba )[2] * ( 1.0f / 255.0f );
			dst.a = ( cast( ubyte * )&rgba )[3] * ( 1.0f / 255.0f );
			break;
		case BYTEORDER.BGRA8:
			dst.b = ( cast( ubyte * )&rgba )[0] * ( 1.0f / 255.0f );
			dst.g = ( cast( ubyte * )&rgba )[1] * ( 1.0f / 255.0f );
			dst.r = ( cast( ubyte * )&rgba )[2] * ( 1.0f / 255.0f );
			dst.a = ( cast( ubyte * )&rgba )[3] * ( 1.0f / 255.0f );
			break;
		}

		return dst;
	}

	float opIndex( size_t index )
	in {
		assert( index >= 0 && index < 4 );
	}
	body {
		return ( &r )[index];
	}

	float opIndexAssign( float f, size_t index )
	in {
		assert( index >= 0 && index < 4 );
	}
	body {
		return ( &r )[index] = f;
	}

	Col4 opAdd( ref Col4 c ) {
		return Col4( r + c.r, g + c.g, b + c.b, a + c.a );
	}

	Col4 opSub( ref Col4 c ) {
		return Col4( r - c.r, g - c.g, b - c.b, a - c.a );
	}

	Col4 opMul( float f )
	in {
		debug ( FLOAT_PARANOID ) {
			assert( Math.isValid( f ) );
		}
	}
	body {
		return Col4( r * f, g * f, b * f, a * f );
	}

	Col4 opMul( Col4 c ) {
		return Col4( r * c.r, g * c.g, b * c.b, a * c.a );
	}

	Col4 opDiv( float f )
	in {
		debug ( FLOAT_PARANOID ) {
			assert( Math.isValid( f ) );
			assert( Math.abs( f - 0.0f ) > 1e-14 );
		}
	}
	body {
		float	invF = 1.0f / f;

		return Col4( r * invF, g * invF, b * invF, a * invF );
	}

	void opAddAssign( Col4 c ) {
		r += c.r;
		g += c.g;
		b += c.b;
		a += c.a;
	}

	void opSubAssign( Col4 c ) {
		r -= c.r;
		g -= c.g;
		b -= c.b;
		a -= c.a;
	}

	void opMulAssign( float f ) {
		r *= f;
		g *= f;
		b *= f;
		a *= f;
	}

	void opMulAssign( Col4 c ) {
		r *= c.r;
		g *= c.g;
		b *= c.b;
		a *= c.a;
	}

	void opDivAssign( float f ) {
		float	invF = 1.0f / f;

		r *= invF;
		g *= invF;
		b *= invF;
		a *= invF;
	}

	/// make _zero (black) color
	void zero() {
		*this = col4_zero;
	}

	/// make _identity (white) color
	void identity() {
		*this = col4_identity;
	}

	/// functions for setting new value of color components
	void set( float r, float g, float b, float a ) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	/// ditto
	void set( float r, float g, float b ) {
		this.r = r;
		this.g = g;
		this.b = b;
	}

	/// ditto
	void set( float a ) {
		this.a = a;
	}

	/// ditto
	void set( ref Col3 rgb ) {
		this.r = rgb.r;
		this.g = rgb.b;
		this.b = rgb.b;
	}

	/// ditto
	void set( Col3 rgb, float a ) {
		this.r = rgb.r;
		this.g = rgb.g;
		this.b = rgb.b;
		this.a = a;
	}

	/// clamp the color components to [0,1] range (inclusive)
	void clampSelf() {
		r = Math.clampBiased( r );
		g = Math.clampBiased( g );
		b = Math.clampBiased( b );
		a = Math.clampBiased( a );
	}

	/**
		Normalize the color, so it's components are in [0,1] range.
		Alpha is only clamped to [0,1] range.
	*/
	void normalize() {
		float	max, scale;

		// catch negative colors
		if ( r < 0.0f ) {
			r = 0.0f;
		}
		if ( g < 0.0f ) {
			g = 0.0f;
		}
		if ( b < 0.0f ) {
			b = 0.0f;
		}

		// determine the brightest of the three color components
		max = r;
		if ( g > max ) {
			max = g;
		}
		if ( b > max ) {
			max = b;
		}

		// rescale all color components if the intensity of the greatest
		// channel exceeds 1.0f
		if ( max > 1.0f ) {
			scale = 1.0f / max;
			r *= scale;
			g *= scale;
			b *= scale;
		}

		// clamp the alpha component
		a = Math.clampBiased( a );
	}

	/// linearly interpolates color from c1 to c2 by fraction f
	void lerpSelf( ref Col4 c1, ref Col4 c2, float f ) {
		if ( f <= 0.0f ) {
			*this = c1;
		}
		else if ( f >= 1.0f ) {
			*this = c2;
		}
		else {
			*this = c1 + f * ( c2 - c1 );
		}
	}

	/// returns color linearly interpolated from this to c2 by fraction f
	Col4 lerp( ref Col4 c2, float f ) {
		if ( f <= 0.0f ) {
			return *this;
		}
		else if ( f >= 1.0f ) {
			return c2;
		}
		return ( *this ) + f * ( c2 - ( *this ) );
	}

	/// returns hash-code for color
	size_t toHash() {
		size_t	red = *cast( size_t * )&r;
		size_t	green = *cast( size_t * )&g;
		size_t	blue = *cast( size_t * )&b;
		size_t	alpha = *cast( size_t * )&a;

		return red + ( green * 37 ) + ( blue * 101 ) + ( alpha * 241 );
	}

	/// packs RGBA values into uint variable
	uint toUint( BYTEORDER order = BYTEORDER.RGBA8 )
	in {
		assert( r >= 0.0f && r <= 1.0f );
		assert( g >= 0.0f && g <= 1.0f );
		assert( b >= 0.0f && b <= 1.0f );
		assert( a >= 0.0f && a <= 1.0f );
	}
	body {
		uint	dst;

		// pack according to byte-order
		switch ( order ) {
		case BYTEORDER.ARGB8:
			( cast( ubyte * )&dst )[0] = cast( ubyte )Math.ftoiFast( a * 255.0f );
			( cast( ubyte * )&dst )[1] = cast( ubyte )Math.ftoiFast( r * 255.0f );
			( cast( ubyte * )&dst )[2] = cast( ubyte )Math.ftoiFast( g * 255.0f );
			( cast( ubyte * )&dst )[3] = cast( ubyte )Math.ftoiFast( b * 255.0f );
			break;
		case BYTEORDER.ABGR8:
			( cast( ubyte * )&dst )[0] = cast( ubyte )Math.ftoiFast( a * 255.0f );
			( cast( ubyte * )&dst )[1] = cast( ubyte )Math.ftoiFast( b * 255.0f );
			( cast( ubyte * )&dst )[2] = cast( ubyte )Math.ftoiFast( g * 255.0f );
			( cast( ubyte * )&dst )[3] = cast( ubyte )Math.ftoiFast( r * 255.0f );
			break;
		case BYTEORDER.RGBA8:
			( cast( ubyte * )&dst )[0] = cast( ubyte )Math.ftoiFast( r * 255.0f );
			( cast( ubyte * )&dst )[1] = cast( ubyte )Math.ftoiFast( g * 255.0f );
			( cast( ubyte * )&dst )[2] = cast( ubyte )Math.ftoiFast( b * 255.0f );
			( cast( ubyte * )&dst )[3] = cast( ubyte )Math.ftoiFast( a * 255.0f );
			break;
		case BYTEORDER.BGRA8:
			( cast( ubyte * )&dst )[0] = cast( ubyte )Math.ftoiFast( b * 255.0f );
			( cast( ubyte * )&dst )[1] = cast( ubyte )Math.ftoiFast( g * 255.0f );
			( cast( ubyte * )&dst )[2] = cast( ubyte )Math.ftoiFast( r * 255.0f );
			( cast( ubyte * )&dst )[3] = cast( ubyte )Math.ftoiFast( a * 255.0f );
			break;
		}

		return dst;
	}

	/// returns string, just a convenience function
	char[] toUtf8() {
		return Math.toUtf8( "( r:{0:E} g:{1:E} b:{2:E} a:{3:E} )", r, g, b, a );
	}

	/// returns the number of components
	size_t length() {
		return 4;
	}

	/// returns raw pointer
	float *ptr() {
		return &r;
	}

	debug ( FLOAT_PARANOID ) {
		invariant() {
			assert( Math.isValid( r ) );
			assert( Math.isValid( g ) );
			assert( Math.isValid( b ) );
			assert( Math.isValid( a ) );
		}
	}

	float	r, g, b, a;		/// color components: red, green, blue and alpha
}
