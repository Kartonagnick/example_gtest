// --- Kartonagnick/example_gtest                         [sample.exe][main.cpp]
// [2024-12-04][15:00:00] 001 Kartonagnick PRE
//==============================================================================
//==============================================================================

#include <sample/sample.hpp>
#include <sample/sample.ver>
#include <iostream>

#define dSTRINGIZE(...) #__VA_ARGS__
#define dSSTRINGIZE(x) dSTRINGIZE(x)

#define dVERSION_NUM(MAJOR, MINOR, PATCH) \
    MAJOR * 100 + MINOR * 10 + PATCH

#define dVERSION_STR(MAJOR, MINOR, PATCH) \
    dSSTRINGIZE(MAJOR.MINOR.PATCH)

#define dGET_VERSION(NAME) \
    dVERSION_STR(NAME##_MAJOR, NAME##_MINOR, NAME##_PATCH)   

int main(int argc, char* argv[])
{
    (void) argc;
    (void) argv;
    std::cout << 'v' << dGET_VERSION(dSAMPLE) << ": in dev...\n";
}
