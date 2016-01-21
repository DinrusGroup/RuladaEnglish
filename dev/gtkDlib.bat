set this=%DINRUS%\..\dev\RULADA
set GTK=%DINRUS%\..\dev\RULADA\gtkD
set L=%DINRUS%\..\lib\rulada
%DINRUS%\ruladaex
:goto libmak
cd %GTK%\src
%DINRUS%\dsss build -full
move *.lib %L%
cd %GTK%\srcgda
%DINRUS%\dsss build -full
move *.lib %L%
cd %GTK%\srcgl
%DINRUS%\dsss build -full
move *.lib %L%
cd %GTK%\srcgstreamer
%DINRUS%\dsss build -full
move *.lib %L%
cd %GTK%\srcsv
%DINRUS%\dsss build -full
move *.lib %L%

:libmak
cd %L%

%DINRUS%\lib -c gtkD.lib DD-atk.lib DD-cairo.lib DD-gda.lib DD-gdac.lib DD-gdk.lib DD-gdkpixbuf.lib DD-gio.lib DD-glade.lib DD-glgdk.lib DD-glgtk.lib DD-glib.lib DD-gobject.lib DD-gsv.lib DD-gsvc.lib DD-gthread.lib DD-gtk.lib DD-gtkc.lib DD-gtkglc.lib DD-pango.lib DD-gstinterfaces.lib DD-gstreamerc.lib DD-gstreamer.lib

if exist gtkD.lib (del DD-atk.lib DD-cairo.lib DD-gda.lib DD-gdac.lib DD-gdk.lib DD-gdkpixbuf.lib DD-gio.lib DD-glade.lib DD-glgdk.lib DD-glgtk.lib DD-glib.lib DD-gobject.lib DD-gsv.lib DD-gsvc.lib DD-gthread.lib DD-gtk.lib DD-gtkc.lib DD-gtkglc.lib DD-pango.lib DD-gstinterfaces.lib DD-gstreamerc.lib DD-gstreamer.lib)

::%DINRUS%\lib gtkD.lib gtkimport.lib

::del gtkimport.lib
if exist %L%/gtkD.lib goto clean 
if not exist %L%/gtkD.lib echo Sorry, the Build  has ended unsuccesfully.
pause
:clean
cd %this%

%DINRUS%\dmd -run clean
