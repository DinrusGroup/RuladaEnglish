@echo off
echo Building samples...
dmd @dbg_events.args
dmd @dbg_hello.args
dmd @dbg_menu.args
dmd @dbg_picture.args
dmd @dbg_rawbitmap.args
dmd @dbg_resources.args
echo Completed!