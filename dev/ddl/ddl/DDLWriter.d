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
	Provides Mango binary Writer support, with a few enhancements
	
	Authors: Eric Anderton
	License: BSD Derivative (see source for details)
	Copyright: 2006 Eric Anderton
*/
module ddl.DDLWriter;

private import mango.io.Writer;
private import mango.io.model.IBuffer;
private import mango.io.model.IConduit;

public class DDLWriter : Writer{
	public this (IBuffer buffer){
		super(buffer);
	}
	
	public this (IConduit conduit){
		super(conduit);
	}
	
	// perform a seek relative to the current buffer position and status using the conduit
	// NOTE: this will flush the current buffer's contents
	void seek(ulong offset, ISeekable.SeekAnchor anchor=ISeekable.SeekAnchor.Begin){
		IConduit conduit = getBuffer.getConduit();
		
		if(conduit){
			ISeekable seekableConduit = cast(ISeekable)(conduit);
			assert(seekableConduit);
			
			// seek and wipe out the buffer
			ulong writable = getBuffer.readable;
			getBuffer.flush();
					
			switch(anchor){
			case ISeekable.SeekAnchor.Begin:
			case ISeekable.SeekAnchor.End:
				seekableConduit.seek(offset,anchor);
				break;
			case ISeekable.SeekAnchor.Current:
				seekableConduit.seek(offset - writable,anchor);		
				break;
			}
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
			return seekableConduit.getPosition() + getBuffer.readable;	
		}
		else{
			return(getBuffer.getPosition);
		}
	}	
}