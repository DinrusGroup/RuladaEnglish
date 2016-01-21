/******************************************************************************* 

	Code for joint. 

	Authors:       ArcLib team, see AUTHORS file 
	Maintainer:    Christian Kamm (kamm incasoftware de) 
	License:       zlib/libpng license: $(LICENSE) 
	Copyright:     ArcLib team 

	The contents of this file are based on E. Catto's Box2d, which is 
	Copyright (c) 2006 Erin Catto http://www.gphysics.com. 

	Description:    
		Code for joint. 

	Examples:      
	---------------------
	None provided 
	---------------------

*******************************************************************************/
module arc.physics.joint; 

import arc.physics.mybody; 

import 
	arc.math.point,
	arc.math.matrix,
	arc.math.routines,
	arc.scenegraph.node,
	arc.types;

/// joint structure 
class Joint : Node
{
	/// set joint between two bodies with a certain point
	this(Body b1, Body b2, inout Point anchor)
	{
		body1 = b1;
		body2 = b2;

		Matrix Rot1 = Matrix(body1.rotation);
		Matrix Rot2 = Matrix(body2.rotation);
		Matrix Rot1T = Rot1.transposeCopy();
		Matrix Rot2T = Rot2.transposeCopy();

		localAnchor1 = Rot1T * (anchor - body1.translation);
		localAnchor2 = Rot2T * (anchor - body2.translation);

		relaxation = 1.0f;
	}

	/// prestep 
	void preStep(arcfl inv_dt)
	{
		// Pre-compute anchors, mass matrix, and bias.
		Matrix Rot1 = Matrix(body1.rotation);
		Matrix Rot2 = Matrix(body2.rotation);

		r1 = Rot1 * localAnchor1;
		r2 = Rot2 * localAnchor2;

		// deltaV = deltaV0 + K * impulse
		// invM = [(1/m1 + 1/m2) * eye(2) - skew(r1) * invInertia1 * skew(r1) - skew(r2) * invInertia2 * skew(r2)]
		//      = [1/m1+1/m2     0    ] + invInertia1 * [r1.y*r1.y -r1.x*r1.y] + invInertia2 * [r1.y*r1.y -r1.x*r1.y]
		//        [    0     1/m1+1/m2]           [-r1.x*r1.y r1.x*r1.x]           [-r1.x*r1.y r1.x*r1.x]
		Matrix K1;
		K1.col1.x = body1.getInvMass + body2.getInvMass;	K1.col2.x = 0.0f;
		K1.col1.y = 0.0f;								K1.col2.y = body1.getInvMass + body2.getInvMass;

		Matrix K2;
		K2.col1.x =  body1.getInvInertia * r1.y * r1.y;		K2.col2.x = -body1.getInvInertia * r1.x * r1.y;
		K2.col1.y = -body1.getInvInertia * r1.x * r1.y;		K2.col2.y =  body1.getInvInertia * r1.x * r1.x;

		Matrix K3;
		K3.col1.x =  body2.getInvInertia * r2.y * r2.y;		K3.col2.x = -body2.getInvInertia * r2.x * r2.y;
		K3.col1.y = -body2.getInvInertia * r2.x * r2.y;		K3.col2.y =  body2.getInvInertia * r2.x * r2.x;

		Matrix K = K1 + K2 + K3;
		M = K.invertCopy();

		Point p1 = body1.translation + r1;
		Point p2 = body2.translation + r2;
		Point dp = p2 - p1;
		bias = -0.1f * inv_dt * dp;


		// Apply accumulated impulse.
		accumulatedImpulse *= relaxation;

		body1.velocity -= body1.getInvMass * accumulatedImpulse;
		body1.angularVelocity -= body1.getInvInertia * r1.cross(accumulatedImpulse);

		body2.velocity += body2.getInvMass * accumulatedImpulse;
		body2.angularVelocity += body2.getInvInertia * r2.cross(accumulatedImpulse);
	}

	/// apply impulse 
	void applyImpulse()
	{
		Point dv = body2.velocity + body2.angularVelocity * Point.makePerpTo(r2) - body1.velocity - body1.angularVelocity * Point.makePerpTo(r1);
		Point impulse = M * (-dv);
		Point bdv = body2.biasVelocity + body2.biasAngularVelocity * Point.makePerpTo(r2) - body1.biasVelocity - body1.biasAngularVelocity * Point.makePerpTo(r1);
		Point biasImpulse = M * (-bdv + bias);

		body1.velocity -= body1.getInvMass * impulse;
		body1.angularVelocity -= body1.getInvInertia * r1.cross(impulse);

		body2.velocity += body2.getInvMass * impulse;
		body2.angularVelocity += body2.getInvInertia * r2.cross(impulse);

		body1.biasVelocity -= body1.getInvMass * biasImpulse;
		body1.biasAngularVelocity -= body1.getInvInertia * r1.cross(biasImpulse);

		body2.biasVelocity += body2.getInvMass * biasImpulse;
		body2.biasAngularVelocity += body2.getInvInertia * r2.cross(biasImpulse);
		
		accumulatedImpulse += impulse;
	}


	Matrix M;
	Point localAnchor1, localAnchor2;
	Point r1, r2;
	Point bias;
	Point accumulatedImpulse;
	Body body1;
	Body body2;
	arcfl relaxation=0;
}

