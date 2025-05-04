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
