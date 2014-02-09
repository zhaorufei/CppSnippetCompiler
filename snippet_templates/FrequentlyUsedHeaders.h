// Place windows.h before any other ANSI include files -- recommanded by Win32 Programming
// #define _WIN32_WINNT 0x0400 
#define _CRT_SECURE_NO_WARNINGS
#include <Winsock2.h>  // For inet_aton etc
#include <windows.h>
// #include <afx.h>
#include <windowsx.h>
#include <tchar.h>  // For _T macro

// GetModuleBaseName
#include <psapi.h>

//
// C++ STL library
//
#include <iostream>
// for stringstream
#include <sstream>
#include <fstream>
#include <iterator>
// For strstream
#include <strstream>
#include <iomanip>
#include <vector>
#include <list>
#include <stack>
#include <deque>
#include <map>
#include <set>
#include <algorithm>
#include <utility>
#include <limits>
// For use of and, or, and_eq, not, not_eq, or_eq, xor_eq, xor, bitor
// bitand, compl: I find only not is practical  if( !ll5 ) { ... } not
// clear, if( not(ll5) ) { ... } is better
#include <iso646.h>

// boost library

#ifdef _MSC_VER
	#pragma warning(push, 0)
#endif

// Only include boost for VS2008, because I only compiled the boost for
// VS2008
#if _MSC_VER == 1400 && !defined(_M_X64) || defined(__GNUC__) && (__GNUC__ < 4 || __GNUC__ == 4 && __GNUC_MINOR__ < 8)
#define BOOST_DISABLE_ABI_HEADERS
#include <boost/regex.hpp>
#include <boost/static_assert.hpp>
#include <boost/type_traits.hpp>
#include <boost/utility.hpp>
#include <boost/lambda/lambda.hpp>
#include <boost/lambda/bind.hpp>
#include <boost/function.hpp>
#include <boost/cast.hpp>
#include <boost/crc.hpp>
#include <boost/limits.hpp>
#include <boost/archive/tmpdir.hpp>

#include <boost/archive/text_iarchive.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/xml_iarchive.hpp>
#include <boost/archive/xml_oarchive.hpp>

#include <boost/serialization/base_object.hpp>
#include <boost/serialization/utility.hpp>
#include <boost/serialization/list.hpp>
#include <boost/serialization/is_abstract.hpp>
#include <boost/preprocessor.hpp>

#ifdef _MSC_VER
	#pragma warning(pop)
#endif
#endif

//
// C standard library
//
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstdarg>
#include <cstring>
#include <cassert>

#include <climits>
// for time_t time(), asctime() gmttime etc
#include <ctime>

#ifdef _MSC_VER
	#pragma comment(lib,"user32.lib")
	#pragma comment(lib,"gdi32.lib")
	#pragma comment(lib,"kernel32.lib")

// GetModuleBaseName in this library
	#pragma comment(lib,"psapi.lib")
#endif

// CREATE:
//      use the following command to create FrequentlyUsedHeaders.pch file:
//      cl /c /YcFrequentlyUsedHeaders.h my_precompile_header.cpp
//      my_precompile_header.cpp can be any file containing only one line:
//         #include "FrequentlyUsedHeaders.h"
//
// USE:
//      use the precompiled header file by(make sure FrequentlyUsedHeaders.pch is in the same dir as
//            FrequentlyUsedHeaders.h):
//      cl /YuFrequentlyUsedHeaders.h   your_code.cpp
// NOTE:
//      the PCH file contains the environment variable.
// PERFORMANCE:
//      run 10 times for a very simple C++ file which contains the above header files, take 6 seconds
//      takes 2 seconds when use the PCH file.

#define COMPILE_ASSERT(expr)  extern int sure_not_exist[ (expr)?1:-1 ]

// BEGIN -- LOG
// Description: This function call GetLastError before doing any non-trival things
//              and get the descriptive string message *ALWAYS* in english.
// RETURN: true if set errmsg OK, otherwise false
bool GetLastErrorMessage(std::string & errmsg);

#define ERR_MSG_BOX(fmtstr, ...)  ErrMsgBox(__FILE__, __FUNCTION__, __LINE__, fmtstr, __VA_ARGS__)

// Description: Do *NOT* use this function directly, use ERR_MSG_BOX instead to get the function name
void ErrMsgBox(const char * const file_name, const char * const func_name, int line_no,
			   const char * fmtstr, ...);
bool GetLastErrorMessage(std::string & errmsg);
// END -- LOG

// Howto delete a pointer and then set it to NULL
// http://www.research.att.com/~bs/bs_faq2.html#in-class
template<class T> inline void destroy(T*& p) { delete p; p = 0; }
// mimic the above
template<class T> inline void destroy_array(T*& p) { delete[] p; p = 0; }
