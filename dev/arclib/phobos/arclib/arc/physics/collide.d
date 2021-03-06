/******************************************************************************* 

	Code for physics collisions. 

	Authors:       ArcLib team, see AUTHORS file 
	Maintainer:    Christian Kamm (kamm incasoftware de) 
	License:       zlib/libpng license: $(LICENSE) 
	Copyright:      ArcLib team 

	The contents of this file are based on E. Catto's Box2d, which is 
	Copyright (c) 2006 Erin Catto http://www.gphysics.com. 

	Description:    
		Code for physics collisions. 

	Examples:      
	---------------------
	None provided 
	---------------------

*******************************************************************************/

module arc.physics.collide;

import 
	arc.types,
	arc.physics.arbiter,
	arc.physics.mybody,
	arc.math.point,
	arc.math.matrix,
	arc.math.routines; 

/// collision functions between body-derived classes must follow this signature
alias int function(inout Contact[], Body bodyA, Body bodyB) Collider;

/***
	sets the collision function to be used for a collision between
	shapes with the given ClassInfos
*/
void registerCollider(B1,B2)(Collider f)
{
	if(collision_key(B1.classinfo, B2.classinfo) in colliders)
		throw new Error("Collision between " ~ B1.classinfo.name ~ " and " ~ B2.classinfo.name ~ " already registered!");
	
	colliders[collision_key(B1.classinfo, B2.classinfo)] = f;
}

/// gets the correct collision function for colliding two body-derived classes
Collider getCollider(Body bodya, Body bodyb)
{
	ClassInfo ca = bodya.classinfo, cb = bodyb.classinfo;
	collision_key key;
	while(ca !is Body.classinfo)
	{
		while(cb !is Body.classinfo)
		{
			key = collision_key(ca,cb);
			if(key in colliders)
				return colliders[key];
			
			cb = cb.base;
		}
		cb = bodyb.classinfo;
		ca = ca.base;
	}
	
	throw new Error("Collision between " ~ bodya.classinfo.name ~ " and " ~ bodyb.classinfo.name ~ " or any of their base classes not registered!");
}

/// Feature Pair struct 
struct FeaturePair
{
	int inEdge1=0;
	int outEdge1=0;

	int inEdge2=0;
	int outEdge2=0; 

	/// key in feature pair
	int key()
	{
		return inEdge1 + (outEdge1 << 8) + (inEdge2 << 16) + (outEdge2 << 24);
	}
}

/// Contact struct 
struct Contact
{
	Point position;
	Point normal;
	
	/// - penetration
	arcfl separation = 0;
	
	arcfl accumulated_normal_impulse = 0;
	arcfl accumulated_tangent_impulse = 0;
	
	/// mass weights for normal and tangent
	arcfl mass_normal=0, mass_tangent=0;
	
	/// velocity resulting from bouncyness of objects
	/// mainly controlled from Body.restitution
	arcfl restitution_velocity=0;
	
	/// velocity set to resolve penetrations
	arcfl bias_velocity=0;
	
	/// contact identifier to identify a contact that simply moved
	/// in order to keep the accumulated impulses between timesteps
	FeaturePair feature;
}

private
{
	struct Pair(T, U)
	{
		static Pair!(T, U) opCall(T t, U u)
		{
			Pair!(T, U) p;
			p.first = t;
			p.second = u;
			return p;
		}
		
		T first;
		U second;
	}
	
	alias Pair!(ClassInfo, ClassInfo) collision_key;
	
	Collider[collision_key] colliders;
}
