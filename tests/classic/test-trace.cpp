// --- Kartonagnick/example_gtest                        [tests][test-trace.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================
// https://google.github.io/googletest/reference/assertions.html

#include <gtest/gtest.h>

TEST(trace, 001)
{
    const bool ok = true;
    SCOPED_TRACE("check: ok");
    EXPECT_TRUE(ok);
}

#if 0
static bool check(int n)
{
    return n < 0;
}

TEST(trace, 002)
{
    for (size_t n = 0; n < 3; ++n)
    {
        SCOPED_TRACE(n);
        EXPECT_PRED1(check, n);
    }
}

// Output:  

// [ RUN      ] trace.002
// test-trace.cpp(27): error: check(n) evaluates to false, where
// n evaluates to 0
// Google Test trace:
// test-trace.cpp(26): 0
// 
// test-trace.cpp(27): error: check(n) evaluates to false, where
// n evaluates to 1
// Google Test trace:
// test-trace.cpp(26): 1
// 
// test-trace.cpp(27): error: check(n) evaluates to false, where
// n evaluates to 2
// Google Test trace:
// test-trace.cpp(26): 2
// 
// [  FAILED  ] trace.002 (0 ms)

#endif
