/*******************************************************************************

        Placed into public domain by Kris

*******************************************************************************/

module  app;

import  std.io;

import  ddl.Linker;

public void entry (Linker linker, char[][] args)
{
        writefln("Mule loaded!");

        foreach (uint idx,char[] arg; args)
                 writefln("%d = %s",idx,arg);

        writefln ("Done.");
}