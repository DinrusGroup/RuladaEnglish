/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.sfml.nfuncs;

private
{
    import derelict.util.compat;
    import derelict.sfml.config;
    import derelict.sfml.ntypes;
}

extern(C)
{
    mixin(gsharedString!() ~
    "
    // Ftp.h
    void function(sfFtpListingResponse*) sfFtpListingResponse_Destroy;
    sfBool function(sfFtpListingResponse*) sfFtpListingResponse_IsOk;
    sfFtpStatus function(sfFtpListingResponse*) sfFtpListingResponse_GetStatus;
    CCPTR function(sfFtpListingResponse*) sfFtpListingResponse_GetMessage;
    size_t function(sfFtpListingResponse*) sfFtpListingResponse_GetCount;
    CCPTR function(sfFtpListingResponse*, size_t) sfFtpListingResponse_GetFilename;
    void function(sfFtpDirectoryResponse*) sfFtpDirectoryResponse_Destroy;
    sfBool function(sfFtpDirectoryResponse*) sfFtpDirectoryResponse_IsOk;
    sfFtpStatus function(sfFtpDirectoryResponse*) sfFtpDirectoryResponse_GetStatus;
    CCPTR function(sfFtpDirectoryResponse*) sfFtpDirectoryResponse_GetMessage;
    CCPTR function(sfFtpDirectoryResponse*) sfFtpDirectoryResponse_GetDirectory;
    void function(sfFtpResponse*) sfFtpResponse_Destroy;
    sfBool function(sfFtpResponse*) sfFtpResponse_IsOk;
    sfFtpStatus function(sfFtpResponse*) sfFtpResponse_GetStatus;
    CCPTR function(sfFtpResponse*) sfFtpResponse_GetMessage;
    sfFtp* function() sfFtp_Create;
    void function(sfFtp*) sfFtp_Destroy;
    sfFtpResponse* function(sfFtp*, sfIPAddress, ushort, float) sfFtp_Connect;
    sfFtpResponse* function(sfFtp*) sfFtp_LoginAnonymous;
    sfFtpResponse* function(sfFtp*, CCPTR, CCPTR) sfFtp_Login;
    sfFtpResponse* function(sfFtp*) sfFtp_Disconnect;
    sfFtpResponse* function(sfFtp*) sfFtp_KeepAlive;
    sfFtpDirectoryResponse* function(sfFtp*) sfFtp_GetWorkingDirectory;
    sfFtpListingResponse* function(sfFtp*, CCPTR) sfFtp_GetDirectoryListing;
    sfFtpResponse* function(sfFtp*, CCPTR) sfFtp_ChangeDirectory;
    sfFtpResponse* function(sfFtp*) sfFtp_ParentDirectory;
    sfFtpResponse* function(sfFtp*, CCPTR) sfFtp_MakeDirectory;
    sfFtpResponse* function(sfFtp*, CCPTR) sfFtp_DeleteDirectory;
    sfFtpResponse* function(sfFtp*, CCPTR, CCPTR) sfFtp_RenameFile;
    sfFtpResponse* function(sfFtp*, CCPTR) sfFtp_DeleteFile;
    sfFtpResponse* function(sfFtp*, CCPTR, CCPTR, sfFtpTransferMode) sfFtp_Download;
    sfFtpResponse* function(sfFtp*, CCPTR, CCPTR, sfFtpTransferMode) sfFtp_Upload;

    // Http.h
    sfHttpRequest* function() sfHttpRequest_Create;
    void function(sfHttpRequest*) sfHttpRequest_Destroy;
    void function(sfHttpRequest*, CCPTR, CCPTR) sfHttpRequest_SetField;
    void function(sfHttpRequest*, sfHttpMethod) sfHttpRequest_SetMethod;
    void function(sfHttpRequest*, CCPTR) sfHttpRequest_SetURI;
    void function(sfHttpRequest*, uint, uint) sfHttpRequest_SetHttpVersion;
    void function(sfHttpRequest*, CCPTR) sfHttpRequest_SetBody;
    void function(sfHttpRequest*) sfHttpResponse_Destroy;
    CCPTR function(sfHttpResponse*, CCPTR) sfHttpResponse_GetField;
    sfHttpStatus function(sfHttpResponse*) sfHttpResponse_GetStatus;
    uint function(sfHttpResponse*) sfHttpResponse_GetMajorVersion;
    uint function(sfHttpResponse*) sfHttpResponse_GetMinorVersion;
    CCPTR function(sfHttpResponse*) sfHttpResponse_GetBody;
    sfHttp* function() sfHttp_Create;
    void function(sfHttp*) sfHttp_Destroy;
    void function(sfHttp*, CCPTR, ushort) sfHttp_SetHost;
    sfHttpResponse* function(sfHttp*, sfHttpRequest*, float) sfHttp_SendRequest;

    // IPAddress.h
    sfIPAddress function(CCPTR) sfIPAddress_FromString;
    sfIPAddress function(sfUint8, sfUint8, sfUint8, sfUint8) sfIPAddress_FromBytes;
    sfIPAddress function(sfUint32) sfIPAddress_FromInteger;
    void function(sfIPAddress, char*) sfIPAddress_ToString;
    sfUint32 function(sfIPAddress) sfIPAddress_ToInteger;
    sfIPAddress function() sfIPAddress_GetLocalAddress;
    sfIPAddress function(float) sfIPAddress_GetPublicAddress;
    sfIPAddress function() sfIPAddress_LocalHost;

    // Packet.h
    sfPacket* function() sfPacket_Create;
    void function(sfPacket*) sfPacket_Destroy;
    void function(sfPacket*, void*, size_t) sfPacket_Append;
    void function(sfPacket*) sfPacket_Clear;
    CUBPTR function(sfPacket*) sfPacket_GetData;
    size_t function(sfPacket*) sfPacket_GetDataSize;
    sfBool function(sfPacket*) sfPacket_EndOfPacket;
    sfBool function(sfPacket*) sfPacket_CanRead;
    sfBool function(sfPacket*) sfPacket_ReadBool;
    sfInt8 function(sfPacket*) sfPacket_ReadInt8;
    sfUint8 function(sfPacket*) sfPacket_ReadUint8;
    sfInt16 function(sfPacket*) sfPacket_ReadInt16;
    sfUint16 function(sfPacket*) sfPacket_ReadUint16;
    sfInt32 function(sfPacket*) sfPacket_ReadInt32;
    sfUint32 function(sfPacket*) sfPacket_ReadUint32;
    float function(sfPacket*) sfPacket_ReadFloat;
    double function(sfPacket*) sfPacket_ReadDouble;
    void function(sfPacket*, char*) sfPacket_ReadString;
    void function(sfPacket*, wchar*) sfPacket_ReadWideString;
    void function(sfPacket*, sfBool) sfPacket_WriteBool;
    void function(sfPacket*, sfInt8) sfPacket_WriteInt8;
    void function(sfPacket*, sfUint8) sfPacket_WriteUint8;
    void function(sfPacket*, sfInt16) sfPacket_WriteInt16;
    void function(sfPacket*, sfUint16) sfPacket_WriteUint16;
    void function(sfPacket*, sfInt32) sfPacket_WriteInt32;
    void function(sfPacket*, sfUint32) sfPacket_WriteUint32;
    void function(sfPacket*, float) sfPacket_WriteFloat;
    void function(sfPacket*, double) sfPacket_WriteDouble;
    void function(sfPacket*, CCPTR) sfPacket_WriteString;
    void function(sfPacket*, CWCPTR) sfPacket_WriteWideString;

    // Selector.h
    sfSelectorTCP* function() sfSelectorTCP_Create;
    void function(sfSelectorTCP*) sfSelectorTCP_Destroy;
    void function(sfSelectorTCP*) sfSelectorTCP_Add;
    void function(sfSelectorTCP*) sfSelectorTCP_Remove;
    void function(sfSelectorTCP*) sfSelectorTCP_Clear;
    uint function(sfSelectorTCP*) sfSelectorTCP_Wait;
    sfSocketTCP* function(sfSelectorTCP*, uint) sfSelectorTCP_GetSocketReady;
    sfSelectorTCP* function() sfSelectorUDP_Create;
    void function(sfSelectorUDP*) sfSelectorUDP_Destroy;
    void function(sfSelectorUDP*) sfSelectorUDP_Add;
    void function(sfSelectorUDP*) sfSelectorUDP_Remove;
    void function(sfSelectorUDP*) sfSelectorUDP_Clear;
    uint function(sfSelectorUDP*) sfSelectorUDP_Wait;
    sfSocketUDP* function(sfSelectorUDP*, uint) sfSelectorUDP_GetSocketReady;

    // SocketTCP.h
    sfSocketTCP* function() sfSocketTCP_Create;
    void function(sfSocketTCP*) sfSocketTCP_Destroy;
    void function(sfSocketTCP*, sfBool) sfSocketTCP_SetBlocking;
    void function(sfSocketTCP*, ushort, sfIPAddress, float) sfSocketTCP_Connect;
    void function(sfSocketTCP*, ushort) sfSocketTCP_Listen;
    sfSocketStatus function(sfSocketTCP*, sfSocketTCP*, sfIPAddress*) sfSocketTCP_Accept;
    sfSocketStatus function(sfSocketTCP*, in ubyte*, size_t) sfSocketTCP_Send;
    sfSocketStatus function(sfSocketTCP*, ubyte*, size_t, size_t*) sfSocketTCP_Receive;
    sfSocketStatus function(sfSocketTCP*, sfPacket*) sfSocketTCP_SendPacket;
    sfSocketStatus function(sfSocketTCP*, sfPacket*) sfSocketTCP_ReceivePacket;
    sfBool function(sfSocketTCP*) sfSocketTCP_IsValid;

    // SocketUDP.h
    sfSocketUDP* function() sfSocketUDP_Create;
    void function(sfSocketUDP*) sfSocketUDP_Destroy;
    void function(sfSocketUDP*, sfBool) sfSocketUDP_SetBlocking;
    sfBool function(sfSocketUDP*, ushort) sfSocketUDP_Bind;
    sfBool function(sfSocketUDP*) sfSocketUDP_Unbind;
    sfSocketStatus function(sfSocketUDP*, in ubyte*, size_t) sfSocketUDP_Send;
    sfSocketStatus function(sfSocketUDP*, ubyte*, size_t, size_t*) sfSocketUDP_Receive;
    sfSocketStatus function(sfSocketUDP*, sfPacket*) sfSocketUDP_SendPacket;
    sfSocketStatus function(sfSocketUDP*, sfPacket*) sfSocketUDP_ReceivePacket;
    sfBool function(sfSocketUDP*) sfSocketUDP_IsValid;
    ");
}