// --- Kartonagnick/example_gtest               [tests][test-turtle-example.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include "test-turtle.hpp"

class Painter
{
    ITurtle* turtle;
public:
    Painter(ITurtle& t): turtle(&t){}

    bool DrawCircle(const int x, int y, int r)
    {
        (void) r;
        turtle->GoTo(x,y);
        turtle->PenDown();
        turtle->Forward(3);
        turtle->Turn(90);
        turtle->Forward(3);
        turtle->Turn(90);
        turtle->Forward(3);
        turtle->PenUp();
        return true;
    }
};

TEST(Turtle, Example_001)
{
    // При использовании MockTurtle напрямую, 
    // система будет генерировать предупреждения вида:  
    // 
    //   GMOCK WARNING:
    //   Uninteresting mock function call - taking default action specified at:
    //   test-turtle-default.cpp(15):
    //       Function call: GetX()
    //             Returns: 100
    //
    // Это связанно с тем, что в рамках теста 
    // нигде не прописаны ожидания вызовов turtle.GetX()
    //
    // Так как для данного теста запуски неинтересных методов - это норма,
    // то что бы подавить предупрежедние, используем милый мок

    testing::NiceMock<MockTurtle> turtle;

    EXPECT_CALL(turtle, PenDown())
        .Times(AtLeast(1));  // не менее 1 раз
    EXPECT_CALL(turtle, Forward(_))
        .Times(AtLeast(1));  // не менее 1 раз
    EXPECT_CALL(turtle, Turn(_))
        .Times(AtLeast(1));  // не менее 1 раз
    EXPECT_CALL(turtle, PenUp())
        .Times(AtLeast(1));

    Painter p(turtle);
    EXPECT_TRUE(p.DrawCircle(0, 0, 10));
}

TEST(Turtle, Example_002)
{
    MockTurtle turtle;
     
    EXPECT_CALL(turtle, GetY())
        .Times(1)
        .WillOnce(Return(100));         // Return 100 once

    EXPECT_CALL(turtle, GetX())
        .Times(5)
        .WillOnce(Return(100))          // Return 100 once
        .WillOnce(Return(200))          // Return 200 once
        .WillRepeatedly(Return(300));   // Return 300 for the remaining calls

    // Execute actions
    ASSERT_EQ(turtle.GetY(), 100);
    ASSERT_EQ(turtle.GetX(), 100);
    ASSERT_EQ(turtle.GetX(), 200);
    ASSERT_EQ(turtle.GetX(), 300);
    ASSERT_EQ(turtle.GetX(), 300);
    ASSERT_EQ(turtle.GetX(), 300);
}
