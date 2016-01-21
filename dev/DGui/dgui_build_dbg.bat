@echo off
ruladaex
echo Compiling DGui [Debug]
dmd @dbg_dgui_cmdfile.args
echo Completed! (check dgui\build\debug directory)
pause