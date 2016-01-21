/******************************************************************************* 

	Code for drawing of physics bodies.

	Authors:       ArcLib team, see AUTHORS file 
	Maintainer:    Christian Kamm (kamm incasoftware de) 
	License:       zlib/libpng license: $(LICENSE) 
	Copyright:     ArcLib team 

	The contents of this file are based on E. Catto's Box2d, which is 
	Copyright (c) 2006 Erin Catto http://www.gphysics.com. 

	Description:    
		Code for drawing of physics bodies.

	Examples:      
	---------------------
	None provided 
	---------------------

*******************************************************************************/

module arc.physics.drawphysics;

import 
	arc.physics.mybody,
	arc.physics.shapes.box,
	arc.physics.shapes.circle,
	arc.scenegraph.node,
	arc.math.matrix,
	arc.math.point,
	arc.math.angle,
	arc.types,
	arc.draw.color;

import 
	derelict.opengl.gl,
	derelict.opengl.glu;

import std.math;

private
{
	const arcfl lineWidth = 2.0f;
	const uint circleSegments = 20;
	Color color = Color.White;
}

/// Draw Body 
void drawBody(Body b)
{
	if(cast(Box) b !is null)
		drawBox(cast(Box) b);
	else if(cast(Circle) b !is null)
		drawCircle(cast(Circle) b);
}

/// Draw box 
void drawBox(Box box)
{
	Matrix R = Matrix(box.rotation);
	Point x = box.translation;
	Size half = 0.5f * box.getSize;

	Point v1 = x + R*Point(-half.w, -half.h);
	Point v2 = x + R*Point( half.w, -half.h);
	Point v3 = x + R*Point( half.w,  half.h);
	Point v4 = x + R*Point(-half.w,  half.h);

	glDisable(GL_TEXTURE_2D);
	color.setGLColor();
	glLineWidth(lineWidth);
	glBegin(GL_LINE_LOOP);
	glVertex2f(v1.x, v1.y);
	glVertex2f(v2.x, v2.y);
	glVertex2f(v3.x, v3.y);
	glVertex2f(v4.x, v4.y);
	glEnd();			
}

/// Draw circle 
void drawCircle(Circle circle)
{
	Matrix R = Matrix(circle.rotation);
	Point x = circle.translation;
	arcfl r = circle.getRadius;

	glDisable(GL_TEXTURE_2D);
	color.setGLColor();
	glLineWidth(lineWidth);
	glBegin(GL_LINE_LOOP);
	glVertex2f(x.x, x.y);
	
	for(uint i = 0; i <= circleSegments; ++i)
	{
		x = circle.translation + R*Point(cos(2*PI*i/circleSegments), sin(2*PI*i/circleSegments))*r;
		glVertex2f(x.x, x.y);
	}
	glEnd();						
}
