/**
 *
 */
module recoder;

version(Windows)
{
	pragma(lib, "zlib");
}

import lodepng.Decode,
	   lodepng.Encode;

import tango.util.Arguments,
	   tango.io.Stdout,
	   tango.io.File,
       tango.stdc.stdio,
       tango.text.Ascii,
       tango.io.FilePath,
       tango.io.FileSystem,
       tango.util.PathUtil;

/+
TODO
    verbose output
    ask for overwriting / renaming
    option aliasing
+/

char[] description = "Recoder: utility to re-encode png files. Test program for the lodepng library. usage: recode pngfile1 [pngfile2] [options]\n";
char[][] options =
[
    "h", "help",       "\tdisplay this help message",
    "r", "reencode",     "keep only known information, this will lose unknown chunks",
    "s", "shrink",       "\tdiscard as much data as possible while still keeping original pixels",
    "t", "test",       "\ttest run, do not save final image"      ,
    "d", "dump",       "\tonly reads and saves chunks, doesn't decode.",
    "f", "force",      "\tdo not ask for confirmation when overwriting files",
];
//"c=x", "color=x",  "\tconvert source to color format x:\n\t\t 2 - 24-bit RGB color format\n\t\t 6 - 32-bit RGBA color format\n\t\t 0 - chooses format 2 if this is a lossless operation, otherwise 6\n"
enum : int
{
    shrink = 1, recode, dump
}

int main(char[][] args)
{
	auto arguments = new Arguments(args, ["source", "target"],
    [
    ["h", "help"],
    ["r", "reencode"],
    ["s", "shrink"],
    ["t", "test"],
    ["d", "dump"],
    ["f", "force"]
    ]
    );
    char[] sourceFile = arguments["source"].length ? arguments["source"][0] : null;
	char[] targetFile = arguments["target"].length ? arguments["target"][0] : null;

    addValidations(arguments);
    arguments.validate();

    if ("h" in arguments || sourceFile.length == 0)
    {
        printHelp();
        return 0;
    }

    if (targetFile.length == 0)
        targetFile = sourceFile.dup;

    bool verbose = "v" in arguments;
    bool test = "t" in arguments;
    bool force = "f" in arguments;
    int  method = chooseMethod(arguments);

    if ((new FilePath(targetFile)).exists() && !force)
    {
        char response;
        while (true)
        {
            Stdout.format("Are you sure you want to overwrite {} (y/n)?", targetFile).newline;
            response = getchar();
            if (response == 'n' || response == 'N')
                return 0;
            else if (response == 'y' || response == 'Y')
                break;
        }
    }

	ubyte[] pngBytes = cast(ubyte[]) (new File(sourceFile)).read();
	PngInfo info;
	ubyte[] result;

    void recodeImage()
    {
        auto imgBytes = pngBytes.decode(info);
        result = imgBytes.encode(Settings(info, false));
    }

    void shrinkImage()
    {
        auto imgBytes = pngBytes.decode(info);
        info.parseText = false;
        auto settings = Settings(info, true);
        settings.compressionLevel = 9;
        result = imgBytes.encode(settings);

    }

    void dumpImage()
    {
        Chunk[] chunks;
        info.image = pngBytes.readHeader();
        pngBytes.iterateChunks(info.image, (ref Chunk chunk)
            {
                if (parseChunk(chunk, info) == false)
                    chunks ~= chunk.dup;
                return 0;
            });

        result = encode(null, Settings(info, false), chunks);
    }

    if (method == dump)
        dumpImage();
    else if (method == shrink)
        shrinkImage();
    else if (method == recode)
        recodeImage();
    else
        Stdout("?").newline;

	if (!test)
        (new File(targetFile)).write(result);


	return 0;
}


void printHelp()
{
    Stdout(description).newline;
    for (int i = 0; i < options.length - 3; i+=3)
        Stdout.format("  -{}\t--{}\t{}", options[i], options[i+1], options[i+2]).newline;
}


void addValidations(ref Arguments arguments)
{
    for (int i = 0; i < options.length - 3; i+=3)
    {
        arguments.addValidation(options[i], false, false);
        arguments.addValidation(options[i + 1], false, false);
    }
    //arguments.addValidation("c", false, true);
    //arguments.addValidation("color", false, true);
}


int chooseMethod(Arguments arguments)
{
    int method = 0;

    if ("s" in arguments)
        method = shrink;
    if ("r" in arguments)
    {
        if (method != 0)
            throw new Exception("options r and s are mutually exclusive");
        method = recode;
    }
    if ("d" in arguments)
    {
        if (method != 0)
            throw new Exception("options mutually exclusive");
        method = dump;
    }
    if (method == 0)
        method = dump;
    return method;
}


void printHeader(PngImage image)
{
    Stdout("Source image properties:").newline;
    Stdout.format("    width: {}", image.width).newline;
    Stdout.format("    height: {}", image.height).newline;
    Stdout.format("    color format: {}", image.colorType).newline;
}