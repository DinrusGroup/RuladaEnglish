/**
	Copyright: Copyright (c) 2007, Artyom Shalkhakov. All rights reserved.
	License: BSD

	Version: Aug 2007: initial release
	Authors: Artyom Shalkhakov
*/
module auxd.ray.base.Plane;

import Math = auxd.ray.base.Math;
import auxd.ray.base.Vector;

const Plane	plane_zero = { normal : { x : 0.0f, y : 0.0f, z : 0.0f }, dist : 0.0f };

/// classification
enum PLANESIDE : int {
	FRONT	= 0,		/// in front of plane
	BACK	= 1,		/// behind plane
	ON		= 2,		/// lies on plane
	CROSS	= 3			/// crosses plane
}

/**
	Plane defined through normal vector and signed distance to origin of coordinates.
*/
struct Plane {
	/// construct plane given normal and distance
	static Plane opCall( ref Vec3 normal, float dist ) {
		Plane	dst;

		dst.normal = normal;
		dst.dist = dist;

		return dst;
	}

	float opIndex( size_t index )
	in {
		assert( index >= 0 && index < 4 );
	}
	body {
		return normal.ptr[index];
	}

	void opIndexAssign( float f, size_t index )
	in {
		assert( index >= 0 && index < 4 );
	}
	body {
		normal.ptr[index] = f;
	}

	Plane opNeg() {
		return Plane( -normal, -dist );
	}

	/// add plane equations
	Plane opAdd( ref Plane p ) {
		return Plane( normal + p.normal, dist + p.dist );
	}

	/// subtract plane equations
	Plane opSub( ref Plane p ) {
		return Plane( normal - p.normal, dist - p.dist );
	}

	/// returns rotated plane
	Plane opMul( ref Mat3 axis ) {
		return Plane( normal * axis, dist );
	}

	/// add plane equations
	void opAddAssign( ref Plane p ) {
		normal += p.normal;
		dist += p.dist;
	}

	/// subtract plane equations in place
	void opSubAssign( ref Plane p ) {
		normal -= p.normal;
		dist -= p.dist;
	}

	/// rotate plane in place
	void opMulAssign( ref Mat3 axis ) {
		normal *= axis;
	}

	/// exact compare
	bool opEquals( Plane p ) {
		return ( normal == p.normal && dist == p.dist );
	}

	/// compare with epsilon
	bool compare( ref Plane p, float epsilon ) {
		if ( !normal.compare( p.normal, epsilon ) ) {
			return false;
		}
		if ( Math.abs( dist - p.dist ) > epsilon ) {
			return false;
		}
		return true;
	}

	/// compare with separate normal/dist epsilon
	bool compare( ref Plane p, float normalEps, float distEps ) {
		if ( !normal.compare( p.normal, normalEps ) ) {
			return false;
		}
		if ( Math.abs( dist - p.dist ) > distEps ) {
			return false;
		}
		return true;
	}

	/// make _zero plane
	void zero() {
		normal.zero();
		dist = 0.0f;
	}

	/// initialize plane using three points, returns true if plane is valid
	bool fromPoints( ref Vec3 p1, ref Vec3 p2, ref Vec3 p3 ) {
		normal = ( p2 - p1 ).cross( p3 - p2 );

		if ( normal.normalizeSelf() == 0.0f ) {
			return false;
		}

		dist = normal * p1;

		return true;
	}

	/// initialize plane from direction vectors, returns true if plane is valid
	bool fromVecs( ref Vec3 dir1, ref Vec3 dir2, ref Vec3 p ) {
		normal = dir1.cross( dir2 );

		if ( normal.normalizeSelf() == 0.0f ) {
			return false;
		}

		dist = normal * p;

		return true;
	}

	/// returns translated plane
	Plane translate( ref Vec3 translation ) {
		return Plane( normal, dist + translation * normal );
	}

	/// translate plane
	void translateSelf( ref Vec3 translation ) {
		dist += translation * normal;
	}

	/// returns rotated plane
	Plane rotate( ref Vec3 origin, ref Mat3 axis ) {
		Vec3	rotated = normal * axis;

		return Plane( rotated, dist - origin * normal + origin * rotated );
	}

	/// rotate plane
	void rotateSelf( ref Vec3 origin, ref Mat3 axis ) {
		dist -= origin * normal;
		normal *= axis;
		dist += origin * normal;
	}

	/// sets plane distance using provided point
	// assumes normal is valid
	void fitThroughPoint( ref Vec3 p ) {
		dist = normal * p;
	}

	/// compute distance from point to plane
	float distance( Vec3 p ) {
		return ( ( normal * p ) - dist );
	}

	/// classify point against plane
	int side( ref Vec3 p, float epsilon = 0.0f ) {
		float	dist = distance( p );

		if ( dist > epsilon ) {
			return PLANESIDE.FRONT;
		}
		if ( dist < -epsilon ) {
			return PLANESIDE.BACK;
		}

		return PLANESIDE.ON;
	}

	/**
		Returns intersection time if ray intersects plane, float.infinity otherwise.
	*/
	float rayIntersection( ref Vec3 start, ref Vec3 dir ) {
		float	d1 = normal * start - dist;
		float	d2 = normal * dir;

		if ( d2 == 0.0f ) {
			return float.infinity;
		}
		return -( d1 / d2 );
	}

	/**
		Returns true if ray intersects plane.
		Intersection point is start + scale * dir.
	*/
	bool rayIntersection( ref Vec3 start, ref Vec3 dir, out float scale ) {
		float	d1 = normal * start - dist;
		float	d2 = normal * dir;

		if ( d2 == 0.0f ) {
			return false;
		}

		scale = -( d1 / d2 );
		return true;
	}

	/// returns true if plane intersects plane
	bool planeIntersection( ref Plane p, ref Vec3 start, ref Vec3 dir ) {
		double	n00 = normal.magnitudeSquared;
		double	n01 = normal * p.normal;
		double	n11 = p.normal.magnitudeSquared;
		double	det = n00 * n11 - n01 * n01;

		if ( Math.abs( det ) < MATRIX_EPSILON ) {
			return false;
		}

		double	invDet = 1.0f / det;
		double	f0 = ( n11 * dist - n01 * p.dist ) * invDet;
		double	f1 = ( n00 * p.dist - n01 * dist ) * invDet;

		dir = normal.cross( p.normal );
		start = f0 * normal + f1 * p.normal;

		return true;
	}

	/// converts to string; just a convenience function
	char[] toUtf8() {
		return Math.toUtf8( "( N:{0} D:{3,4E} )", normal.toUtf8, dist );
	}

	/// returns the number of components
	size_t length() {
		return 4;
	}

	/// returns raw pointer
	float *ptr() {
		return normal.ptr;
	}

	debug ( FLOAT_PARANOID ) {
		invariant() {
			assert( Math.isValid( normal.x ) );
			assert( Math.isValid( normal.y ) );
			assert( Math.isValid( normal.z ) );
			assert( Math.isValid( dist ) );
		}
	}

	Vec3	normal;		/// plane normal
	float	dist;		/// distance from origin of coordinate frame
}
