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
module utils.Script;

// calling script gets all these imports for free.
public import std.process;
public import std.zip;
public import std.file;
public import std.string;
public import std.stdio;

int execute(char[] pathname,char[][] params ...){
	char[] command = pathname;
	foreach(str; params) command ~= " " ~ str;
	system("echo " ~ command);
	system(command);
	return 0;
}

int run(char[] pathname,char[][] params...){
	return execute(fixPath(pathname),params);
}

char[] fixPath(char[] path){
	version(Windows) return std.string.replace(path,"/","\\");
	version(linux) return std.string.replace(path,"\\","/");
}

char[] exeFile(char[] base){
	version(Windows) return base ~ ".exe";
	version(linux) return base;
}

void build(char[] options,char[] target){
	version(Windows) execute("bud","-Xstd",options,fixPath(target));
	version(linux) execute("bud","-Xstd -version=Posix",options,fixPath(target));
}

void compile(char[] options,char[] target){
	version(Windows) execute("dmd",options,fixPath(target));
	version(linux) execute("dmd",options,fixPath(target));
}

void insitu(char[] src,char[] dest){
	execute(fixPath("insitu"),fixPath(src),"-f"~fixPath(dest));
}

void bless(char[] src,char[] dest){
	execute(fixPath("bless"),fixPath(src),"-f"~fixPath(dest));
}

void copyFile(char[] src,char[] dest){
	version(Windows) execute("copy",fixPath(src),fixPath(dest));
	version(linux) execute("cp",fixPath(src),fixPath(dest));
}
	
void removeFile(char[] src){
	version(Windows) execute("del",fixPath(src));
	version(linux) execute("rm",fixPath(src));
}

void moveFile(char[] src,char[] dest){
	version(Windows) execute("move",fixPath(src),fixPath(dest));
	version(linux) execute("mv",fixPath(src),fixPath(dest));
}
		
void zip(char[] dest,char[][] targetFiles ...){
	char[] destPath = fixPath(dest);
	ZipArchive archive;
			
	if(std.file.exists(destPath)){
		archive = new ZipArchive(std.file.read(destPath));
	}
	else{
		archive = new ZipArchive();
	}
	
	foreach(filename; targetFiles){
		auto member = new ArchiveMember();
		auto name = fixPath(filename);
		writefln("Adding: %s",name);
		member.expandedData = cast(ubyte[])std.file.read(name);
		member.name = name;
		archive.addMember(member);
	}
	std.file.write(destPath,archive.build());
	debug writefln("Created Zip: %s",destPath);
} 

