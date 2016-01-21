/*******************************************************************************

        @file SocketConduit.d
        
        Copyright (c) 2004 Kris Bell
        
        This software is provided 'as-is', without any express or implied
        warranty. In no event will the authors be held liable for damages
        of any kind arising from the use of this software.
        
        Permission is hereby granted to anyone to use this software for any 
        purpose, including commercial applications, and to alter it and/or 
        redistribute it freely, subject to the following restrictions:
        
        1. The origin of this software must not be misrepresented; you must 
           not claim that you wrote the original software. If you use this 
           software in a product, an acknowledgment within documentation of 
           said product would be appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must 
           not be misrepresented as being the original software.

        3. This notice may not be removed or altered from any distribution
           of the source.

        4. Derivative works are permitted, but they must carry this notice
           in full and credit the original source.


                        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


        @version        Initial version, March 2004      
			Jan 1st 2005 - Added RedShodan patch for timeout query

        @author         Kris

*******************************************************************************/

module mango.io.SocketConduit;

public  import  mango.io.Socket;

private import  mango.io.Buffer;

/*******************************************************************************

        A wrapper around the bare Socket to implement the IConduit abstraction
        and add socket-specific functionality. SocketConduit data-transfer is 
        typically performed in conjunction with an IBuffer instance, but can 
        be handled directly using raw arrays if preferred. See FileConduit for 
        examples of both approaches.

*******************************************************************************/

class SocketConduit : Socket, ISocketReader
{       
        // expose Conduit read()
        alias Socket.read               read;

        private bool                    textual;

        // freelist support
        private SocketConduit           next;   
        private bool                    fromList;
        private static SocketConduit    freelist;

        /***********************************************************************
        
                Create a streaming Internet Socket. Use the next ctor instead.

        ***********************************************************************/

        deprecated this ()
        {
                this (true);
        }

        /***********************************************************************
        
                Create a streaming Internet Socket

        ***********************************************************************/

        this (bool textual)
        {
                this.textual = textual;
                super (AddressFamily.INET, Type.STREAM, Protocol.IP);                
        }

        /***********************************************************************

                Override closure() to deallocate this SocketConduit 
                when it has been closed. Note that one should *not* 
                delete a SocketConduit when FreeList is enabled ...

        ***********************************************************************/

        override void close ()
        {       
                // be a nice client, and tell the server?
                //super.shutdown();

                // do this first cos' we're gonna' reset the
                // socket handle during deallocate()
                super.close ();


                // deallocate if this came from the free-list,
                // otherwise just wait for the GC to handle it
                if (fromList)
                    deallocate (this);
        }

        /***********************************************************************
        
                Read from conduit into a target buffer. Note that this 
                uses SocketSet to handle timeouts, such that the socket
                does not stall forever.
        
                (for the ISocketReader interface)

        ***********************************************************************/

        uint read (IBuffer target)
        {
                return target.fill (this);
        }

        /***********************************************************************
        
                Returns true if this conduit is text-based

        ***********************************************************************/

        bool isTextual ()
        {
                return textual;
        }               

        /***********************************************************************
        
                Construct this SocketConduit with the given socket handle;
                this is for FreeList and ServerSocket support.

        ***********************************************************************/

        static SocketConduit create (socket_t handle)
        {
                // allocate one from the free-list
                return allocate (handle);
        }

        /***********************************************************************
        
                Construct this SocketConduit with the given socket handle;
                this is for FreeList and ServerSocket support.

        ***********************************************************************/

        private this (socket_t handle)
        {
                super (handle);                
        }
     
        /***********************************************************************

                Allocate a SocketConduit from a list rather than 
                creating a new one

        ***********************************************************************/

        private static synchronized SocketConduit allocate (socket_t sock)
        {       
                SocketConduit s;

                if (freelist)
                   {
                   s = freelist;
                   freelist = s.next;
                   s.set (sock);
                   }
                else
                   {
                   s = new SocketConduit (sock);
                   s.fromList = true;
                   }
                return s;
        }

        /***********************************************************************

                Return this SocketConduit to the free-list

        ***********************************************************************/

        private static synchronized void deallocate (SocketConduit s)
        {
                // socket handle is no longer valid
                s.reset ();
                s.next = freelist;
                freelist = s;
        }
}



