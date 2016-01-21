@echo off
setlocal

rem === Read Arguments ========================================================

set DC=dmd

:loop
if "%1" == "" goto continue
if /i "%1" == "help" goto usage
if /i "%1" == "usage" goto usage
if /i "%1" == "gdc" set DC=gdmd
if /i "%1" == "gdmd" set DC=gdmd
if /i "%1" == "debug" set DEBUG=true
if /i "%1" == "static" set STATIC=true
if /i "%1" == "unittest" set UNITTEST=true
shift
goto loop


:usage
echo Run make-lib with no arguments for a DMD build of DAllegro,
echo for linking with the dynamic link build of Allegro.
echo.
echo Options (combined freely and in any order):
echo gdc      - use GDC instead of DMD.  Uses the gdmd scrip, which requires Perl.
echo static   - Build DAllegro for statically linking with Allegro.
echo debug    - Build DAllegro with debug code and symbols included.
echo unittest - Build DAllegro with unittests enabled.

goto end


:continue
rem === Compile Files =========================================================

if defined DEBUG (set FLAGS=-g -debug) else (set FLAGS=-inline -O -release)
if defined STATIC set FLAGS=%FLAGS% -version=STATICLINK -version=ALLEGRO_NO_ASM
if defined UNITTEST set FLAGS=%FLAGS% -unittest

@echo on
call %DC% -c -odobj -op -w %FLAGS% _3d.d _3dmaths.d _debug.d alcompat.d allegro.d base.d color.d compiled.d config.d datafile.d digi.d draw.d file.d fixed.d fli.d fmaths.d font.d gfx.d gui.d joystick.d keyboard.d lzss.d matrix.d midi.d mouse.d palette.d quat.d rle.d sound.d stream.d system.d text.d timer.d unicode.d inline\_3dmaths_inl.d inline\color_inl.d inline\draw_inl.d inline\fmaths_inl.d inline\gfx_inl.d inline\matrix_inl.d inline\rle_inl.d inline\system_inl.d internal\aintern.d internal\alconfig.d internal\dintern.d platform\alwin.d platform\dcommon.d winalleg.d
@echo off

if errorlevel 1 goto end


rem === Link Configuration ====================================================

if defined DEBUG (set LIBNAME=dalld) else (set LIBNAME=dalleg)
if defined STATIC set LIBNAME=%LIBNAME%_s

if /i "%DC%" == "gdmd" goto gdc


rem === DMD Linking ===========================================================

set LISTFILE=objects%random%.tmp
dir /b /s obj\*.obj > %LISTFILE%

@echo on
%DINRUS%\lib -c %LIBNAME%.lib @%LISTFILE%
@echo off

del %LISTFILE%

goto end


:gdc
rem === GDC Linking ===========================================================

@echo on
ar crs lib%LIBNAME%.a obj\*.o obj\internal\*.o obj\platform\*.o obj\inline\*.o
@echo off


:end
rmdir /s /q .\obj
