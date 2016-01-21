/+
	Copyright (c) 2005 Eric Anderton
        
	Permission is hereby granted, free of charge, to any person
	obtaining a copy of this software and associated documentation
	files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following
	conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
+/
module ddl.Utils;

private import  mango.convert.Type,
                mango.convert.Format,
                mango.convert.Unicode;
          
/**
	Extended Sprintf class.  Features an internally expanding buffer for formatting data,
	and an optional opCall vararg syntax.
*/	
class ExtSprintClassT(T)
{
        package alias FormatStructT!(T) Format;

        private Unicode.Into!(T) into;
        private Format           format;
        private T[128]           tmp;
        private T[]              buffer;
        private T*               p, limit;

        /**********************************************************************

        **********************************************************************/

        this (int size, Format.DblFormat df = null, T[] workspace = null)
        {
                format.ctor (&sink, null, workspace.length ? workspace : tmp, df);
                buffer = new T[size];
				p = cast(T*) buffer;
                limit = p + buffer.length;
        }

        /**********************************************************************

        **********************************************************************/

        private uint sink (void[] v, uint type)   
        {
                auto s = cast(T[]) into.convert (v, type);

                int len = s.length;
                if (p+len >= limit){
                    // expand the buffer to what we need
                    buffer.length = buffer.length + len;
                    p = cast(T*) buffer;
                }

                p[0..len] = s[0..len];
                p += len;       
                return len;
        }

        /**********************************************************************

        **********************************************************************/

        T[] opCall (T[] fmt, ...)
        {
                p = cast(T*) buffer;
                return buffer [0 .. format (fmt, _arguments, _argptr)];
        }
        
      	T[] opCall (T[] fmt,TypeInfo[] arguments,void* argptr)
        {
            p = cast(T*) buffer;
            return buffer [0 .. format (fmt, arguments, argptr)];	        
        }        
}

alias ExtSprintClassT!(char) ExtSprintClass;

char[] dataDumper(void* data,uint length){
	char[] result = "";
	char[] buf2 = "";
	ubyte* ptr = cast(ubyte*)(cast(uint)data&0xFFFFFFF0); // start at nearest page
	ExtSprintClass sprint = new ExtSprintClass(1024);
	
	for(uint idx=0; idx<length; idx++,ptr++){
		ubyte b = *ptr;
		if(idx % 16 == 0){
			 result ~= sprint(" |  %s\n  [%0.8X] ",buf2,ptr);
			 buf2 = "";
		}
		
		if(ptr == data){
			result ~= "*";
		}
		else{
			result ~= " ";
		}
		
		if(b < 16) result ~= "0"; //HACK: sprint doesn't left-pad correctly
		result ~= sprint("%0.2X",b);
				
		if(b >= 32 && b <= 126){
			buf2 ~= cast(char)b;
		}
		else{
			buf2 ~= ".";
		}
	}
	result ~= " | " ~ buf2 ~ "\n";	
	return result;
}

/*
debug{   
	private import mango.log.Logger;
	private import mango.log.DateLayout;
	
	Logger ddlLog;
	
	static this(){
		ddlLog = Logger.getLogger("ddl.logger");
		ddlLog.info("Logger Initalized");
		ddlLog.
	}
	
	public void debugLog(...){
		
	}
}*/
debug{
	private import mango.io.Stdout;
	
	public void debugLog(char[] s,...){
		Stdout.print(s ~ "\n",_arguments,_argptr);
		Stdout.flush();
	}	
}

unittest{}
