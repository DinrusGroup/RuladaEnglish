module packageimport;

import tango.io.FilePath;
import tango.io.device.File;
import tango.io.Buffer;
import tango.io.stream.FileStream;
import tango.io.stream.TextFileStream;
import tango.util.log.Trace;
import tango.text.Regex;
import tango.text.Util;
import tango.text.stream.LineIterator;
import tango.text.convert.Format;

void processDir( char[] dir ){
    auto pack = dir.dup.replace( '/', '.' );
    auto fp = FilePath(dir);
    char[][] mods;
    // read all module names
    foreach( fileinfo; fp ){
        if( fileinfo.folder ){
            processDir( fileinfo.path ~ fileinfo.name );
            continue;
        }
        if( fileinfo.name.length > 2 && fileinfo.name[ $-2 .. $ ] == ".d" ){
            mods ~= fileinfo.name.dup;
        }
    }
    // foreach module
    foreach( mod; mods ){
        auto filename = Format("{}/{}", dir, mod );
        Trace.formatln( "{}", filename );
        auto cont = cast(char[])File.get( filename );
        auto output = new TextFileOutput( filename );
        bool firstline = true;
        void println( char[] l ){
            if( !firstline ){
                output.newline();
            }
            output(l);
            firstline = false;
        }
        bool found = false;
        auto it = new LineIterator!(char)( new Buffer( cont ));
        foreach( line; it ){
            println(line);
            if( line.length && line.locatePattern( "module " ) is 0 ){
                found = true;
                break;
            }
        }
        assert( found );
        println( "" );
        foreach( impmod; mods ){
            if( impmod == mod ){
                continue;
            }
            println( Format( "import {}.{}; // packageimport", pack, impmod[ 0 .. $-2] ));
        }
        println( "" );
        foreach( line; it ){
            println(line);
        }
        output.flush();
        output.close();
    }
        // read content into buffer
        // search module statement and print to outfile
        // write package imports
        // write all remaining lines
}

void main(){
    processDir( "dwtx/text" );
    processDir( "dwtx/jface/text" );
    processDir( "dwtx/jface/internal/text" );
}






