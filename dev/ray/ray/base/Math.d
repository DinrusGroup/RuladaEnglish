/**
	Copyright: Copyright (c) 2002-2006 Chris Lomont
	Copyright: Copyright (c) 2007 Artyom Shalkhakov
	License: BSD-style

	This module contains replacements for some library functions.
	Some functions were taken from FloatHack library by Chris
	Lomont (www.lomont.org), which has the following license agreement:
	---
  FloatHack.cpp -- implementation of Chris Lomont's fast and alternative floating point routines
  version 0.5, October, 2005
  www.lomont.org

  Copyright (C) 2002-2006 Chris Lomont

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the author be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  excluding commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

  If you want to use this for commercial applications please contact me.

  Chris Lomont, you can contact me from www.lomont.org
	---

	It is highly recommended that an import aliasing is applied
	to this module to avoid namespace pollution.

	Version: Aug 2007: initial release
	Authors: Chris Lomont, Artyom Shalkhakov

	Version and debug identifiers:
	---
	version = HACKED_MATH;			// enable FloatHack math routines: sqrt, 1/sqrt, abs
	version = HACKED_CLAMP;			// enable FloatHack clamping routines
	version = HACKED_CONVERSION;	// enable FloatHack int-to-float/float-to-int conversion
	debug = UNITTESTS;				// run unit tests
	---
*/
module auxd.ray.base.Math;

private {
	import StdcMath = tango.stdc.math;			// math functions
	import tango.text.convert.Layout;			// string formatting functions
	debug ( UNITTESTS ) {
		import tango.io.Stdout;
		import tango.math.Random;
	}
	import tango.math.IEEE;
	import tango.math.Math : E, LOG2T, LOG2E, LOG2, LOG10E, LN2, LN10, PI, PI_2, PI_4, M_1_PI, M_2_PI, M_2_SQRTPI, SQRT2, SQRT1_2;
}

const {
	real DEG2RAD		= PI / 180.0;
	real RAD2DEG		= 180.0 / PI;
}

version ( HACKED_MATH ) {
	private {
		union IntFloat {
			float	f;
			int		i;
		}
	
		enum {
			LOOKUP_BITS				= 8,
			EXP_POS					= 23,
			EXP_BIAS				= 127,
			LOOKUP_POS				= ( EXP_POS - LOOKUP_BITS ),
			SEED_POS				= ( EXP_POS - 8 ),
			SQRT_TABLE_SIZE			= ( 2 << LOOKUP_BITS ),
			LOOKUP_MASK				= ( SQRT_TABLE_SIZE - 1 )
		}
		uint[SQRT_TABLE_SIZE]		sqrtValues;
	}

	static this() {
		IntFloat	fi, fo;
	
		for ( int i = 0; i < SQRT_TABLE_SIZE; i++ ) {
			fi.i = ( ( EXP_BIAS - 1 ) << EXP_POS ) | ( i << LOOKUP_POS );
			fo.f = cast( float )( 1.0 / StdcMath.sqrtf( fi.f ) );
			sqrtValues[i] = ( cast( uint )( ( ( fo.i + ( 1 << ( SEED_POS - 2 ) ) ) >> SEED_POS ) & 0xFF ) ) << SEED_POS;
		}
		sqrtValues[SQRT_TABLE_SIZE / 2] = ( cast( uint )0xFF ) << SEED_POS;
	}
}

/// convert degrees to radians
type deg2rad( type )( type degrees ) {
	return degrees * DEG2RAD;
}

/// convert radians to degrees
type rad2deg( type )( type degrees ) {
	return degrees * RAD2DEG;
}

/// returns true if any of arguments is NaN
int isNaN( float x ) {
	return ( *( cast( uint * )( &x ) ) & 0x7f800000 ) == 0x7f800000;
}

/// returns true if any of arguments is either float.infinity or -float.infinity
int isInfinity( float x ) {
	return ( *( cast( uint * )( &x ) ) & 0x7fffffff ) == 0x7f800000;
}

/// returns true if x is valid (not a NaN, and not infinity)
int isValid( type )( type x ) {
	return !isNaN( x ) && !isInfinity( x );
}

debug ( UNITTESTS ) {
	unittest {
		assert( isValid( 0.0f ) );
	}

	unittest {
		float	a, b;

		Stdout( "...testing exceptional functions:" ).newline;
		Stdout( "all expressions should return true" ).newline;

		Stdout.format( "every float is initialized to NaN: {}", isNaN( a ) ).newline;
		a = -1.0f;
		Stdout.format( "-1 is a number: {}", isValid( a ) ).newline;
		b = StdcMath.sqrtf( a );
		Stdout.format( "sqrt( -1 ) is a NaN: {}", isNaN( b ) ).newline;

		a = makeFloat( 0, 0, 0 );		// make 0 this way to prevent optimizer from removing
		b = 1.0f / a;
		Stdout.format( "1/0 is infinity: {}", isInfinity( b ) ).newline;

		// create denormalized value:
		a = makeFloat( 0, 1, 0 );		// smallest normalized number
		Stdout.format( "normalized: {}", !isSubnormal( a ) ).newline;
		a = a * 0.5f;					// now denormalized
		Stdout.format( "denormalized: {}", isSubnormal( a ) ).newline;
	}
}

/// returns the sign-bit of x
int signbit( int x ) {
	return ( ( *cast( uint * )( &x ) ) >> 31 );
}

/// ditto
int signbit( float x ) {
	return ( ( *cast( uint * )( &x ) ) >> 31 );
}

debug ( UNITTESTS ) {
	unittest {
		assert( signbit( 1 ) == 0 );
		assert( signbit( -1 ) == 1 );
		assert( signbit( 0.5f ) == 0 );
		assert( signbit( -2.0f ) == 1 );
	}
}

/// returns 0x00000000 if x >= 0 and returns 0xFFFFFFFF if x < 0
int maskForSign( int x ) {
	return ~( ( ( cast( uint )x ) >> 31 ) - 1 );
}

/// ditto
int maskForSign( float x ) {
	return ~( ( ( *cast( uint * )&x ) >> 31 ) - 1 );
}

debug ( UNITTESTS ) {
	unittest {
		assert( maskForSign( 0 ) == 0 );
		assert( maskForSign( 1 ) == 0 );
		assert( maskForSign( -1 ) == 0xFFFFFFFF );
		assert( maskForSign( 0.0f ) == 0 );
		assert( maskForSign( -0.0f ) == 0xFFFFFFFF );
		assert( maskForSign( 1.0f ) == 0 );
		assert( maskForSign( -1.0f ) == 0xFFFFFFFF );
	}
}

/// absolute value of x
float abs( float x ) {
	version ( HACKED_MATH ) {
		int	i = *cast( int * )( &x );

		i &= 0x7FFFFFFF;       // strip sign bit

		return ( *cast( float * )( &i ) );
	}
	else {
		return x >= 0 ? x : -x;
	}
}

/// negate x
float negate( float x ) {
	version ( HACKED_MATH ) {
		int	i = *cast( int * )( &x );

		i ^= 0x80000000;		// flip sign bit 

		return ( *cast( float * )( &i ) );
	}
	else {
		return -x;
	}
}

float floor( float x ) {
	return StdcMath.floorf( x );
}

float ceil( float x ) {
	return StdcMath.ceilf( x );
}

/// clamp to [min, max]
float clamp( float x, float min, float max )
in {
	assert( min < max );
}
out ( r ) {
	version ( HACKED_CLAMP ) {
		assert( ( r >= min ) && ( r <= max ) );
	}
}
body {
	version ( HACKED_CLAMP ) {
		x -= min;
		x /= ( max - min );
		x = clampBiased( x );
		x *= ( max - min );
		x += min;
		return x;
	}
	else {
		if ( x < min ) {
			return min;
		}
		else if ( x > max ) {
			return max;
		}
		return x;	
	}
}

/// clamp x to [0, 1]
float clampBiased( float x )
out ( r ) {
	version ( HACKED_CLAMP ) {
		assert( ( r >= 0.0f ) && ( r <= 1.0f ) );
	}
}
body {
	version ( HACKED_CLAMP ) {
		int			s = void;
		IntFloat	v = void;

		v.f = x;
		s = maskForSign( v.i );	// all 1's if signbit is 1
		v.i &= ~s;				// 0 if was negative

		// clamp to 1
		v.f = 1.0f - v.f;
		s = maskForSign( v.i );	// all 1's if signbit is 1
		v.i &= ~s;				// 0 if was negative
		v.f = 1.0f - v.f;

		return v.f;
	}
	else {
		if ( x < 0.0f ) {
			return 0.0f;
		}
		else if ( x > 1.0f ) {
			return 1.0f;
		}
		return x;
	}
}

/// clamp to [-1, 1]
float clamp( float x )
out ( r ) {
	version ( HACKED_CLAMP ) {
		assert( ( r >= -1.0f ) && ( r <= 1.0f ) );
	}
}
body {
	version ( HACKED_CLAMP ) {
		x += 1.0f;
		x *= 0.5f;
		x = clampBiased( x );
		x *= 2.0f;
		x -= 1.0f;
		return x;
	}
	else {
		if ( x < -1.0f ) {
			return -1.0f;
		}
		else if ( x > 1.0f ) {
			return 1.0f;
		}
		return x;	
	}
}

/// clamp to [0, float.infinity]
float clampPositive( float x )
out ( r ) {
	version ( HACKED_CLAMP ) {
		assert( r >= 0.0f );
	}
}
body {
	version ( HACKED_CLAMP ) {
		int			s = void;
		IntFloat	v = void;

		v.f = x;
		s = maskForSign( v.i );		// all 1's if sign bit 1
		v.i &= ~s;					// 0 if was negative

		return v.f;
	}
	else {
		if ( x <= 0.0f ) {
			return 0.0f;
		}
		return x;
	}
}

debug ( UNITTESTS ) {
	version ( HACKED_CLAMP ) {
		unittest {
			Stdout( "...testing clamping:" ).newline;
			Stdout.format( "-5 clamped to [0,1] is {}", clampBiased( -5.0f ) ).newline;
			Stdout.format( "0 clamped to [0,1] is {}", clampBiased( 0.0f ) ).newline;
			Stdout.format( "0.5 clamped to [0,1] is {}", clampBiased( 0.5f ) ).newline;
			Stdout.format( "1 clamped to [0,1] is {}", clampBiased( 1.0f ) ).newline;
			Stdout.format( "1.1 clamped to [0,1] is {}", clampBiased( 1.1f ) ).newline;
			Stdout.format( "500.125 clamped to [0,1] is {}", clampBiased( 500.125f ) ).newline;
			Stdout.format( "-5 clamped to [-4,3] is {}", clamp( -5.0f, -4.0f, 3.0f ) ).newline;
			Stdout.format( "-5 clamped to [-5,3] is {}", clamp( -5.0f, -5.0f, 3.0f ) ).newline;
			Stdout.format( "-5 clamped to [-6,3] is {}", clamp( -5.0f, -6.0f, 3.0f ) ).newline;
			Stdout.format( "-5 clamped to [-8,-6] is {}", clamp( -5.0f, -8.0f, -6.0f ) ).newline;
			Stdout.format( "-5 clamped to [-1,1] is {}", clamp( -5.0f ) ).newline;
			Stdout.format( "-1 clamped to [-1,1] is {}", clamp( -1.0f ) ).newline;
			Stdout.format( "0 clamped to [-1,1] is {}", clamp( 0.0f ) ).newline;
			Stdout.format( "0.01 clamped to [-1,1] is {}", clamp( 0.01f ) ).newline;
			Stdout.format( "10000 clamped to [-1,1] is {}", clamp( 10000.0f ) ).newline;
			Stdout.format( "-5 clamped to [0,infinity) is {}", clampPositive( -5.0f ) ).newline;
			Stdout.format( "-1 clamped to [0,infinity) is {}", clampPositive( -1.0f ) ).newline;
			Stdout.format( "0 clamped to [0,infinity) is {}", clampPositive( 0.0f ) ).newline;
			Stdout.format( "0.01 clamped to [0,infinity) is {}", clampPositive( 0.01f ) ).newline;
			Stdout.format( "10000 clamped to [0,infinity) is {}", clampPositive( 10000 ) ).newline;
		}
	}
}

float angleNormalize180( float a ) {
	a = angleNormalize360( a );
	if ( a > 180.0f ) {
		a -= 360.0f;
	}
	return a;
}

float angleNormalize360( float a ) {
	if ( ( a >= 360.0f ) || ( a < 0.0f ) ) {
		a -= floor( a / 360.0f ) * 360.0f;
	}
	return a;
}

float angleDelta( float a1, float a2 ) {
	return angleNormalize180( a1 - a2 );
}

/// fast float comparison with tolerance
// TODO: make sure this works
// TODO: make sure parameters are not garbage (NaNs, etc.)
bool compare( float f1, float f2, int diff ) {
	int		i1 = *cast( int * )&f1;
	int		i2 = *cast( int * )&f2;
	int		mask = maskForSign( i1 ^ i2 );
	int		d = ( ( 0x80000000 - i1 ) & mask ) | ( i1 & ~mask ) - i2;
	int		v1 = diff + d;
	int		v2 = diff - d;

	return ( v1 | v2 ) >= 0;
}

unittest {
	assert( compare( 0.0f, 0.0f, 0 ) == true );
	assert( compare( 500.0f, 500.1f, 100000 ) == true );
	assert( compare( 5000.0f, 5000.1f, 100000 ) == true );
}

/// fast float to int conversion
int ftoi( float x ) {
	version ( HACKED_CONVERSION ) {
		int	i = void;

		x += ( 1 << 23 ) + ( 1 << 22 );
		i = *cast( int * )( &x );
		i &= ( 1 << 23 ) - 1;			// mask out
		i -= ( 1 << 22 );
		return i;
	}
	else {
		return cast( int )x;
	}
}

/// fast float to int conversion, but using current FPU rounding mode
int ftoiFast( float x ) {
	return cast( int )x;
}

/// fast float to long conversion
int ftol( float x ) {
	version ( HACKED_CONVERSION ) {
		// upcast to get enough bits, value is 0x59C00000 = 2^51+2^52
		double d = x + ( ( ( 65536.0 * 65536.0 * 16.0 ) + 32768.0 ) * 65536.0 );
		return ( *cast( long * )&d ) - 0x80000000;
	}
	else {
		return cast( long )x;
	}
}

/// fast float to long conversion, but using current FPU rounding mode
int ftolFast( float x ) {
	return cast( long )x;
}

/// fast int to float conversion
float itof( int x ) {
	version ( HACKED_CONVERSION ) {
		IntFloat	v = void, bias = void;

		v.i = x;
		bias.i = ( ( 23 + 127 ) << 23 ) + ( 1 << 22 );
		v.i += bias.i;
		v.f -= bias.f;

		return v.f;
	}
	else {
		return cast( float )x;
	}
}

/// fast int to float conversion, but using current FPU rounding mode
float itofFast( int x ) {
	return cast( float )x;
}

debug ( UNITTESTS ) {
	version ( HACKED_CONVERSION ) {
		bool testConvert( long v ) {
			float	f = cast( float )v;
	
			v = ftol( f );
			if ( abs( f - v ) > 0.005f ) {
				Stdout.format( "ftol() failed on {}", v ).newline;
				return false;
			}
			return true;
		}
	
		unittest {
			Stdout( "...testing conversion:" ).newline;
	
			Stdout.format( "ftoi( 1234 ): {}", ftoi( 1234.0f ) ).newline;
			Stdout.format( "ftoi( -123.45 ): {}", ftoi( -123.45f ) ).newline;
			Stdout.format( "ftoi( 0.05 ): {}", ftoi( 0.05f ) ).newline;
			Stdout.format( "ftoi( -0.05 ): {}", ftoi( -0.05f ) ).newline;
			Stdout.format( "ftoi( -0.55 ): {}", ftoi( -0.55f ) ).newline;
			Stdout.format( "ftoi( -0.50 ): {}", ftoi( -0.5f ) ).newline;
			Stdout.format( "ftoi( -0.45 ): {}", ftoi( -0.45f ) ).newline;
			Stdout.format( "ftoi( 0.55 ): {}", ftoi( 0.55f ) ).newline;
			Stdout.format( "ftoi( 0.50 ): {}", ftoi( 0.5f ) ).newline;
			Stdout.format( "ftoi( 0.45 ): {}", ftoi( 0.45f ) ).newline;
			Stdout.format( "itof( 100 ): {}", itof( 100 ) ).newline;
			Stdout.format( "itof( -100 ): {}", itof( -100 ) ).newline;
			Stdout.format( "itof( 0 ): {}", itof( 0 ) ).newline;
			Stdout.format( "ftol( 1234 ): {}", ftol( 1234.0f ) ).newline;
			Stdout.format( "ftol( -123.45 ): {}", ftol( -123.45f ) ).newline;
			Stdout.format( "ftol( 0.05 ): {}", ftol( 0.05f ) ).newline;
			Stdout.format( "ftol( -0.05 ): {}", ftol( -0.05f ) ).newline;
		
			bool	passed = true;
			int		top = ( 1 << 22 ) - 1;
		
			Stdout( "testing int conversion ranges:" ).newline;
			for ( int val = -top; val <= top; val++ ) {
				float	f = itof( val );
				int		i = ftoi( f );
		
				if ( abs( f - val ) > 0.005f ) {
					if ( passed ) {
						Stdout.format( "error: itof() failed on {}", val ).newline;
					}
					passed = false;
				}
				if ( abs( f - i ) > 0.005f ) {
					if ( passed ) {
						Stdout.format( "error: ftoi() failed on {}", val ).newline;
					}
					passed = false;
				}
			}
			if ( passed ) {
				Stdout.format( "ftoi() and itof() are valid over +- {}", top ).newline;
			}
			else {
				Stdout( "ftoi() or itof() failed" ).newline;
			}
		
			Stdout( "testing long conversion ranges:" ).newline;
			passed = true;
			for ( int val = -top; val <= top; val++ ) {
				float	f = cast( float )val;
				int		i = ftol( f );
		
				if ( abs( f - i ) > 0.005f ) {
					if ( passed ) {
						Stdout( "error: ftol() failed on {}", val ).newline;
					}
					passed = false;
				}
			}
	
			// test some other ranges
			passed &= testConvert( 1 << 31 );
			passed &= testConvert( 1 << 29 );
			passed &= testConvert( 1 << 28 );
			passed &= testConvert( -( 1 << 31 ) );
	
			if ( passed ) {
				Stdout.format( "ftol() and ltof() are valid over +-{}", top ).newline;
			}
			else {
				Stdout( "ftol() or ltof() failed" ).newline;
			}
		}
	}
}

/// inverse square root with 32 bits precision, returns huge number when x == 0.0f
float invSqrt( float x ) {
	version ( HACKED_MATH ) {
		uint		a = *cast( uint * )( &x );
		IntFloat	seed = void;
		double		y = x * 0.5f, r = void;
	
		seed.i = ( ( ( ( 3 * EXP_BIAS - 1 ) - ( ( a >> EXP_POS ) & 0xFF ) ) >> 1 ) << EXP_POS ) | sqrtValues[( a >> ( EXP_POS - LOOKUP_BITS ) ) & LOOKUP_MASK];
		r = seed.f;
		r = r * ( 1.5f - r * r * y );
		r = r * ( 1.5f - r * r * y );
	
		return cast( float )r;
	}
	else {
		return 1.0f / StdcMath.sqrtf( x );
	}}

/// square root with 32 bits precision
float sqrt( float x ) {
	version ( HACKED_MATH ) {
		return x * invSqrt( x );
	}
	else {
		return StdcMath.sqrtf( x );
	}
}

// create a float, given a sign 0 for positive or 1 for negative,
// an unsigned exponent from 0 to 255 (biased by 127), and a mantissa in [0,(1<<23)-1]
float makeFloat( uint sign, uint exp, uint mant ) {
	uint	v = ( sign << 31 ) | ( ( exp & 255 ) << 23 ) | ( mant & ( ( 1 << 23 ) -1 ) );
	float	f = *cast( float * )( &v );

	return f;
}

debug ( UNITTESTS ) {
	float error( float exact, float fast ) {
		if ( exact == 0.0f ) {
			return ( abs( fast ) < 0.00001f ? 0.0f : 1.0f );
		}
		return abs( ( exact - fast ) / exact );
	}

	// test math functions on various exponent/sign variations
	unittest {
		const uint[]	exponents = [ 1, 1, 2, 126, 127, 128, 253, 254 ];
		scope 			rand = new Random;

		Stdout( "...testing abs, sqrt, invSqrt" ).newline;
		for ( int outer = 0; outer < 8; outer++ ) {
			for ( int sign = 0; sign <= 1; sign++ ) {
				for ( int p = 0; p < 1000000; p++ ) {
					int		mant = rand.next & ( ( 1 << 23 ) - 1 );
					float	f = makeFloat( sign, exponents[outer], mant );
					float	fast, exact;

					fast = abs( f );
					exact = StdcMath.fabs( f );
					if ( fast != exact ) {
						Stdout.format( "abs() failed on {0} (fast: {1}, exact: {2})", f, fast, exact ).newline;
					}

					if ( ( f > 0.0f ) && !isSubnormal( f ) ) {
						fast = invSqrt( f );
						exact = 1.0f / StdcMath.sqrtf( f );
						if ( StdcMath.fabs( fast/exact - 1.0f ) > 0.01f ) {
							Stdout.format( "invSqrt() failed on {0} (fast: {1}, exact: {2}", f, fast, exact ).newline;
						}
					}

					if ( f >= 1.0f ) {
						exact = StdcMath.sqrtf( f );
						fast = sqrt( f );
						if ( error( fast, exact ) > 0.01f ) {
							Stdout.format( "sqrt() failed on {0} (fast: {1}, exact: {2}", f, fast, exact ).newline;
						}
					}
				}
			}
		}
	}
}

/// sine with 32 bits precision
float sin( float x ) {
	return StdcMath.sinf( x );
}

/// cosine with 32 bits precision
float cos( float x ) {
	return StdcMath.cosf( x );
}

/// sine and cosine with 32 bits precision
void sinCos( float x, ref float s, ref float c ) {
	version ( D_InlineAsm_X86 ) {
		asm {
			fld		x;
			fsincos;
			mov		ECX, c;
			mov		EDX, s;
			fstp	dword ptr [ECX];
			fstp	dword ptr [EDX];
		}
	}
	else {
		s = StdcMath.sinf( x );
		c = StdcMath.cosf( x );
	}
}

/// tangent with 32 bits precision
float tan( float x ) {
	return StdcMath.tanf( x );
}

/// arc sine with 32 bits precision
float asin( float x ) {
	return StdcMath.asinf( x );
}

/// arc cosine with 32 bits precision
float acos( float x ) {
	return StdcMath.acosf( x );
}

/// arc tangent with 32 bits precision
float atan( float x ) {
	return StdcMath.atanf( x );
}

/// arc tangent with 32 bits precision
float atan( float y, float x ) {
	return StdcMath.atan2f( y, x );
}

/// round x down to the nearest power of 2
int floorPowerOfTwo( int x ) {
	return ceilPowerOfTwo( x ) >> 1;
}

/// round x up to the nearest power of 2
int ceilPowerOfTwo( int x ) {
	x--;
	x |= x >> 1;
	x |= x >> 2;
	x |= x >> 4;
	x |= x >> 8;
	x |= x >> 16;
	x++;
	return x;
}

/// returns true if x is a power of 2
bool isPowerOfTwo( int x ) {
	return ( x & ( x - 1 ) ) == 0 && x > 0;
}

/// text formatting function, just for convenience
char[] toUtf8( char[] fmt, ... ) {
	scope auto	convert = new Layout!( char );

	return convert( _arguments, _argptr, fmt );
}
