/**
	Copyright: Copyright (c) 2007, Artyom Shalkhakov. All rights reserved.
	License: BSD

	This module implements quaternion.

	Version: Aug 2007: initial release
	Authors: Artyom Shalkhakov
*/
module auxd.ray.base.Quat;

import Math = auxd.ray.base.Math;
import auxd.ray.base.Vector;
import auxd.ray.base.Angles;

/**
	Unit quaternions are used in to represent rotation about an axis.
	Any 3x3 rotation matrix can be stored as a quaternion.
*/
struct Quat {
	static Quat opCall( float x, float y, float z, float w ) {
		Quat	dst;

		dst.x = x;
		dst.y = y;
		dst.z = z;
		dst.w = w;

		return dst;
	}

	float opIndex( size_t index )
	in {
		assert( index >= 0 && index < 4 );
	}
	body {
		return ( &x )[index];
	}

	void opIndexAssign( float f, size_t index )
	in {
		assert( index >= 0 && index < 4 );
	}
	body {
		( &x )[index] = f;
	}

	Quat opNeg() {
		return Quat( -x, -y, -z, -w );
	}

	Quat opAdd( ref Quat q ) {
		return Quat( x + q.x, y + q.y, z + q.z, w + q.w );
	}

	Quat opSub( ref Quat q ) {
		return Quat( x - q.x, y - q.y, z - q.z, w - q.w );
	}

	Quat opMul( float f )
	in {
		debug ( FLOAT_PARANOID ) {
			assert( Math.isValid( f ) );
			assert( Math.abs( f - 0.0f ) > 1e-14 );
		}
	}
	body {
		return Quat( x * f, y * f, z * f, w * f );
	}

	Vec3 opMul( ref Vec3 v ) {
		// result = this.inverse() * Quat( v.x, v.y, v.z, 0.0f ) * ( *this )
		float	xxzz = x * x - z * z;
		float	wwyy = w * w - y * y;

		float	xw2 = x * w * 2.0f;
		float	xy2 = x * y * 2.0f;
		float	xz2 = x * z * 2.0f;
		float	yw2 = y * w * 2.0f;
		float	yz2 = y * z * 2.0f;
		float	zw2 = z * w * 2.0f;

		return Vec3(
			( xxzz + wwyy ) * v.x + ( xy2 + zw2 ) * v.y + ( xz2 - yw2 ) * v.z,
			( xy2 - zw2 ) * v.x + ( xxzz - wwyy ) * v.y + ( yz2 + xw2 ) * v.z,
			( xz2 + yw2 ) * v.x + ( yz2 - xw2 ) * v.y + ( wwyy - xxzz ) * v.z );
	}

	Quat opMul( ref Quat q ) {
		return Quat( w * q.x + x * q.w + y * q.z - z * q.y,
					w * q.y + y * q.w + z * q.x - x * q.z,
					w * q.z + z * q.w + x * q.y - y * q.x,
					w * q.w - x * q.x - y * q.y - z * q.z ); 
	}

	void opAddAssign( ref Quat q ) {
		x += q.x;
		y += q.y;
		z += q.z;
		w += q.w;
	}

	void opSubAssign( ref Quat q ) {
		x -= q.x;
		y -= q.y;
		z -= q.z;
		w -= q.w;
	}

	void opMulAssign( float f )
	in {
		debug ( FLOAT_PARANOID ) {
			assert( Math.isValid( f ) );
		}
	}
	body {
		x *= f;
		y *= f;
		z *= f;
		w *= f;
	}

	void opMulAssign( ref Quat q ) {
		*this = Quat( w * q.x + x * q.w + y * q.z - z * q.y,
					w * q.y + y * q.w + z * q.x - x * q.z,
					w * q.z + z * q.w + x * q.y - y * q.x,
					w * q.w - x * q.x - y * q.y - z * q.z );
	}

	bool opEquals( ref Quat q ) {
		return ( x == q.x && y == q.y && z == q.z && w == q.w );
	}

	bool compare( ref Quat q, float epsilon ) {
		if ( Math.abs( x - q.x ) > epsilon ) {
			return false;
		}
		if ( Math.abs( y - q.y ) > epsilon ) {
			return false;
		}
		if ( Math.abs( z - q.z ) > epsilon ) {
			return false;
		}
		if ( Math.abs( w - q.w ) > epsilon ) {
			return false;
		}
		return true;
	}

	void set( float x, float y, float z, float w ) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	void zero() {
		x = y = z = w = 0.0f;
	}

	Quat inverse() {
		return Quat( -x, -y, -z, w );
	}

	float magnitude() {
		float len = x * x + y * y + z * z + w * w;

		return Math.sqrt( len );
	}

	void normalize() {
		float	len = magnitude;
		float	invLength;
	
		if ( len ) {
			invLength = 1.0f / len;
			x *= invLength;
			y *= invLength;
			z *= invLength;
			w *= invLength;
		}
	}

	/// spherical linear interpolation between to quaternions
	Quat slerp( ref Quat to, float t ) {
		Quat	temp;
		float	omega, cosom, sinom, scale0, scale1;

		if ( t <= 0.0f ) {
			return *this;
		}
		if ( t >= 1.0f ) {
			return to;
		}
		if ( *this == to ) {
			return *this;
		}

		cosom = x * to.x + y * to.y + z * to.z + w * to.w;
		if ( cosom < 0.0f ) {
			temp = -to;
			cosom = -cosom;
		}
		else {
			temp = to;
		}

		if ( ( 1.0f - cosom ) > 1e-6f ) {
			scale0 = 1.0f - cosom * cosom;
			sinom = Math.invSqrt( scale0 );
			omega = Math.atan( scale0 * sinom, cosom );
			scale0 = Math.sin( ( 1.0f - t ) * omega ) * sinom;
			scale1 = Math.sin( t * omega ) * sinom;
		}
		else {
			scale0 = 1.0f - t;
			scale1 = t;
		}

		return ( scale0 * ( *this ) ) + ( scale1 * temp );
	}

	/// ditto
	void slerpSelf( ref Quat from, ref Quat to, float t ) {
		Quat	temp;
		float	omega, cosom, sinom, scale0, scale1;

		if ( t <= 0.0f ) {
			*this = from;
			return;
		}
		if ( t >= 1.0f ) {
			*this = to;
			return;
		}
		if ( from == to ) {
			*this = to;
			return;
		}

		cosom = from.x * to.x + from.y * to.y + from.z * to.z + from.w * to.w;
		if ( cosom < 0.0f ) {
			temp = -to;
			cosom = -cosom;
		}
		else {
			temp = to;
		}

		if ( ( 1.0f - cosom ) > 1e-6f ) {
			scale0 = 1.0f - cosom * cosom;
			sinom = Math.invSqrt( scale0 );
			omega = Math.atan( scale0 * sinom, cosom );
			scale0 = Math.sin( ( 1.0f - t ) * omega ) * sinom;
			scale1 = Math.sin( t * omega ) * sinom;
		}
		else {
			scale0 = 1.0f - t;
			scale1 = t;
		}

		*this = ( scale0 * from ) + ( scale1 * temp );
	}

	Angles toAngles() {
		return toMat3.toAngles;
	}

	Mat3 toMat3() {
		Mat3	mat;
		float	wx, wy, wz;
		float	xx, yy, yz;
		float	xy, xz, zz;
		float	x2, y2, z2;
	
		x2 = x + x;
		y2 = y + y;
		z2 = z + z;

		xx = x * x2;
		xy = x * y2;
		xz = x * z2;

		yy = y * y2;
		yz = y * z2;
		zz = z * z2;

		wx = w * x2;
		wy = w * y2;
		wz = w * z2;

		mat.cols[0][0] = 1.0f - ( yy + zz );
		mat.cols[0][1] = xy - wz;
		mat.cols[0][2] = xz + wy;
	
		mat.cols[1][0] = xy + wz;
		mat.cols[1][1] = 1.0f - ( xx + zz );
		mat.cols[1][2] = yz - wx;
	
		mat.cols[2][0] = xz - wy;
		mat.cols[2][1] = yz + wx;
		mat.cols[2][2] = 1.0f - ( xx + yy );
	
		return mat; 
	}

	Mat4 toMat4() {
		return toMat3.toMat4;
	}

	/// returns string, just a convenience function
	char[] toUtf8() {
		return Math.toUtf8( "( x:{0:E} y:{1:E} z:{2:E} w:{3:E} )", x, y, z, w );
	}

	size_t length() {
		return 4;
	}

	float *ptr() {
		return &x;
	}

	debug ( FLOAT_PARANOID ) {
		invariant() {
			assert( Math.isValid( x ) );
			assert( Math.isValid( y ) );
			assert( Math.isValid( z ) );
			assert( Math.isValid( w ) );
		}
	}

	float	x, y, z, w;
}
