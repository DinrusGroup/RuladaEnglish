import os.win.io.fs;
import std.io;
import std.intrinsic;

void main(){
uint v;
     int x;

     v = 0x21;
     x = bsf(v);
     writefln("bsf(x%x) = %d", v, x);
     x = bsr(v);
     writefln("bsr(x%x) = %d", v, x);
     
writefln("Local logical drives are: %s", logicalDrives());
writefln("Directory <c:\\dm> exists: %s", directoryExists("C:\\dm"));
writefln("Total Free Space of drive C: is equal to %s", getTotalFreeSpace("C:"));
//writefln("Attributes of file <c:\\dm\\dmd.txt> are following: %s", getFileAttributes("c:\\dm\\dmd.txt"));
}