// --- Kartonagnick/example_gtest                        [tests][test-mock1.cpp]
// [2025-12-04][15:00:00] 001 Kartonagnick PRE
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
};

#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

using ::testing::_;
using ::testing::SetArgReferee;
using ::testing::DoAll;
using ::testing::Return;

TEST(OrderTest, check)
{
    MockDatabase db; 
    
    // Макрос EXPECT_CALL описывает, что должно произойти:
    // Метод make_query:
    //   - должен быть вызван строго один раз (WillOnce)
    //   - в качестве первого аргумента передадут "query"
    //   - второй аргумент не важен
    //   - метод make_query установит второй аргумент в значение "result"
    //   - метод make_query вернет true
    
    EXPECT_CALL( db, make_query("query", _) )
        .WillOnce( 
            DoAll(SetArgReferee<1>("result"), Return(true)
        ) 
    );
    
    Order<MockDatabase> order(db); 
    
    // Проверяем метод check и все сделанные предположения относительно 
    // метода make_query. При этом make_query внутри метода check будет
    // вести себя так, как мы ему указали. А все предположения относительно
    // количества вызовов и аргмументов будут строго проверены.

    // Здесь начинаются реальные действия
    ASSERT_TRUE(order.check(100)); 
}

TEST(OrderTest, cancel)
{
    MockDatabase db; 

    // Метод make_query вообще не должен быть вызван
    // Иначе тест будет провален.
    
    EXPECT_CALL( db, make_query(_, _) )
        .Times(0);
    
    Order<MockDatabase> order(db); 
    ASSERT_TRUE(order.cancel(1));
}
