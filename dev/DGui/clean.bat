@echo off
echo Cleaning Files...
cd dgui
del /S *.lib
cd ..
del /S *.obj
del /S *.map
cd samples\obj
del *.obj
cd..
rmdir obj
del *.exe
cd ..
rmdir dgui\build\release
rmdir dgui\build\debug
rmdir dgui\build
echo Done...
pause