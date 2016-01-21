@echo off
:begin_again
@cls
:::Setting environment variables
@set this=%DINRUS%\..\dev\RULADA
@set R=%DINRUS%\..\imp\dinrus\rulada
@set LIBS=%DINRUS%\..\lib\sysimport
@set LDIR=%DINRUS%\..\lib
@set DMD=%DINRUS%\dmd.exe
@set DMC=%DINRUS%\dmc.exe
@set LIB=%DINRUS%\lib.exe
@set IMPLIB=%DINRUS%\implib.exe
@set ARCDIR=%this%\..\R1_Dinrus_Arc
@set MINIDDIR=%this%\..\R2_Dinrus_Minid
@set LS=%DINRUS%\ls2.exe
:set OPTLINKS=/STACK:4294967295
:65535

cd %this%

@del %LDIR%\rulada\*.lib



:copy  d:\dinrus\imp\rulada\cord\exception.d d:\dinrus\imp\rulada\cord\exception1.d
:copy  d:\dinrus\imp\rulada\rt\exception.d d:\dinrus\imp\rulada\cord\exception.d
rem @if not exist %LDIR%\rulada\snn.lib (copy  %LDIR%\rulada\prev\snn.lib /b %LDIR%\rulada\snn.lib /b)
%DINRUS%\ruladaex
copy %LDIR%\minit.obj /b %this% /b
copy %LDIR%\import.lib /b %this%\rulada.lib /b


:got_dmc
set version = DFL_NO_LIB
set dfl_files=os/win/gui/all.d os/win/gui/base.d os/win/gui/application.d os/win/gui/x/dlib.d os/win/gui/x/utf.d os/win/gui/x/com.d os/win/gui/control.d os/win/gui/form.d os/win/gui/registry.d os/win/gui/drawing.d os/win/gui/menu.d os/win/gui/notifyicon.d os/win/gui/commondialog.d os/win/gui/filedialog.d os/win/gui/folderdialog.d os/win/gui/panel.d os/win/gui/textbox.d os/win/gui/richtextbox.d os/win/gui/picturebox.d os/win/gui/listbox.d os/win/gui/groupbox.d os/win/gui/splitter.d os/win/gui/usercontrol.d os/win/gui/button.d os/win/gui/label.d os/win/gui/collections.d os/win/gui/x/winapi.d os/win/gui/x/wincom.d os/win/gui/event.d os/win/gui/socket.d os/win/gui/timer.d os/win/gui/environment.d os/win/gui/messagebox.d os/win/gui/tooltip.d os/win/gui/combobox.d os/win/gui/treeview.d os/win/gui/tabcontrol.d os/win/gui/colordialog.d os/win/gui/listview.d os/win/gui/data.d os/win/gui/clipboard.d os/win/gui/fontdialog.d os/win/gui/progressbar.d os/win/gui/resources.d os/win/gui/statusbar.d os/win/gui/imagelist.d os/win/gui/toolbar.d os/win/gui/x/_stdcwindows.d

set dfl_objs=all.obj base.obj application.obj dlib.obj utf.obj com.obj control.obj form.obj registry.obj drawing.obj menu.obj notifyicon.obj commondialog.obj filedialog.obj folderdialog.obj panel.obj textbox.obj richtextbox.obj picturebox.obj listbox.obj groupbox.obj splitter.obj usercontrol.obj button.obj label.obj collections.obj winapi.obj wincom.obj event.obj socket.obj timer.obj environment.obj messagebox.obj tooltip.obj combobox.obj treeview.obj tabcontrol.obj colordialog.obj listview.obj data.obj clipboard.obj fontdialog.obj progressbar.obj resources.obj statusbar.obj imagelist.obj toolbar.obj _stdcwindows.obj


:rulada
@echo.
 @echo Making MAIN lib, i.e. RULADA.lib, and some auxiliary libs:
@cd %this%
%DINRUS%\dmmake -f win32.mak clean
%DINRUS%\dmmake -f win32.mak
@if not exist rulada.lib @echo WARNING!!! COMPILATION FAILED!!!!
@if not exist rulada.lib goto nolib
@if exist rulada-aux.lib (@echo Done.) else goto nolib
move gcstub.obj %LDIR%\rulada
@echo.
 @echo Copying rulada to lib\rulada directory.
copy rulada.lib /b  ..\..\lib\rulada /b
del rulada-aux.lib
move *.lib  %LDIR%\rulada
del *.lib
del *.map
del *.exe
del *.obj

cls

:goto dmgc_dyn

:dmgc
@echo.
 @echo Making dmgc lib:
@cd %this%\rt\gc
del *.lib
%DINRUS%\dmd -release -inline -O -I..\.. -lib -ofdmgc-static.lib ..\..\std\gc.d   gcstats.d gcalloc.d gcx.d gcbits.d -Lrulada.lib
%DINRUS%\dmd testgc.d dmgc-static.lib
@if exist *.lib (@echo Done.) else goto nolib
move dmgc-static.lib %LDIR%\rulada\dmgc.lib
move testgc.exe %this%\testgc.exe
@cd %LDIR%\rulada
%DINRUS%\lib -p256 rulada.lib dmgc.lib
@cd %this%\rt\gc
del *.obj
del *.map
:call %this%\testgc.exe
del %this%\testgc.exe

cls


goto dfl
:dmgc_dyn
copy %LDIR%\rulada\prev\dmgc.lib %LDIR%\rulada
@cd %LDIR%\rulada
@if exist dmgc.lib (@echo Begining to embed.) else goto nolib
%DINRUS%\lib -p256 rulada.lib dmgc.lib
del dmgc.lib

:dfl
@set dfl_flags=%dfl_flags% -debug=SHOW_MESSAGENFO -Lrulada.lib
@set _dfl_flags=%dfl_flags% 

@if not "%dfl_debug_flags%" == "" goto dfl_debug_flags_set
	@set dfl_debug_flags=-debug -g -Lrulada.lib
:dfl_debug_flags_set

@if not "%dfl_release_flags%" == "" goto dfl_release_flags_set

	@set dfl_release_flags=-O -inline -release
:dfl_release_flags_set
@echo on
@if "%dfl_ddoc%" == "" goto after_dfl_ddoc
@echo.
@echo Generating ddoc documentation...

%DINRUS%\dmd %_dfl_flags% -c -o-  %dfl_files%
@if errorlevel 1 goto oops

@if "%dfl_ddoc%" == "only" goto done
@if not "%dfl_ddoc_only%" == "" goto done
:after_dfl_ddoc

@echo.
@echo Compiling release DFL...
@cd %this%
%DINRUS%\dmd -c  %dfl_release_flags% %_dfl_flags% -I.. %dfl_files%
@if errorlevel 1 goto nolib

@echo.
@echo Making release lib...

%DINRUS%\lib -c -n -p256 dfl.lib %dfl_libs% %dfl_objs%
@if errorlevel 1 goto oops

 @echo.
 @echo Making build lib...

 %DINRUS%\lib -c -n dfl_build.lib %dfl_libs_dfl%
 @if errorlevel 1 goto oops

@del *.obj
@if exist dfl.lib (@echo Done.) else goto nolib 
move dfl.lib %LDIR%\rulada\dfl.lib
@cd %LDIR%\rulada
%DINRUS%\lib -p256 rulada.lib dfl.lib

cls



:tlb
@echo.
@echo Embedding tlb import modules into rulada.lib:

@cd %this%\os\win\tlb
del objs.rsp
%DINRUS%\dmd -run compile.d
del compile.obj *.rsp
%DINRUS%\ls2 -d *.obj>>objs.rsp
%DINRUS%\dmd -lib -oftlb.lib @objs.rsp
move tlb.lib %LDIR%\rulada
del *.obj
del *.rsp
@cd %LDIR%\rulada
@if exist tlb.lib (%DINRUS%\lib -p256 rulada.lib tlb.lib) else goto nolib
@echo Done.

cls

:dbi

@echo.
@echo Building dbi library embeded into rulada.lib:

@cd %this%\dbi
%DINRUS%\dsss build -full
@if exist dbi.lib (@echo Done.) else goto nolib
move dbi.lib %LDIR%\rulada
cd %LDIR%\rulada
@if exist dbi.lib (%DINRUS%\lib -p256 rulada.lib dbi.lib) else goto nolib
@echo Done.

cls

:dcollections
@cd %this%\dcollections
for %%i in (dcollections\*.d) do %DINRUS%\dmd -c -I. %%i
%DINRUS%\lib -c dcollections.lib ArrayList.obj ArrayMultiset.obj DefaultAllocator.obj Functions.obj Hash.obj HashMap.obj HashMultiset.obj HashSet.obj Iterators.obj Link.obj LinkList.obj RBTree.obj TreeMap.obj TreeMultiset.obj TreeSet.obj
@if exist dcollections.lib (@echo Done.) else goto nolib
del *.obj
move dcollections.lib %LDIR%\rulada
@cd %LDIR%\rulada
%DINRUS%\lib rulada.lib dcollections.lib
del dcollections.lib
@echo Dcollections has been embedded into Rulada.

cls

:DD-win32
@cd %this%\win32
@echo.
 @echo Making DD-win32 lib:
%DINRUS%\dsss build -full
@if exist DD-win32.lib (@echo Done.) else goto nolib
move DD-win32.lib %LDIR%\rulada
@echo Done.

cls

:std2
@echo.
 @echo Making std2 lib:
@cd %this%\std2
%DINRUS%\dsss build -full
@if exist std2.lib (@echo Done.) else goto nolib
move std2.lib %LDIR%\rulada
@echo Done.
cls


:auxC
@cd %this%
@rem @if not exist %LDIR%\rulada\dd-al.lib goto nolib
@if exist %LDIR%\rulada\auxc.lib copy %LDIR%\rulada\auxc.lib /b %LDIR%\rulada\auxc.bak /b
del %LDIR%\rulada\auxC.lib
@echo.
 @echo Concatenating DD-al+DD-gl+DD-ft lib+win32+imageio+libgmp in auxC.lib...
%DINRUS%\lib -c  -p256 %LDIR%\rulada\auxc.lib  %LDIR%\rulada\DD-win32.lib %LDIR%\c\imageio.lib %LDIR%\c\libgmp.lib %LDIR%\rulada\DD-auxc.lib %LDIR%\sysimport\libgsl.lib %LDIR%\sysimport\libgslcblas.lib 
@rem %LDIR%\rulada\DD-al.lib %LDIR%\rulada\DD-gl.lib %LDIR%\rulada\DD-ft.lib
@if exist %LDIR%\rulada\auxc.lib (@echo Done.) else goto nolib
@echo Done.
cls

:helix
@echo.
 @echo Making helix lib: 
@cd %this%\auxD\helix
%DINRUS%\dmd -lib -ofhelix.lib  basic.d color.d config.d linalgebra.d random.d -Lrulada.lib -O
@if exist *.lib (@echo Done.) else goto nolib
move helix.lib %LDIR%\rulada
@echo Done.
cls

:auxD
@cd %this%
@if not exist %LDIR%\rulada\helix.lib goto helix
@echo.
 @echo Concatenating helix+std2+DD-auxd in auxD.lib...
%DINRUS%\lib -c -p256 %LDIR%\rulada\auxd.lib %LDIR%\rulada\helix.lib %LDIR%\rulada\std2.lib %LDIR%\rulada\DD-auxd.lib
@if exist %LDIR%\rulada\auxd.lib (@echo Done.) else goto nolib
@echo Done.
cls

:tango
 @echo.
  @echo Making Tango lib:
@cd %this%\tango
%DINRUS%\dsss build -full
@if exist *.lib (@echo Done.) else goto nolib
move *.lib %LDIR%\rulada
@rem cd %LDIR%\rulada
@rem lib rulada.lib tango.lib
@rem if exist tango.lib (del tango.lib)
@rem @cd %LDIR%\rulada
@rem lib -p128 rulada.lib tango.lib
@echo Done.
cls


:derelict 
@echo.
 @echo Begining to construct Derelict libraries and getting them together in derelict.lib

@cd %this%\derelict
@if exist lib\*.lib del lib\*.lib

@echo.
 @echo Making Derelict Util lib.
@cd .\util
%DINRUS%\dmd -lib -ofDerelictUtil.lib compat.d exception.d loader.d loader2.d wintypes.d wrapper.d xtypes.d sharedlib.d -Lrulada.lib
@if exist *.lib (@echo Done.) else goto nolib
move *.lib  ..\lib 
cls
@echo.
 @echo Making Derelict Devil lib.
@cd ..\devil
%DINRUS%\dmd -lib -ofDerelictIL.lib il.d ilfuncs.d iltypes.d -Lrulada.lib
%DINRUS%\dmd -lib -ofDerelictILU.lib ilu.d ilufuncs.d ilutypes.d -Lrulada.lib
%DINRUS%\dmd -lib -ofDerelictILUT.lib ilut.d ilutfuncs.d iluttypes.d -Lrulada.lib
@if exist *.lib (@echo Done.) else goto nolib
move *.lib ..\lib
cls
@echo.
 @echo Making Derelict FreeType lib.
@cd ..\freetype
%DINRUS%\dmd -lib -ofDerelictFT.lib ft.d ftfuncs.d fttypes.d sftfuncs.d -Lrulada.lib
@if exist *.lib (@echo Done.) else goto nolib
@if not exist *.lib goto nolib
move *.lib ..\lib
@cd ..\ode
cls
@echo.
 @echo Making Derelict ODE lib.
%DINRUS%\dmd -lib -ofDerelictODE.lib ode.d odefuncs.d odetypes.d -Lrulada.lib
@if exist *.lib (@echo Done.) else goto nolib
@if not exist *.lib goto nolib
move *.lib ..\lib
@cd ..\ogg
cls
@echo.
 @echo Making Derelict Ogg lib.
%DINRUS%\dmd -lib -ofDerelictOgg.lib ogg.d oggtypes.d -Lrulada.lib
%DINRUS%\dmd -lib -ofDerelictVorbis.lib vorbis.d vorbiscodec.d vorbisenc.d vorbisfile.d -Lrulada.lib
@if exist *.lib (@echo Done.) else goto nolib
@if not exist *.lib goto nolib
move *.lib ..\lib
@cd ..\openal
cls
@echo.
 @echo Making Derelict Openal lib.
%DINRUS%\dmd -lib -ofDerelictAL.lib al.d alcfuncs.d alctypes.d alext.d alfuncs.d altypes.d -Lrulada.lib
@if exist *.lib (@echo Done.) else goto nolib
@if not exist *.lib goto nolib
move *.lib ..\lib
@cd ..\opengl
cls
@echo.
 @echo Making Derelict OpenGL lib
%DINRUS%\dmd -lib -ofDerelictGLU.lib glu.d -Lrulada.lib
%DINRUS%\dmd -lib -ofDerelictGLUT.lib glut.d -Lrulada.lib
%DINRUS%\dmmake 
@if not exist *.lib goto nolib
move *.lib ..\lib
@cd ..\sdl
cls
@echo.
 @echo Making Derelict SDL lib
%DINRUS%\dmd -lib -ofDerelictSDL.lib sdl.d sdlfuncs.d sdltypes.d rotozoom.d keysym.d -Lrulada.lib
%DINRUS%\dmd -lib -ofDerelictSDLImage.lib image.d -Lrulada.lib
%DINRUS%\dmd -lib -ofDerelictSDLMixer.lib mixer.d -Lrulada.lib
%DINRUS%\dmd -lib -ofDerelictSDLNet.lib net.d -Lrulada.lib
%DINRUS%\dmd -lib -ofDerelictSDLTtf.lib ttf.d -Lrulada.lib
@if exist *.lib (@echo Done.) else goto nolib
@if not exist *.lib goto nolib
move *.lib ..\lib
@cd ..\bassmod
cls
@echo.
 @echo Making Derelict BassMod lib.
%DINRUS%\dmd -lib -ofDerelictBM.lib bassmod.d bassmodfuncs.d bassmodtypes.d -Lrulada.lib
@if exist *.lib (@echo Done.) else goto nolib
@if not exist *.lib goto nolib
move *.lib ..\lib
cls
@echo.
 @echo Making Derelict FMod lib.
@cd ..\fmod
%DINRUS%\dmmake
cls
@echo.
 @echo Making Derelict SFML lib.
@cd ..\sfml
%DINRUS%\dmmake
cls
@echo.
 @echo Making Derelict PortAudio lib.
@cd ..\portaudio
%DINRUS%\dmd -lib -ofDerelictPA.lib pa.d pafuncs.d patypes.d -Lrulada.lib
@if exist *.lib (@echo Done.) else goto nolib
@if not exist *.lib goto nolib
move *.lib ..\lib
cls
@cd ..\lib
@if exist *.bak del *.bak
@rem %DINRUS%\ls2 -d *.lib>>libs.rsp
set DL=%this%\derelict\lib\DerelictSDL.lib %this%\derelict\lib\DerelictSDLImage.lib %this%\derelict\lib\DerelictSDLMixer.lib %this%\derelict\lib\DerelictSDLNet.lib %this%\derelict\lib\DerelictSDLTtf.lib %this%\derelict\lib\DerelictAL.lib %this%\derelict\lib\DerelictFT.lib %this%\derelict\lib\DerelictGL.lib %this%\derelict\lib\DerelictGLUT.lib %this%\derelict\lib\DerelictGLU.lib %this%\derelict\lib\DerelictIL.lib %this%\derelict\lib\DerelictILU.lib %this%\derelict\lib\DerelictILUT.lib %this%\derelict\lib\DerelictODE.lib %this%\derelict\lib\DerelictOgg.lib %this%\derelict\lib\DerelictVorbis.lib %this%\derelict\lib\DerelictBM.lib %this%\derelict\lib\DerelictFMODEX.lib %this%\derelict\lib\DerelictSFMLAudio.lib %this%\derelict\lib\DerelictSFMLGraphics.lib %this%\derelict\lib\DerelictSFMLNetwork.lib %this%\derelict\lib\DerelictSFMLSystem.lib %this%\derelict\lib\DerelictSFMLWindow.lib %this%\derelict\lib\DerelictPA.lib %this%\derelict\lib\DerelictUtil.lib
%DINRUS%\lib -c -p256 derelict.lib %DL% 
@if exist *.lib (@echo Done.) else goto nolib
@if not exist derelict.lib goto nolib
move derelict.lib  %LDIR%\rulada 
del *.lib
@echo Done.
cls

:OpenMesh
@cd %this%\OpenMeshD
@echo.
 @echo Making OpenMesh lib:
%DINRUS%\dsss build -full
@if exist *.lib (@echo Done.) else goto nolib
move OpenMesh.lib  %LDIR%\rulada 
@cd %LDIR%\rulada
@echo.
 @echo Integrating OpenMesh into auxD lib:
%DINRUS%\lib auxd.lib OpenMesh.lib
del OpenMesh.lib
@echo Done.
cls

:allegro
@echo.
 @echo Making Allegro lib:
 @cd %this%\derelict
@echo off

rem === Read Arguments ========================================================
set FLAGS=-inline -O -release
if defined STATIC set FLAGS=%FLAGS% -version=STATICLINK -version=ALLEGRO_NO_ASM
if defined UNITTEST set FLAGS=%FLAGS% -unittest

@echo on
%DINRUS%\dmd -c -odobj -op -w %FLAGS% %this%\derelict\allegro\winalleg %this%\derelict\allegro\_3d.d %this%\derelict\allegro\_3dmaths.d %this%\derelict\allegro\_debug.d %this%\derelict\allegro\alcompat.d %this%\derelict\allegro\all.d %this%\derelict\allegro\base.d %this%\derelict\allegro\color.d %this%\derelict\allegro\compiled.d %this%\derelict\allegro\config.d %this%\derelict\allegro\datafile.d %this%\derelict\allegro\digi.d %this%\derelict\allegro\draw.d %this%\derelict\allegro\file.d %this%\derelict\allegro\fixed.d %this%\derelict\allegro\fli.d %this%\derelict\allegro\fmaths.d %this%\derelict\allegro\font.d %this%\derelict\allegro\gfx.d %this%\derelict\allegro\gui.d %this%\derelict\allegro\joystick.d %this%\derelict\allegro\keyboard.d %this%\derelict\allegro\lzss.d %this%\derelict\allegro\matrix.d %this%\derelict\allegro\midi.d %this%\derelict\allegro\mouse.d %this%\derelict\allegro\palette.d %this%\derelict\allegro\quat.d %this%\derelict\allegro\rle.d %this%\derelict\allegro\sound.d %this%\derelict\allegro\stream.d %this%\derelict\allegro\system.d %this%\derelict\allegro\text.d %this%\derelict\allegro\timer.d %this%\derelict\allegro\unicode.d %this%\derelict\allegro\inline\_3dmaths_inl.d %this%\derelict\allegro\inline\color_inl.d %this%\derelict\allegro\inline\draw_inl.d %this%\derelict\allegro\inline\fmaths_inl.d %this%\derelict\allegro\inline\gfx_inl.d %this%\derelict\allegro\inline\matrix_inl.d %this%\derelict\allegro\inline\rle_inl.d %this%\derelict\allegro\inline\system_inl.d %this%\derelict\allegro\internal\aintern.d %this%\derelict\allegro\internal\alconfig.d %this%\derelict\allegro\internal\dintern.d %this%\derelict\allegro\platform\alwin.d %this%\derelict\allegro\platform\dcommon.d
@echo off

if errorlevel 1 goto nolib

set LIBNAME=dalleg

rem === DMD Linking ===========================================================


%DINRUS%\ls2 -d obj\allegro\*.obj obj\allegro\internal\*.obj obj\allegro\inline\*.obj obj\allegro\platform\*.obj> al.rsp

@echo on
%DINRUS%\lib -c %LIBNAME%.lib @al.rsp
@echo off
del al.rsp
goto next


:next
rmdir /s /q %this%\obj
move dalleg.lib %LDIR%\rulada
%DINRUS%\lib %LDIR%\rulada\derelict.lib %LDIR%\rulada\dalleg.lib
%DINRUS%\lib %LDIR%\rulada\derelict.lib %LDIR%\c\alleg.lib



:gsl
cd %this%
%DMD% -run %this%\compileGSL
if not exist %this%\gsl.lib goto nolib
%DINRUS%\lib %LDIR%\rulada\auxc.lib %this%\gsl.lib
del %this%\gsl.lib
@echo Done.
cls

:amigos
@echo.
 @echo Making amigos lib:
%DINRUS%\lib -p128 -c amigos.lib %LDIR%\sysimport\python27_digitalmars.lib %LDIR%\sysimport\lua51.lib %LDIR%\sysimport\tk85.lib %LDIR%\sysimport\tcl85.lib 
@if exist amigos.lib (@echo Done.) else goto nolib
move amigos.lib %LDIR%\rulada
@echo Done.
cls

:dmdscript
@echo.
 @echo Making amigos lib:
@echo.
 @echo Making dmdscript
@cd %this%\amigos\dmdscript
%DINRUS%\dmmake -f %this%\amigos\dmdscript\win32.mak
move %this%\amigos\dmdscript\dmdscript.lib %LDIR%\rulada
@if exist %LDIR%\rulada\dmdscript.lib (@echo Done.) else goto nolib
@rem move *.exe %R%\bin
del *.obj
del *.exe
del *.lib
@echo Done.
cls

:amigos-all
@echo.
 @echo Making amigos lib:
cd %this%\amigos
@if not exist %LDIR%\rulada\amigos.lib  goto nolib
%DINRUS%\dsss build -full
ren amigos.lib auxamigos.lib
move auxamigos.lib %LDIR%\rulada
@if exist %LDIR%\rulada\auxamigos.lib (@echo Done.) else goto nolib
cls
@echo.
 @echo Making amigos lib:
@echo.
 @echo Concatenating pyd+lua+dmdscript+minid into amigos.lib...
@cd %this%
%DINRUS%\lib -p128 %LDIR%\rulada\amigos.lib %LDIR%\rulada\auxamigos.lib   %LDIR%\rulada\dmdscript.lib
@if exist %LDIR%\rulada\amigos.lib (del %LDIR%\rulada\auxamigos.lib %LDIR%\rulada\dmdscript.lib) else @echo amigos.lib missing!!!
@if exist %LDIR%\rulada\amigos.lib (@echo Done.) else goto nolib
@echo Done.
cls

:kong
@echo.
 @echo Making kong lib
@cd %this%\kong
%DINRUS%\dmmake -f makefile.win32.dmd
@if exist kong.lib (@echo Done.) else goto nolib
move kong.lib %LDIR%\rulada
@echo Done.
cls

:mango

@cd %this%\mango
@echo.
 @echo Making Mango library:
%DINRUS%\dsss build -full
@if exist *.lib (@echo Done.) else goto nolib
move mango.lib  %LDIR%\rulada 
@echo Done.
cls

:ddl
@cd %this%\ddl
@echo.
 @echo Making DDL library:
%DINRUS%\dsss build -full
@if exist *.lib (@echo Done.) else goto nolib
move DD-ddl.lib  %LDIR%\rulada 
cd %LDIR%\rulada
%DINRUS%\lib -p256 mango.lib DD-ddl.lib 
@echo Done.
cls

:meta
@cd %this%\meta
@echo.
 @echo Making meta library:
%DINRUS%\dsss build -full
@if exist *.lib (@echo Done.) else goto nolib
move DD-meta.lib  %LDIR%\rulada 
cd %LDIR%\rulada
%DINRUS%\lib -p256 kong.lib DD-meta.lib 
@echo Done.
cls

:ray
@echo.
 @echo Making ray lib
@cd %this%\ray
%DINRUS%\dsss build -full
@if exist ray.lib (@echo Done.) else goto nolib
move ray.lib %LDIR%\rulada
cd %LDIR%\rulada
%DINRUS%\lib -p256 auxd.lib ray.lib
@del ray.lib
@echo Done.
cls


:arc
@cd %this%\arclib\phobos\arclib
@echo.
 @echo Making Arc library:
%DINRUS%\dsss build -full
@if exist *.lib (@echo Done.) else goto nolib
move arc.lib  %LDIR%\rulada 
@echo Done.
cls

:result

@echo.
 @echo            #################    THE JOB WAS DONE    #########################
 
@cd %LDIR%\rulada 
move  d:\dinrus\imp\rulada\cord\exception1.d d:\dinrus\imp\rulada\cord\exception.d
@del DD-win32.lib
@del helix.lib
@del std2.lib
@del DD-ft.lib
@del DD-al.lib
@del DD-gl.lib
@del dfl.lib
@del dmgc.lib
@del dalleg.lib
@del DD-auxc.lib
@del DD-auxd.lib
@del tlb.lib
@del dbi.lib
@del DD-ddl.lib
@del DD-meta.lib
@if not exist "rulada.lib" (@echo File Rulada.lib not found. Backup will be restored now...)
@if not exist "rulada.lib" (@copy  prev/rulada.lib /b rulada.lib /b) 
@if exist "rulada.lib" (@copy rulada.lib /b prev\rulada.lib /b)
@if exist "rulada.lib" (@echo A Backup file of rulada.lib was made for future use.) 
@del *.bak
@echo. Now your Library directory contains the following libraries:
@echo.
@dir .

:end
cls
cd %this%
dmd -run clean.d

cls
@echo	RRRR       UUU       UUUU   LLLL            AA      DDD           AA
@echo	RRRRRRR     UUU     UUUUU    LLL           AAAA     DDD DD       AAAA
@echo	RRR    RR   UUU     UUUUU    LLL          AA  AA    DDD  DD      AAA AA
@echo	RRR    RR   UUU     UUUUU    LLL         AA    AA   DDD   DD     AAAA  AA
@echo	RRR   RR    UUU     UUUUU    LLL         AAAAAAAAA  DDD     DD    AAAA  AA
@echo	RRRRRRR     UUU     UUUUU    LLL         AAAAAAAAAA DDD     DD   AAAA    AA
@echo	RRR   RRR    UUU    UUUUU    LLL         AAA    AAA DDD    DD  AAAAA    AAA
@echo	RRR   RRRR    UUU   UUUUU    LLL      L  AAA    AAA DDD   DD  AAAAAAAAAAAAA 
@echo	RRR   RRRRR    UUUUUU  UUU   LLLLLLLLLL  AAA    AAA DDD  DD  AAAA    AAAAAA
@echo	RRR    RRRRRR   UUUU   UUU   LLLLLLLLLL  AAA    AAA DDDD    AAAAA    AAAAAA

@echo							
@echo							
@echo				
@echo		*************************************************************
@echo		*	So, you have happily ended your libs-building,			*
@echo		*	and now you own a good pack of stuff to					*
@echo		*	develop any kind of application. 						*
@echo		*					CONGRATULATION!							*
@echo		*															*
@echo		*************************************************************
@echo			
@echo			
@echo
pause			
exit 

:delete
@echo	*************************************************************
@echo   *	So, you have happy ended your libs-building,			*
@echo 	*	and now you have a choice:								*
@echo 	*	1) to completely delete files						    *
@echo 	*	needed to build all of this							    *
@echo 	*	or														*
@echo 	*	2) to leave them untouched for future useful reference. *
@echo 	*															*
@echo	* 		That's what You have to decide:						*
@echo 	*************************************************************
:@rmdir /s %R%\auxes


:nolib 
@echo Error during building the library! Please, correct whichever were problems, and retry.
pause
cls
goto begin_again





