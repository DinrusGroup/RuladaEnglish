
module rt.core.thread;

private alias void delegate( void*, void* ) scanAllThreadsFn;
const size_t PAGESIZE;

extern (D) class Thread
{


alias start стартуй;
alias join объедени;
alias name имя;
alias isDaemon демон_ли;
alias isRunning пущена_ли;
alias PRIORITY_MIN ПРИОРИТЕТ_МИН;
alias PRIORITY_MAX ПРИОРИТЕТ_МАКС;
alias priority приоритет;
alias sleep сон;
alias yield взять;
alias getThis дайЭту;
alias getAll дайВсе;
alias createLocal создайЛокальн;
alias deleteLocal удалиЛокальн;
alias getLocal дайЛокальн;
alias setLocal устЛокальн;



    ////////////////////////////////////////////////////////////////////////////
    // Initialization
    ////////////////////////////////////////////////////////////////////////////

    this( void function() fn, size_t sz = 0 );
    this( void delegate() dg, size_t sz = 0 );   
    ~this();


    ////////////////////////////////////////////////////////////////////////////
    // General Actions
    ////////////////////////////////////////////////////////////////////////////

	final void start();
    final Object join( bool rethrow = true );

    ////////////////////////////////////////////////////////////////////////////
    // General Properties
    ////////////////////////////////////////////////////////////////////////////

    final char[] name();

    final void name( char[] val );
    final bool isDaemon();
    final void isDaemon( bool val );
    final bool isRunning();
    ////////////////////////////////////////////////////////////////////////////
    // Thread Priority Actions
    ////////////////////////////////////////////////////////////////////////////

    static const int PRIORITY_MIN;
    static const int PRIORITY_MAX;

    final int priority();
    final void priority( int val );
    

    ////////////////////////////////////////////////////////////////////////////
    // Actions on Calling Thread
    ////////////////////////////////////////////////////////////////////////////

    static void sleep( double period );
    static void yield();

    ////////////////////////////////////////////////////////////////////////////
    // Thread Accessors
    ////////////////////////////////////////////////////////////////////////////

    static Thread getThis();
    static Thread[] getAll();
    static int opApply( int delegate( ref  Thread ) dg );

    ////////////////////////////////////////////////////////////////////////////
    // Local Storage Actions
    ////////////////////////////////////////////////////////////////////////////

    static const uint LOCAL_MAX = 64;
    static uint createLocal();
    static void deleteLocal( uint key );
    static void* getLocal( uint key );
    static void* setLocal( uint key, void* val );

    ////////////////////////////////////////////////////////////////////////////
    // Static Initalizer
    ////////////////////////////////////////////////////////////////////////////


    static this();

    public final Context* topContext();

    public static struct Context
    {
        void*           bstack,
                        tstack;
        Context*        within;
        Context*        next,
                        prev;
    }
}


////////////////////////////////////////////////////////////////////////////////
// GC Support Routines
////////////////////////////////////////////////////////////////////////////////
alias thread_init нить_иниц;
alias thread_attachThis нить_добавьЭту;
alias thread_detachThis нить_сбросьЭту;
alias thread_joinAll нить_объединиВсе;
alias thread_needLock нить_нужнаБлокировка;
alias thread_suspendAll нить_замриВсе;
alias thread_resumeAll нить_отомриВсе;
alias thread_scanAll нить_искатьВсе;

extern (C) void thread_init();
extern (C) void thread_attachThis();
extern (C) void thread_detachThis();
extern (C) void thread_joinAll();

static ~this();

extern (C) bool thread_needLock();
extern (C) void thread_suspendAll();
extern (C) void thread_resumeAll();
extern (C) void thread_scanAll( scanAllThreadsFn scan, void* curStackTop = null );

////////////////////////////////////////////////////////////////////////////////
// Thread Local
////////////////////////////////////////////////////////////////////////////////

class ThreadLocal( T )
{

    ////////////////////////////////////////////////////////////////////////////
    // Initialization
    ////////////////////////////////////////////////////////////////////////////

    this( T def = T.init )
    {
        m_def = def;
        m_key = Thread.createLocal();
    }


    ~this()
    {
        Thread.deleteLocal( m_key );
    }


    ////////////////////////////////////////////////////////////////////////////
    // Accessors
    ////////////////////////////////////////////////////////////////////////////

    T val()
    {
        Wrap* wrap = cast(Wrap*) Thread.getLocal( m_key );

        return wrap ? wrap.val : m_def;
    }

    T val( T newval )
    {
        Wrap* wrap = cast(Wrap*) Thread.getLocal( m_key );

        if( wrap is null )
        {
            wrap = new Wrap;
            Thread.setLocal( m_key, wrap );
        }
        wrap.val = newval;
        return newval;
    }


private:
 
    struct Wrap
    {
        T   val;
    }


    T       m_def;
    uint    m_key;
}


////////////////////////////////////////////////////////////////////////////////
// Thread Group
////////////////////////////////////////////////////////////////////////////////

extern (D) class ThreadGroup
{

    final Thread create( void function() fn );
    final Thread create( void delegate() dg );
    final void add( Thread t );
    final void remove( Thread t );
    final int opApply( int delegate( ref  Thread ) dg );
    final void joinAll( bool rethrow = true );

}


////////////////////////////////////////////////////////////////////////////////
// Fiber Platform Detection and Memory Allocation
////////////////////////////////////////////////////////////////////////////////

static this();
////////////////////////////////////////////////////////////////////////////////
// Fiber Entry Point and Context Switch
////////////////////////////////////////////////////////////////////////////////



extern (D) class Fiber
{

    static class Scheduler
    {
	    alias void* Handle;

        enum Type {Read=1, Write=2, Accept=3, Connect=4, Transfer=5}

        void pause (uint ms) {}

        void ready (Fiber fiber) {}

        void open (Handle fd, char[] name) {}

        void close (Handle fd, char[] name) {}

        void await (Handle fd, Type t, uint timeout) {}
        
        void spawn (char[] name, void delegate() dg, size_t stack=8192) {}    
    }

    struct Event                        // scheduler support 
    {  
        uint             idx;           // support for timer removal
        Fiber            next;          // linked list of elapsed fibers
        void*            data;          // data to exchange
        ulong            clock;         // request timeout duration
        Scheduler.Handle handle;        // IO request handle
        Scheduler        scheduler;     // associated scheduler (may be null)
    }


    final static Scheduler scheduler ();

    ////////////////////////////////////////////////////////////////////////////
    // Initialization
    ////////////////////////////////////////////////////////////////////////////

    this(size_t sz);
    this( void function() fn, size_t sz = PAGESIZE);
    this( void delegate() dg, size_t sz = PAGESIZE, Scheduler s = null );
    ~this();


    ////////////////////////////////////////////////////////////////////////////
    // General Actions
    ////////////////////////////////////////////////////////////////////////////

    final Object call( bool rethrow = true );
    final void reset();
    final void reset( void function() fn );
    final void reset( void delegate() dg );
    final void clear();
    

    ////////////////////////////////////////////////////////////////////////////
    // General Properties
    ////////////////////////////////////////////////////////////////////////////

    enum State
    {
        HOLD,   ///
        EXEC,   ///
        TERM    ///
    }

    final State state();
    size_t stackSize();

    ////////////////////////////////////////////////////////////////////////////
    // Actions on Calling Fiber
    ////////////////////////////////////////////////////////////////////////////

    final void cede ();
    static void yield();
    static void yieldAndThrow( Object obj );

    ////////////////////////////////////////////////////////////////////////////
    // Fiber Accessors
    ////////////////////////////////////////////////////////////////////////////

    static Fiber getThis();


    ////////////////////////////////////////////////////////////////////////////
    // Static Initialization
    ////////////////////////////////////////////////////////////////////////////


    static this();
	
	
public:
    Event               event;


}

extern(C){
    void thread_yield();    
    void thread_sleep(double period);
}
