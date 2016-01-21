
# makefile to build D garbage collector under win32

#DMD=..\..\..\dmd
DMD=dmd

#DFLAGS=-unittest -g -release
#DFLAGS=-inline -O
DFLAGS=-release -inline -O -Lrulada.lib
#DFLAGS=-g

CC=dmc
CFLAGS=-g -mn -6 -r -Igc

.c.obj:
	$(CC) -c $(CFLAGS) $*

.cpp.obj:
	$(CC) -c $(CFLAGS) $*

.d.obj:
	$(DMD) -c $(DFLAGS) $*

.asm.obj:
	$(CC) -c $*

targets : testgc.exe dmgc-static.lib  

testgc.obj : testgc.d

OBJS= gc.obj gcx.obj gcbits.obj gcalloc.obj

SRC= ..\..\std\gc.d gcx.d gcbits.d gcalloc.d gclinux.d testgc.d win32.mak linux.mak

#dmgc.lib : $(OBJS) win32.mak
#	del dmgc.lib
#	lib dmgc /c/noi +gc+gcold+gcx+gcbits+win32;

dmgc-static.lib : ..\..\std\gc.d gcx.d gcalloc.d gcbits.d
	$(DMD) $(DFLAGS) -I..\.. -lib -ofdmgc-static.lib ..\..\std\gc.d   gcalloc.d gcx.d gcbits.d

testgc.exe : testgc.obj dmgc-static.lib
	$(DMD) testgc.obj dmgc.lib -g
	
gc.obj : ..\..\std\gc.d
	$(DMD) -c $(DFLAGS) $*

gcold.obj : gcold.d
	$(DMD) -c $(DFLAGS) $*

gcx.obj : gcx.d gcbits.d
	$(DMD) -c $(DFLAGS) gcx gcbits
	
gcalloc.obj: gcalloc.d
	$(DMD) -c $(DFLAGS) gcalloc
#gcbits.obj : gcbits.d

win32.obj : win32.d

zip : $(SRC)
	del dmgc.zip
	zip32 dmgc $(SRC)

clean:
	del $(OBJS)
	del dmgc.lib
	del testgc.exe
