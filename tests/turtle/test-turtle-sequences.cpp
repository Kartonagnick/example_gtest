// --- Kartonagnick/example_gtest             [tests][test-turtle-sequences.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include "test-turtle.hpp"

// Пример использования testing::Sequence
// С помощью Sequence можно указать строгую очередность вызовов методов
// А так же, можно определить какие вызовы могут выполнять параллельно
// А какие должны быть в строго определенной последовательности.

// В данном примере ожидается следующая очередность вызовов:
//   - сначала turtle1.GetX()
//   - затем либо turtle1.GetY(), turtle2.GetX()
//   - после того, как отработает turtle1.GetY(), ожидается вызов turtle1.GoTo(_, _)

#if 0
//                            +----------------+   +---------------------+
//                        .---| turtle1.GetY() |---| turtle1.GoTo(_ , _) |
//  +----------------+   |    +----------------+   +---------------------+
//  | turtle2.GetX() |---|
//  +----------------+   |    +----------------+
//                        `---| turtle2.GetX() |
//                            +----------------+
#endif

TEST(Turtle, MultipleSequences_001)
{
    MockTurtle turtle1;
    MockTurtle turtle2;

    Sequence seq1;
    Sequence seq2;

    EXPECT_CALL(turtle1, GetX())
        .Times(1)
        .InSequence(seq1, seq2);

    EXPECT_CALL(turtle1, GetY())
        .Times(1)
        .InSequence(seq1);

    EXPECT_CALL(turtle2, GetX())
        .Times(1)
        .InSequence(seq2);

    EXPECT_CALL(turtle1, GoTo(_, _))
        .Times(1)
        .InSequence(seq1);

    // Both sequences expect this call first
    turtle1.GetX();

    // Sequence 1
    turtle1.GetY();
    turtle1.GoTo(0, 0);

    // Sequence 2
    turtle2.GetX();
}

TEST(Turtle, MultipleSequences_002)
{
    // Обратите внимание, что в рамках теста
    // не задана жесткая очередность для вызовов turtle1.GetY() и turtle2.GetX() 
    // поэтому, их можно менять местами

    MockTurtle turtle1;
    MockTurtle turtle2;

    Sequence seq1;
    Sequence seq2;

    EXPECT_CALL(turtle1, GetX())
        .Times(1)
        .InSequence(seq1, seq2);

    EXPECT_CALL(turtle1, GetY())
        .Times(1)
        .InSequence(seq1);

    EXPECT_CALL(turtle2, GetX())
        .Times(1)
        .InSequence(seq2);

    EXPECT_CALL(turtle1, GoTo(_, _))
        .Times(1)
        .InSequence(seq1);

    // Both sequences expect this call first
    turtle1.GetX();

    // В предыдущем тесте  вызов turtle2.GetX(); идет в самом конце

    // Sequence 2
    turtle2.GetX();

    // Sequence 1
    turtle1.GetY();
    turtle1.GoTo(0, 0);
}


TEST(Turtle, InSequences)
{
    MockTurtle turtle;
    
    testing::InSequence seq;

    EXPECT_CALL(turtle, GetX())
        .Times(1)
        .WillOnce(Return(1));


    EXPECT_CALL(turtle, GetY())
        .Times(1)
        .WillOnce(Return(2));
    
    // если поменять вызовы местами, то будет ошибка
    ASSERT_EQ(1, turtle.GetX());
    ASSERT_EQ(2, turtle.GetY());
}
