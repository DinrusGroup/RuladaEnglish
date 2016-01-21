/*
 * Placed into the Public Domain.
 * written by Walter Bright
 * www.digitalmars.com
 */

/*
 *  Modified by Sean Kelly <sean@f4.ca> for use with Tango.
 */

module rt.dmain2;

private
{
    import rt.core.console;

    import rt.core.stdc.stdlib : malloc, free, exit, EXIT_FAILURE;
    import rt.core.stdc.string : strlen;
    import rt.core.stdc.stdio : printf;
	import rt.core.runtime: runModuleUnitTests;
}

version( Win32 )
{
    import rt.core.stdc.stdlib: alloca;
    import rt.core.c: wcslen;
	extern (Windows) alias int function() FARPROC;
    extern (Windows) FARPROC    GetProcAddress(void*, in char*);
    extern (Windows) void*      LoadLibraryA(in char*);
    extern (Windows) int        FreeLibrary(void*);
    extern (Windows) void*    LocalFree(void*);
    extern (Windows) wchar*   GetCommandLineW();
    extern (Windows) wchar**  CommandLineToArgvW(wchar*, int*);
    extern (Windows) export int WideCharToMultiByte(uint, uint, wchar*, int, char*, int, char*, int);
    pragma(lib, "rulada.lib");   // needed for CommandLineToArgvW
    //pragma(lib, "tango-win32-dmd.lib"); // links Tango's Win32 library to reduce EXE size
}

extern (C) void _STI_monitor_staticctor();
extern (C) void _STD_monitor_staticdtor();
extern (C) void _STI_critical_init();
extern (C) void _STD_critical_term();
extern (C) void gc_init();
extern (C) void gc_term();
extern (C) void _minit();
extern (C) void _moduleCtor();
extern (C) void _moduleDtor();
extern (C) void thread_joinAll();
extern (C) void gc_collect();

/***********************************
 * These functions must be defined for any D program linked
 * against this library.
 */
extern (C) void onAssertError( char[] file, ulong  line );
extern (C) void onAssertErrorMsg( char[] file, ulong  line, char[] msg );
extern (C) void onArrayBoundsError( char[] file, ulong  line );
extern (C) void onSwitchError( char[] file, ulong  line );


// this function is called from the utf module
extern (C) void onUnicodeError( char[] msg, size_t idx );

/***********************************
 * These are internal callbacks for various language errors.
 */
 
extern (C) void _d_assert( char[] file, uint line );

extern (C) static void _d_assert_msg( char[] msg, char[] file, uint line );

extern (C) void _d_array_bounds( char[] file, uint line );
extern (C) void _d_switch_error( char[] file, uint line );
extern (C) void _moduleUnitTests();

/***********************************
 * These are a temporary means of providing a GC hook for DLL use.  They may be
 * replaced with some other similar functionality later.
 */
extern (C)
{
    void* gc_getProxy();
    void  gc_setProxy(void* p);
    void  gc_clrProxy();

    alias void* function()      gcGetFn;
    alias void  function(void*) gcSetFn;
    alias void  function()      gcClrFn;
}

extern (C) void* rt_loadLibrary(in char[] name)
{
    version (Windows)
    {
        char[260] temp = void;
        temp[0 .. name.length] = name[];
        temp[name.length] = cast(char) 0;
        void* ptr = LoadLibraryA(temp.ptr);
        if (ptr is null)
            return ptr;
        gcSetFn gcSet = cast(gcSetFn) GetProcAddress(ptr, "gc_setProxy");
        if (gcSet !is null)
            gcSet(gc_getProxy());
        return ptr;

    }
    else version (Posix)
    {
        throw new Exception("rt_loadLibrary not yet implemented on Posix.");
    }
}

extern (C) bool rt_unloadLibrary(void* ptr)
{
    version (Windows)
    {
        gcClrFn gcClr  = cast(gcClrFn) GetProcAddress(ptr, "gc_clrProxy");
        if (gcClr !is null)
            gcClr();
        return FreeLibrary(ptr) != 0;
    }
    else version (Posix)
    {
        throw new Exception("rt_unloadLibrary not yet implemented on Posix.");
    }
}

bool _d_isHalting = false;

extern (C) bool rt_isHalting()
{
    return _d_isHalting;
}

extern (C) bool rt_trapExceptions = true;

version (Posix)
{
	void _d_criticalInit()
	{
	  
			_STI_monitor_staticctor();
			_STI_critical_init();
		
	}

	void _d_criticalTerm()
	{    
		
			_STD_critical_term();
			_STD_monitor_staticdtor();
		
	}
}

alias void delegate( Exception ) ExceptionHandler;

extern (C) bool rt_init( ExceptionHandler dg = null )
{
    static bool result;
    
    if (result)
        return result;
    
   version (Posix) _d_criticalInit();

    try
    {
        gc_init();
        version (Win32)
            _minit();
        _moduleCtor();
		return result = true;
    }
    catch( Exception e )
    {
        if( dg )
            dg( e ); //else{e.print(); throw new Exception("Проблема с rt_init\n"); }
    }
    catch
    {

    }
   version (Posix) _d_criticalTerm();
    return result = false;
}


extern (C) bool rt_term( ExceptionHandler dg = null )
{
    static bool result;
    
	//if(numOfActive <=1)
	//{
		if (result)
			return result;
		
		try
		{
			_d_isHalting = true;
			thread_joinAll();        
			_moduleDtor();
			gc_term();
			return result = true;
		}
		catch( Exception e )
		{
			if( dg )
				dg( e ); //else{throw new Exception("Проблема с rt_term\n");}
		}
		catch
		{

		}
		finally
		{
			version (Posix) _d_criticalTerm();		
		}
		return result = false;
	/*}
	else
		{
		gc_collect();
		//numOfActive--;
		console("Один активный модуль запросил деинициализацию.
		На данный момент активных осталось "); printf("%i", numOfActive);
		}
    return result = false;*/
}

version (OSX)
{
    // The bottom of the stack
    extern (C) void* __osx_stack_end = cast(void*)0xC0000000;
}

version (FreeBSD)
{
    // The bottom of the stack
    extern (C) void* __libc_stack_end;
}

version (Solaris)
{
    // The bottom of the stack
    extern (C) void* __libc_stack_end;
}

/***********************************
 * The D main() function supplied by the user's program
 */
int main(char[][] args);

/***********************************
 * Substitutes for the C main() function.
 * It's purpose is to wrap the call to the D main()
 * function and catch any unhandled exceptions.
 */

extern (C) int main(int argc, char **argv)
{
    char[][] args;
    int result;

    version (OSX)
    {/* OSX does not provide a way to get at the top of the
      * stack, except for the magic value 0xC0000000.
      * But as far as the gc is concerned, argv is at the top
      * of the main thread's stack, so save the address of that.
      */
    __osx_stack_end = cast(void*)&argv;
    }
    version (FreeBSD)
    {	/* FreeBSD does not provide a way to get at the top of the
	 * stack.
	 * But as far as the gc is concerned, argv is at the top
	 * of the main thread's stack, so save the address of that.
	 */
	__libc_stack_end = cast(void*)&argv;
    }

    version (Solaris)
    {	/* As far as the gc is concerned, argv is at the top
	 * of the main thread's stack, so save the address of that.
	 */
	__libc_stack_end = cast(void*)&argv;
    }
    
    version (Posix)
        _d_criticalInit();

    version (Win32)
    {
        wchar*    wcbuf = GetCommandLineW();
        size_t    wclen = wcslen(wcbuf);
        int       wargc = 0;
        wchar**   wargs = CommandLineToArgvW(wcbuf, &wargc);
        assert(wargc == argc);

        char*     cargp = null;
        size_t    cargl = WideCharToMultiByte(65001, 0, wcbuf, wclen, null, 0, null, 0);

        cargp = cast(char*) alloca(cargl);
        args  = ((cast(char[]*) alloca(wargc * (char[]).sizeof)))[0 .. wargc];

        for (size_t i = 0, p = 0; i < wargc; i++)
        {
            int wlen = wcslen( wargs[i] );
            int clen = WideCharToMultiByte(65001, 0, &wargs[i][0], wlen, null, 0, null, 0);
            args[i]  = cargp[p .. p+clen];
            p += clen; assert(p <= cargl);
            WideCharToMultiByte(65001, 0, &wargs[i][0], wlen, &args[i][0], clen, null, 0);
        }
        LocalFree(wargs);
        wargs = null;
        wargc = 0;
    }
    else version (Posix)
    {
        char[]* am = cast(char[]*) malloc(argc * (char[]).sizeof);
        scope(exit) free(am);

        for (size_t i = 0; i < argc; i++)
        {
            auto len = strlen(argv[i]);
            am[i] = argv[i][0 .. len];
        }
        args = am[0 .. argc];
    }

    bool trapExceptions = rt_trapExceptions;

    void tryExec(void delegate() dg)
    {

        if (trapExceptions)
        {
            try
            {
                dg();
            }
            catch (Exception e)
            {
                e.writeOut(delegate void(char[] s){ console(s); });
                result = EXIT_FAILURE;
            }
            catch (Object o)
            {
                //fprintf(stderr, "%.*s\n", o.toString());
                console (o.toString)("\n");
                result = EXIT_FAILURE;
            }
        }
        else
        {
            dg();
        }
    }

    // NOTE: The lifetime of a process is much like the lifetime of an object:
    //       it is initialized, then used, then destroyed.  If initialization
    //       fails, the successive two steps are never reached.  However, if
    //       initialization succeeds, then cleanup will occur even if the use
    //       step fails in some way.  Here, the use phase consists of running
    //       the user's main function.  If main terminates with an exception,
    //       the exception is handled and then cleanup begins.  An exception
    //       thrown during cleanup, however, will abort the cleanup process.

    void runMain()
    {
        result = main(args);
    }

    void runAll()
    {
        rt_init();
        if (runModuleUnitTests())
            tryExec(&runMain);
        rt_term();
    }

    tryExec(&runAll);

    version (Posix)
        _d_criticalTerm();
        
    return result;
}
/*
extern (C) void minit()
	{
	_minit();
	}
	
extern (C) void STI_monitor_staticctor()
{
_STI_monitor_staticctor();
}

extern (C) void STD_monitor_staticdtor()
{
_STD_monitor_staticdtor();
}

extern (C) void STI_critical_init()
{
_STI_critical_init();
}

extern (C) void STD_critical_term()
{
_STD_critical_term();
}
*/
/*
import std.gc, os.windows:HINSTANCE, ОкноСооб, СО_ОК;
uint inf_ = 0;
export extern (C)
{
	 GCAlone *regDdm(HINSTANCE hinst, GCAlone* mygc = null)
	{				
	    GCAlone gc;
		
		if(hinst != null && mygc == null)
		{
		 gc = new GCAlone();
		  ОкноСооб(null, cast(wchar*)"Экземпляр СМ cоздан\n", cast(wchar*) ("Cообщение :"), СО_ОК);
		 gc.enable();
	      _minit();
	    _moduleCtor();
	    _moduleUnitTests();	
		inf_++;
		if(inf_ != 0)
		 ОкноСооб(null, cast(wchar*)"Подключен новый ddm-модуль\n", cast(wchar*) ("Cообщение :"), СО_ОК); 
		return cast(GCAlone*) gc;
		}
		else if(inf_!= 0 && mygc != null )
		{
		gc = cast(GCAlone) mygc;
		gc.collect();
		gc.disable();
		deleteGC(cast(gc_t) gc); console("Экземпляр СМ удалён\n");
		ОкноСооб(null, cast(wchar*)"Экземпляр СМ удалён\n", cast(wchar*) ("Cообщение :"), СО_ОК);
		gc_collect();
		inf_--;
		return null;
		}
		else if(inf_ == 0 && mygc != null)
		ОкноСооб(null, cast(wchar*)"По-видимому, в regDdm не указан экземпляр\n", cast(wchar*) ("Cообщение :"), СО_ОК);
		   else if(inf_ != 0)
		 ОкноСооб(null, cast(wchar*)"Подключен новый ddm-модуль\n", cast(wchar*) ("Cообщение :"), СО_ОК);
		return null;
	
	}
*/
   // bool UnRegDdm(HINSTANCE hinst, gc_t gc=null)
	//{	
	//gc_term();	
	//return true;
	//}
//}
/+
//extern (C)  gc_t newGC();
//extern (C) void deleteGC(gc_t gc);
extern (C) void gc_addRoot(void *p);
extern (C) void gc_removeRoot(void *p);

//typedef export extern (C) HINSTANCE function(HINSTANCE) ddmReg;
//typedef export extern (C) HINSTANCE function(HINSTANCE) ddmUnReg;
import os.windows;


export extern (D) class DdModule
{
export:
//HINSTANCE attachedDdms[];
static this(){};

	bool RegDdm(HINSTANCE hinst)
	{
	//attachedDdms =+ cast(uint) hinst;
	gc_addRoot(cast(void*) hinst);
	return true;
	
	}

    bool UnRegDdm(HINSTANCE hinst)
	{
	//if(hinst in attachedDdms)
	gc_removeRoot(hinst);
	//attachedDdms =- cast(uint) hinst;
	return true;
	}

}
export extern (D) DdModule ddm;
static this() {ddm = new DdModule;}
+/