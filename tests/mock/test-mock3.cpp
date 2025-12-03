// --- Kartonagnick/example_gtest                        [tests][test-mock3.cpp]
// [2025-12-04][15:00:00] 001 Kartonagnick PRE
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <gmock/gmock.h>

class IEngine
{
public:
    virtual ~IEngine(){}

    virtual bool startEngine()  { return true; }
};

#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Weffc++"
#endif

class MockEngine : public IEngine
{
public:
    MOCK_METHOD(bool, startEngine, (), (override));
};

#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

using testing::NiceMock;

TEST(Engine, startEngine)
{
    NiceMock<MockEngine> mockEngine;

    const auto lambda = [&mockEngine]
    {
        return mockEngine.IEngine::startEngine();
    };

    ON_CALL(mockEngine, startEngine())
        .WillByDefault(lambda);

    ASSERT_TRUE(mockEngine.startEngine());
}
