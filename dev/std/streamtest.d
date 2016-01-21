 import  std.stream, std.file; 
  
  void main() {
    File file = new File;
    int i = 666;
    file.create("stream.$$$");
    // should be ok to write
    assert(file.writeable);
    file.writeLine("Testing stream.d:");
    file.writeString("Hello, world!");
    file.write(i);
    // string#1 + string#2 + int should give exacly that
    version (Win32)
      assert(file.position() == 19 + 13 + 4);
    version (Posix)
      assert(file.position() == 18 + 13 + 4);
    // we must be at the end of file
    assert(file.eof());
    file.close();
    // no operations are allowed when file is closed
    assert(!file.readable && !file.writeable && !file.seekable);
    file.open("stream.$$$");
    // should be ok to read
    assert(file.readable);
    assert(file.available == file.size);
    char[] line = file.readLine();
    char[] exp = "Testing stream.d:";
    assert(line[0] == 'T');
    assert(line.length == exp.length);
    assert(!std.string.cmp(line, "Testing stream.d:"));
    // jump over "Hello, "
    file.seek(7, SeekPos.Current);
    version (Win32)
      assert(file.position() == 19 + 7);
    version (Posix)
      assert(file.position() == 18 + 7);
    assert(!std.string.cmp(file.readString(6), "world!"));
    i = 0; file.read(i);
    assert(i == 666);
    // string#1 + string#2 + int should give exacly that
    version (Win32)
      assert(file.position() == 19 + 13 + 4);
    version (Posix)
      assert(file.position() == 18 + 13 + 4);
    // we must be at the end of file
    assert(file.eof());
    file.close();
    file.open("stream.$$$",FileMode.OutNew | FileMode.In);
    file.writeLine("Testing stream.d:");
    file.writeLine("Another line");
    file.writeLine("");
    file.writeLine("That was blank");
    file.position = 0;
    char[][] lines;
    foreach(char[] line; file) {
      lines ~= line.dup;
    }
    assert( lines.length == 4 );
    assert( lines[0] == "Testing stream.d:");
    assert( lines[1] == "Another line");
    assert( lines[2] == "");
    assert( lines[3] == "That was blank");
    file.position = 0;
    lines = new char[][4];
    foreach(ulong n, char[] line; file) {
      lines[cast(size_t)(n-1)] = line.dup;
    }
    assert( lines[0] == "Testing stream.d:");
    assert( lines[1] == "Another line");
    assert( lines[2] == "");
    assert( lines[3] == "That was blank");
    file.close();
    //remove("stream.$$$");
  }