// --- Kartonagnick/example_gtest                    [tests][test-const-ref.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include <memory>

#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Weffc++"
#endif

struct MockCar
{
    MOCK_METHOD(int, getTrunkSize, ()         );
    MOCK_METHOD(int, getTrunkSize, (), (const));
};

#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

using ::testing::Const;
using ::testing::Return;
using ::testing::ReturnPointee;

TEST(Car, RawPointer)
{
    MockCar car;
    int size1 = 1;
    EXPECT_CALL(car, getTrunkSize())
        .Times(2)
        .WillRepeatedly(ReturnPointee(&size1)); 

    int size2 = 2;
    EXPECT_CALL(Const(car), getTrunkSize())
        .Times(2)
        .WillRepeatedly(ReturnPointee(&size2)); 

    size1 = 2;
    ASSERT_EQ(car.getTrunkSize(), 2);
    size1 = 3;
    ASSERT_EQ(car.getTrunkSize(), 3);

    const MockCar& me = car;
    size2 = 5;
    ASSERT_EQ(me.getTrunkSize(), 5);
    size2 = 6;
    ASSERT_EQ(me.getTrunkSize(), 6);
}

//..............................................................................

TEST(Car, SharedPtr)
{
    MockCar car;

    auto shared = std::make_shared<int>(10);
    ASSERT_TRUE(shared);

    EXPECT_CALL(car, getTrunkSize())                  
        .WillOnce(ReturnPointee(shared))
        .WillOnce(ReturnPointee(shared));

    ASSERT_EQ(car.getTrunkSize(), 10);
    ASSERT_TRUE(shared);
    ASSERT_EQ(*shared, 10);
    *shared = 20;
    ASSERT_EQ(car.getTrunkSize(), 20);
    ASSERT_TRUE(shared);
    ASSERT_EQ(*shared, 20);
}

//..............................................................................

#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Weffc++"
#endif

struct MockPointer
{
    MOCK_METHOD(int*, getData, (), (const));
};

#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

TEST(Pointer, example)
{
    MockPointer agent;
    int val = 33;
    EXPECT_CALL(agent, getData())                  
        .WillOnce(Return(&val));

    int* p = agent.getData();
    ASSERT_TRUE(p);
    ASSERT_EQ(*p, 33);
}

//..............................................................................

struct resource
{
    resource(int v): value(v) {}
    int value;
};

struct IWorker
{
    using shared_t = std::shared_ptr<resource>;

    virtual ~IWorker() = default;
    virtual shared_t GetObject() const = 0;
};

struct MockWorker: IWorker 
{
    MOCK_METHOD(shared_t, GetObject, (), (const, override));
};

TEST(Worker, ReturnSharedPtr)
{
    MockWorker mock;
    EXPECT_CALL(mock, GetObject())
        .WillOnce(Return(std::make_shared<resource>(42)));
    IWorker::shared_t result = mock.GetObject();
    ASSERT_TRUE(result);
    EXPECT_EQ(result->value, 42);
}

//..............................................................................
