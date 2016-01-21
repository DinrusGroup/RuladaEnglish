Mango Release 2.0

- Note that some Mango features require the latest dmd compiler; the dependencies are related to the new version= behaviour, and various dmd bug fixes

- Please take a look at the mango/examples/ directory

- Mango uses Build.exe for compilation. You can create a Mango.lib by going to the mango/build directory and using Build @mango. However, Build and DMD are so fast that I find it convenient to just avoid lib files. Setting up DMD for Mango is straightforward ~ either add a -I[mango-path] to the command line, or add it to the sc.ini file in the dmd/bin directory. 

- Mango is fully compatible with the latest release of Ares ~ the two libraries tend to stay in sync. Add a -version=Ares to the DMD command-line when compiling for Ares.

- Note that you will need the wsock32.lib (sockets), or equivalent, available within the link path. The earlier ws2_32.lib does not support multicast, and will therefore produce errors.

- In a similar vein, you will need the ICU DLLs (or shared libs) to use the ICU bindings. These should be placed somewhere where the O/S can find them. Mango.icu now requires ICU v3.2

- Note that doxygen fails to include a significant amount of documentation. This is particularly evident where version{} is used, and where nested classes/functions are taken advantage of. Please refer to the source files for complete documentation.

- mango/mango/test/unittest.d is the main test file. Check in there for some additional usage examples.

========================================================================================

Release 2.0 changes

- Renamed the mango.format package to be mango.convert
- Moved mango.time.Rfc1123 over to the mango.convert package
- Reshaped text-formatting package to be more streamlined
- Added an Atoi template for lightweight conversions
- Moved mango.io.Utf over to convert.Unicode
- Moved mango.sys.Type over to the mango.convert package
- Improved efficiency of URL decoding
- Added Unicode support to printf-style formatting
- Removed decoration from putw() and putd(), to correctly support wchar[] and dchar[]. This will likely require changes to string literals.
- Removed the lazy heap-allocation methods from convert.Integer and convert.Rfc1123
- Module io.TextFormat replaced by convert.Sprint
- Changed all I/O functions and delegates to return a uint, rather than an int
- Added a UnicodeFile module
- Added a UnicodeBom module
- Added Unicode support to Win32 console
- Console is now Buffer based, and UTF-8 encoded across all platforms 
- Added io.Print module for printf compatability (doesn't need Stdout)
- Removed modules Resource & IResource, and cleaned up the relevant Conduit classes
- Reworked ConduitFilter & IConduitFilter to be simpler; added an EndianFilter module
- IBuffer, IReader and IWriter are now abstract classes ~ codegen is considerably better, but the names may need to change
- Completed the convert.Unicode codec, and added streaming support
- Mango.convert package is now templated for char, wchar, dchar
- GrowBuffer renamed, and now lives in its own module
- MappedBuffer now lives in its own module
- Reworked FileStyle and ConduitStyle to be small structs instead. Both files are deprecated. Added Text varieties to the predefined FileStyle.
- Added Mixed, Text, Binary style to the Buffer, and added sanity checks within Reader & Writer
- Added a ream of casts to eliminate compiler warnings
- Hopefully eliminated the cyclic static-ctor issue in mango.log (thanks to Tionex and teqdruid)
- Added checks for app-termination before cleaning up external references (files, sockets, etc)
- Stdin now reads Unicode correctly
- Added a templated BufferFormat module to tie a Format instance to a Buffer. Used by Stdout and friends
- Added a new mango.text package for string handling, and migrated utils.Text over there. Package is templated for char, wchar, dchar
- Added mango.io.BufferTokenizer to bind new Token classes to either a Buffer or a Conduit
- Added several more examples
- Resolved ~this() handling for external resources ~ appears to work correctly on linux.
- Added redirect support to HttpClient
- change pragma(link, wsock32) to the DMD pragma(lib) instead, on Win32
 

Release 1.6 changes

- Updated to latest version of Ares
- Fixed bugs in unitest.d
- Split PropertyConfigurator into its own module
- Added mango.sys.OS module


Release 1.5 changes

- Added support for Http requests with '=' missing from within the query parameters (per request from Carlos)
- All !== and === instances removed (thanks to TeqDruid)
- Various minor patches to keep up with DMD changes
- Added mango.io.Console as a lightweight console facade
- Updated mango.log.ConsoleAppender per mango.io.Console
- Removed the binding between mango.io.FilePath and mango.io.Uri (will provide a utility class instead)


Release 1.4 changes

- Removed customization points for everything other than UTF in the Reader/Writer hierarchy. This just makes things easier to grok
- Added vararg/printf style output to DisplayWriter (and hence Stdout)
- Updated the mango.format package to include vararg/printf style formatting. This includes support for array output, using the '@' format flag. No unicode support yet
- Added a mango.time package with support for a number of HTTP oriented formats.
- Added initial support for the Ares project
- FlushWriter split out into its own module
- Renamed mango.base to mango.sys
- Updated mango.log to use mango.time & mango.sys.Epoch
- Removed final traces of Phobos (other than RegExp), to be compliant with Ares
- Exposed the read() and write() methods within Conduit, allowing one to bypass Buffer et. al.
- FileConduit now derives from DeviceConduit. This was done so that Stdio does not require FileConduit
- Cleaned up some references to Socket internals
- Added Darwin patches from Anders (thanks!)


Release 1.3 changes

- Added special processing for Win32 console output (it doesn't like strings longer than 32K)
- Added a MutableFilePath constructor to accept file names
- Added a new 'File' class to simplify the API. This extends FileProxy, so you get the methods from there also
- Added FileScan class, to collate files from multiple directories (originally from Chris Sauls)
- Fixed a bug in FilePath.splice()
- Added a FilePath.normalize() function to switch separator types
- Changed splice() to include 'file extentions' where the basepath has a name that includes a '.' seperator
- Changed all instances of Seperator to the correct spelling, and provided aliases for the invalid form (Thanks to Brad)
- Moved file-system constants into a new FileConst module (and left aliases in FileSystem)
- File classes now support Win95 & Win32s (thanks to Chris Sauls)
- Added a split() function to the utils.Text class


Release 1.2 changes

- Mango.base.ByteSwap updates from Aleksey Bobnev, who took the time to benchmark various approaches (big thank-you!)
- merged TokenEx back into Token, given new static constructor behavior in dmd 0.115
- added mango.format package
- Added the extended precision floating-point converters by David Gay (wrapped by mango.format.DGDouble)
- changed DisplayWriter to use mango.format
- Added a check for invalid stdio handles in FileConduit
- Cleaned up some cruft in the IWriter/IReader interaces
- Added 'whisper' IO format, as the unoffical Mango standard
- Enhanced support for reading arrays of a pre-determined size. Now uses a second argument instead of the old push() approach; C++ iostream format suffers as a result. 
- Mango.io.Stdio split into mango.io.Stdout and mango.io.Stdin, which reduces baggage for small console programs
- removed some superfluous Phobos imports
- Invalid Stdio handles are quietly ignored (per behaviour of legacy systems)
- ServletContext can now accept independent Logger instances
- Mango.log.Admin had a few public imports which should have been private
- Anders kindly provided a set of patches for both GDC and the Mac (Darwin), along with the appropriate makefile (another big thank-you!)
- removed all dependencies on printf() and sprintf(), except for mango.log
- Http server reverted to HTTP/1.0 since it doesn't support chunking at this time
- Added URegex to the ICU package
- Mango.icu now requires ICU v3.2 (for the URegex package)
- the old version=Mango has been inverted to simplify usage of Build.exe; now it's version=Isolated for the standalone versions of mango.log and mango.icu


Release 1.1 changes

- added UString utility constructor for loading via an IBuffer
- added hadTimeout() method to SocketConduit, for explicit error-checking
- removed some cruft from mango.cluster (an old reference to a specific host name)


Release 1.0a changes

- fixed new const-int errors tagged by dmd 0.107


Release 1.0 changes

- Most version(linux) statements have been changed to version(Posix) instead. Make files should be adjusted accordingly
- ICU wrappers have been fleshed out some more
- UString has a number of additional methods
- Module icu.UMango introduced, which binds the ICU converters into Mango.io
- IArrayAllocator now knows about element widths, and makes adjustments to array.length as appropriate
- Fixed another bug in System.Sleep(), where the Win32 platform was off by a factor of 1000 
- The array lengths read/written by binary readers/writers has changed, from a byte-count to an element-count. This should not affect anything unless you already have persisted data that was originally written by io.Writer
- Delivery of the Mango packages has been split into multiple components
- Added support for all array types to readers/writers. They now support 15 different data types, plus the IReadable/IWritable notion.
- Libraries (for Win32) are now included in the distribution. Linux libs will hopefully be provided in the near future
- FlushBuffer had some design flaws, and has been replaced with FlushWriter instead. Stdio now used the latter, rather than the former, and auto-flushes when a Newline is seen.
- The argument list for icu.UMessageFormat has been reworked
- ICU bindings now operate nicely on linux: a big thank-you to John Reimer.
- Mango.log is now even faster than before, and does zero memory-allocation once running. Supports Phobos, in addition to Mango.io
- UTimeZone.d now has some useful time-zones pre-defined
- Mango.io now uses an alias to support the twin put/get and <</>> syntax (kudos to Ivan Senji).

 
Beta 9.5 changes

- File system is now Unicode enabled (supports Basic Multilingual Plane). FilePath is now assumed to be UTF-8 encoded where it contains non-ansi characters
- Started on the icu package (UChar, UString, ULocale, UConverter, UDateFormat, UMessageFormat, UNumberFormat, UResourceBundle, UTimeZone, UCalendar)
- Added Utf8 functions to mango.io
 

Beta 9.4 changes

- Reworked the internals of the Reader/Writer framework. It's actually an entirely new, and more flexible, implementation with the same interface as before
- Fixed some circular import issues that dmd v.102 brought to light
- Fixed Win32 bug in System.sleep() where a "sleep forever" wouldn't 


Beta 9.3 changes

- split IResource out from IConduit 
- renamed IFilter to IConduitFilter (and propogated changes)
- System.d moved out of mango.io to mango.base (it never belonged there)
- Timer.d moved to mango.utils
- removed get/put support for ubyte[]) and byte[] from IReader/IWriter. There's so many issues regarding arrays in general that the resolution will have to be different that the current approach (note that std.streams has the same issue)
- removed IPickled composite interface since the compiler cannot handle such things correctly (yet)
- added an example of cluster alerts
- moved Timer.Interval over to System.Interval instead
- fixed new getErrno() issues due to Phobos changes
- removed additional dependencies on Phobos
- changed things for new version= behaviour
- fixed Uri problem regarding the funky implicit [length]
- added preliminary IWriter.write([]) and IReader.read([]) support (no Endian or Tokenizing support yet)


Beta 9.2 changes

- replaced cluster notification strategy for queues
- moved AbstractServer, IServer, and ServerThread over to mango.utils
- renamed mango.io.Utils to mango.utils.Text, and added mango.utils.Random
- added an ILogger to the AbstractServer constructor, and some derivatives
- made cluster server much more robust under duress
- changed cluster-socket reaping strategy from server-based to client-based
- added a mango.utils.Timer (with an interval clock also)
- fixed some small bugs, and updated to dmd 0.96 import adjustments
- added a set of base classes for message/task
- added cluster exclusive-updates via remote cache-loading/locking
- ICache renamed IMutableCache; ICache is now immutable
- introduced ICacheLoader, and IRemoteCacheLoader
- added mango.cluster.TaskServer for handling grid-like processing
- added reply facilities for cluster messages/tasks
- fixed all kinds of bugs related to crazy AA hashmap side-effects
- added mango.log.RollingFileAppender, to handle rotation through a file-set
- added mango.cache.HashMap (a port of Doug Lea's latest ConcurrentHashMap)
- added a Timer class to provide large-grained clock values
- changed timout values to Timer.Interval types instead (e.g. socket timeout)
- added System.getMillisecs() and other related methods
- annotated source code is now part of the documentation (still needs a lot of work!)
- added HttpClient.read() to simplify that part of the process
- added IConduit filter support (see IConduit.attach)
- simplified the client-side of IBuffer, and cleaned up all dependents
- added a task-server to the example folder


Beta 9.1 changes

- changed ICacheEntry and CacheEntry names to IPayload and Payload respectively in the mango.cache package
- filled out mango.cluster with a large chunk of remote cache & queue functionality
- fixed a bug in the assembler version of System.flipbytes() 
- the multicast support, hence cluster support, require wsock32.lib under Win32; the old library ws2_32.lib does not provide multicast support
- fixed linux bug with huge Logger timestamps
- fixed linux SocketListener bug (codegen bug, kudos to John)
- added default values for FileConduit constructors (Style.ReadExisting)
- split Dictionary in two (Dictionary and MutableDictionary)
- reworked SocketListener to be an abstract class


Beta 9 changes

- Added multicast support via mango.io.MulticastSocket
- Split mango Socket extensions into modules ServerSocket, SocketConduit, and DatagramSocket
- Added the mango.io.SocketListener class for asynchronously dispatching socket input
- Added a remote cache-invalidator as part of the new mango.cluster package
- reworked PickleFactory yet again (thanks to Eric for pointing out the bogosity therein)
- removed AbstractServer.stop() since it's no longer necessary: Socket.d now has an isCancelled() method

Beta 8 changes

- IBuffer.flush() now throws an IOException if there was an IO problem, as does IConduit.copy() which reversed its orientation from IConduit.copyTo() such that it's now possible to chain copy() operations
- FileConduit gets a copy(FilePath) method to simplify file copying
- Further documentation
- Formal introduction of mango.log.Admin; try it out with mango.examples.servlets!
- Http client and server reorganized as described in the dsource forums (both now a subset of mango.http)
- updated to reflect dmd v0.93 .size, char.init, and typeinfo changes
- added several default values to method arguments
- ISerializable migrates to IPickle; Reader/Writer/Registry renamed appropriately; PickleRegistry is more flexible than before (see HTML documentation on PickleReader)
- A new HybridToken is introduced. Please see documentation
- CompositeReader/Writer method names changed from read/write to get/put instead
- Added the mango.io.model.IBitBucket interface


Beta 7 changes

- certain imports have been made public rather than private, in an effort to reduce the number of user-level imports 
- mango.server.utils.Uri moved to mango.io.Uri
- mango.server.utils.Utils moved to mango.io.Utils
- some internal mango.cache changes
- added the mango.log package
- HttpClient api reshaped yet again
- moved mango.server.http.HttpClient to package mango.client.http.HttpClient instead
- added an addCookie() method to HttpClient, for outgoing cookies. Still does not have support for client cookie parsing ...


Beta 6 changes

- updated old-style casts (thanks Chris S)
- reshaped server.http.HttpClient with respect to Uri access
- a tad more documentation
- reshaped ServletProvider with additional method arguments (unittest.d and servlets.d updated accordingly)


Beta 5 changes

- dsc prefix has been changed to mango. I have updated all make files and so on, and apologize for the inconvenience.
- moved file constants from System.d to FileSystem.d
- add doxygen tags to all files
- fixed FilePath '\0' termination problem in toStringZ()
- added an external Uri contructor to HttpClient
- added an "examples" directory with servlets.d to get things going


Beta 4 changes

- added a few wrappers to make it easier to control the lifespan of Sockets (setLingerPeriod() etc.)
- added SerializableReader/Writer classes, along with SerializableRegistry
- updated unittest.d serialization example to reflect the above
- added HttpClient, for easy management of client-side HTTP requests
- fixed bug in Buffer.toString()
- fixed various linux issues regarding Socket.d constants/enums (thanks John)
- removed 'synchronized' from Socket.accept()
- various examples of HttpClient usage added to unittest.d
- fixed FilePath bug regarding "." and ".." files
- added recursive file-scanner example to unittest (many thanks to Chris)
- added mango.io.FileBucket, for storing serialized classes (doesn't work on linux; no FileConduit.truncate yet)
- added the mango.cache package
- fixed operator precedence bug in FileConduit.seek 
- improved support for 'context' in ServletProvider et. al.
- added Regex pattern support to ServletProvider
- added ServletResponse.copyFile method
- added ServletRequest.getContext method 
- renamed various Input[Name] and Output[Name] classes to be [Name] and Mutable[Name] instead


Beta 3 changes

- memicmp() replaced with strncasecmp() in TokenStack.d (for linux) per John
- added sanity checks in TokenStack.d
- Fixed typo in Uri.d
- toParent() in FilePath.d now throws an exception if the source object is an orphan
- sprinkled a few more asserts around 
- tentatively synchronized Socket.accept(), to see if it resolves the linux server-socket issues
- added the linux makefile, per Brad and John


Beta 2 changes

- several linux typos and bugs were fixed (thanks Brad).
- Mango.utils now lives in Mango.server.utils. You may need to kill the previous folder ...
- Added RFC 2396 compliant URI implementation (Mango.server.utils.Uri)
- Mango.io.FilePath name-parser was reshaped such that it now actually works
- Lots of changes vis-a-vis Mango.server and Mango.servlet; these will be seperated out of here at some point


Beta 1 changes

- fixed invalid import names for linux platform (thanks Brad).
- Extended Token support for FP (thanks Chris) -- this needs further attention.
- Added FreeList support for SocketConduit instances returned via ServerSocket.accept()
- Removed hacks and workarounds vis-a-vis immature Interface runtime (way to go, Walter!). ColumnWriter and TextWriter now work as they were supposed to with dmd v0.83.
- fixed inverted-logic bug in TextReader.get  (per Chris)
- added RFC 2109 Cookie implementation (server-side, not client-side)


Alpha 6 Changes

- added IBuffer.append() for directly appending to a buffer (sans Writer), and added an example to unittest.d
- updated mango.io.FilePath to take advantage of the above
- Socket.accept() now returns null on error rather than throwing an exception. This is to avoid exceptions being thrown when listener-threads are legitimately terminated


Alpha 5 Changes

- added composite IO, via CompositeReader and CompositeWriter
- added some additional examples to mango.unittest.d, including an example of direct IO
- resolved issues regarding the reading & writing of binary arrays 
- added a 'mapped' flag to Reader classes that decides whether to allocate array types, or simply map them onto the read buffer (allocate is the default)
- fixed "forward reference" issue
- removed IBuffer.lookahead() for now since there appears to be no need for it (may change later)
- removed buffer.backup(), and combined its functionality into skip 


Alpha 4 Changes

- removed IBuffer.isReady() since it could result in similar behaviour to eof testing
- added Copyright headers
- TextWriter renamed to DisplayWriter. Plain old text output only
- TokenWriter renamed to TextWriter. TextReader/TextWriter operate upon delimited text only
- TextWriter now takes a char[] delimiter rather than a single char
- fixed precision bug for FP output


Alpha 3 Changes

- BufferToken renamed CompositeToken
- Added IConduit constructors to Tokens and Readers/Writers to make usage somewhat less verbose
- Added file random-access example to unittest.d
- added Writer.flush() 
- some further documentation


Alpha 2 Changes

- IBuffer storage type changed from ubyte[] to void[]
- IBuffer.flush() removed due to a design flaw. The replacement is IConduit.flush(IBuffer)
- Some minor additional commentary and code added to mango/unittest.d


