//vim:ts=4:expandtab:
/*lint +e* -elib(*) -e966 -e964 -e755 -e757 -e970 */
#include "FrequentlyUsedHeaders.h"
// The following lines makes it possible that only /Yu is specified on the
// command line

// Remove #ifdef ... #endif   because VC will stop to compile, don't
// know why
#pragma hdrstop( "FrequentlyUsedHeaders.pch" )

#include "..\PracticalCpp\zrf_utilities.h"
using namespace std;
using namespace zrf;
// I only compile boost for VS2008, 1600 is VS2010
#if _MSC_VER < 1600
using namespace boost;
#endif

// CC_OPTIONS:
// CL_OPTIONS:
// LD_OPTIONS:

#if defined(MSC_VER)
// Press F4 to switch the warning /W4 and /W0
#pragma warning(push, 2)
#endif

int main(int argc, char *argv[])
{
    argc = argc                       ; argv = argv                       ; 
    setvbuf( stdout, NULL, _IONBF, 0) ; setvbuf( stderr, NULL, _IONBF, 0) ; 
    // DEBUG: Un-comment the following line to debug the program.
    // ERR_MSG_BOX("Attach me to a debugger and then click OK");
    
    // Begin your code here :-)
    printf("Hello, world\n");
    return 0;
}
