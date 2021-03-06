/*
 *  PKCS#11 library for .Net smart cards
 *  Copyright (C) 2007-2009 Gemalto <support@gemalto.com>
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#ifndef _include_marshallercfg_h
#define _include_marshallercfg_h

#ifdef WIN32
#include <Windows.h>
#endif

#ifdef SMARTCARDMARSHALLER_EXPORTS
	#define SMARTCARDMARSHALLER_DLLAPI __declspec(dllexport)
#else
	#define SMARTCARDMARSHALLER_DLLAPI
#endif

#ifdef M_SAL_ANNOTATIONS
#include <specstrings.h>
#define M_SAL_IN		__in
#define M_SAL_OUT		__xout
#define M_SAL_INOUT		__inout
#else
#define M_SAL_IN
#define M_SAL_OUT
#define M_SAL_INOUT
#endif

#ifndef NULL
#define NULL 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef WIN32
#include <inttypes.h>
#endif

// data types
typedef unsigned char       u1;
typedef unsigned short      u2;
typedef unsigned int        u4;
typedef char                s1;
typedef short               s2;
typedef int                 s4;

#ifdef WIN32
typedef unsigned __int64    u8;
typedef __int64             s8;
typedef LPSTR               lpCharPtr;
typedef LPTSTR				lpTCharPtr;
typedef LPBYTE				lpByte;
typedef const lpByte        lpCByte;
#else
typedef uint64_t u8;
typedef int64_t s8;
typedef char*				 lpTCharPtr;
typedef char*                lpCharPtr;
typedef unsigned char*       lpByte;
typedef const lpByte		 lpCByte;
#endif

// Marshaller argument type constants
#define MARSHALLER_TYPE_IN_VOID				0
#define MARSHALLER_TYPE_IN_BOOL				1
#define MARSHALLER_TYPE_IN_S1				2
#define MARSHALLER_TYPE_IN_U1				3
#define MARSHALLER_TYPE_IN_CHAR				4
#define MARSHALLER_TYPE_IN_S2				5
#define MARSHALLER_TYPE_IN_U2				6
#define MARSHALLER_TYPE_IN_S4				7
#define MARSHALLER_TYPE_IN_U4				8
#define MARSHALLER_TYPE_IN_S8				9
#define MARSHALLER_TYPE_IN_U8				10
#define MARSHALLER_TYPE_IN_STRING			11

#define MARSHALLER_TYPE_IN_BOOLARRAY		21
#define MARSHALLER_TYPE_IN_S1ARRAY			22
#define MARSHALLER_TYPE_IN_U1ARRAY			23
#define MARSHALLER_TYPE_IN_CHARARRAY		24
#define MARSHALLER_TYPE_IN_S2ARRAY			25
#define MARSHALLER_TYPE_IN_U2ARRAY			26
#define MARSHALLER_TYPE_IN_S4ARRAY			27
#define MARSHALLER_TYPE_IN_U4ARRAY			28
#define MARSHALLER_TYPE_IN_S8ARRAY			29
#define MARSHALLER_TYPE_IN_U8ARRAY			30
#define MARSHALLER_TYPE_IN_STRINGARRAY		31

#define MARSHALLER_TYPE_IN_MEMORYSTREAM     40

#define MARSHALLER_TYPE_REF_BOOL			50
#define MARSHALLER_TYPE_REF_S1				51
#define MARSHALLER_TYPE_REF_U1				52
#define MARSHALLER_TYPE_REF_CHAR			53
#define MARSHALLER_TYPE_REF_S2				54
#define MARSHALLER_TYPE_REF_U2				55
#define MARSHALLER_TYPE_REF_S4				56
#define MARSHALLER_TYPE_REF_U4				57
#define MARSHALLER_TYPE_REF_S8				58
#define MARSHALLER_TYPE_REF_U8				59
#define MARSHALLER_TYPE_REF_STRING			60

#define MARSHALLER_TYPE_REF_BOOLARRAY		61
#define MARSHALLER_TYPE_REF_S1ARRAY			62
#define MARSHALLER_TYPE_REF_U1ARRAY			63
#define MARSHALLER_TYPE_REF_CHARARRAY		64
#define MARSHALLER_TYPE_REF_S2ARRAY			65
#define MARSHALLER_TYPE_REF_U2ARRAY			66
#define MARSHALLER_TYPE_REF_S4ARRAY			67
#define MARSHALLER_TYPE_REF_U4ARRAY			68
#define MARSHALLER_TYPE_REF_S8ARRAY			69
#define MARSHALLER_TYPE_REF_U8ARRAY			70
#define MARSHALLER_TYPE_REF_STRINGARRAY		71

// Marshaller return type arguments
#define MARSHALLER_TYPE_RET_VOID			MARSHALLER_TYPE_IN_VOID
#define MARSHALLER_TYPE_RET_BOOL			MARSHALLER_TYPE_IN_BOOL
#define MARSHALLER_TYPE_RET_S1				MARSHALLER_TYPE_IN_S1
#define MARSHALLER_TYPE_RET_U1				MARSHALLER_TYPE_IN_U1
#define MARSHALLER_TYPE_RET_CHAR			MARSHALLER_TYPE_IN_CHAR
#define MARSHALLER_TYPE_RET_S2				MARSHALLER_TYPE_IN_S2
#define MARSHALLER_TYPE_RET_U2				MARSHALLER_TYPE_IN_U2
#define MARSHALLER_TYPE_RET_S4				MARSHALLER_TYPE_IN_S4
#define MARSHALLER_TYPE_RET_U4				MARSHALLER_TYPE_IN_U4
#define MARSHALLER_TYPE_RET_S8				MARSHALLER_TYPE_IN_S8
#define MARSHALLER_TYPE_RET_U8				MARSHALLER_TYPE_IN_U8
#define MARSHALLER_TYPE_RET_STRING			MARSHALLER_TYPE_IN_STRING

#define MARSHALLER_TYPE_RET_BOOLARRAY		MARSHALLER_TYPE_IN_BOOLARRAY
#define MARSHALLER_TYPE_RET_S1ARRAY			MARSHALLER_TYPE_IN_S1ARRAY
#define MARSHALLER_TYPE_RET_U1ARRAY			MARSHALLER_TYPE_IN_U1ARRAY
#define MARSHALLER_TYPE_RET_CHARARRAY		MARSHALLER_TYPE_IN_CHARARRAY
#define MARSHALLER_TYPE_RET_S2ARRAY			MARSHALLER_TYPE_IN_S2ARRAY
#define MARSHALLER_TYPE_RET_U2ARRAY			MARSHALLER_TYPE_IN_U2ARRAY
#define MARSHALLER_TYPE_RET_S4ARRAY			MARSHALLER_TYPE_IN_S4ARRAY
#define MARSHALLER_TYPE_RET_U4ARRAY			MARSHALLER_TYPE_IN_U4ARRAY
#define MARSHALLER_TYPE_RET_S8ARRAY			MARSHALLER_TYPE_IN_S8ARRAY
#define MARSHALLER_TYPE_RET_U8ARRAY			MARSHALLER_TYPE_IN_U8ARRAY
#define MARSHALLER_TYPE_RET_STRINGARRAY		MARSHALLER_TYPE_IN_STRINGARRAY

#define MARSHALLER_TYPE_RET_MEMORYSTREAM    MARSHALLER_TYPE_IN_MEMORYSTREAM

// namespace for the module
// in case compiler does not support namespace, the defines can be undefined
#define MARSHALLER_NS_BEGIN namespace Marshaller {
#define MARSHALLER_NS_END }


#define SUPPORT_BETA_VERSION

#define APDU_TO_CARD_MAX_SIZE                                   0xFF

#define HIVECODE_NAMESPACE_SYSTEM                               0x00D25D1C
#define HIVECODE_NAMESPACE_SYSTEM_IO                            0x00D5E6DB
#define HIVECODE_NAMESPACE_SYSTEM_RUNTIME_REMOTING_CHANNELS     0x0000886E
#define HIVECODE_NAMESPACE_NETCARD_FILESYSTEM                   0x00A1AC39
#define HIVECODE_NAMESPACE_SYSTEM_RUNTIME_REMOTING              0x00EB3DD9
#define HIVECODE_NAMESPACE_SYSTEM_SECURITY_CRYPTOGRAPHY         0x00ACF53B
#define HIVECODE_NAMESPACE_SYSTEM_COLLECTIONS                   0x00C5A010
#define HIVECODE_NAMESPACE_SYSTEM_RUNTIME_REMOTING_CONTEXTS     0x001F4994
#define HIVECODE_NAMESPACE_SYSTEM_SECURITY                      0x00964145
#define HIVECODE_NAMESPACE_SYSTEM_REFLECTION                    0x0008750F
#define HIVECODE_NAMESPACE_SYSTEM_RUNTIME_SERIALIZATION         0x008D3B3D
#define HIVECODE_NAMESPACE_SYSTEM_RUNTIME_REMOTING_MESSAGING    0x00DEB940
#define HIVECODE_NAMESPACE_SYSTEM_DIAGNOSTICS                   0x0097995F
#define HIVECODE_NAMESPACE_SYSTEM_RUNTIME_COMPILERSERVICES      0x00F63E11
#define HIVECODE_NAMESPACE_SYSTEM_TEXT                          0x00702756

#define HIVECODE_TYPE_SYSTEM_VOID           0xCE81
#define HIVECODE_TYPE_SYSTEM_INT32          0x61C0
#define HIVECODE_TYPE_SYSTEM_INT32_ARRAY    0x61C1
#define HIVECODE_TYPE_SYSTEM_BOOLEAN        0x2227
#define HIVECODE_TYPE_SYSTEM_BOOLEAN_ARRAY  0x2228
#define HIVECODE_TYPE_SYSTEM_SBYTE          0x767E
#define HIVECODE_TYPE_SYSTEM_SBYTE_ARRAY    0x767F
#define HIVECODE_TYPE_SYSTEM_UINT16         0xD98B
#define HIVECODE_TYPE_SYSTEM_UINT16_ARRAY   0xD98C
#define HIVECODE_TYPE_SYSTEM_UINT32         0x95E7
#define HIVECODE_TYPE_SYSTEM_UINT32_ARRAY   0x95E8
#define HIVECODE_TYPE_SYSTEM_BYTE           0x45A2
#define HIVECODE_TYPE_SYSTEM_BYTE_ARRAY     0x45A3
#define HIVECODE_TYPE_SYSTEM_CHAR           0x958E
#define HIVECODE_TYPE_SYSTEM_CHAR_ARRAY     0x958F
#define HIVECODE_TYPE_SYSTEM_INT16          0xBC39
#define HIVECODE_TYPE_SYSTEM_INT16_ARRAY    0xBC3A
#define HIVECODE_TYPE_SYSTEM_STRING         0x1127
#define HIVECODE_TYPE_SYSTEM_STRING_ARRAY   0x1128
#define HIVECODE_TYPE_SYSTEM_INT64			0xDEFB
#define HIVECODE_TYPE_SYSTEM_INT64_ARRAY	0xDEFC
#define HIVECODE_TYPE_SYSTEM_UINT64			0x71AF
#define HIVECODE_TYPE_SYSTEM_UINT64_ARRAY	0x71B0

#define HIVECODE_TYPE_SYSTEM_IO_MEMORYSTREAM 0xFED7

	// for port discovery lookup.
#define CARDMANAGER_SERVICE_PORT                                                    1
#define CARDMANAGER_SERVICE_NAME                                                    "ContentManager"
#define HIVECODE_NAMESPACE_SMARTCARD                                                0x00F5EFBF
#define HIVECODE_TYPE_SMARTCARD_CONTENTMANAGER                                      0xB18C
#define HIVECODE_METHOD_SMARTCARD_CONTENTMANAGER_GETASSOCIATEDPORT                  0x7616

#define HIVECODE_TYPE_SYSTEM_EXCEPTION                                      0xD4B0
#define HIVECODE_TYPE_SYSTEM_SYSTEMEXCEPTION                                0x28AC
#define HIVECODE_TYPE_SYSTEM_OUTOFMEMORYEXCEPTION                           0xE14E
#define HIVECODE_TYPE_SYSTEM_ARGUMENTEXCEPTION                              0xAB8C
#define HIVECODE_TYPE_SYSTEM_ARGUMENTNULLEXCEPTION                          0x2138
#define HIVECODE_TYPE_SYSTEM_NULLREFERENCEEXCEPTION                         0xC5B8
#define HIVECODE_TYPE_SYSTEM_ARGUMENTOUTOFRANGEEXCEPTION                    0x6B11
#define HIVECODE_TYPE_SYSTEM_NOTSUPPORTEDEXCEPTION                          0xAA74
#define HIVECODE_TYPE_SYSTEM_INVALIDCASTEXCEPTION                           0xD24F
#define HIVECODE_TYPE_SYSTEM_INVALIDOPERATIONEXCEPTION                      0xFAB4
#define HIVECODE_TYPE_SYSTEM_NOTIMPLEMENTEDEXCEPTION                        0x3CE5
#define HIVECODE_TYPE_SYSTEM_OBJECTDISPOSEDEXCEPTION                        0x0FAC
#define HIVECODE_TYPE_SYSTEM_UNAUTHORIZEDACCESSEXCEPTION                    0x4697
#define HIVECODE_TYPE_SYSTEM_INDEXOUTOFRANGEEXCEPTION                       0xBF1D
#define HIVECODE_TYPE_SYSTEM_FORMATEXCEPTION                                0xF3BF
#define HIVECODE_TYPE_SYSTEM_ARITHMETICEXCEPTION                            0x6683
#define HIVECODE_TYPE_SYSTEM_OVERFLOWEXCEPTION                              0x20A0
#define HIVECODE_TYPE_SYSTEM_BADIMAGEFORMATEXCEPTION                        0x530A
#define HIVECODE_TYPE_SYSTEM_APPLICATIONEXCEPTION                           0xB1EA
#define HIVECODE_TYPE_SYSTEM_ARRAYTYPEMISMATCHEXCEPTION                     0x3F88
#define HIVECODE_TYPE_SYSTEM_DIVIDEBYZEROEXCEPTION                          0xDFCF
#define HIVECODE_TYPE_SYSTEM_MEMBERACCESSEXCEPTION                          0xF5F3
#define HIVECODE_TYPE_SYSTEM_MISSINGMEMBEREXCEPTION                         0x20BB
#define HIVECODE_TYPE_SYSTEM_MISSINGFIELDEXCEPTION                          0x7366
#define HIVECODE_TYPE_SYSTEM_MISSINGMETHODEXCEPTION                         0x905B
#define HIVECODE_TYPE_SYSTEM_RANKEXCEPTION                                  0xB2AE
#define HIVECODE_TYPE_SYSTEM_STACKOVERFLOWEXCEPTION                         0x0844
#define HIVECODE_TYPE_SYSTEM_TYPELOADEXCEPTION                              0x048E
#define HIVECODE_TYPE_SYSTEM_IO_IOEXCEPTION                                 0x3BBE
#define HIVECODE_TYPE_SYSTEM_IO_DIRECTORYNOTFOUNDEXCEPTION                  0x975A
#define HIVECODE_TYPE_SYSTEM_IO_FILENOTFOUNDEXCEPTION                       0x07EB
#define HIVECODE_TYPE_SYSTEM_RUNTIME_REMOTING_REMOTINGEXCEPTION             0xD52A
#define HIVECODE_TYPE_SYSTEM_RUNTIME_SERIALIZATION_SERIALIZATIONEXCEPTION   0xA1D2
#define HIVECODE_TYPE_SYSTEM_SECURITY_SECURITYEXCEPTION						0x31AF
#define HIVECODE_TYPE_SYSTEM_SECURITY_VERIFICATIONEXCEPTION					0x67F1
#define HIVECODE_TYPE_SYSTEM_SECURITY_CRYPTOGRAPHY_CRYPTOGRAPHICEXCEPTION   0x8FEB


#endif

