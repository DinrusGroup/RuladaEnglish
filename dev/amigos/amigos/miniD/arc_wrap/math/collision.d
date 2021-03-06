module amigos.minid.arc_wrap.math.collision;

import amigos.minid.api;
import amigos.minid.bind;

import arc.math.collision;

void init(MDThread* t)
{
	WrapModule!
	(
		"arc.math.collision",

		WrapFunc!(arc.math.collision.boxBoxCollision),
		WrapFunc!(arc.math.collision.boxCircleCollision),
		WrapFunc!(arc.math.collision.boxXYCollision),
		WrapFunc!(arc.math.collision.circleCircleCollision),
		WrapFunc!(arc.math.collision.circleXYCollision),
		WrapFunc!(arc.math.collision.polygonXYCollision)
	)(t);
}