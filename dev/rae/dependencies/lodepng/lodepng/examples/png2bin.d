module png2bin;

version(Windows)
{
	pragma(lib, "zlib");
}

import lodepng.Decode,
       lodepng.Encode;

import tango.util.Arguments,
       tango.io.Stdout,
       tango.io.FilePath,
       tango.io.FileConduit,
       tango.io.FileScan,
       tango.io.Console,
       tango.util.Convert,
       tango.text.convert.Layout,
       tango.text.Unicode;

int main(char[][] args)
{
	//todo: implent target colortype option
	auto arguments = new Arguments(args, ["pngfile"], 
		[["R", "r", "recursive"], ["t", "target", "T"], ["h", "H","help"], ["f", "F", "force"]]);
	arguments.addValidation("r", false, false);
	arguments.addValidation("t", false, true);
	arguments.addValidation("h", false, false);
	arguments.addValidation("f", false, false);
	
	//todo: write this helpMessage so it is useful
	char[] helpMessage = "usage: png2bin file [dstfile] [options]";
	char[][] messages; 
	try
    {
        arguments.validate();
    }
    catch (ArgumentException ex)
    {
        messages ~= Stdout.layout.convert("{}: {} - {}", ex.name, ex.msg,
                    ex.reason == ArgumentException.ExceptionReason.INVALID_PARAMETER ?
                    "invalid parameter" : ex.reason == ArgumentException.ExceptionReason.MISSING_PARAMETER ?
                    "missing parameter" : "missing argument");
        Stdout(messages).newline;
        Stdout(helpMessage).newline;
        return 0;
    }
    
    char[] pngFileName = arguments["pngfile"].length ? arguments["pngfile"][0] : null;
    
    if (!pngFileName)
    {
    	Stdout("error: missing argument png file").newline;
    	Stdout(helpMessage).newline;
    	return 0;
    }
    
    ubyte[] buffer;
    ubyte[] pixels;
    
    void pngToD(FilePath source, FilePath target, ColorType destCT = ColorType.Any)
    {
    	auto srcConduit = new FileConduit(source);
    	scope(exit)
    		srcConduit.close();
    	auto dstConduit = new FileConduit(target, FileConduit.WriteCreate);
    	scope(exit)
    		dstConduit.close();
    	
    	buffer.length = srcConduit.length;
    	auto bytesRead = srcConduit.input.read(buffer);
    	assert(bytesRead==buffer.length);
    	
    	PngInfo info;
    	
    	pixels = buffer.decode(info, pixels);
    	if (destCT != ColorType.Any && info.image.colorType != destCT)
        {
            pixels = pixels.convert(info, destCT);
            info.image.colorType = destCT;
        }
    	
    	char[][] dFileStrings = ["module " ~ target.name ~ ";\n"];
    	
        dFileStrings.writeDeclarations(pixels, info);

        foreach(str; dFileStrings)
        {
            dstConduit.output.write(str);
            dstConduit.output.write("\n");
        }
    }
    
    auto src = new FilePath(pngFileName);
    if (!src.exists)
    {
    	Stdout.format("error: {} does not exist\n", pngFileName);
    	return 1;
    }
    
    bool force = "f" in arguments;
    
    if (src.isFolder)
    {
    	
    	foreach( source; (new FileScan)(src.toString(), ".png", "r" in arguments).files() )
    	{
    		auto dst = source.dup;
    		dst.suffix = "d";
    		if(!force && dst.exists)
    		{
    			switch(confirm("file " ~ source.file() ~ " exists, overwrite? "))
    			{
    				case Yes: pngToD(source, dst);
    					break;
    				case No:
    					break;
    				case Quit: return 0;
    					break;
    					default:
    						assert(false);
    					return 1;
    			}
    		}
    		else
    		{
    			pngToD(source, dst);
    		}
    	}
    }
    else
    {
    	auto dst = src.dup();
    	dst.suffix = "d";
    	if(!force && dst.exists)
		{
    		switch(confirm("file " ~ src.file() ~ " exists, overwrite? "))
			{
				case Yes: pngToD(src, dst);
					break;
				case No:
					break;
				case Quit: return 0;
					break;
					default:
						assert(false);
					return 1;
			}
		}
		else
		{
			pngToD(src, dst);
		}
    }
   
    return 0;
}

enum : int
{
	Yes,
	No,
	Quit
}

int confirm(char[] message)
{
	
	char[] input;
	while(true)
	{
		Stdout(message ~ " Y(es)/N(o)/Q(uit)").newline;
		Cin.readln(input);
		input = input.toLower();
		if (input == "y")
			return Yes;
		else if (input == "n")
			return No;
		else if (input == "q")
			return Quit;
	}
	return Quit;
}

void writeDeclarations(ref char[][] strings, ubyte[] pixels, ref PngInfo info)
{
    strings ~= "uint width = "      ~ to!(char[])(info.image.width)~ ";";
    strings ~= "uint height = "     ~ to!(char[])(info.image.height)~ ";";
    strings ~= "uint bitDepth = "   ~ to!(char[])(info.image.bitDepth)~ ";";

    char[] ct = colorTypeToString(info.image.colorType);
    strings ~= "char[" ~ to!(char[])(ct.length) ~ "] colorType = \"" ~ ct ~ "\";";
    
    if (!hasAlphaChannel(info.image.colorType) && info.colorKey)
    {
        char[] type = (info.image.bitDepth > 8) ? "ushort[3]" : "ubyte[3]";

        strings ~= type ~ " colorkey = ["   ~ to!(char[])(info.keyR) ~ ", "
                                            ~ to!(char[])(info.keyG) ~ ", "
                                            ~ to!(char[])(info.keyB) ~ "];";
    }
    if (info.backgroundColor.length)
    {
      //TODO
    }

    strings ~=  "ubyte[" ~ to!(char[])(pixels.length) ~ "] pixels = \n" ~
                    formatArrayToStrings(pixels, (info.image.bitDepth / 8) * info.image.width) ~ ";";
 }

char[] formatArrayToStrings(ubyte[] array, size_t width = 0)
{
    //TODO: make type of array generic, error checking (allow 16 bit images)
    Layout!(char) Layouter = new Layout!(char)();
    
    uint hexLength = 4;
    uint stringLength = array.length * (hexLength + 2) + width;
    char[] result = new char[stringLength];
                        
    if (width == 0)
        width = array.length;

    result[0..2] = "[ ";

    Layouter.sprint( result[2 .. $], "0x{:x2}", array[0] );
    size_t pos = hexLength + 2;
    size_t x = 1;
    
    for (size_t y = 0; y < array.length / width; y++)
    {
    
        for (; x < width + (y * width); x++, pos += hexLength + 2)
        {
            Layouter.sprint( result[pos .. $], ", 0x{:x2}", array[x] );
        }
        result[pos..pos+1] = "\n";
        pos+=1;
    }
    result[pos -1..pos] = "]";

    
    return result;
}


