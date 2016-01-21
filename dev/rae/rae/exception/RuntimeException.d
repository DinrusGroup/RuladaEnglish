module rae.exception.RuntimeException;

import tango.util.log.Trace;//Thread safe console output.

public class RuntimeException
{
	public this()
	{
		Trace.formatln("RuntimeException");
	}
	
	public this(char[] message)
	{
		Trace.formatln(message);
	}

}
