import std.file;
import std.process;
import std.io;


void main(){

scope files = std.file.listdir(".", "*.d"); 
     foreach (d; files){
 	sys("%DINRUS%\\dmd -c "~d);	
	say("Попытка компилировать модуль:"); writefln(d);
	 //if(exists((d)~".obj"){writefln("Failed.");}
	 //if(0){writefln("Successful.");}
	 }
	 sys("del *.map *.exe");	
	 
	}