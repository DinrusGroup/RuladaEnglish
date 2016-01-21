module rt.typeinfo;
import rt.hash, rt.core.c;
import std.string;

// Object[]

class TypeInfo_AC : TypeInfo_Array
{
    override hash_t getHash(in void* p)
    {   Object[] s = *cast(Object[]*)p;
        hash_t hash = 0;

        foreach (Object o; s)
        {
            if (o){
                hash = rt_hash_combine(o.toHash(),hash);
            } else {
                hash = rt_hash_combine(cast(hash_t)0xdeadbeef,hash);
            }
        }
        return hash;
    }

    override int equals(in void* p1, in void* p2)
    {
        Object[] s1 = *cast(Object[]*)p1;
        Object[] s2 = *cast(Object[]*)p2;

        if (s1.length == s2.length)
        {
            for (size_t u = 0; u < s1.length; u++)
            {   Object o1 = s1[u];
                Object o2 = s2[u];

                // Do not pass null's to Object.opEquals()
                if (o1 is o2 ||
                    (!(o1 is null) && !(o2 is null) && o1.opEquals(o2)))
                    continue;
                return false;
            }
            return true;
        }
        return false;
    }

    override int compare(in void* p1, in void* p2)
    {
        Object[] s1 = *cast(Object[]*)p1;
        Object[] s2 = *cast(Object[]*)p2;
        ptrdiff_t c;

        c = cast(ptrdiff_t)s1.length - cast(ptrdiff_t)s2.length;
        if (c == 0)
        {
            for (size_t u = 0; u < s1.length; u++)
            {   Object o1 = s1[u];
                Object o2 = s2[u];

                if (o1 is o2)
                    continue;

                // Regard null references as always being "less than"
                if (o1)
                {
                    if (!o2)
                    {   c = 1;
                        break;
                    }
                    c = o1.opCmp(o2);
                    if (c)
                        break;
                }
                else
                {   c = -1;
                    break;
                }
            }
        }
        if (c < 0)
            c = -1;
        else if (c > 0)
            c = 1;
        return 0;
    }

    override size_t tsize()
    {
        return (Object[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(Object);
    }
}

//////////////////////////////////
// cdouble[]

class TypeInfo_Ar : TypeInfo_Array
{
    override char[] toString() { return "cdouble[]"; }

    override hash_t getHash(in void* p) {
        cdouble[] s = *cast(cdouble[]*)p;
        size_t len = s.length;
        cdouble *str = s.ptr;
        return rt_hash_str(str,len*cdouble.sizeof,0);
    }

    override int equals(in void* p1, in void* p2)
    {
        cdouble[] s1 = *cast(cdouble[]*)p1;
        cdouble[] s2 = *cast(cdouble[]*)p2;
        size_t len = s1.length;

        if (len != s2.length)
            return false;
        for (size_t u = 0; u < len; u++)
        {
            if (!TypeInfo_r._equals(s1[u], s2[u]))
                return false;
        }
        return true;
    }

    override int compare(in void* p1, in void* p2)
    {
        cdouble[] s1 = *cast(cdouble[]*)p1;
        cdouble[] s2 = *cast(cdouble[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int c = TypeInfo_r._compare(s1[u], s2[u]);
            if (c)
                return c;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (cdouble[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(cdouble);
    }
}
//////////////////////////////////

// cfloat[]

class TypeInfo_Aq : TypeInfo_Array
{
    override char[] toString() { return "cfloat[]"; }

    override hash_t getHash(in void* p) {
        cfloat[] s = *cast(cfloat[]*)p;
        size_t len = s.length;
        cfloat *str = s.ptr;
        return rt_hash_str(str,len*cfloat.sizeof,0);
    }

    override int equals(in void* p1, in void* p2)
    {
        cfloat[] s1 = *cast(cfloat[]*)p1;
        cfloat[] s2 = *cast(cfloat[]*)p2;
        size_t len = s1.length;

        if (len != s2.length)
            return false;
        for (size_t u = 0; u < len; u++)
        {
            if (!TypeInfo_q._equals(s1[u], s2[u]))
                return false;
        }
        return true;
    }

    override int compare(in void* p1, in void* p2)
    {
        cfloat[] s1 = *cast(cfloat[]*)p1;
        cfloat[] s2 = *cast(cfloat[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int c = TypeInfo_q._compare(s1[u], s2[u]);
            if (c)
                return c;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (cfloat[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(cfloat);
    }
}
/////////////////////////////////////

// creal[]

class TypeInfo_Ac : TypeInfo_Array
{
    override char[] toString() { return "creal[]"; }

    override hash_t getHash(in void* p){
        creal[] s = *cast(creal[]*)p;
        size_t len = s.length;
        creal *str = s.ptr;
        return rt_hash_str(str,len*creal.sizeof,0);
    }

    override int equals(in void* p1, in void* p2)
    {
        creal[] s1 = *cast(creal[]*)p1;
        creal[] s2 = *cast(creal[]*)p2;
        size_t len = s1.length;

        if (len != s2.length)
            return 0;
        for (size_t u = 0; u < len; u++)
        {
            if (!TypeInfo_c._equals(s1[u], s2[u]))
                return false;
        }
        return true;
    }

    override int compare(in void* p1, in void* p2)
    {
        creal[] s1 = *cast(creal[]*)p1;
        creal[] s2 = *cast(creal[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int c = TypeInfo_c._compare(s1[u], s2[u]);
            if (c)
                return c;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (creal[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(creal);
    }
}
/////////////////////////////////////////////

// double[]

class TypeInfo_Ad : TypeInfo_Array
{
    override char[] toString() { return "double[]"; }

    override hash_t getHash(in void* p){
        double[] s = *cast(double[]*)p;
        size_t len = s.length;
        auto str = s.ptr;
        return rt_hash_str(str,len*double.sizeof,0); // use rt_hash_block?
    }

    override int equals(in void* p1, in void* p2)
    {
        double[] s1 = *cast(double[]*)p1;
        double[] s2 = *cast(double[]*)p2;
        size_t len = s1.length;

        if (len != s2.length)
            return 0;
        for (size_t u = 0; u < len; u++)
        {
            if (!TypeInfo_d._equals(s1[u], s2[u]))
                return false;
        }
        return true;
    }

    override int compare(in void* p1, in void* p2)
    {
        double[] s1 = *cast(double[]*)p1;
        double[] s2 = *cast(double[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int c = TypeInfo_d._compare(s1[u], s2[u]);
            if (c)
                return c;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (double[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(double);
    }
}

// idouble[]

class TypeInfo_Ap : TypeInfo_Ad
{
    char[] toString() { return "idouble[]"; }

    override TypeInfo next()
    {
        return typeid(idouble);
    }
}
//////////////////////////////////////

// float[]

class TypeInfo_Af : TypeInfo_Array
{
    override char[] toString() { return "float[]"; }

    override hash_t getHash(in void* p){
        float[] s = *cast(float[]*)p;
        size_t len = s.length;
        auto str = s.ptr;
        return rt_hash_str(str,len*float.sizeof,0);
    }

    override int equals(in void* p1, in void* p2)
    {
        float[] s1 = *cast(float[]*)p1;
        float[] s2 = *cast(float[]*)p2;
        size_t len = s1.length;

        if (len != s2.length)
            return 0;
        for (size_t u = 0; u < len; u++)
        {
            if (!TypeInfo_f._equals(s1[u], s2[u]))
                return false;
        }
        return true;
    }

    override int compare(in void* p1, in void* p2)
    {
        float[] s1 = *cast(float[]*)p1;
        float[] s2 = *cast(float[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int c = TypeInfo_f._compare(s1[u], s2[u]);
            if (c)
                return c;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (float[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(float);
    }
}

// ifloat[]

class TypeInfo_Ao : TypeInfo_Af
{
    override char[] toString() { return "ifloat[]"; }

    override TypeInfo next()
    {
        return typeid(ifloat);
    }
}
///////////////////////////////////

// byte[]

class TypeInfo_Ag : TypeInfo_Array
{
    override char[] toString() { return "byte[]"; }

    override hash_t getHash(in void* p) {
        byte[] s = *cast(byte[]*)p;
        size_t len = s.length;
        byte *str = s.ptr;
        return rt_hash_str(str,len*byte.sizeof,0);
    }

    override int equals(in void* p1, in void* p2)
    {
        byte[] s1 = *cast(byte[]*)p1;
        byte[] s2 = *cast(byte[]*)p2;

        return s1.length == s2.length &&
               memcmp(cast(byte *)s1, cast(byte *)s2, s1.length) == 0;
    }

    override int compare(in void* p1, in void* p2)
    {
        byte[] s1 = *cast(byte[]*)p1;
        byte[] s2 = *cast(byte[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int result = s1[u] - s2[u];
            if (result)
                return result;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (byte[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(byte);
    }
}


// ubyte[]

class TypeInfo_Ah : TypeInfo_Ag
{
    override char[] toString() { return "ubyte[]"; }

    override int compare(in void* p1, in void* p2)
    {
        char[] s1 = *cast(char[]*)p1;
        char[] s2 = *cast(char[]*)p2;

        return stringCompare(s1, s2);
    }

    override TypeInfo next()
    {
        return typeid(ubyte);
    }
}

// void[]

class TypeInfo_Av : TypeInfo_Ah
{
    override char[] toString() { return "void[]"; }

    override TypeInfo next()
    {
        return typeid(void);
    }
}

// bool[]

class TypeInfo_Ab : TypeInfo_Ah
{
    override char[] toString() { return "bool[]"; }

    override TypeInfo next()
    {
        return typeid(bool);
    }
}

// char[]

class TypeInfo_Aa : TypeInfo_Ag
{
    override char[] toString() { return "char[]"; }

    override hash_t getHash(in void* p){
        char[] s = *cast(char[]*)p;
        version (OldHash)
        {
            hash_t hash = 0;
            foreach (char c; s)
                hash = hash * 11 + c;
            return hash;
        } else {
            //return rt_hash_utf8(s,0); // this would be encoding independent
            return rt_hash_str(s.ptr,s.length,0);
        }
    }

    override TypeInfo next()
    {
        return typeid(char);
    }
}
////////////////////////////////////

// int[]

class TypeInfo_Ai : TypeInfo_Array
{
    override char[] toString() { return "int[]"; }

    override hash_t getHash(in void* p)
    {   int[] s = *cast(int[]*)p;
        auto len = s.length;
        auto str = s.ptr;
        return rt_hash_str(str,len*int.sizeof,0);
    }

    override int equals(in void* p1, in void* p2)
    {
        int[] s1 = *cast(int[]*)p1;
        int[] s2 = *cast(int[]*)p2;

        return s1.length == s2.length &&
               memcmp(cast(void *)s1, cast(void *)s2, s1.length * int.sizeof) == 0;
    }

    override int compare(in void* p1, in void* p2)
    {
        int[] s1 = *cast(int[]*)p1;
        int[] s2 = *cast(int[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int result = s1[u] - s2[u];
            if (result)
                return result;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (int[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(int);
    }
}

unittest
{
    int[][] a = [[5,3,8,7], [2,5,3,8,7]];
    a.sort;
    assert(a == [[2,5,3,8,7], [5,3,8,7]]);

    a = [[5,3,8,7], [5,3,8]];
    a.sort;
    assert(a == [[5,3,8], [5,3,8,7]]);
}

// uint[]

class TypeInfo_Ak : TypeInfo_Ai
{
    override char[] toString() { return "uint[]"; }

    override int compare(in void* p1, in void* p2)
    {
        uint[] s1 = *cast(uint[]*)p1;
        uint[] s2 = *cast(uint[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int result = s1[u] - s2[u];
            if (result)
                return result;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override TypeInfo next()
    {
        return typeid(uint);
    }
}

// dchar[]

class TypeInfo_Aw : TypeInfo_Ak
{
    override char[] toString() { return "dchar[]"; }

    override TypeInfo next()
    {
        return typeid(dchar);
    }
}
///////////////////////////////////

// long[]

class TypeInfo_Al : TypeInfo_Array
{
    override char[] toString() { return "long[]"; }

    override hash_t getHash(in void* p)
    {   long[] s = *cast(long[]*)p;
        size_t len = s.length;
        auto str = s.ptr;
        return rt_hash_str(str,len*long.sizeof,0);
    }

    override int equals(in void* p1, in void* p2)
    {
        long[] s1 = *cast(long[]*)p1;
        long[] s2 = *cast(long[]*)p2;

        return s1.length == s2.length &&
               memcmp(cast(void *)s1, cast(void *)s2, s1.length * long.sizeof) == 0;
    }

    override int compare(in void* p1, in void* p2)
    {
        long[] s1 = *cast(long[]*)p1;
        long[] s2 = *cast(long[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            if (s1[u] < s2[u])
                return -1;
            else if (s1[u] > s2[u])
                return 1;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (long[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(long);
    }
}


// ulong[]

class TypeInfo_Am : TypeInfo_Al
{
    override char[] toString() { return "ulong[]"; }

    override int compare(in void* p1, in void* p2)
    {
        ulong[] s1 = *cast(ulong[]*)p1;
        ulong[] s2 = *cast(ulong[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            if (s1[u] < s2[u])
                return -1;
            else if (s1[u] > s2[u])
                return 1;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override TypeInfo next()
    {
        return typeid(ulong);
    }
}
//////////////////////////////////////////////

// real[]

class TypeInfo_Ae : TypeInfo_Array
{
    override char[] toString() { return "real[]"; }

    override hash_t getHash(in void* p)
    {   real[] s = *cast(real[]*)p;
        size_t len = s.length;
        auto str = s.ptr;
        return rt_hash_str(str,len*real.sizeof,0);
    }

    override int equals(in void* p1, in void* p2)
    {
        real[] s1 = *cast(real[]*)p1;
        real[] s2 = *cast(real[]*)p2;
        size_t len = s1.length;

        if (len != s2.length)
            return false;
        for (size_t u = 0; u < len; u++)
        {
            if (!TypeInfo_e._equals(s1[u], s2[u]))
                return false;
        }
        return true;
    }

    override int compare(in void* p1, in void* p2)
    {
        real[] s1 = *cast(real[]*)p1;
        real[] s2 = *cast(real[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int c = TypeInfo_e._compare(s1[u], s2[u]);
            if (c)
                return c;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (real[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(real);
    }
}

// ireal[]

class TypeInfo_Aj : TypeInfo_Ae
{
    override char[] toString() { return "ireal[]"; }

    override TypeInfo next()
    {
        return typeid(ireal);
    }
}
////////////////////////////////////////

// short[]

class TypeInfo_As : TypeInfo_Array
{
    override char[] toString() { return "short[]"; }

    override hash_t getHash(in void* p)
    {   short[] s = *cast(short[]*)p;
        size_t len = s.length;
        short *str = s.ptr;
        return rt_hash_str(str,len*short.sizeof,0);
    }

    override int equals(in void* p1, in void* p2)
    {
        short[] s1 = *cast(short[]*)p1;
        short[] s2 = *cast(short[]*)p2;

        return s1.length == s2.length &&
               memcmp(cast(void *)s1, cast(void *)s2, s1.length * short.sizeof) == 0;
    }

    override int compare(in void* p1, in void* p2)
    {
        short[] s1 = *cast(short[]*)p1;
        short[] s2 = *cast(short[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int result = s1[u] - s2[u];
            if (result)
                return result;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (short[]).sizeof;
    }

    override uint flags()
    {
        return 1;
    }

    override TypeInfo next()
    {
        return typeid(short);
    }
}


// ushort[]

class TypeInfo_At : TypeInfo_As
{
    override char[] toString() { return "ushort[]"; }

    override int compare(in void* p1, in void* p2)
    {
        ushort[] s1 = *cast(ushort[]*)p1;
        ushort[] s2 = *cast(ushort[]*)p2;
        size_t len = s1.length;

        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            int result = s1[u] - s2[u];
            if (result)
                return result;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    override TypeInfo next()
    {
        return typeid(ushort);
    }
}

// wchar[]

class TypeInfo_Au : TypeInfo_At
{
    override char[] toString() { return "wchar[]"; }

    // getHash should be overridden and call rt_hash_utf16 if one wants dependence for codepoints only
    override TypeInfo next()
    {
        return typeid(wchar);
    }
}
///////////////////////////////
// byte
class TypeInfo_g : TypeInfo
{
    override char[] toString() { return "byte"; }

    override hash_t getHash(in void* p)
    {
        return cast(hash_t)(*cast(byte *)p);
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(byte *)p1 == *cast(byte *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        return *cast(byte *)p1 - *cast(byte *)p2;
    }

    override size_t tsize()
    {
        return byte.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        byte t;

        t = *cast(byte *)p1;
        *cast(byte *)p1 = *cast(byte *)p2;
        *cast(byte *)p2 = t;
    }
}
//////////////////////////////////////

// Object

class TypeInfo_C : TypeInfo
{
    override hash_t getHash(in void* p)
    {
        Object o = *cast(Object*)p;
        return o ? o.toHash() : cast(hash_t)0xdeadbeef;
    }

    override int equals(in void* p1, in void* p2)
    {
        Object o1 = *cast(Object*)p1;
        Object o2 = *cast(Object*)p2;

        return o1 == o2;
    }

    override int compare(in void* p1, in void* p2)
    {
        Object o1 = *cast(Object*)p1;
        Object o2 = *cast(Object*)p2;
        int c = 0;

        // Regard null references as always being "less than"
        if (!(o1 is o2))
        {
            if (o1)
            {   if (!o2)
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

    override uint flags()
    {
        return 1;
    }
}

////////////////////////////////////
// cdouble
class TypeInfo_r : TypeInfo
{
    override char[] toString() { return "cdouble"; }

    override hash_t getHash(in void* p)
    {
        return rt_hash_str(p,cdouble.sizeof,0);
    }

    static int _equals(cdouble f1, cdouble f2)
    {
        return f1 == f2;
    }

    static int _compare(cdouble f1, cdouble f2)
    {   int result;

        if (f1.re < f2.re)
            result = -1;
        else if (f1.re > f2.re)
            result = 1;
        else if (f1.im < f2.im)
            result = -1;
        else if (f1.im > f2.im)
            result = 1;
        else
            result = 0;
        return result;
    }

    override int equals(in void* p1, in void* p2)
    {
        return _equals(*cast(cdouble *)p1, *cast(cdouble *)p2);
    }

    override int compare(in void* p1, in void* p2)
    {
        return _compare(*cast(cdouble *)p1, *cast(cdouble *)p2);
    }

    override size_t tsize()
    {
        return cdouble.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        cdouble t;

        t = *cast(cdouble *)p1;
        *cast(cdouble *)p1 = *cast(cdouble *)p2;
        *cast(cdouble *)p2 = t;
    }

    override void[] init()
    {   static cdouble r;

        return (cast(cdouble *)&r)[0 .. 1];
    }
}
////////////////////////////////////////
// cfloat
class TypeInfo_q : TypeInfo
{
    override char[] toString() { return "cfloat"; }

    override hash_t getHash(in void* p)
    {
        return rt_hash_str(p,cfloat.sizeof,0);
    }

    static int _equals(cfloat f1, cfloat f2)
    {
        return f1 == f2;
    }

    static int _compare(cfloat f1, cfloat f2)
    {   int result;

        if (f1.re < f2.re)
            result = -1;
        else if (f1.re > f2.re)
            result = 1;
        else if (f1.im < f2.im)
            result = -1;
        else if (f1.im > f2.im)
            result = 1;
        else
            result = 0;
        return result;
    }

    override int equals(in void* p1, in void* p2)
    {
        return _equals(*cast(cfloat *)p1, *cast(cfloat *)p2);
    }

    override int compare(in void* p1, in void* p2)
    {
        return _compare(*cast(cfloat *)p1, *cast(cfloat *)p2);
    }

    override size_t tsize()
    {
        return cfloat.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        cfloat t;

        t = *cast(cfloat *)p1;
        *cast(cfloat *)p1 = *cast(cfloat *)p2;
        *cast(cfloat *)p2 = t;
    }

    override void[] init()
    {   static cfloat r;

        return (cast(cfloat *)&r)[0 .. 1];
    }
}
////////////////////////////////////////


class TypeInfo_a : TypeInfo
{
    override char[] toString() { return "char"; }

    override hash_t getHash(in void* p)
    {
        return cast(hash_t)(*cast(char *)p);
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(char *)p1 == *cast(char *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        return *cast(char *)p1 - *cast(char *)p2;
    }

    override size_t tsize()
    {
        return char.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        char t;

        t = *cast(char *)p1;
        *cast(char *)p1 = *cast(char *)p2;
        *cast(char *)p2 = t;
    }

    override void[] init()
    {   static char c;

        return (cast(char *)&c)[0 .. 1];
    }
}
///////////////////////////////////
// creal
class TypeInfo_c : TypeInfo
{
    override char[] toString() { return "creal"; }

    override hash_t getHash(in void* p)
    {
        return rt_hash_str(p,creal.sizeof,0);
    }

    static int _equals(creal f1, creal f2)
    {
        return f1 == f2;
    }

    static int _compare(creal f1, creal f2)
    {   int result;

        if (f1.re < f2.re)
            result = -1;
        else if (f1.re > f2.re)
            result = 1;
        else if (f1.im < f2.im)
            result = -1;
        else if (f1.im > f2.im)
            result = 1;
        else
            result = 0;
        return result;
    }

    override int equals(in void* p1, in void* p2)
    {
        return _equals(*cast(creal *)p1, *cast(creal *)p2);
    }

    override int compare(in void* p1, in void* p2)
    {
        return _compare(*cast(creal *)p1, *cast(creal *)p2);
    }

    override size_t tsize()
    {
        return creal.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        creal t;

        t = *cast(creal *)p1;
        *cast(creal *)p1 = *cast(creal *)p2;
        *cast(creal *)p2 = t;
    }

    override void[] init()
    {   static creal r;

        return (cast(creal *)&r)[0 .. 1];
    }
}

///////////////////////////////////////
// dchar
class TypeInfo_w : TypeInfo
{
    override char[] toString() { return "dchar"; }

    override hash_t getHash(in void* p)
    {
        return cast(hash_t)*cast(dchar *)p;
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(dchar *)p1 == *cast(dchar *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        return *cast(dchar *)p1 - *cast(dchar *)p2;
    }

    override size_t tsize()
    {
        return dchar.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        dchar t;

        t = *cast(dchar *)p1;
        *cast(dchar *)p1 = *cast(dchar *)p2;
        *cast(dchar *)p2 = t;
    }

    override void[] init()
    {   static dchar c;

        return (cast(dchar *)&c)[0 .. 1];
    }
}
//////////////////////////////////////

// delegate
alias void delegate(int) dg;

class TypeInfo_D : TypeInfo
{
    override hash_t getHash(in void* p)
    {
        return rt_hash_block(cast(size_t *)p,2,0);
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(dg *)p1 == *cast(dg *)p2;
    }

    override size_t tsize()
    {
        return dg.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        dg t;

        t = *cast(dg *)p1;
        *cast(dg *)p1 = *cast(dg *)p2;
        *cast(dg *)p2 = t;
    }

    override uint flags()
    {
        return 1;
    }
}
////////////////////////////
// double
class TypeInfo_d : TypeInfo
{
    override char[] toString() { return "double"; }

    override hash_t getHash(in void* p)
    {
        return rt_hash_str(p,double.sizeof);
    }

    static int _equals(double f1, double f2)
    {
        return f1 == f2 ||
                (f1 !<>= f1 && f2 !<>= f2);
    }

    static int _compare(double d1, double d2)
    {
        if (d1 !<>= d2)         // if either are NaN
        {
            if (d1 !<>= d1)
            {   if (d2 !<>= d2)
                    return 0;
                return -1;
            }
            return 1;
        }
        return (d1 == d2) ? 0 : ((d1 < d2) ? -1 : 1);
    }

    override int equals(in void* p1, in void* p2)
    {
        return _equals(*cast(double *)p1, *cast(double *)p2);
    }

    override int compare(in void* p1, in void* p2)
    {
        return _compare(*cast(double *)p1, *cast(double *)p2);
    }

    override size_t tsize()
    {
        return double.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        double t;

        t = *cast(double *)p1;
        *cast(double *)p1 = *cast(double *)p2;
        *cast(double *)p2 = t;
    }

    override void[] init()
    {   static double r;

        return (cast(double *)&r)[0 .. 1];
    }
}
///////////////////////////////
// float
class TypeInfo_f : TypeInfo
{
    override char[] toString() { return "float"; }

    override hash_t getHash(in void* p)
    {
        return cast(hash_t)(*cast(uint *)p);
    }

    static int _equals(float f1, float f2)
    {
        return f1 == f2 ||
                (f1 !<>= f1 && f2 !<>= f2);
    }

    static int _compare(float d1, float d2)
    {
        if (d1 !<>= d2)         // if either are NaN
        {
            if (d1 !<>= d1)
            {   if (d2 !<>= d2)
                    return 0;
                return -1;
            }
            return 1;
        }
        return (d1 == d2) ? 0 : ((d1 < d2) ? -1 : 1);
    }

    override int equals(in void* p1, in void* p2)
    {
        return _equals(*cast(float *)p1, *cast(float *)p2);
    }

    override int compare(in void* p1, in void* p2)
    {
        return _compare(*cast(float *)p1, *cast(float *)p2);
    }

    override size_t tsize()
    {
        return float.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        float t;

        t = *cast(float *)p1;
        *cast(float *)p1 = *cast(float *)p2;
        *cast(float *)p2 = t;
    }

    override void[] init()
    {   static float r;

        return (cast(float *)&r)[0 .. 1];
    }
}
/////////////////////////////
// idouble
class TypeInfo_p : TypeInfo_d
{
    override char[] toString() { return "idouble"; }
}
/////////////////////////////
// ifloat
class TypeInfo_o : TypeInfo_f
{
    override char[] toString() { return "ifloat"; }
}
/////////////////////////
// int
class TypeInfo_i : TypeInfo
{
    override char[] toString() { return "int"; }

    override hash_t getHash(in void* p)
    {
        return cast(hash_t)(*cast(uint *)p);
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(uint *)p1 == *cast(uint *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        if (*cast(int*) p1 < *cast(int*) p2)
            return -1;
        else if (*cast(int*) p1 > *cast(int*) p2)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return int.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        int t;

        t = *cast(int *)p1;
        *cast(int *)p1 = *cast(int *)p2;
        *cast(int *)p2 = t;
    }
}
///////////////////////////
// ireal
class TypeInfo_j : TypeInfo_e
{
    override char[] toString() { return "ireal"; }
}
//////////////////////////////
// long
class TypeInfo_l : TypeInfo
{
    override char[] toString() { return "long"; }

    override hash_t getHash(in void* p)
    {
        static if(hash_t.sizeof==8){
            return cast(hash_t)(*cast(ulong *)p);
        } else {
            return rt_hash_combine(*cast(uint *)p,(cast(uint *)p)[1]);
        }
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(long *)p1 == *cast(long *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        if (*cast(long *)p1 < *cast(long *)p2)
            return -1;
        else if (*cast(long *)p1 > *cast(long *)p2)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return long.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        long t;

        t = *cast(long *)p1;
        *cast(long *)p1 = *cast(long *)p2;
        *cast(long *)p2 = t;
    }
}

/////////////////////////////////
// pointer
class TypeInfo_P : TypeInfo
{
    override hash_t getHash(in void* p)
    {
        return cast(hash_t)(*cast(size_t *)p);
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(void* *)p1 == *cast(void* *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        auto c = *cast(void* *)p1 - *cast(void* *)p2;
        if (c < 0)
            return -1;
        else if (c > 0)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return (void*).sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        void* t;

        t = *cast(void* *)p1;
        *cast(void* *)p1 = *cast(void* *)p2;
        *cast(void* *)p2 = t;
    }

    override uint flags()
    {
        return 1;
    }
}

///////////////////////////
// real
class TypeInfo_e : TypeInfo
{
    override char[] toString() { return "real"; }

    override hash_t getHash(in void* p)
    {
        return rt_hash_str(p,real.sizeof,0);
    }

    static int _equals(real f1, real f2)
    {
        return f1 == f2 ||
                (f1 !<>= f1 && f2 !<>= f2);
    }

    static int _compare(real d1, real d2)
    {
        if (d1 !<>= d2)         // if either are NaN
        {
            if (d1 !<>= d1)
            {   if (d2 !<>= d2)
                    return 0;
                return -1;
            }
            return 1;
        }
        return (d1 == d2) ? 0 : ((d1 < d2) ? -1 : 1);
    }

    override int equals(in void* p1, in void* p2)
    {
        return _equals(*cast(real *)p1, *cast(real *)p2);
    }

    override int compare(in void* p1, in void* p2)
    {
        return _compare(*cast(real *)p1, *cast(real *)p2);
    }

    override size_t tsize()
    {
        return real.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        real t;

        t = *cast(real *)p1;
        *cast(real *)p1 = *cast(real *)p2;
        *cast(real *)p2 = t;
    }

    override void[] init()
    {   static real r;

        return (cast(real *)&r)[0 .. 1];
    }
}

////////////////////////////////////
// short
class TypeInfo_s : TypeInfo
{
    override char[] toString() { return "short"; }

    override hash_t getHash(in void* p)
    {
        return cast(hash_t)(*cast(ushort *)p);
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(short *)p1 == *cast(short *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        return *cast(short *)p1 - *cast(short *)p2;
    }

    override size_t tsize()
    {
        return short.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        short t;

        t = *cast(short *)p1;
        *cast(short *)p1 = *cast(short *)p2;
        *cast(short *)p2 = t;
    }
}
//////////////////////////////
// ubyte
class TypeInfo_h : TypeInfo
{
    override char[] toString() { return "ubyte"; }

    override hash_t getHash(in void* p)
    {
        return cast(hash_t)(*cast(ubyte *)p);
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(ubyte *)p1 == *cast(ubyte *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        return *cast(ubyte *)p1 - *cast(ubyte *)p2;
    }

    override size_t tsize()
    {
        return ubyte.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        ubyte t;

        t = *cast(ubyte *)p1;
        *cast(ubyte *)p1 = *cast(ubyte *)p2;
        *cast(ubyte *)p2 = t;
    }
}

class TypeInfo_b : TypeInfo_h
{
    override char[] toString() { return "bool"; }
}
//////////////////////////////////
// uint
class TypeInfo_k : TypeInfo
{
    override char[] toString() { return "uint"; }

    override hash_t getHash(in void* p)
    {
        return *cast(uint *)p;
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(uint *)p1 == *cast(uint *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        if (*cast(uint*) p1 < *cast(uint*) p2)
            return -1;
        else if (*cast(uint*) p1 > *cast(uint*) p2)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return uint.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        int t;

        t = *cast(uint *)p1;
        *cast(uint *)p1 = *cast(uint *)p2;
        *cast(uint *)p2 = t;
    }
}
///////////////////////////////////
// ulong
class TypeInfo_m : TypeInfo
{
    override char[] toString() { return "ulong"; }

    override hash_t getHash(in void* p)
    {
        static if(hash_t.sizeof==8){
            return cast(hash_t)(*cast(ulong *)p);
        } else {
            return rt_hash_combine(*cast(uint *)p,(cast(uint *)p)[1]);
        }
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(ulong *)p1 == *cast(ulong *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        if (*cast(ulong *)p1 < *cast(ulong *)p2)
            return -1;
        else if (*cast(ulong *)p1 > *cast(ulong *)p2)
            return 1;
        return 0;
    }

    override size_t tsize()
    {
        return ulong.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        ulong t;

        t = *cast(ulong *)p1;
        *cast(ulong *)p1 = *cast(ulong *)p2;
        *cast(ulong *)p2 = t;
    }
}
//////////////////////////////
class TypeInfo_t : TypeInfo
{
    override char[] toString() { return "ushort"; }

    override hash_t getHash(in void* p)
    {
        return *cast(ushort *)p;
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(ushort *)p1 == *cast(ushort *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        return *cast(ushort *)p1 - *cast(ushort *)p2;
    }

    override size_t tsize()
    {
        return ushort.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        ushort t;

        t = *cast(ushort *)p1;
        *cast(ushort *)p1 = *cast(ushort *)p2;
        *cast(ushort *)p2 = t;
    }
}
//////////////////////////////////////
// void
class TypeInfo_v : TypeInfo
{
    override char[] toString() { return "void"; }

    override hash_t getHash(in void* p)
    {
        assert(0);
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(byte *)p1 == *cast(byte *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        return *cast(byte *)p1 - *cast(byte *)p2;
    }

    override size_t tsize()
    {
        return void.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        byte t;

        t = *cast(byte *)p1;
        *cast(byte *)p1 = *cast(byte *)p2;
        *cast(byte *)p2 = t;
    }

    override uint flags()
    {
        return 1;
    }
}
///////////////////////////////


class TypeInfo_u : TypeInfo
{
    override char[] toString() { return "wchar"; }

    override hash_t getHash(in void* p)
    {
        return cast(hash_t)(*cast(wchar *)p);
    }

    override int equals(in void* p1, in void* p2)
    {
        return *cast(wchar *)p1 == *cast(wchar *)p2;
    }

    override int compare(in void* p1, in void* p2)
    {
        return *cast(wchar *)p1 - *cast(wchar *)p2;
    }

    override size_t tsize()
    {
        return wchar.sizeof;
    }

    override void swap(void *p1, void *p2)
    {
        wchar t;

        t = *cast(wchar *)p1;
        *cast(wchar *)p1 = *cast(wchar *)p2;
        *cast(wchar *)p2 = t;
    }

    override void[] init()
    {   static wchar c;

        return (cast(wchar *)&c)[0 .. 1];
    }
}
///////////////////////////////////////////////////////

