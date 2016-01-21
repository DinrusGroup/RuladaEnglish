/**
	Copyright: Copyright (c) 2007, Artyom Shalkhakov. All rights reserved.
	License: BSD

	This module implements transformation class.

	Version: Aug 2007: initial release
	Authors: Artyom Shalkhakov
*/
module auxd.ray.base.Transformation;

import auxd.ray.base.Vector;
import auxd.ray.base.Quat;

const Transformation	transform_zero = { axis : mat3_identity, origin : vec3_zero };

/**
	A rigid body transformation: rotation and translation.

	_Transformation abstracts a Mat4 that maps one space to another:

	v_local = T * v_global

	Transformation.axis is the upper 3x3 submatrix, Transformation.origin
	is the right 3x1 column. The 4th row is always [0.0f, 0.0f, 0.0f, 1.0f],
	so it isn't stored.

	An example of usage:
	---
		Transformation	xform = transform_zero;
		Transformation	f;
		Mat4			model;
		Mat3			r = ...;				// initialize
		Vec3			v = ...;				// initialize

		// first variant: procedural style
		xform.translateSelf( v );				// translate
		xform.rotateSelf( r );					// rotate
		// second variant: overloaded operators
		xform += v;
		xform *= r;
		f = xform.rotateSelf( r.transpose );	// cancel rotation out and place result into f
		model = f.matrix;						// get transformation matrix
	---
*/
struct Transformation {
	/// compose transformation out of rotation and translation
	static Transformation opCall( ref Mat3 axis, ref Vec3 origin ) {
		Transformation	dst;

		dst.axis = axis;
		dst.origin = origin;

		return dst;
	}

	/**
		Compose transformation out of Mat4.
		NOTE: if Mat4 contains scale or other additional information, it will be lost.
	*/
	static Transformation opCall( ref Mat4 mat ) {
		Transformation	dst;

		dst.axis.cols[0].set( mat.rows[0].x, mat.rows[1].x, mat.rows[2].x );
		dst.axis.cols[1].set( mat.rows[0].y, mat.rows[1].y, mat.rows[2].y );
		dst.axis.cols[2].set( mat.rows[0].z, mat.rows[1].z, mat.rows[2].z );
		dst.origin = mat.rows[3].toVec3;

		return dst;
	}

	Transformation opAdd( ref Vec3 translation ) {
		return translate( translation );
	}

	Transformation opSub( ref Vec3 translation ) {
		return translate( -translation );
	}

	Transformation opMul( ref Mat3 rotation ) {
		return rotate( rotation );
	}

	Transformation opMul( ref Transformation xform ) {
		return Transformation( axis * xform.axis, xform.origin * axis + origin );
	}

	void opAddAssign( ref Vec3 translation ) {
		translateSelf( translation );
	}

	void opSubAssign( ref Vec3 translation ) {
		translateSelf( -translation );
	}

	void opMulAssign( ref Mat3 rotation ) {
		rotateSelf( rotation );
	}

	void opMulAssign( ref Transformation xform ) {
		origin += xform.origin * axis;
		axis *= xform.axis;
	}

	/// return Mat4 representing transformation
	Mat4 matrix() {
		return Mat4( axis, origin );
	}

	/// returns the inverse of transformation
	Transformation inverse() {
		Transformation	dst;

		dst.axis = axis.transpose;
		dst.origin = dst.axis * -origin;

		return dst;
	}

	/// returns rotated transformation
	Transformation rotate( ref Mat3 rotation ) {
		return Transformation( axis * rotation, origin );
	}

	/// rotates transformation
	void rotateSelf( ref Mat3 rotation ) {
		axis *= rotation;
	}

	/// returns translated transformation
	Transformation translate( ref Vec3 offset ) {
		return Transformation( axis, origin + offset );
	}

	/// translates transformation
	void translateSelf( ref Vec3 offset ) {
		origin += offset;
	}

	/// transform homogenous vector
	void transformVector( ref Vec4 src, ref Vec4 dst ) {
		dst = Vec4( src.toVec3 * axis + src.w * origin, src.w );
	}

	/// transform normal/direction (doesn't apply translation)
	void transformVector( ref Vec3 src, ref Vec3 dst ) {
		dst = src * axis;
	}

	/// transform point (applies translation)
	void transformPoint( ref Vec3 src, ref Vec3 dst ) {
		dst = src * axis + origin;
	}

	/// untransform homogenous vector
	void untransformVector( ref Vec4 src, ref Vec4 dst ) {
		dst = Vec4( ( src.toVec3 - origin * src.w ) * axis.transpose, src.w );
	}

	/// untransform vector (doesn't apply translation)
	void untransformVector( ref Vec3 src, ref Vec3 dst ) {
		dst = src * axis.transpose;
	}

	/// untransform point (applies translation)
	void untransformPoint( ref Vec3 src, ref Vec3 dst ) {
		dst = ( src - origin ) * axis.transpose;
	}

	/**
		Linearly interpolates between two transformations.
		Rotations are slerped.
	*/
	Transformation lerp( ref Transformation xform, float f ) {
		Transformation	dst;
		Quat			a = axis.toQuat;
		Quat			b = xform.axis.toQuat;

		dst.axis = a.slerp( b, f ).toMat3;
		dst.origin.lerpSelf( origin, xform.origin, f );

		return dst;
	}

	/// ditto
	void lerpSelf( ref Transformation src, ref Transformation dst, float f ) {
		Quat	a = src.axis.toQuat;
		Quat	b = dst.axis.toQuat;

		axis = a.slerp( b, f ).toMat3;
		origin.lerpSelf( src.origin, dst.origin, f );
	}

	/// just for convenience
	char[] toUtf8() {
		return Math.toUtf8( "R:({0}) T:({1})", axis.toUtf8, origin.toUtf8 );
	}

	Mat3	axis;			/// coordinate frame axis vectors
	Vec3	origin;			/// offset
}

debug ( UNITTESTS ) {
	private {
		import tango.io.Stdout;
		import auxd.ray.base.Angles;

		void checkTransforms( ref Transformation xform, ref Vec3 v1, ref Vec3 v2, bool points ) {
			Vec3	v;

			if ( points ) {
				xform.transformPoint( v1, v );
			}
			else {
				xform.transformVector( v1, v );
			}
			assert( v2.compare( v, 1e-6 ) );
			if ( points ) {
				xform.untransformPoint( v2, v );
			}
			else {
				xform.untransformVector( v2, v );
			}
			assert( v1.compare( v, 1e-6 ) );
		}

		void checkTransforms( ref Transformation xform, ref Vec4 v1, ref Vec4 v2 ) {
			Vec4	v;

			xform.transformVector( v1, v );
			assert( v2.compare( v, 1e-6 ) );
			xform.untransformVector( v2, v );
			assert( v1.compare( v, 1e-6 ) );
		}
	}

	unittest {
		Transformation	local = transform_zero;
		Transformation	delta = transform_zero;

		//
		// make rotation matrix
		// put Y coordinate up
		//
		local.rotateSelf( Angles( 0.0f, 0.0f, -90.0f ).toMat3 );
		local.rotateSelf( Angles( -90.0f, 0.0f, 0.0f ).toMat3 );

		//
		// transform points/vectors to and fro
		//
		checkTransforms( local, Vec3( 0.0f, 0.0f, 1.0f ), Vec3( 0.0f, 1.0f, 0.0f ), false );
		checkTransforms( local, Vec3( 0.0f, 0.0f, 1.0f ), Vec3( 0.0f, 1.0f, 0.0f ), true );
		checkTransforms( local, Vec4( 0.0f, 0.0f, 1.0f, 0.0f ), Vec4( 0.0f, 1.0f, 0.0f, 0.0f ) );
		checkTransforms( local, Vec4( 0.0f, 0.0f, 1.0f, 1.0f ), Vec4( 0.0f, 1.0f, 0.0f, 1.0f ) );
		local.translateSelf( Vec3( 2.4f, 0.0f, 0.0f ) );
		checkTransforms( local, Vec3( 0.0f, 0.0f, 1.0f ), Vec3( 0.0f, 1.0f, 0.0f ), false );
		checkTransforms( local, Vec3( 1.0f, 0.0f, 1.0f ), Vec3( 2.4f, 1.0f, 1.0f ), true );
		checkTransforms( local, Vec4( 0.0f, 0.0f, 1.0f, 0.0f ), Vec4( 0.0f, 1.0f, 0.0f, 0.0f ) );
		checkTransforms( local, Vec4( 1.0f, 0.0f, 1.0f, 1.0f ), Vec4( 2.4f, 1.0f, 1.0f, 1.0f ) );

		//
		// compose transformations
		//
		// cancel translation out
		delta.translateSelf( Vec3( 0.0f, -2.4f, 0.0f ) );
		local *= delta;
		checkTransforms( local, Vec3( 0.0f, 0.0f, 1.0f ), Vec3( 0.0f, 1.0f, 0.0f ), false );
		checkTransforms( local, Vec3( 0.0f, 0.0f, 1.0f ), Vec3( 0.0f, 1.0f, 0.0f ), true );
		checkTransforms( local, Vec4( 0.0f, 0.0f, 1.0f, 0.0f ), Vec4( 0.0f, 1.0f, 0.0f, 0.0f ) );
		checkTransforms( local, Vec4( 0.0f, 0.0f, 1.0f, 1.0f ), Vec4( 0.0f, 1.0f, 0.0f, 1.0f ) );
		// cancel rotation out
		delta.origin.zero;
		delta.axis = local.axis.transpose;
		local *= delta;
		checkTransforms( local, Vec3( 0.0f, 0.0f, 1.0f ), Vec3( 0.0f, 0.0f, 1.0f ), false );
		checkTransforms( local, Vec4( 0.0f, 0.0f, 1.0f, 0.0f ), Vec4( 0.0f, 0.0f, 1.0f, 0.0f ) );
	}
}
