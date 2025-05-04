// --- Kartonagnick/example_gtest                       [tests][test-sample.cpp]
// [2025-12-04][15:00:00] 001 Kartonagnick PRE
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <sample/sample.hpp>

TEST(sample, foo)
{
    const int v = sample::foo();
    ASSERT_EQ(v, 1);
}
