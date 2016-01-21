//This file changed for Rulada by Vitaly Kulich

/**
 * Part of the D programming language runtime library.
 * Forms the symbols available to all D programs. Includes
 * Object, which is the root of the class object hierarchy.
 *
 * This module is implicitly imported.
 * Macros:
 *	WIKI = Phobos/Object
 */

/*
 *  Copyright (C) 2004-2007 by Digital Mars, www.digitalmars.com
 *  Written by Walter Bright
 *
 *  This software is provided 'as-is', without any express or implied
 *  warranty. In no event will the authors be held liable for any damages
 *  arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute it
 *  freely, in both source and binary form, subject to the following
 *  restrictions:
 *
 *  o  The origin of this software must not be misrepresented; you must not
 *     claim that you wrote the original software. If you use this software
 *     in a product, an acknowledgment in the product documentation would be
 *     appreciated but is not required.
 *  o  Altered source versions must be plainly marked as such, and must not
 *     be misrepresented as being the original software.
 *  o  This notice may not be removed or altered from any source
 *     distribution.
 */


module object;

import rt.core.exception;
import rt.aaA;
import rt.core.c;
public import rt.typeinfo;
/**
 * Беззначный интегральный тип, достаточный по размеру для 
 * аккумуляции пространства памяти. Используется для индексов массивов
 * и смещений указателей в целях максимальной портабельности
 * на архитектуры с разными диапазонами адресов памяти. Аналог
 * size_t из Си.
 */
alias typeof(int.sizeof) size_t;

/**
 * A signed integral type large enough to span the memory space. Use for
 * pointer differences and for size_t differences for maximal portability to
 * architectures that have different memory address ranges. This is
 * analogous to C's ptrdiff_t.
 */
alias typeof(cast(void*)0 - cast(void*)0) ptrdiff_t;
alias size_t hash_t;
alias int equals_t;

extern  (C)
{   /// C's printf function.
    int printf(char *, ...);
	alias printf выводф;
    void trace_term();
	alias trace_term трасс_терм;
	void setTango();
	hash_t rt_hash_combine( hash_t val1, hash_t val2 );
    //int memcmp(void *, void *, size_t);
    //void* memcpy(void *, void *, size_t);
	//void* memmove(void* s1, in void* s2, size_t n);
    //void* calloc(size_t, size_t);
    //void* realloc(void*, size_t);
    //void free(void*);

    Object _d_newclass(ClassInfo ci);
}

/// Standard boolean type.
alias bool bit;
alias char[] string;
alias wchar[] wstring;
alias dchar[] dstring;

alias bool бул;
alias int цел;
alias uint бцел;
alias long дол;
alias ulong бдол;
alias real реал;
alias double дво;
alias char сим;
alias wchar шим;
alias dchar дим;
alias byte байт;
alias ubyte ббайт;
alias short крат;
alias ushort бкрат;
alias float плав;

alias void проц;

alias ireal вреал;
alias idouble вдво;
alias ifloat вплав;

alias creal креал;
alias cdouble кдво;
alias cfloat кплав;

alias size_t т_мера;
alias ptrdiff_t т_дельтаук;
alias hash_t т_хэш;
alias equals_t т_рав;

alias string симма; 
alias симма ткст;
alias wstring шимма;
alias шимма ткстш;
alias dstring димма;
alias димма ткстд;

alias bit бит;

alias Object Объект;


/******************
 * Все объекты "класс" в D наследуют от Object.
 */
class Object
{
	/**
     * Override this to capture an explicit delete or an implicit 
     * delete via a scoped-instance. Unlike a dtor(), GC references
     * are still intact when this method is invoked
     */
    void dispose()
    {
	
    }
    /**
     * Преобразует Object в удобочитаемую форму и записывает эту строку в stdout.
     */
	 alias dispose выместить;
	 
    void print()
    {
	printf("%.*s\n", toString());
    }
	alias print вывод;
    /**
     * Преобразует Object в удобочитаемую строку.
     */
    char[] toString()
    {
	return this.classinfo.name;
    }
	alias toString вСтр;
    /**
     * Вычисляет хеш-функцию для Object.
     */
    hash_t toHash()
    {
	// BUG: this prevents a compacting GC from working, needs to be fixed
	return cast(uint)cast(void *)this;
    }
	alias toHash вХэш;
    /**
     * Compare with another Object obj.
     * Возвращает:
     *	$(TABLE
     *  $(TR $(TD this &lt; obj) $(TD &lt; 0))
     *  $(TR $(TD this == obj) $(TD 0))
     *  $(TR $(TD this &gt; obj) $(TD &gt; 0))
     *  )
     */
    int opCmp(Object o)
    {
	// BUG: this prevents a compacting GC from working, needs to be fixed
	//return cast(int)cast(void *)this - cast(int)cast(void *)o;

	//throw new Error("need opCmp for class " ~ this.classinfo.name);
	return this !is o;
    }

    /**
     * Returns !=0 if this object does have the same contents as obj.
     */
    int opEquals(Object o) //int in Phobos
    {
	return cast(int)(this is o);
    }
	
	
	interface Monitor
    {
        void lock();
		alias lock блокир;
		
        void unlock();
		alias unlock разблок;
    }
	alias Monitor Монитор;
    /* **
     * Call delegate dg, passing this to it, when this object gets destroyed.
     * Use extreme caution, as the list of delegates is stored in a place
     * not known to the gc. Thus, if any objects pointed to by one of these
     * delegates gets freed by the gc, calling the delegate will cause a
     * crash.
     * This is only for use by library developers, as it will need to be
     * redone if weak pointers are added or a moving gc is developed.
     */
    final void notifyRegister(void delegate(Object) dg)
    {
	//printf("notifyRegister(dg = %llx, o = %p)\n", dg, this);
	synchronized (this)
	{
	    .Monitor* m = cast(.Monitor*)(cast(void**)this)[1];
	    foreach (inout x; m.delegates)
	    {
		if (!x || x == dg)
		{   x = dg;
		    return;
		}
	    }

	    // Increase size of delegates[]
	    auto len = m.delegates.length;
	    auto startlen = len;
	    if (len == 0)
	    {
		len = 4;
		auto p = calloc((void delegate(Object)).sizeof, len);
		if (!p)
		    _d_OutOfMemory();
		m.delegates = (cast(void delegate(Object)*)p)[0 .. len];
	    }
	    else
	    {
		len += len + 4;
		auto p = realloc(m.delegates.ptr, (void delegate(Object)).sizeof * len);
		if (!p)
		    _d_OutOfMemory();
		m.delegates = (cast(void delegate(Object)*)p)[0 .. len];
		m.delegates[startlen .. len] = null;
	    }
	    m.delegates[startlen] = dg;
	}
 }
	alias notifyRegister уведомРегистр;
    /* **
     * Remove delegate dg from the notify list.
     * This is only for use by library developers, as it will need to be
     * redone if weak pointers are added or a moving gc is developed.
     */
    final void notifyUnRegister(void delegate(Object) dg)
    {
	synchronized (this)
	{
	    .Monitor* m = cast(.Monitor*)(cast(void**)this)[1];
	    foreach (inout x; m.delegates)
	    {
		if (x == dg)
		    x = null;
	    }
	}
    }
	alias notifyUnRegister уведомОтРегистр;
    /******
     * Создает экземпляр класса, заданного посредством classname.
     * У этого класса либо не должно быть конструкторов,
     * либо дефолтного конструктора.
     * Возвращает:
     *	null if failed
     */
    static Object factory(char[] classname)
    {
	auto ci = ClassInfo.find(classname);
	if (ci)
	{
	    return ci.create();
	}
	return null;
    }
	alias factory фабрика;
}

  extern (C) void _d_notify_release(Object o)
	{
		//printf("_d_notify_release(o = %p)\n", o);
		Monitor* m = cast(Monitor*)(cast(void**)o)[1];
		if (m.delegates.length)
		{
		auto dgs = m.delegates;
		synchronized (o)
		{
			dgs = m.delegates;
			m.delegates = null;
		}

		foreach (dg; dgs)
		{
			if (dg)
			{	//printf("calling dg = %llx (%p)\n", dg, o);
			dg(o);
			}
		}

		free(dgs.ptr);
		}
	}

/**
 * Информация об интерфейсе.
 * При доступе к объекту через интерфейс,  Interface* появляется в виде
 * первой записи в его vtbl (виртуальной таблице).
 */
struct Interface
{
    ClassInfo classinfo;	/// .classinfo for this interface (not for containing class)
	alias classinfo классинфо;
    void *[] vtbl;
	alias vtbl вирттаб;
    int offset;			/// offset to Interface 'this' from Object 'this'
	alias offset смещение;
}
alias Interface Интерфейс;

//import  rt.core.moduleinit;
/**
 * Runtime type information about a class. Can be retrieved for any class type
 * or instance by using the .classinfo property.
 * A pointer to this appears as the first entry in the class's vtbl[].
 */

 alias ClassInfo ИнфОКлассе;
 class ClassInfo //: Object
{
    byte[] init;		/** class static initializer
				 * (init.length gives size in bytes of class)
				 */
	alias init иниц;
	
    char[] name;		/// class name
	alias name имя;
	
    void *[] vtbl;		/// virtual function pointer table
	alias vtbl вирттаб;
	
    Interface[] interfaces;	/// interfaces this class implements
	alias interfaces интерфейсы;
	
    ClassInfo base;		/// base class
	alias base основа;
	
    void *destructor;
	alias destructor деструктор;
	
    void (*classInvariant)(Object);
    uint flags;
	alias flags флаги;
	
    //	1:			// IUnknown
    //	2:			// has no possible pointers into GC memory
    //	4:			// has offTi[] member
    //	8:			// has constructors
    //	32:			// has typeinfo
    void *deallocator;
	alias deallocator выместитель;
	
    OffsetTypeInfo[] offTi;
	alias offTi смТи;
	
    void function(Object) defaultConstructor;	// default Constructor
    TypeInfo typeinfo;

    /*************
     * Search all modules for ClassInfo corresponding to classname.
     * Возвращает: null if not found
     */
    static ClassInfo find(char[] classname)
    {
	foreach (m; ModuleInfo.modules())
	{
	    //writefln("module %s, %d", m.name, m.localClasses.length);
	    foreach (c; m.localClasses)
	    {
		//writefln("\tclass %s", c.name);
		if (c.name == classname)
		    return c;
	    }
	}
	return null;
    }

    /********************
     * Create instance of Object represented by 'this'.
     * Возвращает:
     *	the object created, or null if the Object does
     *	does not have a default constructor
     */
    /*Object create()
    {
	if (flags & 8 && !defaultConstructor)
	    return null;
	Object o = _d_newclass(this);
	if (flags & 8 && defaultConstructor)
	{
	    defaultConstructor(o);
	}
	return o;
    }*/
	Object create()
    {
        if (flags & 8 && defaultConstructor is null)
            return null;
        Object o = _d_newclass(this);
        if (flags & 8 && defaultConstructor !is null)
        {
            Object delegate() ctor;
            ctor.ptr = cast(void*)o;
            ctor.funcptr = cast(Object function())defaultConstructor;
            return ctor();
        }
        return o;
    }
	alias find найти;
	alias create создать;
}
alias ClassInfo ИнфоКлассе;

private import rt.core.string;

/**
 * Array of pairs giving the offset and type information for each
 * member in an aggregate.
 */
struct OffsetTypeInfo
{
    size_t offset;	/// Offset of member from start of object
	alias offset смещение;
    TypeInfo ti;	/// TypeInfo for this member
	alias ti иот;
}
alias OffsetTypeInfo ИнфоТипеИСмещ;

/**
 * Runtime type information about a type.
 * Can be retrieved for any type using a
 * <a href="../expression.html#typeidexpression">TypeidExpression</a>.
 */
 alias TypeInfo ИнфОТипе;
class TypeInfo
{
    hash_t toHash()
    {	hash_t hash;

	foreach (char c; this.toString())
	    hash = hash * 9 + c;
	return hash;
    }

    override int opCmp(Object o)
    {
	if (this is o)
	    return 0;
	TypeInfo ti = cast(TypeInfo)o;
	if (ti is null)
	    return 1;
	return rt.core.string.cmp(this.toString(), ti.toString());
    }

    override int opEquals(Object o)
    {
	/* TypeInfo instances are singletons, but duplicates can exist
	 * across DLL's. Therefore, comparing for a name match is
	 * sufficient.
	 */
	if (this is o)
	    return 1;
	TypeInfo ti = cast(TypeInfo)o;
	return cast(int)(ti && this.toString() == ti.toString());
    }

    /// Returns a hash of the instance of a type.
    hash_t getHash(in void *p) { return cast(hash_t)p; }

    /// Compares two instances for equality.
    int equals(in void *p1, in void *p2) { return cast(int)(p1 == p2); }

    /// Compares two instances for &lt;, ==, or &gt;.
    int compare(in void *p1, in void *p2) { return 0; }

    /// Returns size of the type.
    size_t tsize() { return 0; }

    /// Swaps two instances of the type.
    void swap(void *p1, void *p2)
    {
	size_t n = tsize();
	for (size_t i = 0; i < n; i++)
	{   byte t;

	    t = (cast(byte *)p1)[i];
	    (cast(byte *)p1)[i] = (cast(byte *)p2)[i];
	    (cast(byte *)p2)[i] = t;
	}
    }

    /// Get TypeInfo for 'next' type, as defined by what kind of type this is,
    /// null if none.
    TypeInfo next() { return null; }

    /// Return default initializer, null if default initialize to 0
    void[] init() { return null; }

    /// Get flags for type: 1 means GC should scan for pointers
    uint flags() { return 0; }

    /// Get type information on the contents of the type; null if not available
    OffsetTypeInfo[] offTi() { return null; }
	alias getHash полХэш;
	alias equals равны_ли;
	alias compare сравнить;
	
}

class TypeInfo_Typedef : TypeInfo
{
    override char[] toString() { return name; }

    override int opEquals(Object o)
    {   TypeInfo_Typedef c;

	return cast(int)
		(this is o ||
		((c = cast(TypeInfo_Typedef)o) !is null &&
		 this.name == c.name &&
		 this.base == c.base));
    }

    override hash_t getHash(in void *p) { return base.getHash(p); }
    override int equals(in void *p1, in void *p2) { return base.equals(p1, p2); }
    override int compare(in void *p1, in void *p2) { return base.compare(p1, p2); }
    override size_t tsize() { return base.tsize(); }
    override void swap(void *p1, void *p2) { return base.swap(p1, p2); }

    override TypeInfo next() { return base.next(); }
   override  uint flags() { return base.flags(); }
    override void[] init() { return m_init.length ? m_init : base.init(); }

    TypeInfo base;
    char[] name;
    void[] m_init;
}
alias TypeInfo_Typedef ИнфОТипе_Типдеф;

class TypeInfo_Enum : TypeInfo_Typedef
{
}
alias TypeInfo_Enum  ИнфОТипе_Перечень;

class TypeInfo_Pointer : TypeInfo
{
    override char[] toString() { return m_next.toString() ~ "*"; }

    override int opEquals(Object o)
    {   TypeInfo_Pointer c;

	return this is o ||
		((c = cast(TypeInfo_Pointer)o) !is null &&
		 this.m_next == c.m_next);
    }

    hash_t getHash(void *p)
    {
        return cast(uint)*cast(void* *)p;
    }

    int equals(void *p1, void *p2)
    {
        return cast(int)(*cast(void* *)p1 == *cast(void* *)p2);
    }

    int compare(void *p1, void *p2)
    {
	if (*cast(void* *)p1 < *cast(void* *)p2)
	    return -1;
	else if (*cast(void* *)p1 > *cast(void* *)p2)
	    return 1;
	else
	    return 0;
    }

    override size_t tsize()
    {
	return (void*).sizeof;
    }

    override void swap(void *p1, void *p2)
    {	void* tmp;
	tmp = *cast(void**)p1;
	*cast(void**)p1 = *cast(void**)p2;
	*cast(void**)p2 = tmp;
    }

    override TypeInfo next() { return m_next; }
    override uint flags() { return 1; }

    TypeInfo m_next;
}
alias TypeInfo_Pointer ИнфОТипе_Указатель;

class TypeInfo_Array : TypeInfo
{
    override char[] toString() { return value.toString() ~ "[]"; }

    override int opEquals(Object o)
    {   TypeInfo_Array c;

	return cast(int)
	       (this is o ||
		((c = cast(TypeInfo_Array)o) !is null &&
		 this.value == c.value));
    }

    hash_t getHash(void *p)
    {	size_t sz = value.tsize();
	hash_t hash = 0;
	void[] a = *cast(void[]*)p;
	for (size_t i = 0; i < a.length; i++)
	    hash += value.getHash(a.ptr + i * sz) * 11;
        return hash;
    }

    int equals(void *p1, void *p2)
    {
	void[] a1 = *cast(void[]*)p1;
	void[] a2 = *cast(void[]*)p2;
	if (a1.length != a2.length)
	    return 0;
	size_t sz = value.tsize();
	for (size_t i = 0; i < a1.length; i++)
	{
	    if (!value.equals(a1.ptr + i * sz, a2.ptr + i * sz))
		return 0;
	}
        return 1;
    }

    int compare(void *p1, void *p2)
    {
	void[] a1 = *cast(void[]*)p1;
	void[] a2 = *cast(void[]*)p2;
	size_t sz = value.tsize();
	size_t len = a1.length;

        if (a2.length < len)
            len = a2.length;
        for (size_t u = 0; u < len; u++)
        {
            int result = value.compare(a1.ptr + u * sz, a2.ptr + u * sz);
            if (result)
                return result;
        }
        return cast(int)a1.length - cast(int)a2.length;
    }

    override size_t tsize()
    {
	return (void[]).sizeof;
    }

    override void swap(void *p1, void *p2)
    {	void[] tmp;
	tmp = *cast(void[]*)p1;
	*cast(void[]*)p1 = *cast(void[]*)p2;
	*cast(void[]*)p2 = tmp;
    }

    TypeInfo value;

    override TypeInfo next()
    {
	return value;
    }

    override uint flags() { return 1; }
}
alias TypeInfo_Array ИнфОТипе_Массив;

class TypeInfo_StaticArray : TypeInfo
{
    override char[] toString()
    {
	//return value.toString() ~ "[" ~ rt.core.string.toString(len) ~ "]";
	char [10] tmp = void;
        return value.toString() ~ "[" ~ rt.core.string.intToUtf8(tmp, len) ~ "]";
    }

    override int opEquals(Object o)
    {   TypeInfo_StaticArray c;

	return cast(int)
	       (this is o ||
		((c = cast(TypeInfo_StaticArray)o) !is null &&
		 this.len == c.len &&
		 this.value == c.value));
    }

   /* hash_t getHash(in void *p)
    {	size_t sz = value.tsize();
	hash_t hash = 0;
	for (size_t i = 0; i < len; i++)
	    hash += value.getHash(p + i * sz);
        return hash;
    }*/
	override hash_t getHash(in void* p)
    {
        size_t sz = value.tsize();
        hash_t hash = len;
        for (size_t i = 0; i < len; i++)
            hash = rt_hash_combine(value.getHash(p + i * sz),hash);
        return hash;
    }
	
    override int equals(in void *p1, in void *p2)
    {
	size_t sz = value.tsize();

        for (size_t u = 0; u < len; u++)
        {
	    if (!value.equals(p1 + u * sz, p2 + u * sz))
		return false;//0
        }
        return true; //1;
    }

    override int compare(in void *p1, in void *p2)
    {
	size_t sz = value.tsize();

        for (size_t u = 0; u < len; u++)
        {
            int result = value.compare(p1 + u * sz, p2 + u * sz);
            if (result)
                return result;
        }
        return 0;
    }

    override size_t tsize()
    {
	return len * value.tsize();
    }

    override void swap(void *p1, void *p2)
    {	void* tmp;
	size_t sz = value.tsize();
	ubyte[16] buffer;
	void* pbuffer;

	if (sz < buffer.sizeof)
	    tmp = buffer.ptr;
	else
	    tmp = pbuffer = (new void[sz]).ptr;

	for (size_t u = 0; u < len; u += sz)
	{   size_t o = u * sz;
	    memcpy(tmp, p1 + o, sz);
	    memcpy(p1 + o, p2 + o, sz);
	    memcpy(p2 + o, tmp, sz);
	}
	if (pbuffer)
	    delete pbuffer;
    }

    override void[] init() { return value.init(); }
    override TypeInfo next() { return value; }
    override uint flags() { return value.flags(); }

    TypeInfo value;
    size_t len;
}
alias TypeInfo_StaticArray ИнфОТипе_СтатичМассив;

////////////////////////////////////////////////////////////////////////////////////////////
class TypeInfo_AssociativeArray : TypeInfo
{
    override char[] toString()
    {
        return next.toString() ~ "[" ~ key.toString() ~ "]";
    }

    override /*equals_t*/ int opEquals(Object o)
    {
        TypeInfo_AssociativeArray c;
        return this is o ||
                ((c = cast(TypeInfo_AssociativeArray)o) !is null &&
                 this.key == c.key &&
                 this.next == c.next);
    }

    override hash_t getHash(in void* p)
    {
        size_t sz = value.tsize();
        hash_t hash = sz;
        AA aa=*cast(AA*)p;
        size_t keysize=key.tsize();
        int res=_aaApply2(aa, keysize, cast(dg2_t) delegate int(void *k, void *v){
            hash+=rt_hash_combine(key.getHash(k),value.getHash(v));
            return 0;
        });
        return hash;
    }

    override size_t tsize()
    {
        return (char[int]).sizeof;
    }
    override equals_t equals(in void* p1, in void* p2)
    {
        AA a=*cast(AA*)p1;
        AA b=*cast(AA*)p2;
        if (cast(void*)a.a==cast(void*)b.a) return true;
        size_t l1=_aaLen(a);
        size_t l2=_aaLen(b);
        if (l1!=l2) return false;
        size_t keysize=key.tsize();
        equals_t same=true;
        int res=_aaApply2(a, keysize, cast(dg2_t) delegate int(void *k, void *v){
            void* v2=_aaGetRvalue(b, key, value.tsize(), k);
            if (v2 is null || !value.equals(v,v2)) {
                same=false;
                return 1;
            }
            ++l1;
            return 0;
        });
        return same;
    }

    override int compare(in void* p1, in void* p2)
    {
        throw new Exception("non comparable",__FILE__,__LINE__);
    }

   override TypeInfo next() { return value; }
    override uint flags() { return 1; }

    TypeInfo value;
    TypeInfo key;
}
alias TypeInfo_AssociativeArray  ИнфОТипе_АссоцМассив;
////////////////////////////////////////////////////////////////////////////////////////////
class TypeInfo_Function : TypeInfo
{
    override char[] toString()
    {
	return next.toString() ~ "()";
    }

    override int opEquals(Object o)
    {   TypeInfo_Function c;

	return this is o ||
		((c = cast(TypeInfo_Function)o) !is null &&
		 this.next == c.next);
    }

    // BUG: need to add the rest of the functions

    override size_t tsize()
    {
	return 0;	// no size for functions
    }

    TypeInfo next;
}
alias TypeInfo_Function ИнфОТипе_Функция;
/////////////////////////////////////////////////////////////////////////////////////
class TypeInfo_Delegate : TypeInfo
{
    override char[] toString()
    {
	return next.toString() ~ " delegate()";
    }

    override int opEquals(Object o)
    {   TypeInfo_Delegate c;

	return this is o ||
		((c = cast(TypeInfo_Delegate)o) !is null &&
		 this.next == c.next);
    }

    // BUG: need to add the rest of the functions

    override size_t tsize()
    {	alias int delegate() dg;
	return dg.sizeof;
    }

    override uint flags() { return 1; }

    TypeInfo next;
}
alias TypeInfo_Delegate ИнфОТипе_Делегат;
//////////////////////////////////////////////////////////////////////////////////////
class TypeInfo_Class : TypeInfo
{
    override char[] toString() { return info.name; }

    override int opEquals(Object o)
    {   TypeInfo_Class c;

	return this is o ||
		((c = cast(TypeInfo_Class)o) !is null &&
		 this.info.name == c.classinfo.name);
    }

    hash_t getHash(void *p)
    {
	Object o = *cast(Object*)p;
	return o ? o.toHash() : 0;
    }

    int equals(void *p1, void *p2)
    {
	Object o1 = *cast(Object*)p1;
	Object o2 = *cast(Object*)p2;

	return (o1 is o2) || (o1 && o1.opEquals(o2));
    }

    int compare(void *p1, void *p2)
    {
	Object o1 = *cast(Object*)p1;
	Object o2 = *cast(Object*)p2;
	int c = 0;

	// Regard null references as always being "less than"
	if (o1 !is o2)
	{
	    if (o1)
	    {	if (!o2)
		    c = 1;
		else
		    c = o1.opCmp(o2);
	    }
	    else
		c = -1;
	}
	return c;
    }

    override size_t tsize()
    {
	return Object.sizeof;
    }

    override uint flags() { return 1; }

    override OffsetTypeInfo[] offTi()
    {
	return (info.flags & 4) ? info.offTi : null;
    }

    ClassInfo info;
}
alias TypeInfo_Class ИнфОТип_Класс;
///////////////////////////////////////////////////////////////////////////////////////////
class TypeInfo_Interface : TypeInfo
{
    override char[] toString() { return info.name; }

    override int opEquals(Object o)
    {   TypeInfo_Interface c;

	return this is o ||
		((c = cast(TypeInfo_Interface)o) !is null &&
		 this.info.name == c.classinfo.name);
    }

    hash_t getHash(void *p)
    {
	Interface* pi = **cast(Interface ***)*cast(void**)p;
	Object o = cast(Object)(*cast(void**)p - pi.offset);
	assert(o);
	return o.toHash();
    }

    int equals(void *p1, void *p2)
    {
	Interface* pi = **cast(Interface ***)*cast(void**)p1;
	Object o1 = cast(Object)(*cast(void**)p1 - pi.offset);
	pi = **cast(Interface ***)*cast(void**)p2;
	Object o2 = cast(Object)(*cast(void**)p2 - pi.offset);

	return o1 == o2 || (o1 && o1.opCmp(o2) == 0);
    }

    int compare(void *p1, void *p2)
    {
	Interface* pi = **cast(Interface ***)*cast(void**)p1;
	Object o1 = cast(Object)(*cast(void**)p1 - pi.offset);
	pi = **cast(Interface ***)*cast(void**)p2;
	Object o2 = cast(Object)(*cast(void**)p2 - pi.offset);
	int c = 0;

	// Regard null references as always being "less than"
	if (o1 != o2)
	{
	    if (o1)
	    {	if (!o2)
		    c = 1;
		else
		    c = o1.opCmp(o2);
	    }
	    else
		c = -1;
	}
	return c;
    }

    override size_t tsize()
    {
	return Object.sizeof;
    }

    override uint flags() { return 1; }

    ClassInfo info;
}
alias TypeInfo_Interface ИнфОТипе_Интерфейс;
///////////////////////////////////////////////////////////////////////////////////
class TypeInfo_Struct : TypeInfo
{
    override char[] toString() { return name; }

    override int opEquals(Object o)
    {   TypeInfo_Struct s;

	return this is o ||
		((s = cast(TypeInfo_Struct)o) !is null &&
		 this.name == s.name &&
		 this.init.length == s.init.length);
    }

    hash_t getHash(void *p)
    {	hash_t h;

	assert(p);
	if (xtoHash)
	{   //printf("getHash() using xtoHash\n");
	    h = (*xtoHash)(p);
	}
	else
	{
	    //printf("getHash() using default hash\n");
	    // A sorry hash algorithm.
	    // Should use the one for strings.
	    // BUG: relies on the GC not moving objects
	    for (size_t i = 0; i < init.length; i++)
	    {	h = h * 9 + *cast(ubyte*)p;
		p++;
	    }
	}
	return h;
    }

    int equals(void *p1, void *p2)
    {	int c;

	if (p1 == p2)
	    c = 1;
	else if (!p1 || !p2)
	    c = 0;
	else if (xopEquals)
	    c = (*xopEquals)(p1, p2);
	else
	    // BUG: relies on the GC not moving objects
	    c = (memcmp(p1, p2, init.length) == 0);
	return c;
    }

    int compare(void *p1, void *p2)
    {
	int c = 0;

	// Regard null references as always being "less than"
	if (p1 != p2)
	{
	    if (p1)
	    {	if (!p2)
		    c = 1;
		else if (xopCmp)
		    c = (*xopCmp)(p2, p1);
		else
		    // BUG: relies on the GC not moving objects
		    c = memcmp(p1, p2, init.length);
	    }
	    else
		c = -1;
	}
	return c;
    }

    override size_t tsize()
    {
	return init.length;
    }

    override void[] init() { return m_init; }

    override uint flags() { return m_flags; }

    char[] name;
    void[] m_init;	// initializer; init.ptr == null if 0 initialize

    hash_t function(void*) xtoHash;
    int function(void*,void*) xopEquals;
    int function(void*,void*) xopCmp;
    char[] function(void*) xtoString;

    uint m_flags;
}
alias TypeInfo_Struct ИнфОТипе_Структ;
/////////////////////////////////////////////////////////////////////////////
class TypeInfo_Tuple : TypeInfo
{
    TypeInfo[] elements;

    override char[] toString()
    {
	char[] s;
	s = "(";
	foreach (i, element; elements)
	{
	    if (i)
		s ~= ',';
	    s ~= element.toString();
	}
	s ~= ")";
        return s;
    }

    override int opEquals(Object o)
    {
	if (this is o)
	    return 1;

	auto t = cast(TypeInfo_Tuple)o;
	if (t && elements.length == t.elements.length)
	{
	    for (size_t i = 0; i < elements.length; i++)
	    {
		if (elements[i] != t.elements[i])
		    return 0;
	    }
	    return 1;
	}
	return 0;
    }

    hash_t getHash(void *p)
    {
        assert(0);
    }

    int equals(void *p1, void *p2)
    {
        assert(0);
    }

    int compare(void *p1, void *p2)
    {
        assert(0);
    }

    override size_t tsize()
    {
        assert(0);
    }

    override void swap(void *p1, void *p2)
    {
        assert(0);
    }
}
alias TypeInfo_Tuple ИнфОТипе_Кортеж;
//////////////////////////////////////////////////////////////////////////////
class TypeInfo_Const : TypeInfo
{
    override char[] toString() { return "const " ~ base.toString(); }

    override int opEquals(Object o) { return base.opEquals(o); }
    hash_t getHash(void *p) { return base.getHash(p); }
    int equals(void *p1, void *p2) { return base.equals(p1, p2); }
    int compare(void *p1, void *p2) { return base.compare(p1, p2); }
    override size_t tsize() { return base.tsize(); }
    override void swap(void *p1, void *p2) { return base.swap(p1, p2); }

    override TypeInfo next() { return base.next(); }
    override uint flags() { return base.flags(); }
    override void[] init() { return base.init(); }

    TypeInfo base;
}
alias TypeInfo_Const ИнфОТипе_Конст;
///////////////////////////////////////////////////////////////////
class TypeInfo_Invariant : TypeInfo_Const
{
    override char[] toString() { return "invariant " ~ base.toString(); }
}
alias TypeInfo_Invariant ИнфОТипе_Инвариант;
/////////////////////////////////////////////////////////////////////////////

/**
 * All irrecoverable exceptions should be derived from class Error.
 */
 
 class Exception : Object
{
    struct FrameInfo{
        long line;
        size_t iframe;
        ptrdiff_t offsetSymb;
        size_t baseSymb;
        ptrdiff_t offsetImg;
        size_t baseImg;
        size_t address;
        char[] file;
        char[] func;
        char[] extra;
        bool exactAddress;
        bool internalFunction;
        alias void function(FrameInfo*,void delegate(char[])) FramePrintHandler;
        static FramePrintHandler defaultFramePrintingFunction;
        void writeOut(void delegate(char[])sink){

            if (defaultFramePrintingFunction){
                defaultFramePrintingFunction(this,sink);
            } else {
                char[26] buf;
                //auto len=snprintf(buf.ptr,26,"[%8zx]",address);
                //sink(buf[0..len]);
                //len=snprintf(buf.ptr,26,"%8zx",baseImg);
                //sink(buf[0..len]);
                //len=snprintf(buf.ptr,26,"%+td ",offsetImg);
                //sink(buf[0..len]);
                //while (++len<6) sink(" ");
                if (func.length) {
                    sink(func);
                } else {
                    sink("???");
                }
                for (size_t i=func.length;i<80;++i) sink(" ");
                //len=snprintf(buf.ptr,26," @%zx",baseSymb);
                //sink(buf[0..len]);
                //len=snprintf(buf.ptr,26,"%+td ",offsetSymb);
                //sink(buf[0..len]);
                if (extra.length){
                    sink(extra);
                    sink(" ");
                }
                sink(file);
                sink(":");
                sink(rt.core.string.ulongToUtf8(buf, cast(ulong) line));
            }
        }
        
        void clear(){
            line=0;
            iframe=-1;
            offsetImg=0;
            baseImg=0;
            offsetSymb=0;
            baseSymb=0;
            address=0;
            exactAddress=true;
            internalFunction=false;
            file=null;
            func=null;
            extra=null;
        }
    }
    interface TraceInfo
    {
        int opApply( int delegate( inout FrameInfo fInfo ) );
        void writeOut(void delegate(char[])sink);
    }

    char[]      msg;
    char[]      file;
    size_t      line;  // long would be better
    TraceInfo   info;
    Exception   next;
 
    this( char[] msg, char[] file, long line, Exception next, TraceInfo info )
    {
        // main constructor, breakpoint this if you want...
        this.msg = msg;
        this.next = next;
        this.file = file;
        this.line = cast(size_t)line;
        this.info = info;
    }

    this( char[] msg, Exception next=null )
    {
		
        this(msg,"",0,next,rt_createTraceContext(null));
    }

    this( char[] msg, char[] file, long line, Exception next=null )
    {		
        this(msg,file,line,next,rt_createTraceContext(null));
    }
	
	 override void print()
    {
	printf("%.*s\n", toString());
    }
	
    override char[] toString()
    {
        return msg;
    }
    void writeOutMsg(void delegate(char[])sink){
        sink(toString());
    }
    void writeOut(void delegate(char[])sink){
        if (file.length>0 || line!=0)
        {
            char[25]buf;
            sink(this.classinfo.name);
            sink("@");
            sink(file);
            sink("(");
            sink(rt.core.string.ulongToUtf8(buf, line));
            sink("): ");
            writeOutMsg(sink);
            sink("\n");
        }
        else
        {
           sink(this.classinfo.name);
           sink(": ");
           writeOutMsg(sink);
           sink("\n");
        }
        if (info)
        {
            sink("----------------\n");
            info.writeOut(sink);
        }
        if (next){
            sink("\n++++++++++++++++\n");
            next.writeOut(sink);
        }
    }
}
alias Exception Исключение;

alias Exception.TraceInfo function( void* ptr = null ) TraceHandler;
private TraceHandler traceHandler = null;

class Error : Exception
{
    Error next;
	char[] msg;
	
	 override void print()
    {
	printf("%.*s\n", toString());
    }
	
	override char[] toString() { return msg; }
    /**
     * Constructor; msg is a descriptive message for the exception.
     */
	this(char[] msg){     
	super(msg, next);
	this.msg = msg;	
	this.next = next;
    }

    this(char[] msg, Error next)
    {	
	super(msg, cast(Exception)next);
	this.msg = msg;
	this.next = next;
    }
}

alias Error Ошибка;
	/**
	 * Overrides the default trace hander with a user-supplied version.
	 *
	 * Параметры:
	 *  h = The new trace handler.  Set to null to use the default handler.
	 */
	  extern (C) void  rt_setTraceHandler( TraceHandler h )
	{
		traceHandler = h;
	}

	/**
	 * This function will be called when an Exception is constructed.  The
	 * user-supplied trace handler will be called if one has been supplied,
	 * otherwise no trace will be generated.
	 *
	 * Параметры:
	 *  ptr = A pointer to the location from which to generate the trace, or null
	 *        if the trace should be generated from within the trace handler
	 *        itself.
	 *
	 * Возвращает:
	 *  An object describing the current calling context or null if no handler is
	 *  supplied.
	 */
  extern (C) Exception.TraceInfo rt_createTraceContext( void* ptr ){
		if( traceHandler is null )
			return null;
		return traceHandler( ptr );
	}

alias Object.Monitor        IMonitor;
alias void delegate(Object) DEvent;

/* *************************
 * Internal struct pointed to by the hidden .monitor member.
 */
struct Monitor
{
    void delegate(Object)[] delegates;

    /* More stuff goes here defined by internal/monitor.c */
	IMonitor impl;
    /* internal */
    DEvent[] devt;
    /* stuff */
}
alias Monitor Монитор;



Monitor* getMonitor(Object h)
{
    return cast(Monitor*) (cast(void**) h)[1];
}

void setMonitor(Object h, Monitor* m)
{
    (cast(void**) h)[1] = m;
}

extern  (C) void _d_monitor_create(Object);
extern  (C) void _d_monitor_destroy(Object);
extern  (C) void _d_monitor_lock(Object);
extern  (C) int  _d_monitor_unlock(Object);


  extern (C) void _d_monitordelete(Object h, bool det)
	{
		Monitor* m = getMonitor(h);

		if (m !is null)
		{
			IMonitor i = m.impl;
			if (i is null)
			{
				_d_monitor_devt(m, h);
				_d_monitor_destroy(h);
				setMonitor(h, null);
				return;
			}
			if (det && (cast(void*) i) !is (cast(void*) h))
				delete i;
			setMonitor(h, null);
		}
	}

	  extern (C) void _d_monitorenter(Object h)
	{
		Monitor* m = getMonitor(h);

		if (m is null)
		{
			_d_monitor_create(h);
			m = getMonitor(h);
		}

		IMonitor i = m.impl;

		if (i is null)
		{
			_d_monitor_lock(h);
			return;
		}
		i.lock();
	}

	 extern (C) void _d_monitorexit(Object h)
	{
		Monitor* m = getMonitor(h);
		IMonitor i = m.impl;

		if (i is null)
		{
			_d_monitor_unlock(h);
			return;
		}
		i.unlock();
	}

	  extern (C) void _d_monitor_devt(Monitor* m, Object h)
	{
		if (m.devt.length)
		{
			DEvent[] devt;

			synchronized (h)
			{
				devt = m.devt;
				m.devt = null;
			}
			foreach (v; devt)
			{
				if (v)
					v(h);
			}
			free(devt.ptr);
		}
	}
  extern (C) void rt_attachDisposeEvent(Object h, DEvent e)
	{
		synchronized (h)
		{
			Monitor* m = getMonitor(h);
			IMonitor i = m.impl;
			assert(i is null);

			foreach (inout v; m.devt)
			{
				if (v is null || v == e)
				{
					v = e;
					return;
				}
			}

			auto len = m.devt.length + 4; // grow by 4 elements
			auto pos = m.devt.length;     // insert position
			auto p = realloc(m.devt.ptr, DEvent.sizeof * len);
			if (!p)
				onOutOfMemoryError();
			m.devt = (cast(DEvent*)p)[0 .. len];
			m.devt[pos+1 .. len] = null;
			m.devt[pos] = e;
		}
	}

  extern (C) void rt_detachDisposeEvent(Object h, DEvent e)
	{
		synchronized (h)
		{
			Monitor* m = getMonitor(h);
			IMonitor i = m.impl;
			assert(i is null);

			foreach (p, v; m.devt)
			{
				if (v == e)
				{
					memmove(&m.devt[p],
							&m.devt[p+1],
							(m.devt.length - p - 1) * DEvent.sizeof);
					return;
				}
			}
		}
	}


//extern  (C) int nullext = 0;

// Written in the D programming language

//module rt.core.moduleinit;

//debug = 1;

private
{
    //import object;
   // import  rt.core.io;
    //import rt.core.c;
    import rt.core.string;
}

enum
{   MIctorstart = 1,	// we've started constructing it
    MIctordone = 2,	// finished construction
    MIstandalone = 4,	// module ctor does not depend on other module
			// ctors being done first
    MIhasictor = 8,	// has ictor member
}

/***********************
 * Information about each module.
 */
class ModuleInfo
{
    char name[];
    ModuleInfo importedModules[];
    ClassInfo localClasses[];

    uint flags;		// initialization state

    void function() ctor;       // module static constructor (order dependent)
    void function() dtor;       // module static destructor
    void function() unitTest;
	/*void (*ctor)();	// module static constructor (order dependent)
	  void (*dtor)();	// module static destructor
        void (*unitTest)();	// module unit tests*/

    void* xgetMembers;	// module getMembers() function

    void function() ictor;//void (*ictor)();	// module static constructor (order independent)

	static int opApply( int delegate( ref ModuleInfo ) dg )
    {
        int ret = 0;

        foreach( m; _moduleinfo_array )
        {
            ret = dg( m );
            if( ret )
                break;
        }
        return ret;
    }
    /******************
     * Return collection of all modules in the program.
     */
    static ModuleInfo[] modules()
    {
	return _moduleinfo_array;
    }
}

class ModuleCtorError : Exception
{
    this(ModuleInfo m)
    {
	super(cast(string) ("circular initialization dependency with module "
                            ~ m.name));
    }
}


// Win32: this gets initialized by minit.asm
// linux: this gets initialized in _moduleCtor()
// OSX: this gets initialized in _moduleCtor()
extern  (C) ModuleInfo[] _moduleinfo_array;

version (linux)
{
    // This linked list is created by a compiler generated function inserted
    // into the .ctor list by the compiler.
    struct ModuleReference
    {
	ModuleReference* next;
	ModuleInfo mod;
    }

    extern  (C) ModuleReference *_Dmodule_ref;	// start of linked list
}

version (FreeBSD)
{
    // This linked list is created by a compiler generated function inserted
    // into the .ctor list by the compiler.
    struct ModuleReference
    {
	ModuleReference* next;
	ModuleInfo mod;
    }

    extern  (C) ModuleReference *_Dmodule_ref;	// start of linked list
}

version (Solaris)
{
    // This linked list is created by a compiler generated function inserted
    // into the .ctor list by the compiler.
    struct ModuleReference
    {
       ModuleReference* next;
       ModuleInfo mod;
    }

    extern  (C) ModuleReference *_Dmodule_ref;  // start of linked list
}

version (OSX)
{
    extern  (C)
    {
	extern  void* _minfo_beg;
	extern  void* _minfo_end;
    }
}

ModuleInfo[] _moduleinfo_dtors;
uint _moduleinfo_dtors_i;

// Register termination function pointers
extern  (C) int _fatexit(void *);

/*************************************
 * Initialize the modules.
 */
 
  extern (C) void _moduleCtor()
{
    debug printf("_moduleCtor()\n");

    version (linux)
    {
	int len = 0;
	ModuleReference *mr;

	for (mr = _Dmodule_ref; mr; mr = mr.next)
	    len++;
	_moduleinfo_array = new ModuleInfo[len];
	len = 0;
	for (mr = _Dmodule_ref; mr; mr = mr.next)
	{   _moduleinfo_array[len] = mr.mod;
	    len++;
	}
    }

    version (FreeBSD)
    {
	int len = 0;
	ModuleReference *mr;

	for (mr = _Dmodule_ref; mr; mr = mr.next)
	    len++;
	_moduleinfo_array = new ModuleInfo[len];
	len = 0;
	for (mr = _Dmodule_ref; mr; mr = mr.next)
	{   _moduleinfo_array[len] = mr.mod;
	    len++;
	}
    }

    version (Solaris)
    {
       int len = 0;
       ModuleReference *mr;

       for (mr = _Dmodule_ref; mr; mr = mr.next)
           len++;
       _moduleinfo_array = new ModuleInfo[len];
       len = 0;
       for (mr = _Dmodule_ref; mr; mr = mr.next)
       {   _moduleinfo_array[len] = mr.mod;
           len++;
       }
    }

    version (OSX)
    {	/* The ModuleInfo references are stored in the special segment
	 * __minfodata, which is bracketed by the segments __minfo_beg
	 * and __minfo_end. The variables _minfo_beg and _minfo_end
	 * are of zero size and are in the two bracketing segments,
	 * respectively.
	 */
	size_t length = cast(ModuleInfo*)&_minfo_end - cast(ModuleInfo*)&_minfo_beg;
	_moduleinfo_array = (cast(ModuleInfo*)&_minfo_beg)[0 .. length];
	debug printf("moduleinfo: ptr = %p, length = %d\n", _moduleinfo_array.ptr, _moduleinfo_array.length);

	debug foreach (m; _moduleinfo_array)
	{
	    //printf("\t%p\n", m);
	    printf("\t%.*s\n", m.name);
	}
    }

    version (Win32)
    {
	// Ensure module destructors also get called on program termination
	//_fatexit(&_STD_moduleDtor);
    }

    _moduleinfo_dtors = new ModuleInfo[_moduleinfo_array.length];
    debug printf("_moduleinfo_dtors = x%x\n", cast(void *)_moduleinfo_dtors);
    _moduleIndependentCtors();
    _moduleCtor2(_moduleinfo_array, 0);

    version (none)
    {
	foreach (m; _moduleinfo_array)
	{
	    writefln("module %s, %d", m.name, m.localClasses.length);
	    foreach (c; m.localClasses)
	    {
		writefln("\tclass %s", c.name);
	    }
	}
    }
}

void _moduleCtor2(ModuleInfo[] mi, int skip)
{
    debug printf("_moduleCtor2(): %d modules\n", mi.length);
    for (uint i = 0; i < mi.length; i++)
    {
	ModuleInfo m = mi[i];

	debug printf("\tmodule[%d] = '%p'\n", i, m);
	if (!m)
	    continue;
	debug printf("\tmodule[%d] = '%.*s'\n", i, m.name);
	if (m.flags & MIctordone)
	    continue;
	debug printf("\tmodule[%d] = '%.*s', m = x%x, m.flags = x%x\n", i, m.name, m, m.flags);

	if (m.ctor || m.dtor)
	{
	    if (m.flags & MIctorstart)
	    {	if (skip || m.flags & MIstandalone)
		    continue;
		throw new ModuleCtorError(m);
	    }

	    m.flags |= MIctorstart;
	    _moduleCtor2(m.importedModules, 0);
	    if (m.ctor)
		(*m.ctor)();
	    m.flags &= ~MIctorstart;
	    m.flags |= MIctordone;

	    // Now that construction is done, register the destructor
	    //printf("\tadding module dtor x%x\n", m);
	    assert(_moduleinfo_dtors_i < _moduleinfo_dtors.length);
	    _moduleinfo_dtors[_moduleinfo_dtors_i++] = m;
	}
	else
	{
	    m.flags |= MIctordone;
	    _moduleCtor2(m.importedModules, 1);
	}
    }
}


/**********************************
 * Destruct the modules.
 */

// Starting the name with "_STD" means under linux a pointer to the
// function gets put in the .dtors segment.

  extern (C) void _moduleDtor()
	{
		debug printf("_moduleDtor(): %d modules\n", _moduleinfo_dtors_i);
		for (uint i = _moduleinfo_dtors_i; i-- != 0;)
		{
		ModuleInfo m = _moduleinfo_dtors[i];

		debug printf("\tmodule[%d] = '%.*s', x%x\n", i, m.name, m);
		if (m.dtor)
		{
			(*m.dtor)();
		}
		}
		debug printf("_moduleDtor() done\n");
	}

	/**********************************
	 * Run unit tests.
	 */

	  extern (C) void _moduleUnitTests()
	{
		debug printf("_moduleUnitTests()\n");
		for (uint i = 0; i < _moduleinfo_array.length; i++)
		{
		ModuleInfo m = _moduleinfo_array[i];

		if (!m)
			continue;

		debug printf("\tmodule[%d] = '%.*s'\n", i, m.name);
		if (m.unitTest)
		{
			(*m.unitTest)();
		}
		}
	}

	/**********************************
	 * Run unit tests.
	 */

	 extern (C) void _moduleIndependentCtors()
	{
		debug printf("_moduleIndependentCtors()\n");
		foreach (m; _moduleinfo_array)
		{
		if (m && m.flags & MIhasictor && m.ictor)
		{
			(*m.ictor)();
		}
		}
	}



