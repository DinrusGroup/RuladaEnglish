/**
	Copyright: Copyright (c) 2007, Artyom Shalkhakov. All rights reserved.
	License: BSD

	This module implements ray class.

	Version: Aug 2007: initial release
	Authors: Artyom Shalkhakov
*/
module auxd.ray.base.Ray;

import Math = auxd.ray.base.Math;
import auxd.ray.base.Vector;

const Ray	ray_zero = { origin : { x : 0.0f, y : 0.0f, z : 0.0f }, dir : { x : 0.0f, y : 0.0f, z : 0.0f } };

/// _Ray
struct Ray {
	static Ray opCall( ref Vec3 origin ) {
		Ray	dst;

		dst.origin = origin;

		return dst;
	}

	static Ray opCall( ref Vec3 origin, ref Vec3 dir ) {
		Ray	dst;

		dst.origin = origin;
		dst.dir = dir;
		dst.invDir.set( 1.0f / dir.x, 1.0f / dir.y, 1.0f / dir.z );
		dst.signbits = ( Math.signbit( dst.invDir.z ) << 2 ) | ( Math.signbit( dst.invDir.y ) << 1 ) | Math.signbit( dst.invDir.x );

		return dst;
	}

	/// returns the closest point on ray to point
	Vec3 closestPoint( ref Vec3 p ) {
		double	t = dir * ( p - origin );

		return ( t < 0.0f ) ? origin : origin + dir * t;
	}

	/// returns the closest distance between point and ray
	float distance( ref Vec3 p ) {
		return ( closestPoint( p ) - origin ).magnitude;
	}

	/**
		Returns ray refracted about the normal. The returned ray will have zero direction in case of
		total internal refraction.
		Inside is the index of refraction inside of the surface (on the positive _normal side).
		Outside is the index of refraction outside of the surface (on the positive _normal side).
	*/
	Ray refract( ref Vec3 normal, float inside, float outside ) {
		Vec3	w = -dir.normalize;
		Vec3	n = normal;
		float	h1 = outside;
		float	h2 = inside;
		float	ratio, dot, det;

		if ( normal * dir > 0.0f ) {
			h1 = inside;
			h2 = outside;
			normal = -normal;
		}

		ratio = h1 / h2;
		dot = w * n;
		det = 1.0f - ( ratio * ratio ) * ( 1.0f - dot * dot );

		if ( det < 0.0f ) {
			// total internal reflection
			// FIXME: this Vec3 should be replaced by vec3_zero
			return Ray( origin, Vec3( 0.0f, 0.0f, 0.0f ) );
		}
		return Ray( origin, -ratio * ( w - n * dot ) - n * Math.sqrt( det ) );
	}

	/// refracts ray about the normal
	void refractSelf( ref Vec3 normal, float inside, float outside ) {
		Vec3	w = -dir.normalize;
		Vec3	n = normal;
		float	h1 = outside;
		float	h2 = inside;
		float	ratio, dot, det;

		if ( normal * dir > 0.0f ) {
			h1 = inside;
			h2 = outside;
			normal = -normal;
		}

		ratio = h1 / h2;
		dot = w * n;
		det = 1.0f - ( ratio * ratio ) * ( 1.0f - dot * dot );

		if ( det < 0.0f ) {
			// total internal reflection
			dir.zero;
			return;
		}
		dir = -ratio * ( w - n * dot ) - n * Math.sqrt( det );
	}

	/// returns ray reflected about the normal
	Ray reflect( ref Vec3 normal ) {
		float	d = 2.0f * dir * normal;

		return Ray( origin, dir - normal * d );
	}

	/// reflects ray about the normal
	void reflectSelf( ref Vec3 normal ) {
		float	d = 2.0f * dir * normal;

		dir -= normal * d;
	}

	/// returns string, just a convenience function
	char[] toUtf8() {
		return Math.toUtf8( "( O:{0} R:{1} )", origin.toUtf8, dir.toUtf8 );
	}

	debug ( FLOAT_PARANOID ) {
		invariant() {
			assert( Math.isValid( origin.x ) );
			assert( Math.isValid( origin.y ) );
			assert( Math.isValid( origin.z ) );
			assert( Math.isValid( dir.x ) );
			assert( Math.isValid( dir.y ) );
			assert( Math.isValid( dir.z ) );
			if ( dir.x ) {
				assert( Math.isValid( invDir.x ) );
			}
			if ( dir.y ) {
				assert( Math.isValid( invDir.y ) );
			}
			if ( dir.z ) {
				assert( Math.isValid( invDir.z ) );
			}
		}
	}

	Vec3	origin;		/// ray origin
	Vec3	dir;		/// ray direction, may be non-normalized
	Vec3	invDir;		/// inverse of ray direction
	int		signbits;	/// signbits of invDir:  signX + ( signY << 1 ) + ( signZ << 2 )
}
