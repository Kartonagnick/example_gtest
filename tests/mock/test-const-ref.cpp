// --- Kartonagnick/example_gtest                    [tests][test-const-ref.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <gmock/gmock.h>

struct Bar
{
    int val = 0;
};

struct IFoo
{
    virtual ~IFoo(){}

    virtual       Bar& GetBar()       = 0;
    virtual const Bar& GetBar() const = 0;

    virtual       Bar* GetPtr()       = 0;
    virtual const Bar* GetPtr() const = 0;    
};

#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Weffc++"
#endif

struct MockFoo: IFoo
{
    MOCK_METHOD(      Bar&, GetBar, (), (override)        );
    MOCK_METHOD(const Bar&, GetBar, (), (const, override) );

    MOCK_METHOD(      Bar*, GetPtr, (), (override)        );    
    MOCK_METHOD(const Bar*, GetPtr, (), (const, override) );    
};

struct MockPtr
{
    MOCK_METHOD(      int*, Example, ());    
};


#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

using ::testing::ReturnPointee;
using ::testing::ReturnRef;
using ::testing::Const;

TEST(Foo, ReturnRef)
{
    MockFoo foo;
    Bar bar1; bar1.val = 1;
    Bar bar2; bar2.val = 2;

    EXPECT_CALL(foo, GetBar())         // GetBar()
        .WillOnce(ReturnRef(bar1));

    EXPECT_CALL(Const(foo), GetBar())  // GetBar() const
        .WillOnce(ReturnRef(bar2));

    ASSERT_EQ(foo.GetBar().val, 1);
    const auto& cfoo = foo;
    ASSERT_EQ(cfoo.GetBar().val, 2);
}
