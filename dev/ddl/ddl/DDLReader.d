/+
	Copyright (c) 2006 Eric Anderton
        
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
/**
	Provides Mango binary Reader support, with a few enhancements
	
	Authors: Eric Anderton
	License: BSD Derivative (see source for details)
	Copyright: 2006 Eric Anderton
*/
module ddl.DDLReader;

private import ddl.Utils;

private import mango.io.Reader;
private import mango.io.Buffer;
private import mango.io.model.IBuffer;
private import mango.io.model.IConduit;

debug private import mango.io.Stdout;

public class DDLReader : Reader{
	public this(void[] data){
		super(new Buffer(data,data.length));
	}
	
	public this (IBuffer buffer){
		super(buffer);
	}
	
	public this (IConduit conduit){
		super(conduit);
	}
		
    public DDLReader peek(inout ubyte x){
		x = (cast(ubyte[])buffer.get(1,false))[0];
        return this;
    }	
    
    public DDLReader peek(inout ubyte[] x,uint elements = uint.max){
	    if(elements == uint.max)
	    	elements = buffer.readable;
	    	
	    assert(elements <= buffer.readable);
	    
	   	x = (cast(ubyte[])buffer.get(elements,false));
	    return this;
    }
    
    //props to Kris for suggesting this method of getting 100% of the remaining data in a conduit
	DDLReader getAll(inout void[] x)
	{		
		IConduit conduit = getBuffer.getConduit();
		
		x = getBuffer.get(getBuffer.readable); //exhaust the buffer
		
		if(conduit){
			static const uint BUFFER_LEN = 8192;
			void[] content = new void[BUFFER_LEN];
			uint filled = 0;
			
			while(true){
			    uint chunk = conduit.read(content[filled..$]);
			    if (chunk is conduit.Eof)
			        break;		
			    filled += chunk;
			    if (content.length - filled < 1024)
			        content.length = content.length + BUFFER_LEN;
			}
			if(filled > 0){
				x ~= content [0..filled]; // add on additional data
			}
		}
		
		return this;
	}
	
	bool hasMore(){
		
		//TODO: instead of try-catch, check for underflow instead
		try{
			void[] result = getBuffer().get(1,false);
			return result != null;
		}
		catch(Exception e){
			return false;
		}
	}
	
	// perform a seek relative to the current buffer position and status using the conduit
	// NOTE: this will clear out the current buffer
	void seek(ulong offset, ISeekable.SeekAnchor anchor=ISeekable.SeekAnchor.Begin){
		IConduit conduit = getBuffer.getConduit();
		
		if(conduit){
			ISeekable seekableConduit = cast(ISeekable)(conduit);
			assert(seekableConduit);
			
			// seek and wipe out the buffer
			switch(anchor){
			case ISeekable.SeekAnchor.Begin:
			case ISeekable.SeekAnchor.End:
				seekableConduit.seek(offset,anchor);
				break;
			case ISeekable.SeekAnchor.Current:
				seekableConduit.seek(offset - getBuffer.readable,anchor);		
				break;
			}
			getBuffer.clear();
		}
		else{ // no conduit for buffer
			switch(anchor){
			case ISeekable.SeekAnchor.Begin:
				getBuffer.skip(offset-getBuffer.getPosition);
				break;
			case ISeekable.SeekAnchor.End:
				getBuffer.skip(getBuffer.readable-offset);
				break;
			case ISeekable.SeekAnchor.Current:
				getBuffer.skip(offset);
				break;
			}	
		}
	}
	
	// get the position relative to the current buffer position and status
	ulong getPosition(){
		IConduit conduit = getBuffer.getConduit();
		if(conduit){
			ISeekable seekableConduit = cast(ISeekable)(conduit);
			assert(seekableConduit);		
			return seekableConduit.getPosition() - getBuffer.readable;	
		}
		else{
			return(getBuffer.getPosition);
		}
	}
	
	// override to provide debug support
	debug (REMOVE) override protected IReader decodeArray (void[]* x, uint bytes, uint width, uint type){
		try{
			return super.decodeArray(x,bytes,width,type);
		}
		catch(Exception e){
			Stdout.println("Exception thrown while decoding array (%0.8X) %d bytes, width %d, type %d",x,bytes,width,type);
			throw e;
		}
		return this;
	}
	
	// override to provide debug support
	debug override protected uint read (void *dst, uint bytes, uint type){	
		try{
			return super.read(dst,bytes,type);
		}
		catch(Exception e){
			Stdout.println("Exception thrown while reading (%0.8X) %d bytes, type %d",dst,bytes,type);
			throw e;
		}
		return 0;
	}
}
