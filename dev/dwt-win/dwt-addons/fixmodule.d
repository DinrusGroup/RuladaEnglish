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
        auto cont = cast(char[])File.get( filename );
        char[][] lines = cont.splitLines();
        int modLine = -1;
        foreach( uint idx, char[] line; lines ){
            if( line.length && line.locatePattern( "module dwtx" ) is 0 ){
        //Trace.formatln( "mod: {} {}", idx, line );
                modLine = idx;
                break;
            }
        }
        int impLine = -1;
        foreach( uint idx, char[] line; lines ){
            if( line.length && line.locatePattern( "import dwtx" ) is 0 ){
        //Trace.formatln( "imp: {} {}", idx, line );
                impLine = idx;
                break;
            }
        }
        assert( modLine !is -1 );
        assert( impLine !is -1 );
        if( modLine > impLine ){
            Trace.formatln( "{} {} {} {}", filename, modLine, impLine, lines.length );
            auto moddecl = lines[ modLine .. modLine + 2 ].dup;
            for( int i = modLine; i >= impLine+1; i-- ){
                lines[i+1] = lines[i-1];
            }
            lines[ impLine .. impLine+2 ] = moddecl;
            auto output = new TextFileOutput( filename );
            bool first = true;
            foreach( line; lines ){
                if( !first ){
                    output.write( \n );
                }
                first = false;
                output.write( line );
            }
            output.flush();
            output.close();
        }
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






