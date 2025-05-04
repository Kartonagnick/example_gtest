// --- Kartonagnick/example_gtest                        [tests][test-mock1.cpp]
// [2025-12-04][15:00:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include <stdexcept>
#include <iostream>
#include <string>

using str_t = std::string;

template <class Database> class Order
{
public:
    Order& operator=(const Order&) = delete;
    Order(const Order&)            = delete;

    Order(Database& db_)
        : db(&db_) 
        , query()
        , result()
    {}

    bool check(int64_t) 
    { 
        return db->make_query("query", result);
    }

    bool payment(int64_t) 
    { 
        return db->make_query(query, result);
    }

    bool cancel(int64_t) 
    { 
        return true;
    }
private:
    Database* db;
    str_t query ;
    str_t result;
};

#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Weffc++"
#endif

class MockDatabase
{
public:
    MOCK_METHOD(bool, make_query, (const str_t& query, str_t& result));
    MOCK_METHOD(void, mutate, (bool, int*));
};

#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

using ::testing::_;
using ::testing::SetArgReferee;
using ::testing::SetArgPointee;
using ::testing::DoAll;
using ::testing::Return;

TEST(OrderTest, check)
{
    MockDatabase db; 
    
    // Макрос EXPECT_CALL описывает, что должно произойти:
    // Метод make_query:
    //   - должен быть вызван строго один раз (WillOnce)
    //   - в качестве первого аргумента должны передать "query"
    //   - второй аргумент не важен
    //   - В результе make_query установит 2-му параметру значение "result",
    //     и вернет true
    
    EXPECT_CALL( db, make_query("query", _) )
        .WillOnce( 
            DoAll(SetArgReferee<1>("result"), Return(true)
        ) 
    );
    
    Order<MockDatabase> order(db); 
    
    // Проверяем метод check
    //  - внутри метод check должен осуществить запуск db.make_query
    //    причем только один раз, и с правильными аргументами,
    //    ожидание которых мы описали выше
    //  - если реальные вызовы не совпадут с ожидаемыми,
    //    тогда тест будет не пройден.

    // Здесь начинаются реальные действия
    ASSERT_TRUE(order.check(100)); 
}

TEST(OrderTest, cancel)
{
    MockDatabase db; 

    // Метод .Times(количество) определяет сколько всего вызовов ожидается
    // Если количество не совпадет, тогда тест будет провален. 
    
    // В данном случае заданно значение ноль.
    // Это значит, что метод db.make_query вообще не должен быть вызван.
    // Иначе тест будет провален.
    
    EXPECT_CALL( db, make_query(_, _) )
        .Times(0);
    
    Order<MockDatabase> order(db); 
    ASSERT_TRUE(order.cancel(1));
}

TEST(OrderTest, pointer)
{
    // Пример-иллюстрация, как можно задать значение dst-parameter
    // который является указателем

    MockDatabase db; 

    EXPECT_CALL( db, mutate(true, _) )
        .WillOnce(SetArgPointee<1>(5));
    
    int val = 0;
    db.mutate(true, &val);
    ASSERT_EQ(val, 5);
}
