#include <windows.h>


    extern int __cdecl _xi_a;	// &_xi_a just happens to be start of data segment
    extern int __cdecl _edata;	// &_edata is start of BSS segment
    extern int __cdecl _end;	// &_end is past end of BSS


extern void query_staticdataseg(void **base, unsigned *nbytes)
{
    *base = (void *)&_xi_a;
    *nbytes = (unsigned)((char *)&_end - (char *)&_xi_a);
}