// --- Kartonagnick/example_gtest                [tests][test-turtle-sticky.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick PRE
//==============================================================================
//==============================================================================

#include "test-turtle.hpp"

// По умолчанию ожидания являются "привязанными". 
// Это означает, что они сохраняются на неопределенный срок. 
// В некоторых случаях это может неожиданно привести к сбою теста

#if 0

TEST(Sticky, 001)
{
    // Когда ожидания совпадают, используется то, которое было добавлено последним.    

    // Несмотря на то, что GoTo также ожидается для любого аргумента, 
    // его вызов с помощью (0, 0) в третий раз приводит к сбою теста.
    // Это связано с тем, что GoTo(0, 0) ожидается только дважды.
    // После второго вызова, ожидание все ещё продолжает существовать,
    // что бы убедиться, что его не вызовут в 3й раз
    MockTurtle turtle;

    EXPECT_CALL(turtle, GoTo(_, _))
        .Times(AnyNumber());
    EXPECT_CALL(turtle, GoTo(0, 0))
        .Times(2);

    turtle.GoTo(0, 0);
    turtle.GoTo(0, 0);
    turtle.GoTo(0, 0);       
}

TEST(Sticky, 001)
{
    // Примечательно, что если поменять ожидания местами, тест тоже провалится

    // В этом случае все вызовы GoTo(0, 0) попадут под последнее ожидание
    // а до первого ожидание дело так и не дойдет
    // В результате тест провалиться из-за неоправдавшегося первого ожидания

    MockTurtle turtle;

    EXPECT_CALL(turtle, GoTo(0, 0))
        .Times(2);

    EXPECT_CALL(turtle, GoTo(_, _))
        .Times(AnyNumber());

    turtle.GoTo(0, 0);
    turtle.GoTo(0, 0);
    turtle.GoTo(0, 0);       
}
#endif

TEST(Sticky, 003)
{
    // А вот здесь все хорошо
    // Указание RetiresOnSaturation 

    MockTurtle turtle;

    EXPECT_CALL(turtle, GoTo(_, _))
        .Times(AnyNumber());

    EXPECT_CALL(turtle, GoTo(0, 0))
        .Times(2)
        .RetiresOnSaturation();

    turtle.GoTo(0, 0);
    turtle.GoTo(0, 0);
    turtle.GoTo(0, 0);
}


TEST(Sticky, 004)
{
    MockTurtle turtle;

    EXPECT_CALL(turtle, GetX())
        .WillOnce(Return(0));

    {
        testing::InSequence s;
        EXPECT_CALL(turtle, GetX())
            .WillOnce(Return(10))
            .RetiresOnSaturation();

        //EXPECT_CALL(turtle, GetX())
        //    .WillOnce(Return(10))
        //    .RetiresOnSaturation();
    }

    turtle.GetX();
    turtle.GetX();
    //turtle.GetX();
}

#if 0
TEST(Sticky, 004)
{
    MockTurtle turtle;

    EXPECT_CALL(turtle, GetX())
        .WillOnce(Return(0));

    {
        testing::InSequence s;
        EXPECT_CALL(turtle, GetX())
            .WillOnce(Return(10));

        EXPECT_CALL(turtle, GetX())
            .WillOnce(Return(10))
            .RetiresOnSaturation();
    }

    turtle.GetX();
    turtle.GetX();
    turtle.GetX();
}
#endif