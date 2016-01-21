module rae.exception.IllegalArgumentException;

import rae.exception.RuntimeException;

public
class IllegalArgumentException : RuntimeException
{
	public this()
	{
		super();
	}

	public this(char[] s)
	{
		super(s);
	}
}

