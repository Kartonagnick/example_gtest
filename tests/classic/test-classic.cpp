// --- Kartonagnick/example_gtest                      [tests][test-classic.cpp]
// [2025-12-04][15:00:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <stdexcept>
#include <iostream>
#include <cassert>

template <class callable> 
static void death_test(callable& call)
{
    #ifdef NDEBUG
        (void) call;
        std::cout << "release: skip death-test\n";
    #else
        std::cout << "debug: execute death-test\n";
        ASSERT_DEATH(call(), ".*");
    #endif
}

static void foo()
{
    assert(false);
    std::cerr << "INVALID\n";
    throw ::std::runtime_error("test");
}

static ::testing::AssertionResult is_true(const bool val)
{
    if (val)
        return ::testing::AssertionSuccess();
    else
        return ::testing::AssertionFailure() 
            << foo << " is not true";
}

TEST(classic, method_001)
{
    std::cout << "ok\n";
}

TEST(classic, deatch_002)
{
    death_test(foo);
}

TEST(classic, AssertionFailed)
{
    EXPECT_FALSE(is_true(false));
}
