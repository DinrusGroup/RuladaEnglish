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
module ddl.FileBuffer;

private import mango.io.Buffer;
private import mango.io.FileConduit;

private import mango.io.model.IBuffer;
private import mango.io.model.IConduit;

/**
	Gives the basic Mango buffer class some additional information about its origin.
*/
//TODO: should this pre-buffer the entire file into memory first?
class FileBuffer: Buffer{
	FilePath path;
	
	public this(char[] path, FileStyle.Bits style = FileStyle.ReadExisting){
		this.path = new FilePath(path);
		super(new FileConduit(this.path,style));
	}
	
	public this(FilePath path, FileStyle.Bits style = FileStyle.ReadExisting){
		super(new FileConduit(path,style));
		this.path = path;
	}
	
	public this(FilePath path,void[] data){
		super(data,data.length);
		this.path = path;
	}
	
	public this(char[] path,void[] data){
		super(data,data.length);
		this.path = new FilePath(path);
	}	
	
	public this(IConduit conduit,FilePath path){
		super(conduit);
		this.path = path;
	}
	
	public this(FileConduit file){
		super(file);
		this.path = file.getPath;
	}
	
	public FilePath getPath(){
		return path;
	}
	
	public IBuffer.Style getStyle(){
		return IBuffer.Mixed;
	}
}