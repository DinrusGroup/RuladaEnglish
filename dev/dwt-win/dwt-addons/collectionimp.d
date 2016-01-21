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

const char[][] javaimps = [
"import java.util.ArrayList;", 
"import java.util.Arrays;", 
"import java.util.Collection;", 
"import java.util.Collections;", 
"import java.util.HashMap;", 
"import java.util.HashSet;", 
"import java.util.IdentityHashMap;", 
"import java.util.Iterator;", 
"import java.util.LinkedHashMap;", 
"import java.util.LinkedList;", 
"import java.util.List;", 
"import java.util.ListIterator;", 
"import java.util.Map;", 
"import java.util.Map.Entry;", 
"import java.util.Set;", 
"import java.util.Comparator;", 
"import java.util.Stack;"
];
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
        char[][] outlines = lines.dup;
        bool found = true;
        foreach( uint idx, char[] line; lines ){
            foreach( javaimp; javaimps ){
                if( line == javaimp ){
                    outlines[idx] = found ? "import dwtx.dwtxhelper.Collection;" : "";
                    found = false;
                }
            }
        }
        if( !found ){
            Trace.formatln( "{} ", filename );
            bool first = true;
            auto output = new TextFileOutput( filename );
            foreach( line; outlines ){
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






