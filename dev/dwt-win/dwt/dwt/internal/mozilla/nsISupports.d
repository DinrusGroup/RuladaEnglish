module dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;

const char[] NS_ISUPPORTS_IID_STR = "00000000-0000-0000-c000-000000000046";

const nsIID NS_ISUPPORTS_IID= 
        { 0x00000000, 0x0000, 0x0000, 
          [ 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46 ] };

interface IUnknown
{
    static const char[] IID_STR = NS_ISUPPORTS_IID_STR;
    static const nsIID IID = NS_ISUPPORTS_IID;

extern(System):
    nsresult QueryInterface( nsIID* uuid, void **result);

    nsrefcnt AddRef();
    nsrefcnt Release();
}

// WHY WE USE COM's IUnknown for XPCOM:
//
// The IUnknown interface is special-cased in D and is specifically designed to be
// compatible with MS COM.  XPCOM's nsISupports interface is the exact equivalent
// of IUnknown so we alias it here to take advantage of D's COM support. -JJR

alias IUnknown nsISupports;