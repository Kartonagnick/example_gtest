// --- Kartonagnick/example_gtest                        [tests][test-fake1.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick PRE
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <gmock/gmock.h>

namespace v1
{
    struct IDatabase
    {
        virtual ~IDatabase() {}
        virtual int query(int) = 0;
    };
    
    struct Order
    {
        Order& operator=(const Order&) = delete;
        Order(const Order&)            = delete;
        
        Order(IDatabase& db_)
            : db(&db_) 
        {}
        
        int check(int id) 
        {
            return db->query(id);
        }
    
        IDatabase* db;
    };
    
    struct FakeDatabase: IDatabase
    {
        int query(int) { return 0; }
    };

} // namespace v1

TEST(Order, 001)
{
    v1::FakeDatabase db; 
    v1::Order order(db); 
    ASSERT_EQ(order.check(100), 0); 
}

namespace v1
{
    #ifdef __GNUC__
        #pragma GCC diagnostic push
        #pragma GCC diagnostic ignored "-Weffc++"
    #endif
    
    struct MockDatabase: IDatabase
    {
        MOCK_METHOD(int, query, (int), (override));
    };
    
    #ifdef __GNUC__
        #pragma GCC diagnostic pop
    #endif

} // namespace v1

using ::testing::_;
using ::testing::Return;

TEST(Order, 002)
{
    v1::MockDatabase db; 

    EXPECT_CALL(db, query(_))
        .WillOnce(Return(0));

    v1::Order order(db); 
    ASSERT_EQ(order.check(100), 0); 
}
