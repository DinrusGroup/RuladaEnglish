/**
	Copyright: Copyright (c) 2007, Artyom Shalkhakov. All rights reserved.
	License: BSD

	This module implements pluecker coordinates for line segments.

	Version: Aug 2007: initial release
	Authors: Artyom Shalkhakov
*/
module auxd.ray.base.Pluecker;

import Math = auxd.ray.base.Math;
import auxd.ray.base.Vector;
import auxd.ray.base.Plane;

const Pluecker	pluecker_zero = { p : [ 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f ] };

/// Pluecker coordinate
struct Pluecker {
	static Pluecker opCall( float[6] p ) {
		Pluecker	pl;

		pl.p[0] = p[0];
		pl.p[1] = p[1];
		pl.p[2] = p[2];
		pl.p[3] = p[3];
		pl.p[4] = p[4];
		pl.p[5] = p[5];

		return pl;
	}

	static Pluecker opCall( ref Vec3 start, ref Vec3 end ) {
		Pluecker	pl;

		pl.fromLineSegment( start, end );

		return pl;
	}

	static Pluecker opCall( float a1, float a2, float a3, float a4, float a5, float a6 ) {
		Pluecker	pl;

		with ( pl ) {
			p[0] = a1;
			p[1] = a2;
			p[2] = a3;
			p[3] = a4;
			p[4] = a5;
			p[5] = a6;
		}

		return pl;
	}

	/// returns Pluecker coordinate with flipped direction
	Pluecker opNeg() {
		return Pluecker( -p[0], -p[1], -p[2], -p[3], -p[4], -p[5] );
	}

	Pluecker opAdd( ref Pluecker a ) {
		return Pluecker( p[0] + a.p[0], p[1] + a.p[1], p[2] + a.p[2], p[3] + a.p[3], p[4] + a.p[4], p[5] + a.p[5] );
	}

	Pluecker opSub( ref Pluecker a ) {
		return Pluecker( p[0] - a.p[0], p[1] - a.p[1], p[2] - a.p[2], p[3] - a.p[3], p[4] - a.p[4], p[5] - a.p[5] );
	}

	Pluecker opMul( float f )
	in {
		debug ( FLOAT_PARANOID ) {
			assert( Math.isValid( f ) );
		}
	}
	body {
		return Pluecker( p[0] * f, p[1] * f, p[2] * f, p[3] * f, p[4] * f, p[5] * f );
	}

	/// permuted inner product
	float opMul( Pluecker a ) {
		return p[0] * a.p[4] + p[1] * a.p[5] + p[2] * a.p[3] + p[4] * a.p[0] + p[5] * a.p[1] + p[3] * a.p[2];
	}

	Pluecker opDiv( float f )
	in {
		debug ( FLOAT_PARANOID ) {
			assert( Math.isValid( f ) );
			assert( Math.abs( f - 0.0f ) > 1e-14 );
		}
	}
	body {
		float	invF = 1.0f / f;

		return Pluecker( p[0] * invF, p[1] * invF, p[2] * invF, p[3] * invF, p[4] * invF, p[5] * invF );
	}

	void opAddAssign( ref Pluecker a ) {
		p[0] += a.p[0];
		p[1] += a.p[1];
		p[2] += a.p[2];
		p[3] += a.p[3];
		p[4] += a.p[4];
		p[5] += a.p[5];
	}

	void opSubAssign( ref Pluecker a ) {
		p[0] -= a.p[0];
		p[1] -= a.p[1];
		p[2] -= a.p[2];
		p[3] -= a.p[3];
		p[4] -= a.p[4];
		p[5] -= a.p[5];
	}

	void opMulAssign( float f )
	in {
		debug ( FLOAT_PARANOID ) {
			assert( Math.isValid( f ) );
		}
	}
	body {
		p[0] *= f;
		p[1] *= f;
		p[2] *= f;
		p[3] *= f;
		p[4] *= f;
		p[5] *= f;
	}

	void opDivAssign( float f )
	in {
		debug ( FLOAT_PARANOID ) {
			assert( Math.isValid( f ) );
			assert( Math.abs( f - 0.0f ) > 1e-14 );
		}
	}
	body {
		float	invF = 1.0f / f;

		p[0] *= invF;
		p[1] *= invF;
		p[2] *= invF;
		p[3] *= invF;
		p[4] *= invF;
		p[5] *= invF;
	}

	/// exact compare
	bool opEquals( ref Pluecker a ) {
		return ( p[0] == a.p[0] && p[1] == a.p[1] && p[2] == a.p[2] && p[3] == a.p[3] && p[4] == a.p[4] && p[5] == a.p[5] );
	}

	/// compare with epsilon
	bool compare( ref Pluecker a, float epsilon ) {
		if ( Math.abs( p[0] - a.p[0] ) > epsilon ) {
			return false;
		}
		if ( Math.abs( p[1] - a.p[1] ) > epsilon ) {
			return false;
		}
		if ( Math.abs( p[2] - a.p[2] ) > epsilon ) {
			return false;
		}
		if ( Math.abs( p[3] - a.p[3] ) > epsilon ) {
			return false;
		}
		if ( Math.abs( p[4] - a.p[4] ) > epsilon ) {
			return false;
		}
		if ( Math.abs( p[5] - a.p[5] ) > epsilon ) {
			return false;
		}
		return true;
	}

	void set( float a1, float a2, float a3, float a4, float a5, float a6 ) {
		p[0] = a1;
		p[1] = a2;
		p[2] = a3;
		p[3] = a4;
		p[4] = a5;
		p[5] = a6;
	}

	void zero() {
		p[] = 0.0f;
	}

	float magnitude() {
		return Math.sqrt( p[5] * p[5] + p[4] * p[4] + p[2] * p[2] );
	}

	float magnitudeSquared() {
		return ( p[5] * p[5] + p[4] * p[4] + p[2] * p[2] );
	}

	Pluecker normalize() {
		float	d;
	
		d = magnitudeSquared;
		if ( d == 0.0f ) {
			return *this;	// pluecker coordinate does not represent a line
		}
		d = 1.0f / Math.sqrt( d );
		return Pluecker( p[0] * d, p[1] * d, p[2] * d, p[3] * d, p[4] * d, p[5] * d ); 
	}

	/// returns magnitude
	float normalizeSelf() {
		float	l = magnitudeSquared, d;

		if ( l == 0.0f ) {
			return l; // pluecker coordinate does not represent a line
		}

		d = 1.0f / Math.sqrt( l );

		p[0] *= d;
		p[1] *= d;
		p[2] *= d;
		p[3] *= d;
		p[4] *= d;
		p[5] *= d;

		return d * l;
	}

	float permutedInnerProduct( ref Pluecker a ) {
		return p[0] * a.p[4] + p[1] * a.p[5] + p[2] * a.p[3] + p[4] * a.p[0] + p[5] * a.p[1] + p[3] * a.p[2];
	}

	void fromLineSegment( ref Vec3 start, ref Vec3 end ) {
		p[0] = start.x * end.y - end.x * start.y;
		p[1] = start.x * end.z - end.x * start.z;
		p[2] = start.x - end.x;
		p[3] = start.y * end.z - end.y * start.z;
		p[4] = start.z - end.z;
		p[5] = end.y - start.y; 
	}

	void fromRay( ref Vec3 start, ref Vec3 dir ) {
		p[0] = start.x * dir.y - dir.x * start.y;
		p[1] = start.x * dir.z - dir.x * start.z;
		p[2] = -dir.x;
		p[3] = start.y * dir.z - dir.y * start.z;
		p[4] = -dir.z;
		p[5] = dir.y; 
	}

	/// pluecker coordinate for the intersection of two planes
	bool fromPlanes( ref Plane p1, ref Plane p2 ) {
		p[0] = -( p1[2] * -p2[3] - p2[2] * -p1[3] );
		p[1] = -( p2[1] * -p1[3] - p1[1] * -p2[3] );
		p[2] = p1[1] * p2[2] - p2[1] * p1[2];

		p[3] = -( p1[0] * -p2[3] - p2[0] * -p1[3] );
		p[4] = p1[0] * p2[1] - p2[0] * p1[1];
		p[5] = p1[0] * p2[2] - p2[0] * p1[2];

		return ( p[2] != 0.0f || p[5] != 0.0f || p[4] != 0.0f ); 
	}

	/**
		Convert pluecker coordinate to line segment.
		Returns false if pluecker coodinate does not represent a line.
	*/
	bool toLineSegment( ref Vec3 start, ref Vec3 end ) {
		Vec3	dir1, dir2;
		float	d;
	
		dir1.x = p[3];
		dir1.y = -p[1];
		dir1.z = p[0];	
		dir2.x = -p[2];
		dir2.y = p[5];
		dir2.z = -p[4];

		d = dir2 * dir2;
		if ( d == 0.0f ) {
			return false; 	// pluecker coordinate does not represent a line
		}
	
		start = dir2.cross( dir1 ) * ( 1.0f / d );
		end = start + dir2;
		return true; 
	}

	/**
		Convert pluecker coordinate to auxd.ray.
		Returns false if pluecker coordinate does not represent a line.
	*/
	bool toRay( ref Vec3 start, ref Vec3 dir ) {
		Vec3	dir1;
		float	d;

		dir1.x = p[3];
		dir1.y = -p[1];
		dir1.z = p[0];
		dir.x = -p[2];
		dir.y = p[5];
		dir.z = -p[4];

		d = dir * dir;
		if ( d == 0.0f ) {
			return false; 	// pluecker coordinate does not represent a line
		}
	
		start = dir.cross( dir1 ) * ( 1.0f / d );
		return true; 
	}

	/// convert pluecker coordinate to direction vector
	void toDir( ref Vec3 dir ) {
		dir.x = -p[2];
		dir.y = p[5];
		dir.z = -p[4]; 
	}

	/// converts to string; just a convenience function
	char[] toUtf8() {
		return Math.toUtf8( "( P( {0:E} {1:E} {2:E} ); Q( {3:E} {4:E} {5:E} ) )", p[0], p[1], p[2], p[3], p[4], p[5] );
	}

	size_t length() {
		return 6;
	}

	float *ptr() {
		return p.ptr;
	}

	debug ( FLOAT_PARANOID ) {
		invariant() {
			assert( Math.isValid( p[0] ) );
			assert( Math.isValid( p[1] ) );
			assert( Math.isValid( p[2] ) );
			assert( Math.isValid( p[3] ) );
			assert( Math.isValid( p[4] ) );
			assert( Math.isValid( p[5] ) );
		}
	}

	float[6]	p;
}
