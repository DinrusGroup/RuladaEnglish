# Makefile to build D runtime library rulada.lib for Win32
# Designed to work with \dinrus\bin\dmmake.exe
# Targets:
#	make
#		Same as make unittest
#	make rulada.lib
#		Build rulada.lib
#	make clean
#		Delete unneeded files created by build process
#	make unittest
#		Build rulada.lib, build and run unit tests
#	make html
#		Build documentation
# Notes:
#	This relies on LIB.EXE 8.00 or later, and MAKE.EXE 5.01 or later.

CP=cp
DIR=$(DINRUS)\..\imp\rulada\auxes\pkg
LDIR=$(DINRUS)\..\lib
SI=sysimport
DMDDIR=$(DINRUS)\..\bin
LIBS=$(DINRUS)\..\lib\sysimport
CFLAGS=-mn -6 -r
#CFLAGS=-g -mn -6 -r

DFLAGS=-O -release  -nofloat -w
#DFLAGS=-nofloat -w
#DFLAGS=-unittest -g -w
#DFLAGS=-unittest -cov -g

CC=$(DINRUS)\..\bin\dmc.exe
DMD=$(DINRUS)\..\bin\dmd.exe
LL=$(DINRUS)\..\bin\lib.exe
DOC=.\html

.c.obj:
	$(CC) -c $(CFLAGS) $*

.cpp.obj:
	$(CC) -c $(CFLAGS) $*

.d.obj:
	$(DMD) -c $(DFLAGS) $*

.asm.obj:
	$(CC) -c $*

targets : rulada.lib rulada-aux.lib gcstub.obj DD-auxc.lib DD-auxd.lib 
#runexe.lib runexet.lib unittest.exe
			#DD-al.lib DD-gl.lib DD-ft.lib 

#test : test.exe

#test.obj : test.d
	#$(DMD) -c test -g -unittest

#test.exe : test.obj rulada.lib
	#$(DMD) test.obj -g -L/map

OBJS= deh.obj complex.obj \
	critical.obj object.obj monitor.obj \
	crc32.obj\
	Czlib.obj Dzlib.obj \
	oldsyserror.obj\
	errno.obj metastrings.obj
#gcstats.d crc32.d rt\object.d\

MAKEFILES=win32.mak
	
exceptions=  std\array.d std\switcherr.d std\asserterror.d \
			std\outofmemory.d std\moduleinit.d std\gc.d

SRCS=   std\intrinsic.d std\math.d std\io.d std\dateparse.d std\date.d std\uni.d std\string.d\
			std\array.d std\switcherr.d std\asserterror.d \
			std\outofmemory.d std\moduleinit.d\
        std\base64.d std\md5.d std\regexp.d std\exception.d\
        std\compiler.d std\cpuid.d std\format.d std\demangle.d\
        std\path.d std\outbuffer.d std\utf.d std\uri.d\
        std\ctype.d std\random.d  std\mmfile.d\
         std\system.d std\console.d std\stdio.d \
        std\bitarray.d std\gamma.d std\signals.d std\typetuple.d std\traits.d std\bind.d\
         std\stdarg.d  std\thread_helper.d\
        std\thread.d std\boxer.d\
        std\stream.d std\socket.d std\socketstream.d\
        std\perf.d std\openrj.d std\conv.d\
        std\zip.d std\cstream.d std\loader.d\
		std\cover.d std\process.d std\file.d\
		std\math2.d  std\c.d os\windows.d\
		os\win\charset.d os\win\iunknown.d os\win\registry.d\
		os\win\syserror.d\
		os\win\base\all.d os\win\base\collections.d os\win\base\core.d os\win\base\environment.d\
		os\win\base\events.d os\win\base\math.d os\win\base\native.d\
		os\win\base\string.d os\win\base\text.d os\win\base\threading.d os\win\base\time.d\
		os\win\com\all.d os\win\com\bstr.d os\win\com\client.d os\win\com\core.d os\win\com\reflect.d\
		os\win\com\server.d\
		os\win\io\core.d os\win\io\fs.d os\win\io\path.d os\win\io\zip.d\
		os\win\loc\consts.d os\win\loc\conv.d os\win\loc\core.d\
		os\win\loc\num.d os\win\loc\time.d\
		os\win\media\all.d os\win\media\consts.d os\win\media\core.d\
		os\win\media\geometry.d os\win\media\imaging.d os\win\media\native.d\
		os\win\net\all.d os\win\net\client.d os\win\net\core.d os\win\net\mail.d\
		os\win\sec\crypto.d\
		os\win\xml\all.d os\win\xml\core.d os\win\xml\dom.d os\win\xml\msxml.d\
		os\win\xml\streaming.d os\win\xml\xsl.d\
		os\win\utils\process.d os\win\utils\registry.d\
		utils\ArgParser.d utils\Script.d
		
		
SRC_RT= rt\aaA.d rt\adi.d\
        rt\aApply.d rt\aApplyR.d rt\memset.d\
        rt\arraycast.d rt\arraycat.d\
		rt\hash.d 	rt\typeinfo.d\
		rt\trace.d rt\core\console.d\
        rt\switch.d rt\qsort.d rt\invariant.d rt\dmain2.d rt\cast.d rt\obj.d\
        rt\arrayfloat.d rt\arraydouble.d rt\arrayreal.d\
        rt\arraybyte.d rt\arrayshort.d rt\arrayint.d\
		rt\core\sync\atomic.d \
		rt\core\sync\barrier.d rt\core\bitop.d rt\core\sync\condition.d\
		rt\core\sync\config.d rt\core\sync\mutex.d\
		rt\core\sync\rwmutex.d rt\core\sync\semaphore.d\
		rt\core\os\windows.d rt\core\os\win\charset.d\
		rt\core\os\win\iunknown.d rt\core\os\win\registry.d\
		rt\core\os\win\syserror.d\
		rt\core\c.d\
		rt\core\stdc\config.d rt\core\stdc\stringz.d rt\core\vararg.d\
		rt\core\stdc\ctype.d rt\core\stdc\errno_.d rt\core\stdc\fenv.d\
		rt\core\stdc\float_.d rt\core\stdc\inttypes.d rt\core\stdc\limits.d rt\core\stdc\complex_.d\
		rt\core\thread.d rt\core\lifetime.d\
		rt\core\stdc\locale.d rt\core\stdc\math.d rt\core\stdc\signal.d\
		rt\core\stdc\stdarg.d rt\core\stdc\stddef.d rt\core\stdc\stdint.d\
		rt\core\stdc\stdio.d rt\core\stdc\stdlib.d rt\core\stdc\string.d rt\core\stdc\process.d\
		rt\core\stdc\tgmath.d std\memory.d	rt\core\stdc\time.d\
		rt\core\stdc\wchar_.d rt\core\stdc\wctype.d	rt\core\exception.d	rt\core\runtime.d\
		rt\llmath.d rt\cmath2.d rt\alloca.d
#
#rt\core\dtype.d rt\core\format.d 
#rt\core\cpuid.d rt\core\string.d rt\core\utf.d\

SRC_AUXC=auxc\imageio.d auxc\gmp.d
		
SRC_AUXD=auxd\st\coroutine.d auxd\st\stackcontext.d auxd\st\stackthread.d auxd\st\tls.d\
		auxd\meta\Default.d auxd\meta\Demangle.d auxd\meta\Nameof.d auxd\meta\Util.d\
		auxd\com.d auxd\net.d auxd\media.d auxd\gui.d auxd\xml.d auxd\ini.d\
		auxd\linalg\MatrixT.d auxd\linalg\VectorT.d auxd\linalg\VectorTypes.d	
		
SRC=	rt\errno.c rt\object.d unittest.d crc32.d gcstats.d rulada.d

SRC_STD= std\intrinsic.d std\zlib.d std\zip.d std\stdint.d std\conv.d std\utf.d std\uri.d\
	std\math.d std\string.d std\path.d std\date.d\
	std\ctype.d std\file.d std\compiler.d std\system.d std\moduleinit.d\
	std\outbuffer.d std\math2.d std\thread.d std\md5.d std\base64.d\
	std\asserterror.d std\dateparse.d std\outofmemory.d std\mmfile.d\
	std\array.d std\switcherr.d std\syserror.d\
	std\regexp.d std\random.d std\stream.d std\process.d\
	std\socket.d std\socketstream.d std\loader.d std\stdarg.d std\format.d\
	std\stdio.d std\io.d std\perf.d std\openrj.d std\uni.d std\boxer.d\
	std\cstream.d std\demangle.d std\cover.d std\bitarray.d std\signals.d std\cpuid.d std\typetuple.d std\traits.d std\bind.d\
	std\metastrings.d std\c.d std\gamma.d

SRC_STD_X=  \
	rt\switch.d rt\complex.c rt\critical.c \
	rt\minit.asm rt\alloca.d rt\llmath.d rt\deh.c \
	rt\arraycat.d rt\invariant.d rt\monitor.c \
	rt\memset.d rt\arraycast.d rt\aaA.d rt\adi.d\
	rt\dmain2.d rt\cast.d rt\qsort.d rt\deh2.d\
	rt\cmath2.d rt\obj.d rt\mars.h rt\aApply.d\
	rt\aApplyR.d rt\object.d rt\trace.d rt\qsort2.d\
	rt\arrayfloat.d rt\arraydouble.d rt\arrayreal.d\
	rt\arraybyte.d rt\arrayshort.d rt\arrayint.d\
	
	
SRC_OS= os\windows.d os\linux.d os\osx.d os\solaris.d os\posix.d

SRC_OS_WIN=  os\win\registry.d\
	os\win\iunknown.d os\win\syserror.d os\win\charset.d
	
SRC_OS_WIN_BASE= s\win\base\all.d os\win\base\collections.d os\win\base\core.d os\win\base\environment.d\
	os\win\base\events.d os\win\base\math.d os\win\base\native.d os\win\base\string.d\
	os\win\base\text.d os\win\base\threading.d os\win\base\time.d
	
SRC_OS_WIN_COM= os\win\com\all.d os\win\com\bstr.d os\win\com\client.d os\win\com\core.d os\win\com\reflect.d\
	os\win\com\server.d
	
SRC_OS_WIN_IO= os\win\io\core.d os\win\io\fs.d os\win\io\path.d os\win\io\zip.d

SRC_OS_WIN_LOC=  os\win\loc\consts.d os\win\loc\conv.d os\win\loc\core.d\
	os\win\loc\num.d os\win\loc\time.d
	
SRC_OS_WIN_MEDIA= os\win\media\all.d os\win\media\consts.d os\win\media\core.d\
	os\win\media\geometry.d os\win\media\imaging.d os\win\media\native.d
	
SRC_OS_WIN_UTILS= os\win\utils\process.d os\win\utils\registry.d

SRC_OS_WIN_XML= os\win\xml\all.d os\win\xml\core.d os\win\xml\dom.d os\win\xml\msxml.d\
	os\win\xml\streaming.d os\win\xml\xsl.d
	
SRC_OS_WIN_NET= os\win\net\all.d os\win\net\client.d os\win\net\core.d os\win\net\mail.d

SRC_OS_WIN_SEC= os\win\sec\crypto.d

SRC_OS_WIN_GUI= os\win\gui\all.d os\win\gui\application.d os\win\gui\base.d\
	os\win\gui\button.d os\win\gui\clipboard.d os\win\gui\collections.d\
	os\win\gui\colordialog.d os\win\gui\combobox.d\
	os\win\gui\commondialog.d os\win\gui\control.d os\win\gui\data.d\
	os\win\gui\drawing.d os\win\gui\environment.d os\win\gui\event.d\
	os\win\gui\filedialog.d os\win\gui\folderdialog.d os\win\gui\form.d\
	os\win\gui\groupbox.d os\win\gui\imagelist.d os\win\gui\label.d\
	os\win\gui\listbox.d os\win\gui\listview.d os\win\gui\menu.d os\win\gui\messagebox.d\
	os\win\gui\notifyicon.d os\win\gui\panel.d os\win\gui\picturebox.d\
	os\win\gui\progressbar.d os\win\gui\registry.d os\win\gui\resources.d\
	os\win\gui\richtextbox.d os\win\gui\socket.d os\win\gui\splitter.d\
	os\win\gui\statusbar.d os\win\gui\tabcontrol.d os\win\gui\textbox.d\
	os\win\gui\timer.d os\win\gui\toolbar.d os\win\gui\tooltip.d\
	os\win\gui\treeview.d os\win\gui\usercontrol.d
	
	
SRC_OS_WIN_GUI_X= os\win\gui\x\_stdcwindows.d os\win\gui\x\com.d\
	os\win\gui\x\dlib.d os\win\gui\x\utf.d\
	os\win\gui\x\winapi.d os\win\gui\x\wincom.d

SRC_OS_LIN= os\lin\linuxextern.d\
	os\lin\socket.d os\lin\pthread.d

#SRC_OS_OSX= 

SRC_OS_FBSD= os\freebsd.d\
	os\fbsd\socket.d os\fbsd\pthread.d\
	os\fbsd\math.d

SRC_OS_SOL=  \
     os\sol\socket.d os\sol\pthread.d

SRC_OS_POS=  \
	os\pos\socket.d os\pos\pthread.d

#SRC_ETC= 

SRC_C= auxc\zlib.d auxc\imageio.d

SRC_ZLIB= auxes\clib\zlib\trees.h \
	auxes\clib\zlib\inffixed.h \
	auxes\clib\zlib\inffast.h \
	auxes\clib\zlib\crc32.h \
	auxes\clib\zlib\algorithm.txt \
	auxes\clib\zlib\uncompr.c \
	auxes\clib\zlib\compress.c \
	auxes\clib\zlib\deflate.h \
	auxes\clib\zlib\inftrees.h \
	auxes\clib\zlib\infback.c \
	auxes\clib\zlib\zutil.c \
	auxes\clib\zlib\crc32.c \
	auxes\clib\zlib\inflate.h \
	auxes\clib\zlib\example.c \
	auxes\clib\zlib\inffast.c \
	auxes\clib\zlib\trees.c \
	auxes\clib\zlib\inflate.c \
	auxes\clib\zlib\gzio.c \
	auxes\clib\zlib\zconf.h \
	auxes\clib\zlib\zconf.in.h \
	auxes\clib\zlib\minigzip.c \
	auxes\clib\zlib\deflate.c \
	auxes\clib\zlib\inftrees.c \
	auxes\clib\zlib\zutil.h \
	auxes\clib\zlib\zlib.3 \
	auxes\clib\zlib\zlib.h \
	auxes\clib\zlib\adler32.c \
	auxes\clib\zlib\ChangeLog \
	auxes\clib\zlib\README \
	auxes\clib\zlib\win32.mak \
	auxes\clib\zlib\linux.mak \
	auxes\clib\zlib\osx.mak \
	auxes\clib\zlib\freebsd.mak \
	auxes\clib\zlib\solaris.mak

SRC_GC= rt\gc\gc.d\
	rt\gc\gcold.d\
	rt\gc\gcx.d\
	rt\gc\gcstub.d\
	rt\gc\gcbits.d\
	rt\gc\win32.d\
	rt\gc\gclinux.d\
	rt\gc\gcosxc.c \
	rt\gc\testgc.d\
	rt\gc\win32.mak \
	rt\gc\linux.mak \
	rt\gc\osx.mak \
	rt\gc\freebsd.mak \
	rt\gc\solaris.mak

LIBS= $(LDIR)\c\snn.lib \
	$(LIBS)\user32.lib \
	#$(LIBS)\msvcrt.lib \
	$(LIBS)\kernel32.lib \
	$(LDIR)\c\zlib.lib \
	$(LIBS)\aclui.lib \
	$(LDIR)\c\uuid.lib \
	$(LIBS)\crypt32.lib \
	$(LIBS)\version.lib \
	$(LIBS)\ntdll.lib \
	$(LIBS)\comctl32.lib \
	$(LIBS)\comdlg32.lib  \
	#$(LIBS)\glu32.lib \
	$(LIBS)\sqlite3.lib \
	$(LIBS)\shlwapi.lib \
	#$(LIBS)\OpenGL32.lib \
	$(LIBS)\OpenCL.lib \
	#$(LIBS)\glut32.lib \
	$(LIBS)\uxtheme.lib \
	$(LIBS)\mscoree.lib \
	$(LIBS)\mSQL.lib \
	$(LIBS)\advapi32.lib \
	$(LIBS)\gdi32.lib \
	$(LIBS)\gdiplus.lib  \
	$(LIBS)\oleacc.lib \
	$(LIBS)\ole32.lib \
	$(LIBS)\olepro32.lib \
	$(LIBS)\oleaut32.lib\
	$(LIBS)\shell32.lib \
	$(LIBS)\ws2_32.lib \
	$(LIBS)\ctl3d32.lib \
	$(LIBS)\WinMM.lib \
	$(LIBS)\usp10.lib \
	$(LIBS)\url.lib \
	$(LIBS)\WSock32.lib \
	$(LIBS)\imm32.lib \
	$(LIBS)\msimg32.lib \
	$(LIBS)\wininet.lib \
	$(LIBS)\urlmon.lib\
	$(LIBS)\atl100.lib\
	$(LIBS)\bzip2.lib
	
	
AUXCLIBS=$(DINRUS)\..\lib\sysimport\mSQL.lib \
	$(DINRUS)\..\lib\sysimport\libmySQL.lib \
	$(DINRUS)\..\lib\sysimport\sqlite3.lib
	#$(DINRUS)\..\lib\sysimport\d3d9.lib \
	#$(DINRUS)\..\lib\sysimport\d3dx9.lib \
	#$(DINRUS)\..\lib\sysimport\d3dxof.lib \
	#$(DINRUS)\..\lib\sysimport\ddraw.lib \
	#$(DINRUS)\..\lib\sysimport\dinput8.lib \
	#$(DINRUS)\..\lib\sysimport\dsetup.lib \
	#$(DINRUS)\..\lib\sysimport\dsound.lib \
	#$(DINRUS)\..\lib\sysimport\dxgi.lib \
	#$(DINRUS)\..\lib\sysimport\X3DAudio.lib \
	#$(DINRUS)\..\lib\sysimport\XInput.lib \
		

#		$(SRC_TGC)
	
#rulada.lib : $(LIBS) $(AUXCLIBS)
	#$(LL) -c -p256 rulada.lib $(LIBS) $(AUXCLIBS)

rulada-aux.lib: $(OBJS) $(SRC_RT) $(SRCS) minit.obj  win32.mak
	     $(DMD) -lib -ofrulada-aux.lib $(DFLAGS) $(OBJS) $(SRC_RT) $(SRCS) minit.obj -L+rulada.lib
		$(LL) -p256 rulada.lib rulada-aux.lib 
		#bud -ofruladaD.dll $(DFLAGS) dll.d $(SRCS) $(OBJS) minit.obj ruladaD.def
		
#DD-al.lib: $(C_AL)
			#$(DMD) -lib -ofDD-al.lib $(C_AL)

#DD-gl.lib: $(C_GL)
			#$(DMD) -lib -ofDD-gl.lib $(C_GL)

#DD-ft.lib: $(C_FT)
			#$(DMD) -lib -ofDD-ft.lib $(C_FT)
			
DD-auxc.lib: $(SRC_AUXD) $(AUXCLIBS)
			$(LL)  -c -p256 auxc.lib $(AUXCLIBS)
			$(DMD) -lib -ofDD-auxc.lib $(SRC_AUXC) 
			$(LL)  -p256 DD-auxc.lib auxc.lib
			
DD-auxd.lib: $(SRC_AUXD)
			$(DMD) -lib -ofDD-auxd.lib $(SRC_AUXD)
			
unittest : $(SRCS) rulada.lib
        $(DMD) $(DFLAGS) -unittest -version=Unittest unittest.d $(SRCS) rulada.lib
        unittest
		

#unittest : unittest.exe
#       unittest
#
unittest.exe : unittest.d rulada.lib
       $(DMD) unittest -g
       dmc unittest.obj -g

cov : $(SRCS) rulada.lib
        $(DMD) -cov -unittest -ofcov.exe unittest.d $(SRCS) rulada.lib
        cov

html : $(DOCS)

################# runtime #####################################

errno.obj : rt\errno.c
 $(CC) -c rt\errno.c
 
critical.obj: rt\critical.c
 $(CC) -c rt\critical.c
 
complex.obj: rt\complex.c
 $(CC) -c rt\complex.c
 
gcstats.obj: gcstats.d
    $(DMD) -c $(DFLAGS) gcstats.d
	
crc32.obj: crc32.d
	 $(DMD) -c $(DFLAGS) crc32.d
	
### internal
bitop.obj: rt\core\bitop.d
		$(DMD) -c $(DFLAGS) -inline rt\core\bitop.d
		
aaA.obj : rt\aaA.d
	$(DMD)  $(DFLAGS) rt\aaA.d
	
cmath.obj : rt\llmath.d rt\cmath2.d rt\alloca.d
	$(DMD)  $(DFLAGS) -cmath.obj rt\llmath.d rt\cmath2.d rt\alloca.d

aApply.obj : rt\aApply.d
	$(DMD)  $(DFLAGS) rt\aApply.d

aApplyR.obj : rt\aApplyR.d
	$(DMD) -c $(DFLAGS) rt\aApplyR.d

console.obj: std\console.d
	$(DMD) -c $(DFLAGS) std\console.d
	
rtconsole.obj: rt\core\console.d
	$(DMD) -c $(DFLAGS) -ofrtconsole.obj rt\core\console.d
	
adi.obj : rt\adi.d
	$(DMD) -c $(DFLAGS) rt\adi.d

arraycast.obj : rt\arraycast.d
	$(DMD) -c $(DFLAGS) rt\arraycast.d

arraycat.obj : rt\arraycat.d
	$(DMD) -c $(DFLAGS) rt\arraycat.d

cast.obj : rt\cast.d
	$(DMD) -c $(DFLAGS) rt\cast.d

runtime.obj: rt\core\runtime.d
	$(DMD) -c $(DFLAGS) rt\core\runtime.d
	
hash.obj: rt\hash.d
	$(DMD) -c $(DFLAGS) rt\hash.d
	
critical.obj : rt\critical.c
	$(CC) -c $(CFLAGS) rt\critical.c

deh.obj : rt\mars.h rt\deh.c
	$(CC) -c $(CFLAGS) rt\deh.c
	
dmain2.obj : rt\dmain2.d
	$(DMD) -c $(DFLAGS) rt\dmain2.d
	

gcstub.obj : rt\gc\gcstub.d
	$(DMD) -c $(DFLAGS) -Irt\gc rt\gc\gcstub.d

invariant.obj : rt\invariant.d
	$(DMD) -c $(DFLAGS) rt\invariant.d

memset.obj : rt\memset.d
	$(DMD) -c $(DFLAGS) rt\memset.d

#minit.obj : $(DINRUS)\..\dev1\rt\minit.asm
	#$(CC) -c $(DINRUS)\..\dev1\rt\minit.asm

monitor.obj : rt\mars.h rt\monitor.c
	$(CC) -c $(CFLAGS) rt\monitor.c

obj.obj : rt\obj.d
	$(DMD) -c $(DFLAGS) rt\obj.d
	
trace.obj : rt\trace.d
	$(DMD) -c $(DFLAGS) rt\trace.d

object.obj : rt\object.d
	$(DMD) -c $(DFLAGS) rt\object.d

qsort.obj : rt\qsort.d
	$(DMD) -c $(DFLAGS) rt\qsort.d

switch.obj : rt\switch.d
	$(DMD) -c $(DFLAGS) rt\switch.d
	
typeinfo.obj : rt\typeinfo.d
	$(DMD) -c $(DFLAGS) -inline rt\typeinfo.d


windows.obj: rt\core\os\windows.d os\windows.d
	$(DMD) -c $(DFLAGS) rt\core\os\windows.d os\windows.d
	
charset.obj : rt\core\os\win\charset.d os\win\charset.d
	$(DMD) -c $(DFLAGS) rt\core\os\win\charset.d os\win\charset.d

iunknown.obj : rt\core\os\win\iunknown.d os\win\iunknown.d
	$(DMD) -c $(DFLAGS) rt\core\os\win\iunknown.d os\win\iunknown.d

registry.obj : rt\core\os\win\registry.d os\win\registry.d
	$(DMD) -c $(DFLAGS) rt\core\os\win\registry.d os\win\registry.d

syserror.obj : rt\core\os\win\syserror.d os\win\syserrror.d
	$(DMD) -c $(DFLAGS) rt\core\os\win\syserror.d os\win\syserrror.d
#############sync####################

atomic.obj: rt\core\sync\atomic.d
	$(DMD) -c $(DFLAGS) rt\core\sync\atomic.d
	
barier.obj: rt\core\sync\barier.d
	$(DMD) -c $(DFLAGS) rt\core\sync\barier.d
	
condition.obj: rt\core\sync\condition.d
	$(DMD) -c $(DFLAGS) rt\core\sync\condition.d
	
syncconfig.obj:rt\core\sync\config.d
	$(DMD) -c $(DFLAGS) rt\core\sync\config.d

mutex.obj:rt\core\sync\mutex.d
	$(DMD) -c $(DFLAGS) rt\core\sync\mutex.d

rwmutex.obj:rt\core\sync\rwmutex.d
	$(DMD) -c $(DFLAGS) rt\core\sync\rwmutex.d

semaphore.obj:rt\core\sync\semaphore.d
	$(DMD) -c $(DFLAGS) rt\core\sync\semaphore.d

############stdc####################################
c.obj : std\c.d
	$(DMD) -c $(DFLAGS) -inline std\c.d 
	
corthread.obj : rt\core\thread.d
	$(DMD) -c $(DFLAGS) -ofcorthread.obj rt\core\thread.d
	
corec.obj : rt\core\c.d
	$(DMD) -c $(DFLAGS) -inline -ofcorec.obj rt\core\c.d
	
vararg.obj : rt\core\vararg.d
	$(DMD) -c $(DFLAGS) -inline rt\core\vararg.d
	
lifetime.obj : rt\core\lifetime.d
	$(DMD) -c $(DFLAGS) -inline rt\core\lifetime.d
	
memory.obj : std\memory.d
	$(DMD) -c $(DFLAGS) -inline std\memory.d

runtime.obj : rt\core\runtime.d
	$(DMD) -c $(DFLAGS) -inline rt\core\runtime.d
	
complex_.obj : rt\core\stdc\complex_.d
	$(DMD) -c $(DFLAGS) -inline rt\core\stdc\complex_.d
	
stringz.obj : rt\core\stdc\stringz.d
	$(DMD) -c $(DFLAGS) -inline rt\core\stdc\stringz.d	

corelimits.obj :  rt\core\stdc\limits.d
	$(DMD) -c $(DFLAGS) -inline -ofcorelimits.obj rt\core\stdc\limits.d

coreconfig.obj :  rt\core\stdc\config.d
	$(DMD) -c $(DFLAGS) -inline -ofcoreconf.obj rt\core\stdc\config.d

corectype.obj :  rt\core\stdc\ctype.d
	$(DMD) -c $(DFLAGS) -inline -ofcorectype.obj rt\core\stdc\ctype.d
	
errno_.obj :  rt\core\stdc\errno_.d
	$(DMD) -c $(DFLAGS) -inline  rt\core\stdc\errno_.d
	
fenv.obj :  rt\core\stdc\fenv.d
	$(DMD) -c $(DFLAGS) -inline  rt\core\stdc\fenv.d
	
float_.obj :  rt\core\stdc\float_.d
	$(DMD) -c $(DFLAGS) -inline  rt\core\stdc\float_.d
	
inttypes.obj :  rt\core\stdc\inttypes.d
	$(DMD) -c $(DFLAGS) -inline  rt\core\stdc\inttypes.d
  
corelocale.obj :  rt\core\stdc\locale.d
	$(DMD) -c $(DFLAGS) -inline  -ofcorelocale.obj rt\core\stdc\locale.d

coremath.obj :  rt\core\stdc\math.d
	$(DMD) -c $(DFLAGS) -inline -ofcoremath.obj rt\core\stdc\math.d

coreprocess.obj: rt\core\stdc\process.d
	$(DMD) -c $(DFLAGS) -inline -ofcoreprocess.obj rt\core\stdc\process.d
	
coresignal.obj :  rt\core\stdc\signal.d
	$(DMD) -c $(DFLAGS) -inline -ofcoresignal.obj rt\core\stdc\signal.d
	
corestdarg.obj :  rt\core\stdc\stdarg.d
	$(DMD) -c $(DFLAGS) -inline -ofcorestdarg.obj rt\core\stdc\stdarg.d
	
corestddef.obj :  rt\core\stdc\stddef.d
	$(DMD) -c $(DFLAGS) -inline -ofcorestddef.obj rt\core\stdc\stddef.d
	
corestdint.obj :  rt\core\stdc\stdint.d
	$(DMD) -c $(DFLAGS) -inline -ofcorestdint.obj rt\core\stdc\stdint.d
	
corestdio.obj :  rt\core\stdc\stdio.d
	$(DMD) -c $(DFLAGS) -inline -ofcorestdio.obj rt\core\stdc\stdio.d
	
stdlib.obj :  rt\core\stdc\stdlib.d
	$(DMD) -c $(DFLAGS) -inline rt\core\stdc\stdlib.d
	
corestring.obj :  rt\core\stdc\string.d
	$(DMD) -c $(DFLAGS) -inline -ofcorestring.obj rt\core\stdc\string.d
	
tgmath.obj :  rt\core\stdc\tgmath.d
	$(DMD) -c $(DFLAGS) -inline  rt\core\stdc\tgmath.d
	
coretime.obj :  rt\core\stdc\time.d
	$(DMD) -c $(DFLAGS) -inline -ofcoretime.obj rt\core\stdc\time.d
	
wchar_.obj :  rt\core\stdc\wchar_.d
	$(DMD) -c $(DFLAGS) -inline  rt\core\stdc\wchar_.d
	
wctype.obj :  rt\core\stdc\wctype.d
	$(DMD) -c $(DFLAGS) -inline  rt\core\stdc\wctype.d

#############rt.util#################
cpuid.obj: std\cpuid.d
	$(DMD) -c $(DFLAGS) -inline  std\cpuid.d	

corecpuid.obj: rt\core\cpuid.d 
	$(DMD) -c $(DFLAGS) -inline -ofcorecpuid.obj rt\core\cpuid.d

string.obj : std\string.d
	$(DMD) -c $(DFLAGS) std\string.d
	
corestring.obj: rt\core\string.d
	$(DMD) -c $(DFLAGS) -inline -ofcorestring.obj rt\core\string.d
	
utf.obj: std\utf.d
	$(DMD) -c $(DFLAGS) -inline std\utf.d
	
coreutf.obj: rt\core\utf.d
	$(DMD) -c $(DFLAGS) -inline -ofcoreutf.obj rt\core\utf.d
	
exception.obj: std\exception.d rt\core\exception.d
	$(DMD) -c $(DFLAGS) std\exception.d rt\core\exception.d
	
coreexcept.obj:  rt\core\exception.d
	$(DMD) -c $(DFLAGS)  -ofcoreexcept.obj -inline rt\core\exception.d
	
ctype.obj : std\ctype.d 
	$(DMD) -c $(DFLAGS) std\ctype.d
	
coredtype.obj : rt\core\dtype.d
	$(DMD) -c $(DFLAGS) -ofcoredtype.obj -inline rt\core\dtype.d
	
format.obj : std\format.d
	$(DMD) -c $(DFLAGS) std\format.d
	
coreformat.obj : rt\core\format.d
	$(DMD) -c $(DFLAGS) -inline -ofcoreformat.obj rt\core\format.d
	
stdthread.obj : std\thread.d
	$(DMD) -c $(DFLAGS) std\thread.d

threadhelper.obj: std\thread_helper.d
	$(DMD) -c $(DFLAGS) std\thread_helper.d

	
array.obj : std\array.d
	$(DMD) -c $(DFLAGS) std\array.d

asserterror.obj : std\asserterror.d
	$(DMD) -c $(DFLAGS) std\asserterror.d

base64.obj : std\base64.d
	$(DMD) -c $(DFLAGS) -inline std\base64.d

bind.obj : std\bind.d
	$(DMD) -c $(DFLAGS) -inline std\bind.d
	
bitarray.obj : std\bitarray.d
	$(DMD) -c $(DFLAGS) -inline std\bitarray.d

intrinsic.obj : std\intrinsic.d
	$(DMD) -c $(DFLAGS) -inline std\intrinsic.d
	
boxer.obj : std\boxer.d
	$(DMD) -c $(DFLAGS) std\boxer.d

compiler.obj : std\compiler.d
	$(DMD) -c $(DFLAGS) std\compiler.d

conv.obj : std\conv.d
	$(DMD) -c $(DFLAGS) std\conv.d

cover.obj : std\cover.d
	$(DMD) -c $(DFLAGS) std\cover.d

cstream.obj : std\cstream.d
	$(DMD) -c $(DFLAGS) std\cstream.d

date.obj : std\dateparse.d std\date.d
	$(DMD) -c $(DFLAGS) std\date.d

dateparse.obj : std\dateparse.d std\date.d
	$(DMD) -c $(DFLAGS) std\dateparse.d

demangle.obj : std\demangle.d
	$(DMD) -c $(DFLAGS) std\demangle.d

file.obj : std\file.d
	$(DMD) -c $(DFLAGS) std\file.d

stdgc.obj : std\gc.d
	$(DMD) -c $(DFLAGS) -ofstdgc.obj std\gc.d

loader.obj : std\loader.d
	$(DMD) -c $(DFLAGS) std\loader.d

math.obj : std\math.d
	$(DMD) -c $(DFLAGS) -inline std\math.d
	
gc.obj : std\gc.d
	$(DMD) -c $(DFLAGS) std\gc.d

math2.obj : std\math2.d
	$(DMD) -c $(DFLAGS) std\math2.d

md5.obj : std\md5.d
	$(DMD) -c $(DFLAGS) -inline std\md5.d

metastrings.obj : std\metastrings.d
	$(DMD) -c $(DFLAGS) -inline std\metastrings.d

mmfile.obj : std\mmfile.d
	$(DMD) -c $(DFLAGS) std\mmfile.d

moduleinit.obj : std\moduleinit.d
	$(DMD) -c $(DFLAGS) std\moduleinit.d 

#object.obj : object.d
	#$(DMD) -c $(DFLAGS) object.d

openrj.obj : std\openrj.d
	$(DMD) -c $(DFLAGS) std\openrj.d

outbuffer.obj : std\outbuffer.d
	$(DMD) -c $(DFLAGS) std\outbuffer.d

outofmemory.obj : std\outofmemory.d
	$(DMD) -c $(DFLAGS) std\outofmemory.d

path.obj : std\path.d
	$(DMD) -c $(DFLAGS) std\path.d

perf.obj : std\perf.d
	$(DMD) -c $(DFLAGS) std\perf.d

process.obj : std\process.d
	$(DMD) -c $(DFLAGS) std\process.d

random.obj : std\random.d
	$(DMD) -c $(DFLAGS) std\random.d

regexp.obj : std\regexp.d
	$(DMD) -c $(DFLAGS) std\regexp.d

signals.obj : std\signals.d
	$(DMD) -c $(DFLAGS) std\signals.d -ofsignals.obj

socket.obj : std\socket.d
	$(DMD) -c $(DFLAGS) std\socket.d -ofsocket.obj

socketstream.obj : std\socketstream.d
	$(DMD) -c $(DFLAGS) std\socketstream.d -ofsocketstream.obj

stdio.obj : std\stdio.d
	$(DMD) -c $(DFLAGS) std\stdio.d
	
io.obj : std\io.d 
	$(DMD) -c $(DFLAGS) std\io.d

stream.obj : std\stream.d
	$(DMD) -c $(DFLAGS) -d std\stream.d


switcherr.obj : std\switcherr.d
	$(DMD) -c $(DFLAGS) std\switcherr.d

oldsyserror.obj : std\syserror.d
	$(DMD) -c $(DFLAGS) std\syserror.d -ofoldsyserror.obj

system.obj : std\system.d
	$(DMD) -c $(DFLAGS) std\system.d

traits.obj : std\traits.d
	$(DMD) -c $(DFLAGS) std\traits.d -oftraits.obj

typetuple.obj : std\typetuple.d
	$(DMD) -c $(DFLAGS) std\typetuple.d -oftypetuple.obj

uni.obj : std\uni.d
	$(DMD) -c $(DFLAGS) std\uni.d

uri.obj : std\uri.d
	$(DMD) -c $(DFLAGS) std\uri.d

utf.obj : std\utf.d
	$(DMD) -c $(DFLAGS) std\utf.d

Dzlib.obj : std\zlib.d
	$(DMD) -c $(DFLAGS) std\zlib.d -ofDzlib.obj

zip.obj : std\zip.d
	$(DMD) -c $(DFLAGS) std\zip.d
	
gamma.obj : std\gamma.d
	$(DMD) -c $(DFLAGS) std\gamma.d

#####################################################
all.obj: os\win\base\all.d
	$(DMD) -c $(DFLAGS) rt\core\os\win\base\all.d
	
collections.obj: os\win\base\collections.d
	$(DMD) -c $(DFLAGS) os\win\base\collections.d
	
core.obj: os\win\base\core.d
	$(DMD) -c $(DFLAGS) os\win\base\core.d
	
environment.obj: os\win\base\environment.d
	$(DMD) -c $(DFLAGS) os\win\base\environment.d
	
events.obj:os\win\base\events.d
	$(DMD) -c $(DFLAGS) os\win\base\events.d
	
math.obj: os\win\base\math.d
	$(DMD) -c $(DFLAGS) os\win\base\math.d
	
native.obj: os\win\base\native.d
	$(DMD) -c $(DFLAGS) os\win\base\native.d
	
string.obj: os\win\base\string.d
	$(DMD) -c $(DFLAGS) os\win\base\string.d
	
text.obj:os\win\base\text.d
	$(DMD) -c $(DFLAGS) os\win\base\text.d
	
threading.obj: os\win\base\threading.d
	$(DMD) -c $(DFLAGS) os\win\base\threading.d
	
time.obj: os\win\base\time.d
	$(DMD) -c $(DFLAGS) os\win\base\time.d
	
all.obj: os\win\com\all.d
	$(DMD) -c $(DFLAGS) os\win\com\all.d
	
bstr.obj:os\win\com\bstr.d
	$(DMD) -c $(DFLAGS) os\win\com\bstr.d
	
client.obj: os\win\com\client.d
	$(DMD) -c $(DFLAGS) os\win\com\client.d
	
core.obj: os\win\com\core.d
	$(DMD) -c $(DFLAGS) os\win\com\core.d
	
reflect.obj: os\win\com\reflect.d
	$(DMD) -c $(DFLAGS) os\win\com\reflect.d
	
server.obj: os\win\com\server.d
	$(DMD) -c $(DFLAGS) os\win\com\server.d
	
core.obj: os\win\io\core.d
	$(DMD) -c $(DFLAGS) os\win\io\core.d
	
fs.obj: os\win\io\fs.d
	$(DMD) -c $(DFLAGS) os\win\io\fs.d
	
path.obj: os\win\io\path.d
	$(DMD) -c $(DFLAGS) os\win\io\path.d
	
zip.obj: os\win\io\zip.d
	$(DMD) -c $(DFLAGS) os\win\io\zip.d
	
consts.obj:	os\win\loc\consts.d
	$(DMD) -c $(DFLAGS) os\win\loc\consts.d
	
conv.obj: os\win\loc\conv.d
	$(DMD) -c $(DFLAGS) os\win\loc\conv.d
	
core.obj: os\win\loc\core.d
	$(DMD) -c $(DFLAGS) os\win\loc\core.d
	
num.obj: os\win\loc\num.d
	$(DMD) -c $(DFLAGS) os\win\loc\num.d
	
time.obj: os\win\loc\time.d
	$(DMD) -c $(DFLAGS) os\win\loc\time.d
	
all.obj: os\win\media\all.d
	$(DMD) -c $(DFLAGS) os\win\media\all.d
	
consts.obj:os\win\media\consts.d
	$(DMD) -c $(DFLAGS) os\win\media\consts.d
	
core.obj: os\win\media\core.d
	$(DMD) -c $(DFLAGS) os\win\media\core.d
	
geometry.obj: os\win\media\geometry.d
	$(DMD) -c $(DFLAGS) os\win\media\geometry.d
	
imaging.obj: os\win\media\imaging.d
	$(DMD) -c $(DFLAGS) os\win\media\imaging.d
	
native.obj: os\win\media\native.d
	$(DMD) -c $(DFLAGS) os\win\media\native.d
	
all.obj: os\win\net\all.d
	$(DMD) -c $(DFLAGS) os\win\net\all.d
	
client.obj: os\win\net\client.d
	$(DMD) -c $(DFLAGS) os\win\net\client.d
	
core.obj: os\win\net\core.d
	$(DMD) -c $(DFLAGS) os\win\net\core.d
	
mail.obj: os\win\net\mail.d
	$(DMD) -c $(DFLAGS) os\win\net\mail.d
	
crypto.obj:	os\win\sec\crypto.d
	$(DMD) -c $(DFLAGS) os\win\sec\crypto.d
	
all.obj: os\win\xml\all.d
	$(DMD) -c $(DFLAGS) os\win\xml\all.d
	
core.obj: os\win\xml\core.d
	$(DMD) -c $(DFLAGS) os\win\xml\core.d
	
dom.obj: os\win\xml\dom.d
	$(DMD) -c $(DFLAGS) os\win\xml\dom.d
	
msxml.obj: os\win\xml\msxml.d
	$(DMD) -c $(DFLAGS) os\win\xml\msxml.d
	
streaming.obj: os\win\xml\streaming.d
	$(DMD) -c $(DFLAGS) os\win\xml\streaming.d
	
xsl.obj: os\win\xml\xsl.d
	$(DMD) -c $(DFLAGS) os\win\xml\xsl.d
	
process.obj: os\win\utils\process.d
	$(DMD) -c $(DFLAGS) os\win\utils\process.d
	
registry.obj: os\win\utils\registry.d
	$(DMD) -c $(DFLAGS) os\win\utils\registry.d
	
######

Czlib.obj : auxc\zlib.d
	$(DMD) -c $(DFLAGS) auxc\zlib.d -ofCzlib.obj


### std\typeinfo
all.obj:os\win\gui\all.d
	$(DMD) -c $(DFLAGS) os\win\gui\all.d
	
application.obj: os\win\gui\application.d
	$(DMD) -c $(DFLAGS) os\win\gui\application.d
	
base.obj: os\win\gui\base.d
	$(DMD) -c $(DFLAGS) os\win\gui\base.d
	
button.obj:	os\win\gui\button.d
	$(DMD) -c $(DFLAGS) os\win\gui\button.d
	
clipboard.obj: os\win\gui\clipboard.d	
	$(DMD) -c $(DFLAGS) os\win\gui\clipboard.d
	
collections.obj: os\win\gui\collections.d
	$(DMD) -c $(DFLAGS) os\win\gui\collections.d
	
colordialog.obj: os\win\gui\colordialog.d
	$(DMD) -c $(DFLAGS) os\win\gui\colordialog.d
	
combobox.obj: os\win\gui\combobox.d
	$(DMD) -c $(DFLAGS) os\win\gui\combobox.d
	
commondialog.obj: os\win\gui\commondialog.d
	$(DMD) -c $(DFLAGS) os\win\gui\commondialog.d
	
control.obj: os\win\gui\control.d
	$(DMD) -c $(DFLAGS) os\win\gui\control.d
	
data.obj: os\win\gui\data.d
	$(DMD) -c $(DFLAGS) os\win\gui\data.d
	
drawing.obj: os\win\gui\drawing.d
	$(DMD) -c $(DFLAGS) os\win\gui\drawing.d
	
environment.obj: os\win\gui\environment.d
	$(DMD) -c $(DFLAGS) os\win\gui\environment.d
	
event.obj: os\win\gui\event.d
	$(DMD) -c $(DFLAGS) os\win\gui\event.d
	
filedialog.obj: os\win\gui\filedialog.d
	$(DMD) -c $(DFLAGS) os\win\gui\filedialog.d
	
folderdialog.obj: os\win\gui\folderdialog.d
	$(DMD) -c $(DFLAGS) os\win\gui\folderdialog.d
	
form.obj: os\win\gui\form.d
	$(DMD) -c $(DFLAGS) os\win\gui\form.d
	
groupbox.obj: os\win\gui\groupbox.d
	$(DMD) -c $(DFLAGS) os\win\gui\groupbox.d
	
imagelist.obj: os\win\gui\imagelist.d
	$(DMD) -c $(DFLAGS) os\win\gui\imagelist.d
	
label.obj: os\win\gui\label.d
	$(DMD) -c $(DFLAGS) os\win\gui\label.d
	
listbox.obj: os\win\gui\listbox.d
	$(DMD) -c $(DFLAGS) os\win\gui\listbox.d
	
listview.obj: os\win\gui\listview.d
	$(DMD) -c $(DFLAGS) os\win\gui\listview.d
	
menu.obj: os\win\gui\menu.d
	$(DMD) -c $(DFLAGS) os\win\gui\menu.d
	
messagebox.obj:	os\win\gui\messagebox.d
	$(DMD) -c $(DFLAGS) os\win\gui\messagebox.d
	
notifyicon.obj: os\win\gui\notifyicon.d
	$(DMD) -c $(DFLAGS) os\win\gui\notifyicon.d
	
panel.obj: os\win\gui\panel.d
	$(DMD) -c $(DFLAGS) os\win\gui\panel.d
	
picturebox.obj:	os\win\gui\picturebox.d
	$(DMD) -c $(DFLAGS) os\win\gui\picturebox.d
	
progressbar.obj: os\win\gui\progressbar.d
	$(DMD) -c $(DFLAGS) os\win\gui\progressbar.d
	
registry.obj:os\win\gui\registry.d	
	$(DMD) -c $(DFLAGS) os\win\gui\registry.d
	
resources.obj: os\win\gui\resources.d
	$(DMD) -c $(DFLAGS) os\win\gui\resources.d
	
richtextbox.obj: os\win\gui\richtextbox.d
	$(DMD) -c $(DFLAGS) os\win\gui\richtextbox.d
	
socket.obj: os\win\gui\socket.d
	$(DMD) -c $(DFLAGS) os\win\gui\socket.d
	
splitter.obj: os\win\gui\splitter.d
	$(DMD) -c $(DFLAGS) os\win\gui\splitter.d
	
statusbar.obj: os\win\gui\statusbar.d
	$(DMD) -c $(DFLAGS) os\win\gui\statusbar.d
	
tabcontrol.obj: os\win\gui\tabcontrol.d
	$(DMD) -c $(DFLAGS) os\win\gui\tabcontrol.d
	
textbox.obj: os\win\gui\textbox.d
	$(DMD) -c $(DFLAGS) os\win\gui\textbox.d
	
timer.obj: os\win\gui\timer.d
	$(DMD) -c $(DFLAGS) os\win\gui\timer.d
	
toolbar.obj: os\win\gui\toolbar.d
	$(DMD) -c $(DFLAGS) os\win\gui\toolbar.d
	
tooltip.obj: os\win\gui\toolbar.d
	$(DMD) -c $(DFLAGS) os\win\gui\toolbar.d
	
treeview.obj: os\win\gui\treeview.d
	$(DMD) -c $(DFLAGS) os\win\gui\treeview.d
	
usercontrol.obj: os\win\gui\usercontrol.d
	$(DMD) -c $(DFLAGS) os\win\gui\usercontrol.d
	
_stdcwindows.obj: os\win\gui\x\_stdcwindows.d
	$(DMD) -c $(DFLAGS) os\win\gui\x\_stdcwindows.d
	
com.obj: os\win\gui\x\com.d
	$(DMD) -c $(DFLAGS) os\win\gui\x\com.d
	
dlib.obj: os\win\gui\x\dlib.d
	$(DMD) -c $(DFLAGS) os\win\gui\x\dlib.d
	
utf.obj: os\win\gui\x\utf.d
	$(DMD) -c $(DFLAGS) os\win\gui\x\utf.d
	
winapi.obj:	os\win\gui\x\winapi.d
	$(DMD) -c $(DFLAGS) os\win\gui\x\winapi.d
	
wincom.obj: os\win\gui\x\wincom.d
	$(DMD) -c $(DFLAGS) os\win\gui\x\wincom.d
	
Argparser.obj: utils\ArgParser.d
	$(DMD) -c $(DFLAGS) utils\ArgParser.d
	
Script.obj: utils\Script.d
	$(DMD) -c $(DFLAGS) utils\Script.d
######################################################

zip : $(MAKEFILES) ruladalicense.txt std.ddoc $(SRC) \
	$(SRC_STD) $(SRC_INT) $(SRC_OS) $(SRC_OS_WIN) \
	$(SRC_OS_LIN) $(SRC_ETC_C) $(SRC_ZLIB) $(SRC_GC)
	del rulada.zip
	zip32 -u rulada $(MAKEFILES) std.ddoc
	zip32 -u rulada $(SRC)	
	zip32 -u rulada $(SRC_INT)
	zip32 -u rulada $(SRC_STD)
	zip32 -u rulada $(SRC_OS)
	zip32 -u rulada $(SRC_OS_WIN)	
	zip32 -u rulada $(SRC_OS_LIN)
	zip32 -u rulada $(SRC_OS_OSX)
	zip32 -u rulada $(SRC_OS_FREEBSD)
	zip32 -u rulada $(SRC_OS_SOLARIS)
	zip32 -u rulada $(SRC_OS_POSIX)
	#zip32 -u rulada $(SRC_ETC)
	zip32 -u rulada $(SRC_ETC_C)
	zip32 -u rulada $(SRC_ZLIB)
	zip32 -u rulada $(SRC_GC)

clean:
	del $(OBJS)
	del $(DOCS)

cleanhtml:
	del $(DOCS)

install:
	$(CP) rulada.lib gcstub.obj $(DMDDIR)\lib\rulada
	$(CP) $(MAKEFILES) ruladalicense.txt minit.obj std.ddoc $(DMDDIR)\src\rulada
	$(CP) $(SRC) $(DIR)
	$(CP) $(SRC_STD) $(DIR)\dinrus
	$(CP) $(SRC_INT) $(DIR)\internal
	$(CP) $(SRC_OS) $(DIR)\sys
	$(CP) $(SRC_OS_WIN) $(DIR)\os\win
	#$(CP)  $(DIR)\os\win
	#$(CP) $(SRC_STD_C_LINUX) $(DIR)\srauxc\rulada\std\auxc\linux
	#$(CP) $(SRC_STD_C_OSX) $(DIR)\srauxc\rulada\std\auxc\osx
	#$(CP) $(SRC_STD_C_FREEBSD) $(DIR)\srauxc\rulada\std\auxc\freebsd
	#$(CP) $(SRC_STD_C_SOLARIS) $(DIR)\srauxc\rulada\std\auxc\solaris
	#$(CP) $(SRC_STD_C_POSIX) $(DIR)\srauxc\rulada\std\auxc\posix
	#$(CP) $(SRC_ETC) $(DIR)\etc
	$(CP) $(SRC_ETC_C) $(DIR)\etauxc\c
	$(CP) $(SRC_ZLIB) $(DIR)\auxes\clib\zlib
	$(CP) $(SRC_GC) $(DIR)\rt\gc

