﻿/**
 * D header file for C99.
 *
 * Copyright: Public Domain
 * License:   Public Domain
 * Authors:   Sean Kelly, Walter Bright
 * Standards: ISO/IEC 9899:1999 (E)
 */
module rt.core.stdc.stdio;

//version = Windows;

private
{
    import rt.core.stdc.config;
    import rt.core.stdc.stddef; // for size_t
    import rt.core.stdc.stdarg; // for va_list
	
}

extern (C):

version( Windows )
{
    enum
    {
        BUFSIZ       = 0x4000,
        EOF          = -1,
        FOPEN_MAX    = 20,
        FILENAME_MAX = 256, // 255 plus NULL
        TMP_MAX      = 32767,
        SYS_OPEN     = 20,	// non-standard
    }

    const int     _NFILE     = 60;	// non-standard
    const string  _P_tmpdir  = "\\"; // non-standard
    const wstring _wP_tmpdir = "\\"; // non-standard
    const int     L_tmpnam   = _P_tmpdir.length + 12;
}
else version( linux )
{
    enum
    {
        BUFSIZ       = 8192,
        EOF          = -1,
        FOPEN_MAX    = 16,
        FILENAME_MAX = 4095,
        TMP_MAX      = 238328,
        L_tmpnam     = 20
    }
}
else version( OSX )
{
    enum
    {
		BUFSIZ		= 1024,
        EOF          = -1,
        FOPEN_MAX    = 20,
        FILENAME_MAX = 1024,
        TMP_MAX      = 308915776,
        L_tmpnam     = 1024,
    }

    private
    {
        struct __sbuf
        {
            ubyte*  _base;
            int     _size;
        }

        struct __sFILEX
        {

        }
    }
}
else version ( freebsd )
{
    enum
    {
        EOF          = -1,
        FOPEN_MAX    = 20,
        FILENAME_MAX = 1024,
        TMP_MAX      = 308915776,
        L_tmpnam     = 1024
    }

    private
    {
        struct __sbuf
        {
            ubyte *_base;
            int _size;
        }
        struct __sFILEX
        {

        }
    }
}
else
{
    static assert( false );
}

enum
{
    SEEK_SET,
    SEEK_CUR,
    SEEK_END
}

struct _iobuf
{
    align (1):
    version( Windows )
    {
        char* _ptr;
        int   _cnt;
        char* _base;
        int   _flag;
        int   _file;
        int   _charbuf;
        int   _bufsiz;
        int   __tmpnum;
    }
    else version( linux )
    {
        char*   _read_ptr;
        char*   _read_end;
        char*   _read_base;
        char*   _write_base;
        char*   _write_ptr;
        char*   _write_end;
        char*   _buf_base;
        char*   _buf_end;
        char*   _save_base;
        char*   _backup_base;
        char*   _save_end;
        void*   _markers;
        _iobuf* _chain;
        int     _fileno;
        int     _blksize;
        int     _old_offset;
        ushort  _cur_column;
        byte    _vtable_offset;
        char[1] _shortbuf;
        void*   _lock;
    }
    else version( OSX )
    {
        ubyte*    _p;
        int       _r;
        int       _w;
        short     _flags;
        short     _file;
        __sbuf    _bf;
        int       _lbfsize;

        int* function(void*)                    _close;
        int* function(void*, char*, int)        _read;
        fpos_t* function(void*, fpos_t, int)    _seek;
        int* function(void*, char *, int)       _write;

        __sbuf    _ub;
        __sFILEX* _extra;
        int       _ur;

        ubyte[3]  _ubuf;
        ubyte[1]  _nbuf;

        __sbuf    _lb;

        int       _blksize;
        fpos_t    _offset;
    }
    else version( freebsd )
    {
        ubyte*    _p;
        int       _r;
        int       _w;
        short     _flags;
        short     _file;
        __sbuf    _bf;
        int       _lbfsize;

        void* function()                        _cookie;
        int* function(void*)                    _close;
        int* function(void*, char*, int)        _read;
        fpos_t* function(void*, fpos_t, int)    _seek;
        int* function(void*, char *, int)       _write;

        __sbuf    _ub;
        __sFILEX* _extra;
        int       _ur;

        ubyte[3]  _ubuf;
        ubyte[1]  _nbuf;

        __sbuf    _lb;

        int       _blksize;
        fpos_t    _offset;
    }
    else
    {
        static assert( false );
    }
}

alias _iobuf FILE;
alias FILE ФАЙЛ;
alias stdin стдвхо;
alias stdout стдвых;
alias stderr стдош;
alias stdaux стддоп;
alias stdprn стдпрн;
alias __fhnd_info фук_инфо;
enum
{
    _F_RDWR = 0x0003, // non-standard
    _F_READ = 0x0001, // non-standard
    _F_WRIT = 0x0002, // non-standard
    _F_BUF  = 0x0004, // non-standard
    _F_LBUF = 0x0008, // non-standard
    _F_ERR  = 0x0010, // non-standard
    _F_EOF  = 0x0020, // non-standard
    _F_BIN  = 0x0040, // non-standard
    _F_IN   = 0x0080, // non-standard
    _F_OUT  = 0x0100, // non-standard
    _F_TERM = 0x0200, // non-standard
}

version( Windows )
{
    extern FILE[_NFILE] _iob;
    //extern void function() _fcloseallp;
    extern ubyte __fhnd_info[_NFILE];

    enum
    {
	FHND_APPEND	= 0x04,
	FHND_DEVICE	= 0x08,
	FHND_TEXT	= 0x10,
	FHND_BYTE	= 0x20,
	FHND_WCHAR	= 0x40,
    }
	
    enum
    {
        _IOFBF   = 0,
        _IOLBF   = 0x40,
		_IONBF   = 4,
        _IOREAD  = 1,	  // non-standard
        _IOWRT   = 2,	  // non-standard
        _IOMYBUF = 8,	  // non-standard	
        _IOEOF   = 0x10,  // non-standard
        _IOERR   = 0x20,  // non-standard
        _IOSTRG  = 0x40,  // non-standard
        _IORW    = 0x80,  // non-standard
        _IOTRAN  = 0x100, // non-standard
        _IOAPP   = 0x200, // non-standard
    }

    extern void function() _fcloseallp;

    //extern FILE[_NFILE] _iob;

    const FILE *stdin  = &_iob[0];
    const FILE *stdout = &_iob[1];
    const FILE *stderr = &_iob[2];
    const FILE *stdaux = &_iob[3];
    const FILE *stdprn = &_iob[4];
}
else version( linux )
{
    enum
    {
        _IOFBF = 0,
        _IOLBF = 1,
        _IONBF = 2,
    }

    extern FILE* stdin;
    extern FILE* stdout;
    extern FILE* stderr;
}
else version( OSX )
{
	enum
    {
        _IOFBF = 0,
        _IOLBF = 1,
        _IONBF = 2,
    }

    private extern FILE* __stdinp;
    private extern FILE* __stdoutp;
    private extern FILE* __stderrp;

    alias __stdinp  stdin;
    alias __stdoutp stdout;
    alias __stderrp stderr;
}
else version( freebsd )
{
    private extern FILE[3] __sF;

    const FILE* stdin  = &__sF[0];
    const FILE* stdout = &__sF[1];
    const FILE* stderr = &__sF[2];
}
else
{
    static assert( false );
}

alias int fpos_t;

int remove(in char* filename);
int rename(in char* from, in char* to);

FILE* tmpfile();
char* tmpnam(char* s);

int   fclose(FILE* stream);
int   fflush(FILE* stream);
FILE* fopen(in char* filename, in char* mode);
FILE* freopen(in char* filename, in char* mode, FILE* stream);

void setbuf(FILE* stream, char* buf);
int  setvbuf(FILE* stream, char* buf, int mode, size_t size);

int fprintf(FILE* stream, in char* format, ...);
int fscanf(FILE* stream, in char* format, ...);
int sprintf(char* s, in char* format, ...);
int sscanf(in char* s, in char* format, ...);
int vfprintf(FILE* stream, in char* format, va_list arg);
int vfscanf(FILE* stream, in char* format, va_list arg);
int vsprintf(char* s, in char* format, va_list arg);
int vsscanf(in char* s, in char* format, va_list arg);
int vprintf(in char* format, va_list arg);
int vscanf(in char* format, va_list arg);
//int printf(in char* format, ...);
int scanf(in char* format, ...);

int fgetc(FILE* stream);
int fputc(int c, FILE* stream);

char* fgets(char* s, int n, FILE* stream);
int   fputs(in char* s, FILE* stream);
char* gets(char* s);
int   puts(in char* s);

extern (D)
{
    int getchar()                 { return getc(stdin);     }
    int putchar(int c)            { return putc(c,stdout);  }
    int getc(FILE* stream)        { return fgetc(stream);   }
    int putc(int c, FILE* stream) { return fputc(c,stream); }
}

int ungetc(int c, FILE* stream);

size_t fread(void* ptr, size_t size, size_t nmemb, FILE* stream);
size_t fwrite(in void* ptr, size_t size, size_t nmemb, FILE* stream);

int fgetpos(FILE* stream, fpos_t * pos);
int fsetpos(FILE* stream, in fpos_t* pos);

int    fseek(FILE* stream, c_long offset, int whence);
c_long ftell(FILE* stream);

version( Windows )
{
  extern (D)
  {
    void rewind(FILE * stream)   { fseek(stream,0L,SEEK_SET); stream._flag&=~_IOERR; }
    void clearerr(FILE *stream) { stream._flag &= ~(_IOERR|_IOEOF);                 }
    int  feof(FILE *stream)     { return stream._flag&_IOEOF;                       }
    int  ferror(FILE* stream)   { return stream._flag&_IOERR;                       }
  }
    int   _snprintf(char* s, size_t n, in char* fmt, ...);
    alias _snprintf snprintf;

    int   _vsnprintf(char* s, size_t n, in char* format, va_list arg);
    alias _vsnprintf vsnprintf;
}
else version( linux )
{
    void rewind(FILE* stream);
    void clearerr(FILE* stream);
    int  feof(FILE* stream);
    int  ferror(FILE* stream);
    int  fileno(FILE *);

    int  snprintf(char* s, size_t n, in char* format, ...);
    int  vsnprintf(char* s, size_t n, in char* format, va_list arg);
}
else version( OSX )
{
    void rewind(FILE*);
    void clearerr(FILE*);
    int  feof(FILE*);
    int  ferror(FILE*);
    int  fileno(FILE*);

    int  snprintf(char* s, size_t n, in char* format, ...);
    int  vsnprintf(char* s, size_t n, in char* format, va_list arg);
}
else version( freebsd )
{
    void rewind(FILE*);
    void clearerr(FILE*);
    int  feof(FILE*);
    int  ferror(FILE*);
    int  fileno(FILE*);

    int  snprintf(char* s, size_t n, in char* format, ...);
    int  vsnprintf(char* s, size_t n, in char* format, va_list arg);
}
else
{
    static assert( false );
}

void perror(in char* s);
