/*******************************************************************************

        Placed into public domain by Kris


        Use this as an application-loader, where the application itself
        is a .obj file (or equivalent). The application is expected to 
        have a module name of "app" and a public function conforming to 
        the following signature:

                void entry (Linker linker, char[][] args)

        The application can then use the provided linker and args for 
        whatever purpose deemed appropriate. 

        An example application is mule.d, which looks like so:

                module  app;

                import  std.stdio;
                import  ddl.Linker;

                public void entry (Linker linker, char[][] args)
                {
                        writef ("executing ...");

                        foreach (char[] arg; args)
                                 writef (" %s", arg);

                        writefln (" ... done");
                }

*******************************************************************************/

module  host;

import  std.io;

import  ddl.Linker,
        ddl.DefaultRegistry;

import  utils.ArgParser;

int main (char[][] args)
{
        int     ret;

        if (args.length > 1)
           {
           // load the statically-linked symbols for this executable
           auto linker = new Linker (new DefaultRegistry);
           linker.loadAndRegister ("examples\\host.ddl");

           // get dash prefixed args
           ArgParser parser = new ArgParser;
           parser.bind ("-", "l", delegate uint(char[] value) {
						writefln ("loading '%s'", value);
						linker.loadAndRegister (value);
                        return value.length;
                        });
           parser.parse (args[2..$]);

           // load the application file
           auto app = linker.loadAndLink (args[1]);

           // and locate the entry point
           auto entry = app.getDExport!(void function(Linker, char[][]), "app.entry")();

           try {
               entry (linker, args[1..$]);
               } catch (Object o)
                       {
                       ret = -1;
                       throw o;
                       }
           }
        else
           writefln ("usage is: host AppPath [-lLibName] [args]");
        return ret;
}