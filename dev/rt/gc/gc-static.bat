cd .
del *.obj
del *.exe
dmmake -f win32_static.mak
dmd -c -oftestgc.exe testgc.obj dmgc.lib -g
pause
