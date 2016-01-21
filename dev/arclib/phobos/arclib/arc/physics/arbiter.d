/******************************************************************************* 

	Arbiter calculates contact points between two bodies. 

	Authors:       ArcLib team, see AUTHORS file 
	Maintainer:    Christian Kamm (kamm incasoftware de) 
	License:       zlib/libpng license: $(LICENSE) 
	Copyright:      ArcLib team 

	The contents of this file are based on E. Catto's Box2d, which is 
	Copyright (c) 2006 Erin Catto http://www.gphysics.com. 

	Description:    
	Arbiter calculates contact points between two bodies. 

	Examples:      
	---------------------
	None provided 
	---------------------

*******************************************************************************/

module arc.physics.arbiter; 

import 
	arc.physics.collide, 
	arc.physics.mybody,
	arc.math.point,
	arc.math.matrix,
	arc.math.routines,
	arc.types;

import std.math;

///TODO: polygons might have an arbitrary number of collision points.
const size_t MAX_COLLISION_POINTS = 2; 

/// Arbiter struct 
struct Arbiter
{
	/// whether this arbiter's contacts have been calculated this round
	bool updated = false;
	/// remove the arbiter after this round?
	bool remove = false;
	
	size_t nContacts = 0;
	Contact[] contacts;
	
	Body body1, body2;
	
	/// combined friction
	arcfl combined_friction = 0;
	/// combined restitution
	arcfl combined_restitution = 0;
	
	/// test if arbiter equals another arbiter 
	bool opEquals(inout Arbiter a)
	{
		return (body1 is a.body1 && body2 is a.body2);
	}

	/// order arbiters lexographically by (body1, body2)
	int opCmp(inout Arbiter a)
	{
		if (body1.toHash() < a.body1.toHash())
			return -1;
		if (body1.toHash() > a.body1.toHash())
			return 1;

		if (body2.toHash() < a.body2.toHash())
			return -1;		
		if (body2.toHash() > a.body2.toHash())
			return 1;
		
		return 0;
	}	
	
	/// only use to generate dumb keys
	static Arbiter opCall(Body a, Body b)
	{
		Arbiter arb;
			
		if (a.toHash() < b.toHash())
		{
			arb.body1 = a;
			arb.body2 = b;
		}
		else
		{
			arb.body1 = b;
			arb.body2 = a;
		}
		
		return arb;
	}
	
	/// Arbiter constructor 
	static Arbiter opCall(Body a, Body b, Contact[] acontacts, size_t anContacts)
	{
		Arbiter arb = Arbiter(a, b);
		
		// why's contacts not a static array, then?
		arb.contacts.length = MAX_COLLISION_POINTS;
		
		arb.nContacts = anContacts;
		for(size_t i = 0; i < anContacts; ++i)
			arb.contacts[i] = acontacts[i];
		
		arb.combined_friction = sqrt(arb.body1.friction * arb.body2.friction);
		arb.combined_restitution = arb.body1.restitution * arb.body2.restitution;
		
		return arb;		
	}

	/// updates an existing arbiter with new collision points
	void update(Contact[] new_contacts, int n_new_contacts)
	in
	{
		assert(n_new_contacts <= MAX_COLLISION_POINTS);
	}
	out
	{
		assert(nContacts == n_new_contacts);
	}
	body
	{
		Contact[] merged_contacts;
		merged_contacts.length = MAX_COLLISION_POINTS;

		for (size_t i = 0; i < n_new_contacts; ++i)
		{
			// take all the data from the new contact
			merged_contacts[i] = new_contacts[i];
			
			// go through existing contacts and check if there's one with
			// the same key, so we can copy over the accumulated impulses
			for (size_t j = 0; j < nContacts; ++j)
			{
				if (new_contacts[i].feature.key == contacts[j].feature.key)
				{
					merged_contacts[i].accumulated_normal_impulse = contacts[j].accumulated_normal_impulse;
					merged_contacts[i].accumulated_tangent_impulse = contacts[j].accumulated_tangent_impulse;
					break;
				}
			}
		}

		for (size_t i = 0; i < n_new_contacts; ++i)
			contacts[i] = merged_contacts[i];

		nContacts = n_new_contacts;
	}	

	/**
		Performs once-per timestep actions and precomputations for the following iterations.
		- calculate normal and tangent mass vectors
		- compute restitution velocity
		- compute bias velocity
		- apply accumulated impulses for coherence
	*/
	void preStep(arcfl inv_dt)
	{
		const arcfl k_allowedPenetration = 0.01f;
		const arcfl bias_factor = 0.5f;
		//TODO: Investigate if the dampening code makes sense, especially since it's on-contact-only
		// don't know what this does
		const arcfl damping = 0.0f; 
		 // damps angular velocity to approximate rolling friction
		const arcfl angular_damping = 0.5f;

		// angular damping
		//BUG: This does not really work. Besides, it wasn't configurable anyway
//		body1.angularVelocity *= (1.0f - 1/(1000*inv_dt)) * angular_damping;
//		body2.angularVelocity *= (1.0f - 1/(1000*inv_dt)) * angular_damping;
		
		for (int i = 0; i < nContacts; ++i)
		{
			Point r1 = contacts[i].position - body1.translation;
			Point r2 = contacts[i].position - body2.translation;

			//
			// Precompute normal mass, tangent mass
			//
			
			arcfl rn1 = r1.dot(contacts[i].normal);
			arcfl rn2 = r2.dot(contacts[i].normal);
			arcfl kNormal = body1.getInvMass + body2.getInvMass;
			kNormal += body1.getInvInertia * (r1.lengthSquared - rn1*rn1) + body2.getInvInertia * (r2.lengthSquared - rn2*rn2);
			contacts[i].mass_normal = (1.0f - damping) / kNormal;

			Point tangent = -Point.makePerpTo(contacts[i].normal);
			arcfl rt1 = r1.dot(tangent);
			arcfl rt2 = r2.dot(tangent);
			arcfl kTangent = body1.getInvMass + body2.getInvMass;
			kTangent += body1.getInvInertia * (r1.lengthSquared - rt1*rt1) + body2.getInvInertia * (r2.lengthSquared - rt2*rt2);
			contacts[i].mass_tangent = (1.0f - damping) /  kTangent;

			//
			// Compute restitution
			//
			
			Point dv = body2.preStep_velocity + body2.preStep_angularVelocity * Point.makePerpTo(r2) - body1.preStep_velocity - body1.preStep_angularVelocity * Point.makePerpTo(r1);
			// velocity in normal direction
			arcfl vn = dv.dot(contacts[i].normal);
			// velocity change from forces in normal direction needs to be undone for stability
			arcfl dvn = (body2.force * body2.getInvMass - body1.force * body1.getInvMass).dot(contacts[i].normal) / inv_dt;
			contacts[i].restitution_velocity = -(vn - dvn) * combined_restitution;
			
			//TODO: does this clamping make sense?
			if(contacts[i].restitution_velocity < 0.0f)
				contacts[i].restitution_velocity = 0.0f;
			
			//
			// Compute bias
			//
			
			// Overlapping objects should be moved out of one another.
			// Bias is a additional impulse used to achieve that.						
			// if the restitution impulse is enough to clear the overlap in
			// one step: bias = 0 - else, use bias
			if(contacts[i].restitution_velocity >= - contacts[i].separation * inv_dt)
				contacts[i].bias_velocity = 0.0f;
			else
				contacts[i].bias_velocity = - bias_factor * min!(arcfl)(0.0f, inv_dt * (contacts[i].separation + k_allowedPenetration) + contacts[i].restitution_velocity);

			// damping
			contacts[i].accumulated_normal_impulse *= (1.0f - damping);
			
			//
			// Apply last step's normal + friction impulse
			//
			
			Point impulse = contacts[i].accumulated_normal_impulse * contacts[i].normal + contacts[i].accumulated_tangent_impulse * tangent;

			body1.velocity -= body1.getInvMass * impulse;
			body1.angularVelocity -= body1.getInvInertia * r1.cross(impulse);

			body2.velocity += body2.getInvMass * impulse;
			body2.angularVelocity += body2.getInvInertia * r2.cross(impulse);
		}
	}

	/**
		Perform one step of the iteration by trying to reach the desired
		velocities through applying impulses
	*/
	void applyImpulse()
	{
		for (int i = 0; i < nContacts; ++i)
		{
			Point r1 = contacts[i].position - body1.translation;
			Point r2 = contacts[i].position - body2.translation;

			//
			// normal impulses
			//
			
			// Relative velocity at contact
			Point dv = body2.velocity + body2.angularVelocity * Point.makePerpTo(r2) - body1.velocity - body1.angularVelocity * Point.makePerpTo(r1);
			Point bdv = body2.biasVelocity + body2.biasAngularVelocity * Point.makePerpTo(r2) - body1.biasVelocity - body1.biasAngularVelocity * Point.makePerpTo(r1);
			
			// Compute normal impulse with bias.
			arcfl vn = dv.dot(contacts[i].normal);
			arcfl normalImpulse = contacts[i].mass_normal * (-vn + contacts[i].restitution_velocity);
			
			arcfl bvn = bdv.dot(contacts[i].normal);
			arcfl biasNormalImpulse = contacts[i].mass_normal * (-bvn + contacts[i].bias_velocity);
			
			// Clamp the accumulated impulse
			arcfl oldNormalImpulse = contacts[i].accumulated_normal_impulse;
			contacts[i].accumulated_normal_impulse = max!(arcfl)(oldNormalImpulse + normalImpulse, 0.0f);
			normalImpulse = contacts[i].accumulated_normal_impulse - oldNormalImpulse;

			// Apply contact impulse
			Point impulse = normalImpulse * contacts[i].normal;
			Point biasImpulse = biasNormalImpulse * contacts[i].normal;

			body1.velocity -= body1.getInvMass * impulse;
			body1.angularVelocity -= body1.getInvInertia * r1.cross(impulse);
			
			body2.velocity += body2.getInvMass * impulse;
			body2.angularVelocity += body2.getInvInertia * r2.cross(impulse);
			
			body1.biasVelocity -= body1.getInvMass * biasImpulse;
			body1.biasAngularVelocity -= body1.getInvInertia * r1.cross(biasImpulse);

			body2.biasVelocity += body2.getInvMass * biasImpulse;
			body2.biasAngularVelocity += body2.getInvInertia * r2.cross(biasImpulse);

			//
			// tangential impulses (kinetic friction)
			//
			
			// Relative velocity at contact
			dv = body2.velocity + body2.angularVelocity * Point.makePerpTo(r2) - body1.velocity - body1.angularVelocity * Point.makePerpTo(r1);

			// Compute friction impulse
			arcfl maxTangentImpulse = combined_friction * contacts[i].accumulated_normal_impulse;

			Point tangent = - Point.makePerpTo(contacts[i].normal);
			arcfl vt = dv.dot(tangent);
			arcfl tangentImpulse = contacts[i].mass_tangent * (-vt);
			
			// Clamp friction
			arcfl oldTangentImpulse = contacts[i].accumulated_tangent_impulse;
			contacts[i].accumulated_tangent_impulse = clamp(oldTangentImpulse + tangentImpulse, -maxTangentImpulse, maxTangentImpulse);
			tangentImpulse = contacts[i].accumulated_tangent_impulse - oldTangentImpulse;

			// Apply contact impulse
			impulse = tangentImpulse * tangent;
			
			body1.velocity -= body1.getInvMass * impulse;
			body1.angularVelocity -= body1.getInvInertia * r1.cross(impulse);

			body2.velocity += body2.getInvMass * impulse;
			body2.angularVelocity += body2.getInvInertia * r2.cross(impulse);			
		}
	}    
}




