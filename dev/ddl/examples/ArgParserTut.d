pragma(lib, "rulada.lib");
pragma(lib, "mango.lib");

private {
    import utils.ArgParser;
    import mango.io.Stdout;
    import mango.io.FileConduit;
    import mango.text.LineIterator;
}

void main(char[][] args)
{
    char[][] fileList;
    char[] responseFile = null;
    bool coolAction = false;
    bool displayHelp = false;
    char[] helpText = "Available options:\n\t\t-h\tthis help\n\t\t-cool-option\tdo cool things to your files\n\t\t@filename\tuse filename as a response file with extra arguments\n\t\tall other arguments are handled as files to do cool things with.";

    ArgParser parser = new ArgParser(delegate uint(char[] value,uint ordinal){
        Stdout.println ("Added file number %s to list of files", ordinal);
		fileList ~= value;
		return value.length;
	});

	parser.bind("-", "h",delegate void(){
		displayHelp=true;
	});

	parser.bind("-", "cool-action",delegate void(){
		coolAction=true;
	});
	
    parser.bindDefault("@",delegate uint(char[] value, uint ordinal){
        if (ordinal > 0) {
            throw new Exception("Only one response file can be given.");
        }
        responseFile = value;
        return value.length;
    });

    if (args.length < 2) {
        Stdout.println(helpText);
        return;
    }
    parser.parse(args[1..$]);

    if (displayHelp) {
        Stdout.println(helpText);
    }
    else {
        if (responseFile !is null) {
            auto file = new FileConduit(responseFile);
            // create an iterator and bind it to the file
            auto lines = new LineIterator(file);
            // process file one line at a time
            char[][] arguments;
            foreach (line; lines) {
                arguments ~= line;
            }
            parser.parse(arguments);
        }
        if (coolAction) {
            Stdout.println("Listing the files to be actioned in a cool way.");
            foreach (id, file; fileList) {
                Stdout.println("%s. %s", id + 1, file);
            }
            Stdout.println("Cool and secret action performed.");
        }
    }	
}
