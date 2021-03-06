﻿/***********************************************************************\
*                                shlobj.d                               *
*                                                                       *
*                       Windows API header module                       *
*                                                                       *
*                 Translated from MinGW Windows headers                 *
*                                                                       *
*                       Placed into public domain                       *
\***********************************************************************/
module os.win32.shlobj;
//pragma(lib, "shell32.lib");
pragma(lib, "rulada.lib");

// TODO: fix bitfields
// TODO: CMIC_VALID_SEE_FLAGS
// SHGetFolderPath in shfolder.dll on W9x, NT4, also in shell32.dll on W2K

import os.win32.commctrl, os.win32.ole2, os.win32.shlguid, os.win32.shellapi;
private import os.win32.prsht, os.win32.unknwn, os.win32.w32api, os.win32.winbase,
  os.win32.winnt, os.win32.winuser, os.win32.wtypes, os.win32.objfwd, os.win32.objidl;
private import os.win32.winnetwk; // for NETRESOURCE


// FIXME: clean up Windows version support

align(1):

const BIF_RETURNONLYFSDIRS = 1;
const BIF_DONTGOBELOWDOMAIN = 2;
const BIF_STATUSTEXT = 4;
const BIF_RETURNFSANCESTORS = 8;
const BIF_EDITBOX = 16;
const BIF_VALIDATE = 32;
const BIF_NEWDIALOGSTYLE = 64;
const BIF_BROWSEINCLUDEURLS = 128;
const BIF_USENEWUI =  BIF_EDITBOX | BIF_NEWDIALOGSTYLE;
const BIF_BROWSEFORCOMPUTER = 0x1000;
const BIF_BROWSEFORPRINTER = 0x2000;
const BIF_BROWSEINCLUDEFILES = 0x4000;
const BIF_SHAREABLE = 0x8000;
const BFFM_INITIALIZED = 1;
const BFFM_SELCHANGED = 2;
const BFFM_VALIDATEFAILEDA = 3;
const BFFM_VALIDATEFAILEDW = 4;
const BFFM_SETSTATUSTEXTA = WM_USER + 100;
const BFFM_ENABLEOK = WM_USER + 101;
const BFFM_SETSELECTIONA = WM_USER + 102;
const BFFM_SETSELECTIONW = WM_USER + 103;
const BFFM_SETSTATUSTEXTW = WM_USER + 104;
const BFFM_SETOKTEXT = WM_USER + 105;
const BFFM_SETEXPANDED = WM_USER + 106;

version(Unicode) {
	alias BFFM_SETSTATUSTEXTW BFFM_SETSTATUSTEXT;
	alias BFFM_SETSELECTIONW BFFM_SETSELECTION;
	alias BFFM_VALIDATEFAILEDW BFFM_VALIDATEFAILED;
} else {
	alias BFFM_SETSTATUSTEXTA BFFM_SETSTATUSTEXT;
	alias BFFM_SETSELECTIONA BFFM_SETSELECTION;
	alias BFFM_VALIDATEFAILEDA BFFM_VALIDATEFAILED;
}

const DVASPECT_SHORTNAME = 2;

const SHARD_PIDL = 1;
const SHARD_PATH = 2;

const SHCNE_RENAMEITEM = 1;
const SHCNE_CREATE = 2;
const SHCNE_DELETE = 4;
const SHCNE_MKDIR = 8;
const SHCNE_RMDIR = 16;
const SHCNE_MEDIAINSERTED = 32;
const SHCNE_MEDIAREMOVED = 64;
const SHCNE_DRIVEREMOVED = 128;
const SHCNE_DRIVEADD = 256;
const SHCNE_NETSHARE = 512;
const SHCNE_NETUNSHARE = 1024;
const SHCNE_ATTRIBUTES = 2048;
const SHCNE_UPDATEDIR = 4096;
const SHCNE_UPDATEITEM = 8192;
const SHCNE_SERVERDISCONNECT = 16384;
const SHCNE_UPDATEIMAGE = 32768;
const SHCNE_DRIVEADDGUI = 65536;
const SHCNE_RENAMEFOLDER = 0x20000;
const SHCNE_FREESPACE = 0x40000;
const SHCNE_ASSOCCHANGED = 0x8000000;
const SHCNE_DISKEVENTS = 0x2381F;
const SHCNE_GLOBALEVENTS = 0xC0581E0;
const SHCNE_ALLEVENTS = 0x7FFFFFFF;
const SHCNE_INTERRUPT = 0x80000000;

const SHCNF_IDLIST = 0;
const SHCNF_PATHA = 1;
const SHCNF_PRINTERA = 2;
const SHCNF_DWORD = 3;
const SHCNF_PATHW = 5;
const SHCNF_PRINTERW = 6;
const SHCNF_TYPE = 0xFF;
const SHCNF_FLUSH = 0x1000;
const SHCNF_FLUSHNOWAIT = 0x2000;

version(Unicode) {
	alias SHCNF_PATHW SHCNF_PATH;
	alias SHCNF_PRINTERW SHCNF_PRINTER;
} else {
	alias SHCNF_PATHA SHCNF_PATH;
	alias SHCNF_PRINTERA SHCNF_PRINTER;
}

const SFGAO_CANCOPY = DROPEFFECT.DROPEFFECT_COPY;
const SFGAO_CANMOVE = DROPEFFECT.DROPEFFECT_MOVE;
const SFGAO_CANLINK = DROPEFFECT.DROPEFFECT_LINK;
const SFGAO_CANRENAME = 0x00000010L;
const SFGAO_CANDELETE = 0x00000020L;
const SFGAO_HASPROPSHEET = 0x00000040L;
const SFGAO_DROPTARGET = 0x00000100L;
const SFGAO_CAPABILITYMASK = 0x00000177L;
const SFGAO_GHOSTED = 0x00008000L;
const SFGAO_LINK = 0x00010000L;
const SFGAO_SHARE = 0x00020000L;
const SFGAO_READONLY = 0x00040000L;
const SFGAO_HIDDEN = 0x00080000L;
const SFGAO_DISPLAYATTRMASK = 0x000F0000L;
const SFGAO_FILESYSANCESTOR = 0x10000000L;
const SFGAO_FOLDER = 0x20000000L;
const SFGAO_FILESYSTEM = 0x40000000L;
const SFGAO_HASSUBFOLDER = 0x80000000L;
const SFGAO_CONTENTSMASK = 0x80000000L;
const SFGAO_VALIDATE = 0x01000000L;
const SFGAO_REMOVABLE = 0x02000000L;
const SFGAO_COMPRESSED = 0x04000000L;
const STRRET_WSTR = 0;
const STRRET_OFFSET = 1;
const STRRET_CSTR = 2;

enum {
	SHGDFIL_FINDDATA = 1,
	SHGDFIL_NETRESOURCE,
	SHGDFIL_DESCRIPTIONID
}

enum {
	SHDID_ROOT_REGITEM = 1,
	SHDID_FS_FILE,
	SHDID_FS_DIRECTORY,
	SHDID_FS_OTHER,
	SHDID_COMPUTER_DRIVE35,
	SHDID_COMPUTER_DRIVE525,
	SHDID_COMPUTER_REMOVABLE,
	SHDID_COMPUTER_FIXED,
	SHDID_COMPUTER_NETDRIVE,
	SHDID_COMPUTER_CDROM,
	SHDID_COMPUTER_RAMDISK,
	SHDID_COMPUTER_OTHER,
	SHDID_NET_DOMAIN,
	SHDID_NET_SERVER,
	SHDID_NET_SHARE,
	SHDID_NET_RESTOFNET,
	SHDID_NET_OTHER
}

const TCHAR[] REGSTR_PATH_EXPLORER = "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer";
const TCHAR[] REGSTR_PATH_SPECIAL_FOLDERS=REGSTR_PATH_EXPLORER ~ "\\Shell Folders";

enum {
	CSIDL_DESKTOP = 0,
	CSIDL_INTERNET,
	CSIDL_PROGRAMS,
	CSIDL_CONTROLS,
	CSIDL_PRINTERS,
	CSIDL_PERSONAL,
	CSIDL_FAVORITES,
	CSIDL_STARTUP,
	CSIDL_RECENT,
	CSIDL_SENDTO,
	CSIDL_BITBUCKET,
	CSIDL_STARTMENU, // = 11
	CSIDL_DESKTOPDIRECTORY = 16,
	CSIDL_DRIVES,
	CSIDL_NETWORK,
	CSIDL_NETHOOD,
	CSIDL_FONTS,
	CSIDL_TEMPLATES,
	CSIDL_COMMON_STARTMENU,
	CSIDL_COMMON_PROGRAMS,
	CSIDL_COMMON_STARTUP,
	CSIDL_COMMON_DESKTOPDIRECTORY,
	CSIDL_APPDATA,
	CSIDL_PRINTHOOD,
	CSIDL_LOCAL_APPDATA,
	CSIDL_ALTSTARTUP,
	CSIDL_COMMON_ALTSTARTUP,
	CSIDL_COMMON_FAVORITES,
	CSIDL_INTERNET_CACHE,
	CSIDL_COOKIES,
	CSIDL_HISTORY,
	CSIDL_COMMON_APPDATA,
	CSIDL_WINDOWS,
	CSIDL_SYSTEM,
	CSIDL_PROGRAM_FILES,
	CSIDL_MYPICTURES,
	CSIDL_PROFILE,
	CSIDL_SYSTEMX86,
	CSIDL_PROGRAM_FILESX86,
	CSIDL_PROGRAM_FILES_COMMON,
	CSIDL_PROGRAM_FILES_COMMONX86,
	CSIDL_COMMON_TEMPLATES,
	CSIDL_COMMON_DOCUMENTS,
	CSIDL_COMMON_ADMINTOOLS,
	CSIDL_ADMINTOOLS,
	CSIDL_CONNECTIONS, // =49
	CSIDL_COMMON_MUSIC = 53,
	CSIDL_COMMON_PICTURES,
	CSIDL_COMMON_VIDEO,
	CSIDL_RESOURCES,
	CSIDL_RESOURCES_LOCALIZED,
	CSIDL_COMMON_OEM_LINKS,
	CSIDL_CDBURN_AREA, // = 59
	CSIDL_COMPUTERSNEARME = 61,
	CSIDL_FLAG_DONT_VERIFY = 0x4000,
	CSIDL_FLAG_CREATE = 0x8000,
	CSIDL_FLAG_MASK = 0xFF00
}

const TCHAR[]
	CFSTR_SHELLIDLIST       = "Shell IDList Array",
	CFSTR_SHELLIDLISTOFFSET = "Shell Object Offsets",
	CFSTR_NETRESOURCES      = "Net Resource",
	CFSTR_FILECONTENTS      = "FileContents",
	CFSTR_FILENAMEA         = "FileName",
	CFSTR_FILENAMEMAPA      = "FileNameMap",
	CFSTR_FILEDESCRIPTORA   = "FileGroupDescriptor",
	CFSTR_INETURLA          = "UniformResourceLocator",
	CFSTR_SHELLURL          = CFSTR_INETURLA,
	CFSTR_FILENAMEW         = "FileNameW",
	CFSTR_FILENAMEMAPW      = "FileNameMapW",
	CFSTR_FILEDESCRIPTORW   = "FileGroupDescriptorW",
	CFSTR_INETURLW          = "UniformResourceLocatorW";

version(Unicode) {
	alias CFSTR_FILENAMEW CFSTR_FILENAME;
	alias CFSTR_FILENAMEMAPW CFSTR_FILENAMEMAP;
	alias CFSTR_FILEDESCRIPTORW CFSTR_FILEDESCRIPTOR;
	alias CFSTR_INETURLW CFSTR_INETURL;
} else {
	alias CFSTR_FILENAMEA CFSTR_FILENAME;
	alias CFSTR_FILENAMEMAPA CFSTR_FILENAMEMAP;
	alias CFSTR_FILEDESCRIPTORA CFSTR_FILEDESCRIPTOR;
	alias CFSTR_INETURLA CFSTR_INETURL;
}
const TCHAR[]
	CFSTR_PRINTERGROUP        = "PrinterFriendlyName",
	CFSTR_INDRAGLOOP          = "InShellDragLoop",
	CFSTR_PASTESUCCEEDED      = "Paste Succeeded",
	CFSTR_PERFORMEDDROPEFFECT = "Performed DropEffect",
	CFSTR_PREFERREDDROPEFFECT = "Preferred DropEffect";

const CMF_NORMAL=0;
const CMF_DEFAULTONLY=1;
const CMF_VERBSONLY=2;
const CMF_EXPLORE=4;
const CMF_NOVERBS=8;
const CMF_CANRENAME=16;
const CMF_NODEFAULT=32;
const CMF_INCLUDESTATIC=64;
const CMF_RESERVED=0xffff0000;
const GCS_VERBA=0;
const GCS_HELPTEXTA=1;
const GCS_VALIDATEA=2;
const GCS_VERBW=4;
const GCS_HELPTEXTW=5;
const GCS_VALIDATEW=6;
const GCS_UNICODE=4;

version(Unicode) {
	alias GCS_VERBW GCS_VERB;
	alias GCS_HELPTEXTW GCS_HELPTEXT;
	alias GCS_VALIDATEW GCS_VALIDATE;
} else {
	alias GCS_VERBA GCS_VERB;
	alias GCS_HELPTEXTA GCS_HELPTEXT;
	alias GCS_VALIDATEA GCS_VALIDATE;
}

const TCHAR[]
	CMDSTR_NEWFOLDER   = "NewFolder",
	CMDSTR_VIEWLIST    = "ViewList",
	CMDSTR_VIEWDETAILS = "ViewDetails";

const CMIC_MASK_HOTKEY     = SEE_MASK_HOTKEY;
const CMIC_MASK_ICON       = SEE_MASK_ICON;
const CMIC_MASK_FLAG_NO_UI = SEE_MASK_FLAG_NO_UI;
const CMIC_MASK_MODAL      = 0x80000000;
// TODO: This isn't defined anywhere in MinGW.
//const CMIC_VALID_SEE_FLAGS=SEE_VALID_CMIC_FLAGS;

const GIL_OPENICON = 1;
const GIL_FORSHELL = 2;
const GIL_SIMULATEDOC = 1;
const GIL_PERINSTANCE = 2;
const GIL_PERCLASS = 4;
const GIL_NOTFILENAME = 8;
const GIL_DONTCACHE = 16;

const FVSIF_RECT = 1;
const FVSIF_PINNED = 2;
const FVSIF_NEWFAILED = 0x8000000;
const FVSIF_NEWFILE = 0x80000000;
const FVSIF_CANVIEWIT = 0x40000000;

const CDBOSC_SETFOCUS = 0;
const CDBOSC_KILLFOCUS = 1;
const CDBOSC_SELCHANGE = 2;
const CDBOSC_RENAME = 3;

const FCIDM_SHVIEWFIRST = 0;
const FCIDM_SHVIEWLAST = 0x7fff;
const FCIDM_BROWSERFIRST = 0xa000;
const FCIDM_BROWSERLAST = 0xbf00;
const FCIDM_GLOBALFIRST = 0x8000;
const FCIDM_GLOBALLAST = 0x9fff;
const FCIDM_MENU_FILE = FCIDM_GLOBALFIRST;
const FCIDM_MENU_EDIT = FCIDM_GLOBALFIRST+0x0040;
const FCIDM_MENU_VIEW = FCIDM_GLOBALFIRST+0x0080;
const FCIDM_MENU_VIEW_SEP_OPTIONS = FCIDM_GLOBALFIRST+0x0081;
const FCIDM_MENU_TOOLS = FCIDM_GLOBALFIRST+0x00c0;
const FCIDM_MENU_TOOLS_SEP_GOTO = FCIDM_GLOBALFIRST+0x00c1;
const FCIDM_MENU_HELP = FCIDM_GLOBALFIRST+0x0100;
const FCIDM_MENU_FIND = FCIDM_GLOBALFIRST+0x0140;
const FCIDM_MENU_EXPLORE = FCIDM_GLOBALFIRST+0x0150;
const FCIDM_MENU_FAVORITES = FCIDM_GLOBALFIRST+0x0170;
const FCIDM_TOOLBAR = FCIDM_BROWSERFIRST;
const FCIDM_STATUS = FCIDM_BROWSERFIRST+1;

const SBSP_DEFBROWSER = 0;
const SBSP_SAMEBROWSER = 1;
const SBSP_NEWBROWSER = 2;
const SBSP_DEFMODE = 0;
const SBSP_OPENMODE = 16;
const SBSP_EXPLOREMODE = 32;
const SBSP_ABSOLUTE = 0;
const SBSP_RELATIVE = 0x1000;
const SBSP_PARENT = 0x2000;
const SBSP_INITIATEDBYHLINKFRAME = 0x80000000;
const SBSP_REDIRECT = 0x40000000;

enum {
	FCW_STATUS=1,
	FCW_TOOLBAR,
	FCW_TREE
}

const FCT_MERGE=1;
const FCT_CONFIGABLE=2;
const FCT_ADDTOEND=4;

const SVSI_DESELECT=0;
const SVSI_SELECT=1;
const SVSI_EDIT=3;
const SVSI_DESELECTOTHERS=4;
const SVSI_ENSUREVISIBLE=8;
const SVSI_FOCUSED=16;

const SVGIO_BACKGROUND=0;
const SVGIO_SELECTION=1;
const SVGIO_ALLVIEW=2;

const UINT SV2GV_CURRENTVIEW=-1;
const UINT SV2GV_DEFAULTVIEW=-2;

alias ULONG SFGAOF;
alias DWORD SHGDNF;

struct CIDA {
	UINT    cidl;
	UINT[1] aoffset;
}
alias CIDA* LPIDA;

struct SHITEMID {
	USHORT  cb;
	BYTE[1] abID;
}
alias SHITEMID* LPSHITEMID, LPCSHITEMID;

struct ITEMIDLIST {
	SHITEMID mkid;
}
alias ITEMIDLIST* LPITEMIDLIST, LPCITEMIDLIST;

alias int function(HWND,UINT,LPARAM,LPARAM) BFFCALLBACK;

struct BROWSEINFOA {
	HWND          hwndOwner;
	LPCITEMIDLIST pidlRoot;
	LPSTR         pszDisplayName;
	LPCSTR        lpszTitle;
	UINT          ulFlags;
	BFFCALLBACK   lpfn;
	LPARAM        lParam;
	int           iImage;
}
alias BROWSEINFOA* PBROWSEINFOA, LPBROWSEINFOA;

struct BROWSEINFOW {
	HWND          hwndOwner;
	LPCITEMIDLIST pidlRoot;
	LPWSTR        pszDisplayName;
	LPCWSTR       lpszTitle;
	UINT          ulFlags;
	BFFCALLBACK   lpfn;
	LPARAM        lParam;
	int           iImage;
}
alias BROWSEINFOW* PBROWSEINFOW, LPBROWSEINFOW;

struct CMINVOKECOMMANDINFO {
	DWORD cbSize = this.sizeof;
	DWORD fMask;
	HWND hwnd;
	LPCSTR lpVerb;
	LPCSTR lpParameters;
	LPCSTR lpDirectory;
	int nShow;
	DWORD dwHotKey;
	HANDLE hIcon;
}
alias CMINVOKECOMMANDINFO* LPCMINVOKECOMMANDINFO;

struct DROPFILES {
	DWORD pFiles;
	POINT pt;
	BOOL fNC;
	BOOL fWide;
}
alias DROPFILES* LPDROPFILES;

enum SHGNO {
	SHGDN_NORMAL             = 0,
	SHGDN_INFOLDER,
	SHGDN_FOREDITING         = 0x1000,
	SHGDN_INCLUDE_NONFILESYS = 0x2000,
	SHGDN_FORADDRESSBAR      = 0x4000,
	SHGDN_FORPARSING         = 0x8000
}

enum SHCONTF {
	SHCONTF_FOLDERS            = 32,
	SHCONTF_NONFOLDERS         = 64,
	SHCONTF_INCLUDEHIDDEN      = 128,
	SHCONTF_INIT_ON_FIRST_NEXT = 256,
	SHCONTF_NETPRINTERSRCH     = 512,
	SHCONTF_SHAREABLE          = 1024,
	SHCONTF_STORAGE            = 2048
}

struct STRRET {
	UINT uType;
	union {
		LPWSTR pOleStr;
		UINT uOffset;
		char cStr[MAX_PATH];
	}
}
alias STRRET* LPSTRRET;

enum FD_FLAGS {
	FD_CLSID      = 1,
	FD_SIZEPOINT  = 2,
	FD_ATTRIBUTES = 4,
	FD_CREATETIME = 8,
	FD_ACCESSTIME = 16,
	FD_WRITESTIME = 32,
	FD_FILESIZE   = 64,
	FD_LINKUI     = 0x8000
}

struct FILEDESCRIPTORA {
	DWORD dwFlags;
	CLSID clsid;
	SIZEL sizel;
	POINTL pointl;
	DWORD dwFileAttributes;
	FILETIME ftCreationTime;
	FILETIME ftLastAccessTime;
	FILETIME ftLastWriteTime;
	DWORD nFileSizeHigh;
	DWORD nFileSizeLow;
	CHAR cFileName[MAX_PATH];
}
alias FILEDESCRIPTORA* LPFILEDESCRIPTORA;

struct FILEDESCRIPTORW {
	DWORD dwFlags;
	CLSID clsid;
	SIZEL sizel;
	POINTL pointl;
	DWORD dwFileAttributes;
	FILETIME ftCreationTime;
	FILETIME ftLastAccessTime;
	FILETIME ftLastWriteTime;
	DWORD nFileSizeHigh;
	DWORD nFileSizeLow;
	WCHAR cFileName[MAX_PATH];
}
alias FILEDESCRIPTORW* LPFILEDESCRIPTORW;

struct FILEGROUPDESCRIPTORA {
	UINT cItems;
	FILEDESCRIPTORA fgd[1];
}
alias FILEGROUPDESCRIPTORA* LPFILEGROUPDESCRIPTORA;

struct FILEGROUPDESCRIPTORW {
	UINT cItems;
	FILEDESCRIPTORW fgd[1];
}
alias FILEGROUPDESCRIPTORW* LPFILEGROUPDESCRIPTORW;

enum SLR_FLAGS {
	SLR_NO_UI      = 1,
	SLR_ANY_MATCH  = 2,
	SLR_UPDATE     = 4,
	SLR_NOUPDATE   = 8,
	SLR_NOSEARCH   = 16,
	SLR_NOTRACK    = 32,
	SLR_NOLINKINFO = 64,
	SLR_INVOKE_MSI = 128
}

enum SLGP_FLAGS {
	SLGP_SHORTPATH=1,
	SLGP_UNCPRIORITY=2,
	SLGP_RAWPATH=4
}

alias PBYTE LPVIEWSETTINGS;

enum FOLDERFLAGS {
	FWF_AUTOARRANGE         = 1,
	FWF_ABBREVIATEDNAMES    = 2,
	FWF_SNAPTOGRID          = 4,
	FWF_OWNERDATA           = 8,
	FWF_BESTFITWINDOW       = 16,
	FWF_DESKTOP             = 32,
	FWF_SINGLESEL           = 64,
	FWF_NOSUBFOLDERS        = 128,
	FWF_TRANSPARENT         = 256,
	FWF_NOCLIENTEDGE        = 512,
	FWF_NOSCROLL            = 0x400,
	FWF_ALIGNLEFT           = 0x800,
	FWF_SINGLECLICKACTIVATE = 0x8000
}

enum FOLDERVIEWMODE {
	FVM_ICON      = 1,
	FVM_SMALLICON,
	FVM_LIST,
	FVM_DETAILS
}

struct FOLDERSETTINGS {
	UINT ViewMode;
	UINT fFlags;
}
alias FOLDERSETTINGS* LPFOLDERSETTINGS, LPCFOLDERSETTINGS;

struct FVSHOWINFO {
	DWORD cbSize = this.sizeof;
	HWND hwndOwner;
	int iShow;
	DWORD dwFlags;
	RECT rect;
	LPUNKNOWN punkRel;
	OLECHAR strNewFile[MAX_PATH];
}
alias FVSHOWINFO* LPFVSHOWINFO;

struct NRESARRAY {
	UINT cItems;
	NETRESOURCE nr[1];
}
alias NRESARRAY* LPNRESARRAY;

enum {
	SBSC_HIDE,
	SBSC_SHOW,
	SBSC_TOGGLE,
	SBSC_QUERY
}

enum {
	SBCMDID_ENABLESHOWTREE,
	SBCMDID_SHOWCONTROL,
	SBCMDID_CANCELNAVIGATION,
	SBCMDID_MAYSAVECHANGES,
	SBCMDID_SETHLINKFRAME,
	SBCMDID_ENABLESTOP,
	SBCMDID_OPTIONS
}
enum SVUIA_STATUS {
	SVUIA_DEACTIVATE,
	SVUIA_ACTIVATE_NOFOCUS,
	SVUIA_ACTIVATE_FOCUS,
	SVUIA_INPLACEACTIVATE
}

static if (_WIN32_IE >= 0x0500) {

	struct EXTRASEARCH
	 {
		GUID guidSearch;
		WCHAR wszFriendlyName[80];
		WCHAR wszUrl[2084];
	}
	alias EXTRASEARCH* LPEXTRASEARCH;

	alias DWORD SHCOLSTATEF;

	struct SHCOLUMNID {
		GUID fmtid;
		DWORD pid;
	}
	alias SHCOLUMNID* LPSHCOLUMNID, LPCSHCOLUMNID;

	struct SHELLDETAILS {
		int fmt;
		int cxChar;
		STRRET str;
	}
	alias SHELLDETAILS* LPSHELLDETAILS;

	struct PERSIST_FOLDER_TARGET_INFO
	 {
		LPITEMIDLIST pidlTargetFolder;
		WCHAR szTargetParsingName[MAX_PATH];
		WCHAR szNetworkProvider[MAX_PATH];
		DWORD dwAttributes;
		int csidl;
	}

	enum SHGFP_TYPE {
		SHGFP_TYPE_CURRENT = 0,
		SHGFP_TYPE_DEFAULT = 1,
	}

}

interface IEnumIDList: public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT Next(ULONG,LPITEMIDLIST*,ULONG*);
	HRESULT Skip(ULONG);
	HRESULT Reset();
	HRESULT Clone(IEnumIDList**);
}
alias IEnumIDList *LPENUMIDLIST;

interface IObjMgr : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT Append(IUnknown*);
	HRESULT Remove(IUnknown*);
}

interface IContextMenu : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT QueryContextMenu(HMENU,UINT,UINT,UINT,UINT);
	HRESULT InvokeCommand(LPCMINVOKECOMMANDINFO);
	HRESULT GetCommandString(UINT,UINT,PUINT,LPSTR,UINT);
}
alias IContextMenu* LPCONTEXTMENU;

interface IContextMenu2 : public IContextMenu
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT QueryContextMenu(HMENU,UINT,UINT,UINT,UINT);
	HRESULT InvokeCommand(LPCMINVOKECOMMANDINFO);
	HRESULT GetCommandString(UINT,UINT,PUINT,LPSTR,UINT);
	HRESULT HandleMenuMsg(UINT,WPARAM,LPARAM);
};
alias IContextMenu2* LPCONTEXTMENU2;

static if (_WIN32_IE >= 0x0500) {

	align(8):
	struct SHCOLUMNINIT {
		ULONG dwFlags;
		ULONG dwReserved;
		WCHAR wszFolder[MAX_PATH];
	}
	alias SHCOLUMNINIT* LPSHCOLUMNINIT, LPCSHCOLUMNINIT;

	struct SHCOLUMNDATA {
		ULONG dwFlags;
		DWORD dwFileAttributes;
		ULONG dwReserved;
		WCHAR *pwszExt;
		WCHAR wszFile[MAX_PATH];
	}
	alias SHCOLUMNDATA* LPSHCOLUMNDATA, LPCSHCOLUMNDATA;
	align:

	const MAX_COLUMN_NAME_LEN = 80;
	const MAX_COLUMN_DESC_LEN = 128;

	align(1):
	struct SHCOLUMNINFO {
		SHCOLUMNID scid;
		VARTYPE vt;
		DWORD fmt;
		UINT cChars;
		DWORD csFlags;
		WCHAR wszTitle[MAX_COLUMN_NAME_LEN];
		WCHAR wszDescription[MAX_COLUMN_DESC_LEN];
	}
	alias SHCOLUMNINFO* LPSHCOLUMNINFO, LPCSHCOLUMNINFO;
	align:

	enum SHCOLSTATE {
		SHCOLSTATE_TYPE_STR      = 0x00000001,
		SHCOLSTATE_TYPE_INT      = 0x00000002,
		SHCOLSTATE_TYPE_DATE     = 0x00000003,
		SHCOLSTATE_TYPEMASK      = 0x0000000f,
		SHCOLSTATE_ONBYDEFAULT   = 0x00000010,
		SHCOLSTATE_SLOW          = 0x00000020,
		SHCOLSTATE_EXTENDED      = 0x00000040,
		SHCOLSTATE_SECONDARYUI   = 0x00000080,
		SHCOLSTATE_HIDDEN        = 0x00000100,
		SHCOLSTATE_PREFER_VARCMP = 0x00000200
	}

	interface IColumnProvider : public IUnknown
	 {
		HRESULT QueryInterface(REFIID,PVOID*);
		ULONG AddRef();
		ULONG Release();
		HRESULT Initialize(LPCSHCOLUMNINIT);
		HRESULT GetColumnInfo(DWORD,SHCOLUMNINFO*);
		HRESULT GetItemData(LPCSHCOLUMNID,LPCSHCOLUMNDATA,VARIANT*);
	}
}/* _WIN32_IE >= 0x0500 */

interface IQueryInfo : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetInfoTip(DWORD,WCHAR**);
	HRESULT GetInfoFlags(DWORD*);
}

interface IShellExtInit : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT Initialize(LPCITEMIDLIST,LPDATAOBJECT,HKEY);
}
alias IShellExtInit *LPSHELLEXTINIT;

interface IShellPropSheetExt : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT AddPages(LPFNADDPROPSHEETPAGE,LPARAM);
	HRESULT ReplacePage(UINT,LPFNADDPROPSHEETPAGE,LPARAM);
}
alias IShellPropSheetExt *LPSHELLPROPSHEETEXT;

interface IExtractIconA : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetIconLocation(UINT,LPSTR,UINT,int*,PUINT);
	HRESULT Extract(LPCSTR,UINT,HICON*,HICON*,UINT);
};
alias IExtractIconA *LPEXTRACTICONA;

interface IExtractIconW : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetIconLocation(UINT,LPWSTR,UINT,int*,PUINT);
	HRESULT Extract(LPCWSTR,UINT,HICON*,HICON*,UINT);
}
alias IExtractIconW *LPEXTRACTICONW;

version(Unicode) {
	alias IExtractIconW IExtractIcon;
	alias LPEXTRACTICONW LPEXTRACTICON;
} else {
	alias IExtractIconA IExtractIcon;
	alias LPEXTRACTICONA LPEXTRACTICON;
}

interface IShellLinkA : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetPath(LPSTR,int,WIN32_FIND_DATAA*,DWORD);
	HRESULT GetIDList(LPITEMIDLIST*);
	HRESULT SetIDList(LPCITEMIDLIST);
	HRESULT GetDescription(LPSTR,int);
	HRESULT SetDescription(LPCSTR);
	HRESULT GetWorkingDirectory(LPSTR,int);
	HRESULT SetWorkingDirectory(LPCSTR);
	HRESULT GetArguments(LPSTR,int);
	HRESULT SetArguments(LPCSTR);
	HRESULT GetHotkey(PWORD);
	HRESULT SetHotkey(WORD);
	HRESULT GetShowCmd(int*);
	HRESULT SetShowCmd(int);
	HRESULT GetIconLocation(LPSTR,int,int*);
	HRESULT SetIconLocation(LPCSTR,int);
	HRESULT SetRelativePath(LPCSTR ,DWORD);
	HRESULT Resolve(HWND,DWORD);
	HRESULT SetPath(LPCSTR);
}

interface IShellLinkW : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetPath(LPWSTR,int,WIN32_FIND_DATAW*,DWORD);
	HRESULT GetIDList(LPITEMIDLIST*);
	HRESULT SetIDList(LPCITEMIDLIST);
	HRESULT GetDescription(LPWSTR,int);
	HRESULT SetDescription(LPCWSTR);
	HRESULT GetWorkingDirectory(LPWSTR,int);
	HRESULT SetWorkingDirectory(LPCWSTR);
	HRESULT GetArguments(LPWSTR,int);
	HRESULT SetArguments(LPCWSTR);
	HRESULT GetHotkey(PWORD);
	HRESULT SetHotkey(WORD);
	HRESULT GetShowCmd(int*);
	HRESULT SetShowCmd(int);
	HRESULT GetIconLocation(LPWSTR,int,int*);
	HRESULT SetIconLocation(LPCWSTR,int);
	HRESULT SetRelativePath(LPCWSTR ,DWORD);
	HRESULT Resolve(HWND,DWORD);
	HRESULT SetPath(LPCWSTR);
}


interface IShellFolder : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT ParseDisplayName(HWND,LPBC,LPOLESTR,PULONG,LPITEMIDLIST*,PULONG);
	HRESULT EnumObjects(HWND,DWORD,LPENUMIDLIST*);
	HRESULT BindToObject(LPCITEMIDLIST,LPBC,REFIID,PVOID*);
	HRESULT BindToStorage(LPCITEMIDLIST,LPBC,REFIID,PVOID*);
	HRESULT CompareIDs(LPARAM,LPCITEMIDLIST,LPCITEMIDLIST);
	HRESULT CreateViewObject(HWND,REFIID,PVOID*);
	HRESULT GetAttributesOf(UINT,LPCITEMIDLIST*,PULONG);
	HRESULT GetUIObjectOf(HWND,UINT,LPCITEMIDLIST*,REFIID,PUINT,PVOID*);
	HRESULT GetDisplayNameOf(LPCITEMIDLIST,DWORD,LPSTRRET);
	HRESULT SetNameOf(HWND,LPCITEMIDLIST,LPCOLESTR,DWORD,LPITEMIDLIST*);
}
alias IShellFolder *LPSHELLFOLDER;

static if (_WIN32_IE >= 0x0500) {

interface IEnumExtraSearch: public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT Next(ULONG,LPEXTRASEARCH*,ULONG*);
	HRESULT Skip(ULONG);
	HRESULT Reset();
	HRESULT Clone(IEnumExtraSearch**);
}
alias IEnumExtraSearch *LPENUMEXTRASEARCH;

interface IShellFolder2 : public IShellFolder
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT ParseDisplayName(HWND,LPBC,LPOLESTR,PULONG,LPITEMIDLIST*,PULONG);
	HRESULT EnumObjects(HWND,DWORD,LPENUMIDLIST*);
	HRESULT BindToObject(LPCITEMIDLIST,LPBC,REFIID,PVOID*);
	HRESULT BindToStorage(LPCITEMIDLIST,LPBC,REFIID,PVOID*);
	HRESULT CompareIDs(LPARAM,LPCITEMIDLIST,LPCITEMIDLIST);
	HRESULT CreateViewObject(HWND,REFIID,PVOID*);
	HRESULT GetAttributesOf(UINT,LPCITEMIDLIST*,PULONG);
	HRESULT GetUIObjectOf(HWND,UINT,LPCITEMIDLIST*,REFIID,PUINT,PVOID*);
	HRESULT GetDisplayNameOf(LPCITEMIDLIST,DWORD,LPSTRRET);
	HRESULT SetNameOf(HWND,LPCITEMIDLIST,LPCOLESTR,DWORD,LPITEMIDLIST*);
	HRESULT GetDefaultSearchGUID(GUID*);
	HRESULT EnumSearches(IEnumExtraSearch**);
	HRESULT GetDefaultColumn(DWORD,ULONG*,ULONG*);
	HRESULT GetDefaultColumnState(UINT,SHCOLSTATEF*);
	HRESULT GetDetailsEx(LPCITEMIDLIST, SHCOLUMNID*,VARIANT*);
	HRESULT GetDetailsOf(LPCITEMIDLIST,UINT,SHELLDETAILS*);
	HRESULT MapColumnToSCID(UINT,SHCOLUMNID*);
}
alias IShellFolder2 *LPSHELLFOLDER2;

} /* _WIN32_IE >= 0x0500 */

interface ICopyHook : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	UINT CopyCallback(HWND,UINT,UINT,LPCSTR,DWORD,LPCSTR,DWORD);
}
alias ICopyHook *LPCOPYHOOK;

interface IFileViewerSite : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT SetPinnedWindow(HWND);
	HRESULT GetPinnedWindow(HWND*);
}
alias IFileViewerSite *LPFILEVIEWERSITE;

interface IFileViewer : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT ShowInitialize(LPFILEVIEWERSITE);
	HRESULT Show(LPFVSHOWINFO);
	HRESULT PrintTo(LPSTR,BOOL);
}
alias IFileViewer *LPFILEVIEWER;

interface IFileSystemBindData : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT SetFindData( WIN32_FIND_DATAW*);
	HRESULT GetFindData(WIN32_FIND_DATAW*);
}

interface IPersistFolder : public IPersist
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetClassID(CLSID*);
	HRESULT Initialize(LPCITEMIDLIST);
}
alias IPersistFolder *LPPERSISTFOLDER;

static if (_WIN32_IE >= 0x0400 || _WIN32_WINNT >= 0x0500) {

interface IPersistFolder2 : public IPersistFolder
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetClassID(CLSID*);
	HRESULT Initialize(LPCITEMIDLIST);
	HRESULT GetCurFolder(LPITEMIDLIST*);
}
alias IPersistFolder2 *LPPERSISTFOLDER2;

}/* _WIN32_IE >= 0x0400 || _WIN32_WINNT >= 0x0500 */

static if (_WIN32_IE >= 0x0500) {

interface IPersistFolder3 : public IPersistFolder2
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetClassID(CLSID*);
	HRESULT Initialize(LPCITEMIDLIST);
	HRESULT GetCurFolder(LPITEMIDLIST*);
	HRESULT InitializeEx(IBindCtx*,LPCITEMIDLIST, PERSIST_FOLDER_TARGET_INFO*);
	HRESULT GetFolderTargetInfo(PERSIST_FOLDER_TARGET_INFO*);
}
alias IPersistFolder3 *LPPERSISTFOLDER3;

} /* _WIN32_IE >= 0x0500 */

alias IShellBrowser* LPSHELLBROWSER;
alias IShellView* LPSHELLVIEW;

interface IShellBrowser : public IOleWindow
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetWindow(HWND*);
	HRESULT ContextSensitiveHelp(BOOL);
	HRESULT InsertMenusSB(HMENU,LPOLEMENUGROUPWIDTHS);
	HRESULT SetMenuSB(HMENU,HOLEMENU,HWND);
	HRESULT RemoveMenusSB(HMENU);
	HRESULT SetStatusTextSB(LPCOLESTR);
	HRESULT EnableModelessSB(BOOL);
	HRESULT TranslateAcceleratorSB(LPMSG,WORD);
	HRESULT BrowseObject(LPCITEMIDLIST,UINT);
	HRESULT GetViewStateStream(DWORD,LPSTREAM*);
	HRESULT GetControlWindow(UINT,HWND*);
	HRESULT SendControlMsg(UINT,UINT,WPARAM,LPARAM,LRESULT*);
	HRESULT QueryActiveShellView(LPSHELLVIEW*);
	HRESULT OnViewWindowActive(LPSHELLVIEW);
	HRESULT SetToolbarItems(LPTBBUTTON,UINT,UINT);
}

interface IShellView : public IOleWindow
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetWindow(HWND*);
	HRESULT ContextSensitiveHelp(BOOL);
	HRESULT TranslateAccelerator(LPMSG);
//[No] #ifdef _FIX_ENABLEMODELESS_CONFLICT
//[No] 	STDMETHOD(EnableModelessSV)(THIS_ BOOL) PURE;
//[Yes] #else
	HRESULT EnableModeless(BOOL);
//[Yes] #endif
	HRESULT UIActivate(UINT);
	HRESULT Refresh();
	HRESULT CreateViewWindow(IShellView*,LPCFOLDERSETTINGS,LPSHELLBROWSER,RECT*,HWND*);
	HRESULT DestroyViewWindow();
	HRESULT GetCurrentInfo(LPFOLDERSETTINGS);
	HRESULT AddPropertySheetPages(DWORD,LPFNADDPROPSHEETPAGE,LPARAM);
	HRESULT SaveViewState();
	HRESULT SelectItem(LPCITEMIDLIST,UINT);
	HRESULT GetItemObject(UINT,REFIID,PVOID*);
}

interface ICommDlgBrowser : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT OnDefaultCommand(IShellView*);
	HRESULT OnStateChange(IShellView*,ULONG);
	HRESULT IncludeObject(IShellView*,LPCITEMIDLIST);
}
alias ICommDlgBrowser *LPCOMMDLGBROWSER;

alias GUID SHELLVIEWID;

struct SV2CVW2_PARAMS {
	DWORD cbSize = this.sizeof;
	IShellView *psvPrev;
	FOLDERSETTINGS  *pfs;
	IShellBrowser *psbOwner;
	RECT *prcView;
	SHELLVIEWID  *pvid;
	HWND hwndView;
}
alias SV2CVW2_PARAMS* LPSV2CVW2_PARAMS;

interface IShellView2 : public IShellView
{

	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetWindow(HWND*);
	HRESULT ContextSensitiveHelp(BOOL);
	HRESULT TranslateAccelerator(LPMSG);
//[No] #ifdef _FIX_ENABLEMODELESS_CONFLICT
//[No] 	STDMETHOD(EnableModelessSV)(THIS_ BOOL) PURE;
//[Yes] #else
	HRESULT EnableModeless(BOOL);
//[Yes] #endif
	HRESULT UIActivate(UINT);
	HRESULT Refresh();
	HRESULT CreateViewWindow(IShellView*,LPCFOLDERSETTINGS,LPSHELLBROWSER,RECT*,HWND*);
	HRESULT DestroyViewWindow();
	HRESULT GetCurrentInfo(LPFOLDERSETTINGS);
	HRESULT AddPropertySheetPages(DWORD,LPFNADDPROPSHEETPAGE,LPARAM);
	HRESULT SaveViewState();
	HRESULT SelectItem(LPCITEMIDLIST,UINT);
	HRESULT GetItemObject(UINT,REFIID,PVOID*);
	HRESULT GetView(SHELLVIEWID*,ULONG);
	HRESULT CreateViewWindow2(LPSV2CVW2_PARAMS);
}

interface IShellExecuteHookA : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT Execute(LPSHELLEXECUTEINFOA);
}

interface IShellExecuteHookW : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT Execute(LPSHELLEXECUTEINFOW);
}

interface IShellIcon : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT GetIconOf(LPCITEMIDLIST,UINT,PINT);
}
alias IShellIcon* LPSHELLICON;

struct SHELLFLAGSTATE {
// TODO
 short bitflags_; // for D.
 /*
	BOOL fShowAllObjects : 1;
	BOOL fShowExtensions : 1;
	BOOL fNoConfirmRecycle : 1;
	BOOL fShowSysFiles : 1;
	BOOL fShowCompColor : 1;
	BOOL fDoubleClickInWebView : 1;
	BOOL fDesktopHTML : 1;
	BOOL fWin95Classic : 1;
	BOOL fDontPrettyPath : 1;
	BOOL fShowAttribCol : 1;
	BOOL fMapNetDrvBtn : 1;
	BOOL fShowInfoTip : 1;
	BOOL fHideIcons : 1;
	UINT fRestFlags : 3;
*/
}
alias SHELLFLAGSTATE* LPSHELLFLAGSTATE;

const SSF_SHOWALLOBJECTS = 0x1;
const SSF_SHOWEXTENSIONS = 0x2;
const SSF_SHOWCOMPCOLOR = 0x8;
const SSF_SHOWSYSFILES = 0x20;
const SSF_DOUBLECLICKINWEBVIEW = 0x80;
const SSF_SHOWATTRIBCOL = 0x100;
const SSF_DESKTOPHTML = 0x200;
const SSF_WIN95CLASSIC = 0x400;
const SSF_DONTPRETTYPATH = 0x800;
const SSF_MAPNETDRVBUTTON = 0x1000;
const SSF_SHOWINFOTIP = 0x2000;
const SSF_HIDEICONS = 0x4000;
const SSF_NOCONFIRMRECYCLE = 0x8000;

interface IShellIconOverlayIdentifier : public IUnknown
{
	HRESULT QueryInterface(REFIID,PVOID*);
	ULONG AddRef();
	ULONG Release();
	HRESULT IsMemberOf(LPCWSTR,DWORD);
	HRESULT GetOverlayInfo(LPWSTR,int,int*,DWORD*);
	HRESULT GetPriority(int*);
}

const ISIOI_ICONFILE  = 0x00000001;
const ISIOI_ICONINDEX = 0x00000002;

static if (_WIN32_WINNT >= 0x0500) {/* W2K */
	struct SHELLSTATE {
	//TODO:
	/*
		BOOL fShowAllObjects : 1;
		BOOL fShowExtensions : 1;
		BOOL fNoConfirmRecycle : 1;
		BOOL fShowSysFiles : 1;
		BOOL fShowCompColor : 1;
		BOOL fDoubleClickInWebView : 1;
		BOOL fDesktopHTML : 1;
		BOOL fWin95Classic : 1;
		BOOL fDontPrettyPath : 1;
		BOOL fShowAttribCol : 1;
		BOOL fMapNetDrvBtn : 1;
		BOOL fShowInfoTip : 1;
		BOOL fHideIcons : 1;
		BOOL fWebView : 1;
		BOOL fFilter : 1;
		BOOL fShowSuperHidden : 1;
		BOOL fNoNetCrawling : 1;
		DWORD dwWin95Unused;
		UINT uWin95Unused;
		LONG lParamSort;
		int iSortDirection;
		UINT version;
		UINT uNotUsed;
		BOOL fSepProcess : 1;
		BOOL fStartPanelOn : 1;
		BOOL fShowStartPage : 1;
		UINT fSpareFlags : 13;
*/
	}
	alias SHELLSTATE* LPSHELLSTATE;
}

static if (_WIN32_IE >= 0x0500) {
	align(8):
	struct SHDRAGIMAGE {
		SIZE sizeDragImage;
		POINT ptOffset;
		HBITMAP hbmpDragImage;
		COLORREF crColorKey;
	}
	alias SHDRAGIMAGE* LPSHDRAGIMAGE;
	align:

	interface IDragSourceHelper : public IUnknown
	 {
		HRESULT QueryInterface(REFIID riid, void **ppv);
		ULONG AddRef();
		ULONG Release();
		HRESULT InitializeFromBitmap(LPSHDRAGIMAGE pshdi, IDataObject* pDataObject);
		HRESULT InitializeFromWindow(HWND hwnd, POINT* ppt, IDataObject* pDataObject);
	}

	interface IDropTargetHelper : public IUnknown
	 {
		HRESULT QueryInterface(REFIID riid, void** ppv);
		ULONG AddRef();
		ULONG Release();
		HRESULT DragEnter(HWND hwndTarget, IDataObject* pDataObject, POINT* ppt, DWORD dwEffect);
		HRESULT DragLeave();
		HRESULT DragOver(POINT* ppt, DWORD dwEffect);
		HRESULT Drop(IDataObject* pDataObject, POINT* ppt, DWORD dwEffect);
		HRESULT Show(BOOL fShow);
	}
}

extern (Windows):
void SHAddToRecentDocs(UINT,PCVOID);
LPITEMIDLIST SHBrowseForFolderA(PBROWSEINFOA);
LPITEMIDLIST SHBrowseForFolderW(PBROWSEINFOW);
void SHChangeNotify(LONG,UINT,PCVOID,PCVOID);
HRESULT SHGetDataFromIDListA(LPSHELLFOLDER,LPCITEMIDLIST,int,PVOID,int);
HRESULT SHGetDataFromIDListW(LPSHELLFOLDER,LPCITEMIDLIST,int,PVOID,int);
HRESULT SHGetDesktopFolder(LPSHELLFOLDER*);
HRESULT SHGetInstanceExplorer(IUnknown **);
HRESULT SHGetMalloc(LPMALLOC*);
BOOL SHGetPathFromIDListA(LPCITEMIDLIST,LPSTR);
BOOL SHGetPathFromIDListW(LPCITEMIDLIST,LPWSTR);
HRESULT SHGetSpecialFolderLocation(HWND,int,LPITEMIDLIST*);
HRESULT SHLoadInProc(REFCLSID);

static if (_WIN32_IE >= 0x0400) {
	BOOL SHGetSpecialFolderPathA(HWND,LPSTR,int,BOOL);
	BOOL SHGetSpecialFolderPathW(HWND,LPWSTR,int,BOOL);
}

/* SHGetFolderPath in shfolder.dll on W9x, NT4, also in shell32.dll on W2K */
HRESULT SHGetFolderPathA(HWND,int,HANDLE,DWORD,LPSTR);
HRESULT SHGetFolderPathW(HWND,int,HANDLE,DWORD,LPWSTR);

static if ((_WIN32_WINDOWS >= 0x0490) || (_WIN32_WINNT >= 0x0500)) {/* ME or W2K */
	HRESULT SHGetFolderLocation(HWND,int,HANDLE,DWORD,LPITEMIDLIST*);
}

static if (_WIN32_WINNT >= 0x0500) {
	INT SHCreateDirectoryExA(HWND,LPCSTR,LPSECURITY_ATTRIBUTES);
	INT SHCreateDirectoryExW(HWND,LPCWSTR,LPSECURITY_ATTRIBUTES);
	HRESULT SHBindToParent(LPCITEMIDLIST,REFIID,VOID**,LPCITEMIDLIST*);
}

static if (_WIN32_WINNT >= 0x0501) {/* XP */
	HRESULT SHGetFolderPathAndSubDirA(HWND,int,HANDLE,DWORD,LPCSTR,LPSTR);
	HRESULT SHGetFolderPathAndSubDirW(HWND,int,HANDLE,DWORD,LPCWSTR,LPWSTR);
}

void SHGetSettings(LPSHELLFLAGSTATE,DWORD);

static if (_WIN32_WINNT >= 0x0500) {/* W2K */
	void SHGetSetSettings(LPSHELLSTATE,DWORD,BOOL);
}

static if (_WIN32_WINNT >= 0x0500) {/* W2K */
	BOOL ILIsEqual(LPCITEMIDLIST, LPCITEMIDLIST);
	BOOL ILIsParent(LPCITEMIDLIST, LPCITEMIDLIST, BOOL);
	BOOL ILRemoveLastID(LPITEMIDLIST);
	HRESULT ILLoadFromStream(IStream*, LPITEMIDLIST*);
	HRESULT ILSaveToStream(IStream*, LPCITEMIDLIST);
	LPITEMIDLIST ILAppendID(LPITEMIDLIST, LPCSHITEMID, BOOL);
	LPITEMIDLIST ILClone(LPCITEMIDLIST);
	LPITEMIDLIST ILCloneFirst(LPCITEMIDLIST);
	LPITEMIDLIST ILCombine(LPCITEMIDLIST, LPCITEMIDLIST);
	LPITEMIDLIST ILFindChild(LPCITEMIDLIST, LPCITEMIDLIST);
	LPITEMIDLIST ILFindLastID(LPCITEMIDLIST);
	LPITEMIDLIST ILGetNext(LPCITEMIDLIST);
	UINT ILGetSize(LPCITEMIDLIST);
	void ILFree(LPITEMIDLIST);

	HRESULT SHCoCreateInstance(LPCWSTR,REFCLSID,IUnknown*,REFIID,void**);
}

version(Unicode) {
	alias IShellExecuteHookW IShellExecuteHook;
	alias IShellLinkW IShellLink;
	alias BROWSEINFOW BROWSEINFO;
	alias SHBrowseForFolderW SHBrowseForFolder;
	alias SHGetDataFromIDListW SHGetDataFromIDList;
	alias SHGetPathFromIDListW SHGetPathFromIDList;
	static if (_WIN32_IE >= 0x0400) {
		alias SHGetSpecialFolderPathW SHGetSpecialFolderPath;
	}
	alias SHGetFolderPathW SHGetFolderPath;
	static if (_WIN32_WINNT >= 0x0500) {
		alias SHCreateDirectoryExW SHCreateDirectoryEx;
	}
	static if (_WIN32_WINNT >= 0x0501) {
		alias SHGetFolderPathAndSubDirW SHGetFolderPathAndSubDir;
	}
	alias FILEDESCRIPTORW FILEDESCRIPTOR;
	alias LPFILEDESCRIPTORW LPFILEDESCRIPTOR;
	alias FILEGROUPDESCRIPTORW FILEGROUPDESCRIPTOR;
	alias LPFILEGROUPDESCRIPTORW LPFILEGROUPDESCRIPTOR;

} else {
	alias IShellExecuteHookA IShellExecuteHook;
	alias IShellLinkA IShellLink;
	alias BROWSEINFOA BROWSEINFO;
	alias SHBrowseForFolderA SHBrowseForFolder;
	alias SHGetDataFromIDListA SHGetDataFromIDList;
	alias SHGetPathFromIDListA SHGetPathFromIDList;
	static if (_WIN32_IE >= 0x0400) {
		alias SHGetSpecialFolderPathA SHGetSpecialFolderPath;
	}
	alias SHGetFolderPathA SHGetFolderPath;
	static if (_WIN32_WINNT >= 0x0500) {
		alias SHCreateDirectoryExA SHCreateDirectoryEx;
	}
	static if (_WIN32_WINNT >= 0x0501) {
		alias SHGetFolderPathAndSubDirA SHGetFolderPathAndSubDir;
	}
	alias FILEDESCRIPTORA FILEDESCRIPTOR;
	alias LPFILEDESCRIPTORA LPFILEDESCRIPTOR;
	alias FILEGROUPDESCRIPTORA FILEGROUPDESCRIPTOR;
	alias LPFILEGROUPDESCRIPTORA LPFILEGROUPDESCRIPTOR;
}
alias BROWSEINFO* PBROWSEINFO, LPBROWSEINFO;
