del testlog.txt
implib/system dmgc.lib dmgc.dll
%DINRUS%\dmd  testdyn dmgc.lib
call testdyn
%DINRUS%\dmd  -oftestgc-static.exe testgc dmgc-static.lib
call testgc-static
