// --- Kartonagnick/example_gtest                      [tests][test-fixture.cpp]
// [2025-12-04][15:00:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <iostream>

class Foo
{
public:
    Foo() noexcept: i(0)
    {
        std::cout << "CONSTRUCTED" << std::endl;
    }
    ~Foo()
    {
        std::cout << "DESTRUCTED" << std::endl;
    }
    int i;
};

class fixture : public ::testing::Test
{
protected:
    fixture(const fixture&)            = delete;
    fixture& operator=(const fixture&) = delete;

    fixture() noexcept: foo(){}

    void SetUp()
    {
        foo = new Foo;
        foo->i = 5;
    }
    void TearDown()
    {
        delete foo;
    }
    Foo* foo;
};

TEST_F(fixture, example_001)
{
    ASSERT_EQ(foo->i, 5);
    foo->i = 10;
}

TEST_F(fixture, example_002)
{
    ASSERT_EQ(foo->i, 5);
}
