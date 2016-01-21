
# makefile to build D garbage collector under win32

#DMD=..\..\..\dmd
DMD=dmd

#DFLAGS=-unittest -g -release
#DFLAGS=-inline -O
DFLAGS=-release -inline -O 
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

targets : DMGC.dll  testgc.exe 

testgc.obj : testgc.d

OBJS= gc.obj gcx.obj gcbits.obj gcalloc.obj

SRC=gc_dyn.d gcx.d gcbits.d gcalloc.d gclinux.d testgc.d dll.d win32.mak linux.mak dmgc.def

#dmgc.lib : $(OBJS) win32.mak
#	del dmgc.lib
#	lib dmgc /c/noi +gc+gcold+gcx+gcbits+win32;

DMGC.dll : gc_dyn.d gcx.d gcalloc.d gcstats.d gcbits.d thread_stat.d dll.d ..\core\thread_stat.d ..\core\sync\atomic.d 
	$(DMD) $(DFLAGS) -I..\.. -ofDMGC.dll gc_dyn.d   gcalloc.d gcx.d gcstats.d gcbits.d dll.d dmgc.def
    	
testgc.exe : testgc.obj dmgc.lib
	$(DMD) testgc.obj dmgc.lib -g
	
gc.obj : gc_dyn.d
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
