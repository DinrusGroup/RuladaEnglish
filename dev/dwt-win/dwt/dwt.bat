del .\build.log
dsss build -full
if not exist dwt.lib (dsss_objs\D\dwt.bat)
if exist dwt.lib (move dwt.lib d:\dm\lib\rulada)
pause