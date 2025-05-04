// --- Kartonagnick/example_gtest                        [tests][test-mock2.cpp]
// [2025-12-04][15:00:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <gmock/gmock.h>

class IChild
{
public:
    virtual ~IChild(){}
    virtual void doThis() {}
    virtual bool doThat(int, double) { return false; }
};

#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Weffc++"
#endif

class MockChild : public IChild
{
public:
    MOCK_METHOD(void, doThis, (), (override));
    MOCK_METHOD(bool, doThat, (int, double), (override));
};

#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

class Fighter
{
public:
    void run(IChild& child)
    {
        child.doThis();
        child.doThat(4, 5);
    }
};

using testing::Exactly;

TEST(Fighter, doSomething)
{
    MockChild mockChild;
    Fighter fighter;

    // doThis() must be called exactly 1 time.
    EXPECT_CALL(mockChild, doThis).Times(Exactly(1));

    // doThat() must be called exactly 1 time with parameters 4, 5
    EXPECT_CALL(mockChild, doThat(4, 5))
        .Times(Exactly(1));

    fighter.run(mockChild);
}
