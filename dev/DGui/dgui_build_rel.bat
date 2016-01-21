@echo off
echo Compiling DGui [Release]
ruladaex
dmd @rel_dgui_cmdfile.args
echo Completed! (check dgui\build\release directory)
pause