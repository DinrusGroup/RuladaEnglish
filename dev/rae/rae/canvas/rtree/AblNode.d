module rae.canvas.rtree.AblNode;

//import rae.canvas.rtree.AbstractNode;
import rae.canvas.rtree.Node;

import tango.util.container.LinkedList;

// generate Active Branch List.
class ABLNode
{
	Node node;//was AbstractNode
	float minDist;

	public this(Node node, float minDist)//was AbstractNode
	{
		this.node = node;
		this.minDist = minDist;
	}
}


