/+
	Copyright (c) 2005 Eric Anderton
	
	Based on demangler.d written by James Dunne, Copyright (C) 2005
        
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

module ddl.ddl.DDLLoader;

private import ddl.DynamicLibrary;
private import ddl.DynamicModule;
private import ddl.DynamicLibraryLoader;
private import ddl.LoaderRegistry;
private import ddl.FileBuffer;

private import ddl.ddl.DDLLibrary;

class DDLLoader : DynamicLibraryLoader{
	public static char[] typeName = "DDL";
	public static char[] fileExtension = "ddl";
	
	public char[] getLibraryType(){
		return(typeName);
	}
	
	public char[] getFileExtension(){
		return(fileExtension);
	}	
		
	public bit canLoadLibrary(FileBuffer file){
		return file.get(4,false) == cast(void[])"DDL!";
	}
	
	public DynamicLibrary load(LoaderRegistry registry,FileBuffer file){
		return new DDLLibrary(registry,file);
	}
}