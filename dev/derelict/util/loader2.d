﻿/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.util.loader2;

private
{
    import derelict.util.sharedlib;
    import derelict.util.compat;
}

class SharedLibLoader
{
public:
    this(string winLibs, string nixLibs, string macLibs)
    {
        version(Windows)
        {
            _libNames = winLibs;
        }
        else version(OSX)
        {
            _libNames = macLibs;
        }
        else version(darwin)
        {
            _libNames = macLibs;
        }
        else
        {
            _libNames = nixLibs;
        }

        _lib = new SharedLib();
    }

    void load()
    {
        load(_libNames);
    }

    void load(string libNameString)
    {
        assert(libNameString !is null);

        string[] libNames = libNameString.splitStr(",");
        foreach(ref string l; libNames)
        {
            l = l.stripWhiteSpace();
        }

        load(libNames);
    }

    void load(string[] libNames)
    {
        _lib.load(libNames);
        loadSymbols();
    }

    void unload()
    {
        _lib.unload();
    }

    bool isLoaded()
    {
        return _lib.isLoaded;
    }

protected:
    abstract void loadSymbols();

    void* loadSymbol(string name)
    {
        return _lib.loadSymbol(name);
    }

    SharedLib lib()
    {
        return _lib;
    }

    void bindFunc(void** ptr, string funcName, bool doThrow = true)
    {
        void* func = lib.loadSymbol(funcName, doThrow);
        *ptr = func;
    }

private:
    string _libNames;
    SharedLib _lib;
}

/*
* These templates need to stick around a bit longer, until the macinit stuff
in Derelict SDL gets sorted
*/
package struct Binder(T) {
    void opCall(in char[] n, SharedLib lib) {
        *fptr = lib.loadSymbol(n);
    }


    private {
        void** fptr;
    }
}


template bindFunc(T) {
    Binder!(T) bindFunc(inout T a) {
        Binder!(T) res;
        res.fptr = cast(void**)&a;
        return res;
    }
}