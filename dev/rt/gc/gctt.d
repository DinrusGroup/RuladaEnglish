module std.gc;

version= Static;

version(Dynamic)
{
	struct GCStats
	{
		size_t poolsize;        // total size of pool
		size_t usedsize;        // bytes allocated
		size_t freeblocks;      // number of blocks marked FREE
		size_t freelistsize;    // total of memory on free lists
		size_t pageblocks; 
	}
	struct BlkInfo
	{
		void*  base;
		size_t size;
		uint   attr;
	}

	struct Array
	{
		size_t length;
		byte *data;
	};

	struct Array2
	{
		size_t length;
		void* ptr;
	}

	version (GCCLASS)
		alias GC gc_t;
	else
		alias GC* gc_t;

	gc_t _gc;

	alias extern(D) void delegate() ddel;
	alias extern(D) void delegate(int, int) dint;

	alias void (*GC_FINALIZER)(void *p, bool dummy);

	private int _termCleanupLevel=1;

	///////////////////////////////////////////////////////////////////
	 extern (C) void _d_callinterfacefinalizer(void *p);
	 extern (C)  byte[] _d_arraysetlengthT(TypeInfo ti, size_t newlength, Array *p);
	 extern (C) byte[] _d_arraysetlengthiT(TypeInfo ti, size_t newlength, Array *p);
	 extern (C) long _d_arrayappendT(TypeInfo ti, Array *px, byte[] y);
	 extern (C) byte[] _d_arrayappendcT(TypeInfo ti, inout byte[] x, ...);
	 extern (C)  char[] _d_arrayappendcd(inout char[] x, dchar c);
	 extern (C)  wchar[] _d_arrayappendwd(inout wchar[] x, dchar c);
	 extern (C) byte[] _d_arraycatT(TypeInfo ti, byte[] x, byte[] y);
	 extern (C) byte[] _d_arraycatnT(TypeInfo ti, uint n, ...);
	 extern (C) void* _d_arrayliteralT(TypeInfo ti, size_t length, ...);
	extern (C)
	{
	void setTypeInfo(TypeInfo ti, void* p);
	void* getGCHandle();
	void setGCHandle(void* p);
	void endGCHandle();
	}
	 extern (C) void gc_init();
	 extern (C) void gc_term();
	 extern (C) size_t gc_capacity(void* p);
	 extern (C) void gc_minimize();
	 extern (C) void gc_addRoot( void* p );
	 extern (C) void gc_addRange( void* p, size_t sz );
	 extern (C) void gc_removeRoot( void* p );
	 extern (C) void gc_removeRange( void* p );	
	 extern (C) void gc_monitor(ddel begin, dint end );
	 extern (C)  gc_t newGC();
	 extern (C) void deleteGC(gc_t gc);
	 extern (C) void gc_printStats(gc_t gc);
	 extern (C)  GCStats gc_stats();
	 extern (C)  void _d_gc_addrange(void *pbot, void *ptop);
	 extern (C)  void _d_gc_removerange(void *pbot);
	 extern (C) long _adDupT(TypeInfo ti, Array2 a);
	 extern (C) uint gc_getAttr( void* p );
	 extern (C) uint gc_setAttr( void* p, uint a );
	 extern (C) uint gc_clrAttr( void* p, uint a );
	 extern (C) void* gc_malloc( size_t sz, uint ba = 0 );
	 extern (C) void* gc_calloc( size_t sz, uint ba = 0 );
	 extern (C) void* gc_realloc( void* p, size_t sz, uint ba = 0 );
	 extern (C) size_t gc_extend( void* p, size_t mx, size_t sz );
	 extern (C) size_t gc_reserve( size_t sz );
	 extern (C) void gc_free( void* p );
	 extern (C) void* gc_addrOf( void* p );
	 extern (C) size_t gc_sizeOf( void* p );
	 extern (C) void* gc_weakpointerCreate( Object r );
	 extern (C) void gc_weakpointerDestroy( void* wp );
	 extern (C) Object gc_weakpointerGet( void* wp );
	 extern (C) BlkInfo gc_query( void* p );
	 extern (C) void gc_enable();
	 extern (C) void gc_disable();
	 extern (C) void gc_collect();
	 extern (C) void gc_check(void *p);
	 
	 extern (D){
	 void setFinalizer(void *p, GC_FINALIZER pFn);
	 void addRoot(void *p);
	 void removeRoot(void *p);
	 void addRange(void *pbot, void *ptop);
	 void removeRange(void *pbot);
	 void fullCollect();
	 void fullCollectNoStack();
	 void genCollect();
	 void minimize();
	 void disable();
	 void enable();
	 void getStats(out GCStats stats);
	 void hasPointers(void* p);
	 void hasNoPointers(void* p);
	 void setV1_0();
	 }
	 
class GC{}


extern (D):
	void printStats(gc_t gc);
	//void[] malloc(size_t sz, uint ba = 0);
		//void[] realloc(void* p, size_t sz, uint ba = 0);		
	size_t capacity(void* p);		
	size_t capacity(void[] p);
	void[] malloc(size_t nbytes);
	void[] realloc(void* p, size_t nbytes);
	size_t extend(void* p, size_t minbytes, size_t maxbytes);
	//size_t capacity(void* p);
	void new_finalizer(void *p, bool dummy);
}
version(Static)
{

	public import std.c;
	public import rt.gc.gcx;
	public import std.exception;
	public import gcstats;
	public import std.thread;

	version=GCCLASS;

	version (GCCLASS)
		alias GC gc_t;
	else
		alias GC* gc_t;

	gc_t _gc;


	private int _termCleanupLevel=1;


	 void addRoot(void *p)		      { _gc.addRoot(p); }
	 void removeRoot(void *p)	      { _gc.removeRoot(p); }
	 void addRange(void *pbot, void *ptop) { _gc.addRange(pbot, ptop); }
	 void removeRange(void *pbot)	      { _gc.removeRange(pbot); }
	 void fullCollect()		      { _gc.fullCollect(); }
	 void fullCollectNoStack()	      { _gc.fullCollectNoStack(); }
	 void genCollect()		      { _gc.genCollect(); }
	 void minimize()			      { _gc.minimize(); }
	 void disable()			      { _gc.disable(); }
	 void enable()			      { _gc.enable(); }
	 void getStats(out GCStats stats)      { _gc.getStats(stats); }
	 void hasPointers(void* p)	      { _gc.hasPointers(p); }
	 void hasNoPointers(void* p)	      { _gc.hasNoPointers(p); }
	 void setV1_0()			      { _gc.setV1_0(); }
	 
	///////////////////////////////////////////////////////////////////
	 extern (C) void gc_check(void *p){_gc.check(p);}
	extern (C) void gc_minimize() { _gc.minimize(); }
	extern (C) void gc_addRoot( void* p ){ _gc.addRoot(p); }
	extern (C) void gc_addRange( void* p, size_t sz ){ _gc.addRange(p, sz); }
	extern (C) void gc_removeRoot( void* p ){ _gc.removeRoot(p); }
	extern (C) void gc_removeRange( void* p ){ _gc.removeRange(p); }
	 extern (C) size_t gc_capacity(void* p){  return _gc.capacity(p);}
	alias extern(D) void delegate() ddel;
	alias extern(D) void delegate(int, int) dint;
		
	extern (C) void gc_monitor(ddel begin, dint end ){_gc.monitor(begin, end);}
	/////////////////////////////////////////////////////////////////////////
	 extern (C)  gc_t newGC()
	{
		version (all)
		{	void* p;
		ClassInfo ci = GC.classinfo;

		p = std.c.malloc(ci.init.length);
		(cast(byte*)p)[0 .. ci.init.length] = ci.init[];
		//printf("Returning from newGC all\n");
		return cast(GC)p;
		}
		else
		{
		//printf("Returning from newGC else\n");
		return cast(gc_t)std.c.calloc(1, GC.sizeof);
		}
	}

	 extern (C) void deleteGC(gc_t gc)
	{
		gc.Dtor();
		std.c.free(cast(void*)gc);
	}

	 extern (C) void gc_printStats(gc_t gc)
	{
		GCStats stats;

		//gc.getStats(stats);
		printf("poolsize = x%x, usedsize = x%x, freelistsize = x%x, freeblocks = %d, pageblocks = %d\n",
		stats.poolsize, stats.usedsize, stats.freelistsize, stats.freeblocks, stats.pageblocks);
	}

	 extern (C)  GCStats gc_stats()
	{
		GCStats stats = void;
		_gc.getStats( stats );
		return stats;
	}
	// for gcosxc.c
	 extern (C)  void _d_gc_addrange(void *pbot, void *ptop)
	{
		_gc.addRange(pbot, ptop);
	}

	//for gcosxc.c
	 extern (C)  void _d_gc_removerange(void *pbot)
	{
		_gc.removeRange(pbot);
	}

	 void[] malloc(size_t nbytes)
	{
		void* p = gc_malloc(nbytes);
		return cast(void[]) p[0 .. nbytes];	
	}

	 void[] realloc(void* p, size_t nbytes)
	{
		void* q = _gc.realloc(p, nbytes);
		return cast(void[]) q[0 .. nbytes];
	}

	 size_t extend(void* p, size_t minbytes, size_t maxbytes)
	{
		return _gc.extend(p, minbytes, maxbytes);
	}

	 size_t capacity(void* p)
	{
		return _gc.capacity(p);
	}

	extern (C) void setTypeInfo(TypeInfo ti, void* p)
	{
		if (ti.flags() & 1)
		hasNoPointers(p);
		else
		hasPointers(p);
	}

	 extern (C) void* getGCHandle()
	{
		return cast(void*)_gc;
	}

	 extern (C) void setGCHandle(void* p)
	{
		void* oldp = getGCHandle();
		gc_t g = cast(gc_t)p;
		if (g.gcversion != rt.gc.gcx.GCVERSION)
		throw new Error("incompatible gc versions");

		// Add our static data to the new gc
		GC.scanStaticData(g);

		_gc = g;
	//    return oldp;
	}

	 extern (C) void endGCHandle()
	{
		GC.unscanStaticData(_gc);
	}




	 extern (C) 	void _d_monitorrelease(Object h);

		version(OSX)
		{
		 extern (C) 	void _d_osx_image_init();
		}

	 extern (C) void thread_init();

	 extern (C) void gc_init()
	{
		version (GCCLASS)
		{   void* p;
			ClassInfo ci = GC.classinfo;

			p = rt.core.stdc.stdlib.malloc(ci.init.length);
			(cast(byte*)p)[0 .. ci.init.length] = ci.init[];
			_gc = cast(GC)p;
		}
		else
		{
			_gc = cast(GC*) rt.core.stdc.stdlib.calloc(1, GC.sizeof);
		}
		_gc.initialize();
		version (DigitalMars) version(OSX) {
			_d_osx_image_init();
		}
		// NOTE: The GC must initialize the thread library
		//       before its first collection.
		GC.scanStaticData(_gc);
		std.thread.DThread.thread_init();
		thread_init();
	}

	 extern (C) void gc_term()
	{
		if (_termCleanupLevel<1) {
			// no cleanup
		} else if (_termCleanupLevel==2){
			// a more complete cleanup
			// NOTE: There may be daemons threads still running when this routine is
			//       called.  If so, cleaning memory out from under then is a good
			//       way to make them crash horribly.
			//       Often this probably doesn't matter much since the app is
			//       supposed to be shutting down anyway, but for example tests might
			//       crash (and be considerd failed even if the test was ok).
			//       thus this is not the default and should be enabled by 
			//       I'm disabling cleanup for now until I can think about it some
			//       more.
			//
			_gc.fullCollectNoStack(); // not really a 'collect all' -- still scans
									  // static data area, roots, and ranges.
			_gc.Dtor();
		} else {
			// default (safe) clenup
			_gc.fullCollect(); 
		}
	}

	 extern (C)   Object _d_newclass(ClassInfo ci);

	 extern (C)	void _d_delinterface(void** p);

	 extern (C)  void _d_delclass(Object *p);

	/******************************************
	 * Allocate a new array of length elements.
	 * ti is the type of the resulting array, or pointer to element.
	 */

	 extern (C) ulong _d_newarrayT(TypeInfo ti, size_t length);

	 extern (C) ulong _d_newarrayiT(TypeInfo ti, size_t length);

	 extern (C) ulong _d_newarraymT(TypeInfo ti, int ndims, ...);

	 extern (C) ulong _d_newarraymiT(TypeInfo ti, int ndims, ...);


	struct Array
	{
		size_t length;
		byte *data;
	};

	// Perhaps we should get a a size argument like _d_new(), so we
	// can zero out the array?

	 extern (C) void _d_delarray(Array *p);


	 extern (C) void _d_delmemory(void* *p);


	 void new_finalizer(void *p, bool dummy)
	{
		//printf("new_finalizer(p = %p)\n", p);
		_d_callfinalizer(p);
	}

	 extern (C) void _d_callinterfacefinalizer(void *p)
	{
		//printf("_d_callinterfacefinalizer(p = %p)\n", p);
		if (p)
		{
		Interface *pi = **cast(Interface ***)p;
		Object o = cast(Object)(p - pi.offset);
		_d_callfinalizer(cast(void*)o);
		}
	}

	 extern (C) void _d_callfinalizer(void *p);


	/+ ------------------------------------------------ +/


	/******************************
	 * Resize dynamic arrays with 0 initializers.
	 */

	 extern (C)  byte[] _d_arraysetlengthT(TypeInfo ti, size_t newlength, Array *p);

	/**
	 * Resize arrays for non-zero initializers.
	 *	p		pointer to array lvalue to be updated
	 *	newlength	new .length property of array
	 *	sizeelem	size of each element of array
	 *	initsize	size of initializer
	 *	...		initializer
	 */
	 extern (C) byte[] _d_arraysetlengthiT(TypeInfo ti, size_t newlength, Array *p);

	/****************************************
	 * Append y[] to array x[].
	 * size is size of each array element.
	 */

	 extern (C) long _d_arrayappendT(TypeInfo ti, Array *px, byte[] y);


	 extern (C)  size_t gc_newCapacity(size_t newlength, size_t size)
	{
		version(none)
		{
		size_t newcap = newlength * size;
		}
		else
		{
		/*
		 * Better version by Dave Fladebo:
		 * This uses an inverse logorithmic algorithm to pre-allocate a bit more
		 * space for larger arrays.
		 * - Arrays smaller than 4096 bytes are left as-is, so for the most
		 * common cases, memory allocation is 1 to 1. The small overhead added
		 * doesn't effect small array perf. (it's virtually the same as
		 * current).
		 * - Larger arrays have some space pre-allocated.
		 * - As the arrays grow, the relative pre-allocated space shrinks.
		 * - The logorithmic algorithm allocates relatively more space for
		 * mid-size arrays, making it very fast for medium arrays (for
		 * mid-to-large arrays, this turns out to be quite a bit faster than the
		 * equivalent realloc() code in C, on Linux at least. Small arrays are
		 * just as fast as GCC).
		 * - Perhaps most importantly, overall memory usage and stress on the GC
		 * is decreased significantly for demanding environments.
		 */
		size_t newcap = newlength * size;
		size_t newext = 0;

		if (newcap > 4096)
		{
			//double mult2 = 1.0 + (size / log10(pow(newcap * 2.0,2.0)));

			// Redo above line using only integer math

			static int log2plus1(size_t c)
			{   int i;

			if (c == 0)
				i = -1;
			else
				for (i = 1; c >>= 1; i++)
				{   }
			return i;
			}

			/* The following setting for mult sets how much bigger
			 * the new size will be over what is actually needed.
			 * 100 means the same size, more means proportionally more.
			 * More means faster but more memory consumption.
			 */
			//long mult = 100 + (1000L * size) / (6 * log2plus1(newcap));
			long mult = 100 + (1000L * size) / log2plus1(newcap);

			// testing shows 1.02 for large arrays is about the point of diminishing return
			if (mult < 102)
			mult = 102;
			newext = cast(size_t)((newcap * mult) / 100);
			newext -= newext % size;
			//printf("mult: %2.2f, mult2: %2.2f, alloc: %2.2f\n",mult/100.0,mult2,newext / cast(double)size);
		}
		newcap = newext > newcap ? newext : newcap;
		//printf("newcap = %d, newlength = %d, size = %d\n", newcap, newlength, size);
		}
		return newcap;
	}

	 extern (C) byte[] _d_arrayappendcT(TypeInfo ti, inout byte[] x, ...);

	/**
	 * Append dchar to char[]
	 */
	 extern (C)  char[] _d_arrayappendcd(inout char[] x, dchar c)
	{
		const sizeelem = c.sizeof;            // array element size
		auto cap = _gc.capacity(x.ptr);
		auto length = x.length;

		// c could encode into from 1 to 4 characters
		int nchars;
		if (c <= 0x7F)
			nchars = 1;
		else if (c <= 0x7FF)
			nchars = 2;
		else if (c <= 0xFFFF)
			nchars = 3;
		else if (c <= 0x10FFFF)
			nchars = 4;
		else
		assert(0);	// invalid utf character - should we throw an exception instead?

		auto newlength = length + nchars;
		auto newsize = newlength * sizeelem;

		assert(cap == 0 || length * sizeelem <= cap);

		debug(PRINTF) printf("_d_arrayappendcd(sizeelem = %d, ptr = %p, length = %d, cap = %d)\n", sizeelem, x.ptr, x.length, cap);

		if (cap <= newsize)
		{   byte* newdata;

		if (cap >= 4096)
		{   // Try to extend in-place
			auto u = _gc.extend(x.ptr, (newsize + 1) - cap, (newsize + 1) - cap);
			if (u)
			{
			goto L1;
			}
		}
			debug(PRINTF) printf("_d_arrayappendcd(length = %d, newlength = %d, cap = %d)\n", length, newlength, cap);
			auto newcap = gc_newCapacity(newlength, sizeelem);
			assert(newcap >= newlength * sizeelem);
			newdata = cast(byte *)_gc.malloc(newcap + 1);
		_gc.hasNoPointers(newdata);
			memcpy(newdata, x.ptr, length * sizeelem);
			(cast(void**)(&x))[1] = newdata;
		}
	  L1:
		*cast(size_t *)&x = newlength;
		char* ptr = &x.ptr[length];

		if (c <= 0x7F)
		{
			ptr[0] = cast(char) c;
		}
		else if (c <= 0x7FF)
		{
			ptr[0] = cast(char)(0xC0 | (c >> 6));
			ptr[1] = cast(char)(0x80 | (c & 0x3F));
		}
		else if (c <= 0xFFFF)
		{
			ptr[0] = cast(char)(0xE0 | (c >> 12));
			ptr[1] = cast(char)(0x80 | ((c >> 6) & 0x3F));
			ptr[2] = cast(char)(0x80 | (c & 0x3F));
		}
		else if (c <= 0x10FFFF)
		{
			ptr[0] = cast(char)(0xF0 | (c >> 18));
			ptr[1] = cast(char)(0x80 | ((c >> 12) & 0x3F));
			ptr[2] = cast(char)(0x80 | ((c >> 6) & 0x3F));
			ptr[3] = cast(char)(0x80 | (c & 0x3F));
		}
		else
		assert(0);

		assert((cast(size_t)x.ptr & 15) == 0);
		assert(_gc.capacity(x.ptr) > x.length * sizeelem);
		return x;
	}


	/**
	 * Append dchar to wchar[]
	 */
	 extern (C)  wchar[] _d_arrayappendwd(inout wchar[] x, dchar c)
	{
		const sizeelem = c.sizeof;            // array element size
		auto cap = _gc.capacity(x.ptr);
		auto length = x.length;

		// c could encode into from 1 to 2 w characters
		int nchars;
		if (c <= 0xFFFF)
			nchars = 1;
		else
			nchars = 2;

		auto newlength = length + nchars;
		auto newsize = newlength * sizeelem;

		assert(cap == 0 || length * sizeelem <= cap);

		debug(PRINTF) printf("_d_arrayappendwd(sizeelem = %d, ptr = %p, length = %d, cap = %d)\n", sizeelem, x.ptr, x.length, cap);

		if (cap <= newsize)
		{   byte* newdata;

		if (cap >= 4096)
		{   // Try to extend in-place
			auto u = _gc.extend(x.ptr, (newsize + 1) - cap, (newsize + 1) - cap);
			if (u)
			{
			goto L1;
			}
		}

			debug(PRINTF) printf("_d_arrayappendwd(length = %d, newlength = %d, cap = %d)\n", length, newlength, cap);
			auto newcap = gc_newCapacity(newlength, sizeelem);
			assert(newcap >= newlength * sizeelem);
			newdata = cast(byte *)_gc.malloc(newcap + 1);
		_gc.hasNoPointers(newdata);
			memcpy(newdata, x.ptr, length * sizeelem);
			(cast(void**)(&x))[1] = newdata;
		}
	  L1:
		*cast(size_t *)&x = newlength;
		wchar* ptr = &x.ptr[length];

		if (c <= 0xFFFF)
		{
			ptr[0] = cast(wchar) c;
		}
		else
		{
		ptr[0] = cast(wchar) ((((c - 0x10000) >> 10) & 0x3FF) + 0xD800);
		ptr[1] = cast(wchar) (((c - 0x10000) & 0x3FF) + 0xDC00);
		}

		assert((cast(size_t)x.ptr & 15) == 0);
		assert(_gc.capacity(x.ptr) > x.length * sizeelem);
		return x;
	}


	 extern (C) byte[] _d_arraycatT(TypeInfo ti, byte[] x, byte[] y);


	 extern (C) byte[] _d_arraycatnT(TypeInfo ti, uint n, ...);


	 extern (C) void* _d_arrayliteralT(TypeInfo ti, size_t length, ...);


	/**********************************
	 * Support for array.dup property.
	 */

	struct Array2
	{
		size_t length;
		void* ptr;
	}

	 extern (C) long _adDupT(TypeInfo ti, Array2 a);


	 extern (C) uint gc_getAttr( void* p )
	{
		return _gc.getAttr(p);
	}

	 extern (C) uint gc_setAttr( void* p, uint a )
	{
		return _gc.setAttr(p, a);
	}

	 extern (C) uint gc_clrAttr( void* p, uint a )
	{
		return _gc.clrAttr(p, a);
	}

	 extern (C) void* gc_malloc( size_t sz, uint ba = 0 )
	{
	   /* void* p = cast(void*)std.c.malloc( sz );

		if( sz && p is null )
			std.exception.onOutOfMemoryError();*/
		return _gc.malloc(sz, ba);//p;
	}

	 extern (C) void* gc_calloc( size_t sz, uint ba = 0 )
	{
		/*void* p = calloc( 1, sz );

		if( sz && p is null )
			std.exception.onOutOfMemoryError();*/
		return _gc.calloc(sz, ba);//p;
	}

	 extern (C) void* gc_realloc( void* p, size_t sz, uint ba = 0 )
	{
	   /* p = cast(void*)realloc( p, sz );

		if( sz && p is null )
			std.exception.onOutOfMemoryError();*/
		return _gc.realloc(p, sz, ba);//up;
	}

	 extern (C) size_t gc_extend( void* p, size_t mx, size_t sz )
	{
		return _gc.extend(p, mx, sz);
	}

	 extern (C) size_t gc_reserve( size_t sz )
	{
		return _gc.reserve(sz);
	}

	 extern (C) void gc_free( void* p )
	{
		_gc.free( p );
	}

	 extern (C) void* gc_addrOf( void* p )
	{
		return _gc.addrOf(p);
	}

	 extern (C) size_t gc_sizeOf( void* p )
	{
		return _gc.sizeOf(p);
	}

	 extern (C) void* gc_weakpointerCreate( Object r )
	{
		return _gc.weakpointerCreate(r);//cast(void*)r;
	}

	 extern (C) void gc_weakpointerDestroy( void* wp )
	{
	_gc.weakpointerDestroy(wp);
	}

	 extern (C) Object gc_weakpointerGet( void* wp )
	{
		return _gc.weakpointerGet(wp);//cast(Object)wp;
	}

	 extern (C) BlkInfo gc_query( void* p )
	{
	return _gc.query(p);
	}

	 extern (C) void rt_finalize(void* p, bool det = true);

	 extern (C) void gc_enable()
	{
	_gc.enable();
	}

	 extern (C) void gc_disable()
	{
	_gc.disable();
	}

	 extern (C) void gc_collect()
	{
	_gc.fullCollect();
	}

	 extern (C) void setFinalizer(void *p, GC_FINALIZER pFn)
	{
	_gc.setFinalizer(p, pFn);
	}

}

