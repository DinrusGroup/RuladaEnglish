ruladaex
@echo off
echo Building samples...
dmd @rel_events.args
dmd @rel_hello.args
dmd @rel_menu.args
dmd @rel_picture.args
dmd @rel_rawbitmap.args
dmd @rel_resources.args
echo Completed!