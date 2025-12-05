// --- Kartonagnick/example_gtest                       [tests][test-turtle.hpp]
// [2025-12-05][20:20:00] 001 Kartonagnick PRE
//==============================================================================
//==============================================================================
// https://github.com/google/googletest/blob/main/docs/reference/matchers.md#wildcard

#pragma once
#include <gtest/gtest.h>
#include <gmock/gmock.h>

class ITurtle
{
public:
    ITurtle()          = default;
    virtual ~ITurtle() = default;
    virtual void PenUp()   = 0;
    virtual void PenDown() = 0;
    virtual void Forward(int distance) = 0;
    virtual void Turn(int degrees)     = 0;
    virtual void GoTo(int x, int y)    = 0;
    virtual int GetX() const = 0;
    virtual int GetY() const = 0;
};

#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Weffc++"
#endif

class MockTurtle: public ITurtle
{
public:
    MOCK_METHOD(void, PenUp  , (), (override));
    MOCK_METHOD(void, PenDown, (), (override));
    MOCK_METHOD(void, Forward, (int distance), (override));
    MOCK_METHOD(void, Turn   , (int degrees) , (override));
    MOCK_METHOD(void, GoTo   , (int x, int y), (override));
    MOCK_METHOD( int, GetX   , (), (const, override));
    MOCK_METHOD( int, GetY   , (), (const, override));
};
#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

using ::testing::_;
using ::testing::Return;
using ::testing::AtLeast;
using ::testing::AnyNumber;

using ::testing::Sequence;

using ::testing::ReturnRef;
using ::testing::Matcher;
using ::testing::TypedEq;
using ::testing::An;


#if 0
AnyNumber()    // может быть вызвана сколько угодно раз
AtLeast(n)     // ожидается не менее, чем n раз
AtMost(n)      // ожидается не более, чем n раз
Between(m, n)  // ожидается между m и n раз (включительно)
Exactly(n)     // ожидается ровно n раз. "Exactly" можно не писать
#endif

#if 0
_               // Any value (of the correct type)
Eq(value)       // argument == value
Ge(value)       // argument >= value
Gt(value)       // argument > value
Le(value)       // argument <= value
Lt(value)       // argument < value
Ne(value)       // argument != value
#endif

#if 0
// Nice objects ignore all uninteresting calls. If a call is not expected, it won’t result in a warning.
// игнорируют все неинтересные вызовы
NiceMock<MockClass>

// Naggy objects log a warning for all uninteresting calls.
// пишет предупреждение о неитересных вызовах
// но при этом сами тесты проходят без ошибок
NaggyMock<MockClass> 

// Strict objects simply fail the test if any uninteresting call is made.
// неитересные вызовы провоцируют ошибки
StrictMock<MockClass> 
#endif

#if 0
EXPECT_CALL(mock_object, method_name(matchers...))
    .With(multi_argument_matcher)  // Можно использовать не более одного раза
    .Times(cardinality)            // Можно использовать не более одного раза
    .InSequence(sequences...)      // Можно использовать много раз
    .After(expectations...)        // Можно использовать много раз
    .WillOnce(action)              // Можно использовать много раз
    .WillRepeatedly(action)        // Можно использовать не более одного раза
    .RetiresOnSaturation();        // Можно использовать не более одного раза
#endif
