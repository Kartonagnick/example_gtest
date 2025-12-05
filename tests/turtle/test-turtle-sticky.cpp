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
    // В результате тест провалится из-за неоправдавшегося первого ожидания

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
    // Указание RetiresOnSaturation сообщает, 
    // что ожидание перестает быть активным 
    // после достижения ожидаемого кол-ва 
    // совпадающих вызовов функций

    // Обратите внимание: 
    // RetiresOnSaturation запускается для последнего ожидания, 
    // а не для первого

    MockTurtle turtle;

    EXPECT_CALL(turtle, GoTo(_, _))
        .Times(AnyNumber());

    EXPECT_CALL(turtle, GoTo(0, 0))
        .Times(2)
        .RetiresOnSaturation();

    // из-за того, что ожидания наложились друг на друга
    // сначала отработает последнее, и только потом 1е

    turtle.GoTo(0, 0);  // 2е ожидание
    turtle.GoTo(0, 0);  // 2е ожидание
    turtle.GoTo(0, 0);  // 1е ожидание
}

TEST(Sticky, 004)
{
    MockTurtle turtle;

    EXPECT_CALL(turtle, GoTo(_, _))
        .Times(AnyNumber());

    EXPECT_CALL(turtle, GoTo(0, 0))
        .Times(2);

    // а вот здесь, комбинация аргументов (1,1) подходит только для 1го ожидания
    // поэтому, ожидания не наложились друг на друга
    // и поэтому порядок следования ожиданий совпадает с порядком их объявления

    turtle.GoTo(1, 1); // 1е ожидание
    turtle.GoTo(0, 0); // 2е ожидание
    turtle.GoTo(0, 0); // 2е ожидание
}

TEST(Sticky, 005)
{
    // аналогично предыдущему тесту,
    // ожидания накладываются друг на друга
    // поэтому нужен RetiresOnSaturation

    MockTurtle turtle;

    EXPECT_CALL(turtle, GetX())
        .WillOnce(Return(10));

    EXPECT_CALL(turtle, GetX())
        .WillOnce(Return(20))
        .RetiresOnSaturation();

    // так как ожидания наложились
    // поменялся порядок следования
    ASSERT_EQ(turtle.GetX(), 20);
    ASSERT_EQ(turtle.GetX(), 10);
}

TEST(Sticky, 006)
{
    // суть теста: показать, что использование InSequence
    // не отменяет необходимость RetiresOnSaturation

    MockTurtle turtle;

    EXPECT_CALL(turtle, GetX())
        .WillOnce(Return(10));

    {
        testing::InSequence s;
        EXPECT_CALL(turtle, GetX())
            .WillOnce(Return(20))
            .RetiresOnSaturation();
    }

    // так как ожидания наложились
    // то получили обратный порядок их следования

    ASSERT_EQ(turtle.GetX(), 20);
    ASSERT_EQ(turtle.GetX(), 10);
}


TEST(Sticky, 007)
{
   // технически, RetiresOnSaturation можно вызывать многократно
   // однако нужно понимать, что его использование - это своего рода костыль
   // когда вам нужен RetiresOnSaturation, подумайте о том,
   // что может быть стоит пересмотреть дизайн теста

    MockTurtle turtle;

    EXPECT_CALL(turtle, GetX())
        .WillOnce(Return(10))
        .RetiresOnSaturation();     // не обязательный

    {
        testing::InSequence s;
        EXPECT_CALL(turtle, GetX())
            .WillOnce(Return(20))
            .RetiresOnSaturation(); // не обязательный

        EXPECT_CALL(turtle, GetX())
            .WillOnce(Return(30))
            .RetiresOnSaturation();
    }

    // Обратите внимание, что сначала отрабатывает InSequence
    // и только в самом конце дело доходит до Return(10)

    // при наложении ожиданий, сначала отрабатывает последнее ожидание
    // затем, благодаря RetiresOnSaturation, насыщенное ожидание отменяется
    // и затем действие переходит к предшествующему ожиданию
    
    ASSERT_EQ(turtle.GetX(), 20);
    ASSERT_EQ(turtle.GetX(), 30);
    ASSERT_EQ(turtle.GetX(), 10);
}

TEST(Sticky, 007)
{
    // данный тест аналогичен предыдущему,
    // но не использует RetiresOnSaturation

    // идея в том, что бы подумать: можно ли как то так реализовать тест
    // что бы не нужно было использовать RetiresOnSaturation
    // и тогда мир станет чуточку проще

    MockTurtle turtle;

    EXPECT_CALL(turtle, GetX())
        .WillOnce(Return(10))
        .WillOnce(Return(20))
        .WillOnce(Return(30));

    ASSERT_EQ(turtle.GetX(), 10);
    ASSERT_EQ(turtle.GetX(), 20);
    ASSERT_EQ(turtle.GetX(), 30);
}
