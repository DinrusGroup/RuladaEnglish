dmd mconvert
del *.obj
del *.map
pause
mconvert
pause
copy mconvert.exe /b ..\..\bin\mconvert.exe /b