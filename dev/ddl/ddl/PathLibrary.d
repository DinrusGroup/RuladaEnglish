/+
   Copyright (c) 2006 Eric Anderton, Tomasz Stachowiak
   
   Permission is hereby granted, free of charge, to any person
   obtaining a copy of this software and associated documentation
   files (the "Software"), to deal in the Software without
   restriction, including without limitation the rights to use,
   copy, modify, merge, publish, distribute, sublicense, and/or
   sell copies of the Software, and to permit persons to whom the
   Software is furnished to do so, subject to the following
   conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
   OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   OTHER DEALINGS IN THE SOFTWARE.
+/

module ddl.PathLibrary;

private import ddl.DynamicLibrary;
private import ddl.DynamicModule;
private import ddl.LoaderRegistry;
private import ddl.Linker;
private import ddl.Demangle;
private import ddl.Attributes;
private import ddl.ExportSymbol;
private import ddl.Utils;

private import mango.io.FileScan;
private import mango.io.File;
private import mango.io.FilePath;
private import mango.io.FileConduit;
private import mango.text.Text;

private import std.ctype : isdigit;
private import std.string : rfind;
private import std.path : joinPaths = join;
private import std.file : isFile = isfile, fileExists = exists;
   

//TODO: insensitive to file time/date changes
//TODO: use delegate pass-forward to eliminate double-looping with processing file listings
class PathLibrary : DynamicLibrary{
   LoaderRegistry loaderRegistry;
   DynamicLibrary[] rootLibraries;
   DynamicLibrary[char[]] cachedLibraries; // libraries by namespace
   Attributes attributes;
   FilePath root;
   protected char[] delegate(char[])[]   namespaceTranslators;
      
   void addNamespaceTranslator(char[] delegate(char[]) dg) {
      namespaceTranslators ~= dg;
   }
   
   
   debug protected void debugPathList(char[] prompt,FilePath[] list){
      debugLog("%s (%d)\n",prompt,list.length);
       foreach(path; list){
          debugLog("  %s\n",path.toUtf8());
       }      
   }
   
   protected FilePath[] getRootFiles(){
       FilePath[] result = (new FileProxy(root)).toList();
       if(result.length >= 2){
          result = result[2..$]; //HACK: get rid of the '.' and '..' entries
      }
      else{
         result.length = 0;
      }
       debug debugPathList("PathLibrary.getRootFiles",result);
       return result;
   }
   
   protected FilePath[] getFiles(char[] subDirectory){
       FilePath[] result = (new FileProxy(root.toString ~ subDirectory)).toList();      
       if(result.length >= 2){
          result = result[2..$]; //HACK: get rid of the '.' and '..' entries
      }
      else{
         result.length = 0;
      }
       debug debugPathList("PathLibrary.getFiles",result);
       return result;
   }
   
   protected FilePath[] getAllFiles(){
      FilePath[] result;
      FileScan scan = new FileScan();
      
      bool filter(FilePath path){
         return true; // don't filter at all
      }
      void handle(File file){
         result ~= file.getPath();
      }
      
      scan(root,&filter);
      scan.files(&handle);
      
       debug debugPathList("PathLibrary.getAllFiles",result);
       return result;
   }
   
   protected char[] convertPathToNamespace(char[] path){
      char[] temp = Text.replace(path,'/','.');
      return Text.replace(temp,'\\','.');
   }
   
   protected char[] convertNamespaceToPath(char[] namespace){
      int split = Text.rIndexOf(namespace,'.');
      if(split == -1){
         return "";
      }
      // process everything up to the last '.' - this is the true namespace
      return Text.replace(namespace[0..split],'.','\\');
   }
   
   
   private static bool dSymbolStripType(char[] s, inout char[] res) {
      static char[][] prefixes = [
         "_Class", "__init_", "__vtbl_", "__arguments_",
         "__d", "_assert_", "_array_", "__modctor_",
         "__moddtor_", "__ModuleInfo_", "__nullext",
         "_Dmain", "_DWinMain", "_D"
      ];
   
      foreach (char[] prefix; prefixes) {
         if (s.length > prefix.length && s[0 .. prefix.length] == prefix) {
            res = s[prefix.length .. length];
            return true;
         }
      }
   
      return false;
   }
   
   
   private static char[] parseNamespace(char[] symbolName) {
      char[] raw;
      if (!dSymbolStripType(symbolName, raw) || !isdigit(raw[0])) {
         return symbolName;
      }
   
      char[] res;
      while (raw.length > 0 && isdigit(raw[0])) {
         int len = 0;
         while (raw.length > 0 && isdigit(raw[0])) {
            len *= 10;
            len += raw[0] - '0';
            raw = raw[1..$];
         }
         if (raw.length < len) {
            // invalid symbol ?
            return symbolName;
         }
   
         if (res.length) res ~= '.';
         res ~= raw[0 .. len];
         raw = raw[len .. $];
      }
   
      return res;
   }
   
   
   private static char[] getParentNamespace(char[] name) {
      int i = name.rfind('.');
      if (-1 == i) return null;
      else return name[0 .. i];
   }
   
   
   unittest {
      static char[][2][] tests = [
         ["printf", "printf"],
         ["_foo", "_foo"],
         ["_D88", "_D88"],
         ["_D4test3fooAa", "test.foo"],
         ["_D8demangle8demangleFAaZAa", "demangle.demangle"],
         ["_D6object6Object8opEqualsFC6ObjectZi", "object.Object.opEquals"],
         ["_D4test2dgDFiYd", "test.dg"],
         ["_D4test58__T9factorialVde67666666666666860140VG5aa5_68656c6c6fVPvnZ9factorialf", "test.__T9factorialVde67666666666666860140VG5aa5_68656c6c6fVPvnZ.factorial"],
         ["_D4test101__T9factorialVde67666666666666860140Vrc9a999999999999d9014000000000000000c00040VG5aa5_68656c6c6fVPvnZ9factorialf","test.__T9factorialVde67666666666666860140Vrc9a999999999999d9014000000000000000c00040VG5aa5_68656c6c6fVPvnZ.factorial"],
         ["_D4test34__T3barVG3uw3_616263VG3wd3_646566Z1xi", "test.__T3barVG3uw3_616263VG3wd3_646566Z.x"]
      ];
   
   
      foreach (char[][2] t; tests) {
         assert (parseNamespace(t[0]) == t[1]);
      }      
      
      assert(getParentNamespace("std.stdio") == "std");
      assert(getParentNamespace("foo.bar.baz") == "foo.bar");
      assert(getParentNamespace("blah") is null);
   }
   
   
   public this(char[] rootPath,LoaderRegistry loaderRegistry, bool preloadRootLibs = true){
      this.root = new FilePath(rootPath);
      this.loaderRegistry = loaderRegistry;
      
      if (preloadRootLibs) {
         //pre-load all root libs
         foreach(FilePath filepath; getRootFiles()){
            debug debugLog("[PathLibrary] Loading: %s",filepath.splice(root));
            DynamicLibrary lib = loaderRegistry.load(filepath.splice(root));
            if(lib){
               rootLibraries ~= lib;
            }
         }
      }
      
      addNamespaceTranslator(&convertNamespaceToPath);
      
      attributes["PATH.path"] = root.toUtf8;
   }
   
   public ExportSymbolPtr getSymbol(char[] name){
      DynamicModule mod = this.getModuleForSymbol(name);
      if(mod) return mod.getSymbol(name);
      return null;
   }
   
   public ExportSymbol[] getSymbols(){
      ExportSymbol[] symbols;
      foreach(DynamicModule mod; getModules()){
         symbols ~= mod.getSymbols();
      }
      return symbols;
   }
      
   public DynamicModule[] getModules(){
      DynamicModule[] result;
      
      //go through all the files in scope and load everything possible
      //NOTE: this ignores already loaded root libs
      foreach(FilePath libPath; getAllFiles()){
         DynamicLibrary lib = loaderRegistry.load(libPath.toString);
         if(lib) result ~= lib.getModules();
      }
      return result;
   }
   
   public char[] getType(){
      return "PATH";
   }
   
   public char[][char[]] getAttributes(){
      return this.attributes;
   }

   public DynamicModule getModuleForSymbol(char[] name){
      if(name.length > 2 && name[0..2] == "_D"){
         for (char[] namespace = parseNamespace(name); namespace !is null; namespace = getParentNamespace(namespace)) {

            // dig through the root libs   
            foreach(DynamicLibrary lib; rootLibraries){
               DynamicModule mod = lib.getModuleForSymbol(name);
               cachedLibraries[namespace] = lib;
               if(mod) return mod;
            }
                  
            // attempt to search the cache
            DynamicLibrary* pLib = namespace in cachedLibraries;
            if(pLib) return pLib.getModuleForSymbol(name);
            
            foreach (xlat; namespaceTranslators) {
               // look for a path match
               char[] path = joinPaths(this.root.toString(), xlat(namespace.dup));
               if(path != ""){
                  if (fileExists(path) && isFile(path)) {
                     DynamicLibrary lib = loaderRegistry.load(path);
                     if(lib) {
                        cachedLibraries[namespace] = lib;
                        return lib.getModuleForSymbol(name);
                     }
                  }
                  
                  //find first loadable library file that matches <root-path><path>/* and contains 'name'
                  foreach(FilePath libPath; getFiles(path)){
                     DynamicLibrary lib = loaderRegistry.load(libPath.toString);
                     if(lib) {
                        cachedLibraries[namespace] = lib;
                        return lib.getModuleForSymbol(name);
                     }
                  }
               }
            }
         }
      }
      // match a non-D symbol
      else{
         // dig through the root libs
         foreach(DynamicLibrary lib; rootLibraries){
            DynamicModule mod = lib.getModuleForSymbol(name);
            if(mod) return mod;
         }   
      }
      //failed to find the module
      debug debugLog("PathLibrary.getModuleForSymbol - failed to find: %s",name);
      return null;
   }

   // expects resource in file-path format
   public ubyte[] getResource(char[] name){
      FileConduit fc = new FileConduit(this.root.toString ~ name);
      ubyte[] data = new ubyte[fc.length];
      fc.read(data);
      return data;
   }
}