// --- Kartonagnick/example_gtest                        [tests][test-mock3.cpp]
// [2025-12-04][15:00:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

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

TEST(Engine, lambda)
{
    // в рамках данного теста отсутствует 
    // ожидание вызова mockEngine.startEngine()
    // т.е., отсутствует соответствующий EXPECT_CALL, 
    // в котором было бы прописано такое ожидание
    
    // в терминологии мок-тестирования, 
    // запуски методов мок-объектов, которые явным образом не ожидались,
    // являются т.н. "неинтересными" запусками.  
    
    // факт запуска неинтересного метода сам по себе ошибкой не является.
    // однако, тем не менее, мок-объекты генерируют предупреждения о том,
    // что такие методы запускались.  
    
    // если в рамках некоторого теста запуск неинтересного метода является нормой,
    // и не хочется получать никаких предупрежедний по этому поводу,
    // то специально для этой цели существует NiceMock
    
    // NiceMock - модель мок-объекта, которая подавляет предупреждения 
    // о запусках неинтересных методов мок-объектов
    
    NiceMock<MockEngine> mockEngine;

    const auto lambda = [&mockEngine]
    {
        return mockEngine.IEngine::startEngine();
    };

    ON_CALL(mockEngine, startEngine())
        .WillByDefault(lambda);

    ASSERT_TRUE(mockEngine.startEngine());
}

using testing::Invoke;

struct FakeHelp
{
    bool startEngine() { return true; }
};

TEST(Engine, Invoke)
{
    NiceMock<MockEngine> mockEngine;
    FakeHelp help;
    ON_CALL(mockEngine, startEngine())
        .WillByDefault(Invoke(&help, &FakeHelp::startEngine));

    ASSERT_TRUE(mockEngine.startEngine());
}

//..............................................................................

struct IDummy
{
    virtual int foo() = 0;
};

#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Weffc++"
#endif

struct DummyMock: IDummy
{
    MOCK_METHOD0(foo, int());
};

#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

using namespace ::testing;
class DummySuite : public Test
{
    int dummyValue = 0;
protected:
    DummyMock dummy;

    void SetUp() override
    {
        ON_CALL(dummy, foo())
           .WillByDefault(
                InvokeWithoutArgs(this, &DummySuite::Increment)
           );
    }

    int Increment()
    {
        return ++dummyValue;
    }
};

TEST_F(DummySuite, example)
{
    ASSERT_EQ(1, dummy.foo());
    ASSERT_EQ(2, dummy.foo());
    ASSERT_EQ(3, dummy.foo());
} 
