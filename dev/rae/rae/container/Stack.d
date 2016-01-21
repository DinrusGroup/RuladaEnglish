module rae.container.Stack;

import tango.util.container.LinkedList;

class Stack(T) : public LinkedList!(T)
{
public:
	this()
	{
		super();
	}

	void push(T t)
	{
		append(t);
	}
	
	T pop()
	{
		T t = tail();
		removeTail();
		return t;
	}
}


