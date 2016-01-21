# Makefile for the Windows API project
# Uses GNU Make-specific extensions

DC := c:/dmd/bin/dmd

DFLAGS := -inline -O -release -w
#DFLAGS := -debug -gc -unittest -w

DFLAGS += -version=Unicode

########################################

SUBDIRS := directx

EXCLUSIONS := winsock.d

########################################

SOURCES := $(wildcard *.d $(addsuffix /*.d, $(SUBDIRS)))
SOURCES := $(filter-out $(EXCLUSIONS), $(SOURCES))

########################################

win32.lib : $(SOURCES)
	$(DC) $^ -lib -of$@ $(DFLAGS)

clean :
	-del win32.lib

.PHONY : clean
