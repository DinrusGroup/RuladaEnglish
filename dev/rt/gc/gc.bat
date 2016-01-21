cd .
del *.obj
del *.exe
dmmake -f win32_gc.mak
dmd -c -oftestgc.exe testgc.obj dmgc.lib -g
implib/system dmgc.lib dmgc.dll
pause
