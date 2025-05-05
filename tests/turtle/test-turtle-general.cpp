// --- Kartonagnick/example_gtest               [tests][test-turtle-general.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include "test-turtle.hpp"

// Можно задать действие по умолчанию, не задавая ожидаемых значений 
// Для этого используется макрос ON_CALL, и функция WillByDefault(действие)

TEST(Turtle, WillByDefault)
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

    // Указываем, что по умолчанию нужно возвращать 100
    ON_CALL(turtle, GetX())
        .WillByDefault(Return(100));

    // Make an uninteresting call
    ASSERT_EQ(turtle.GetX(), 100);
}

TEST(Turtle, DoDefault)
{
    // В данном тесте явно прописано ожидание вызовов методов
    // которые должны возвращать значения по умолчанию
    // Поэтому, никаких предупреждений о неитересных методах быть не должно

    using testing::DoDefault;
    MockTurtle turtle;

    // Указываем, что по умолчанию нужно возвращать 100
    ON_CALL(turtle, GetX())
        .WillByDefault(Return(100));

    // Теперь задаем ожидаемое поведение
    EXPECT_CALL(turtle, GetX())
        .Times(AtLeast(1))               // кол-во вызовов должно быть не меньше 1
        .WillOnce(Return(1))             // однократно нужно вернуть 1
        .WillRepeatedly(DoDefault());    // для прочих вызовов нужно возвращать по умолчанию

    // первый ожидаемый вызов должен вернуть 1
    ASSERT_EQ(turtle.GetX(), 1);     

    // прочие вызовы должны вернуть по умолчанию значение 100
    ASSERT_EQ(turtle.GetX(), 100);   
    ASSERT_EQ(turtle.GetX(), 100);   
    ASSERT_EQ(turtle.GetX(), 100);   
}


TEST(Turtle, WillRepeatedly)
{
    // Во многих случаях можно вообще не указывать,
    // что должны возвращать методы по умолчанию
    // Вместе этого можно просто указать, что нужно возвращать при "прочих вызовах"

    MockTurtle turtle;

    // Задаем программу ожидания
    EXPECT_CALL(turtle, GetX())
        .Times(AtLeast(1))            // кол-во вызовов должно быть не меньше 1
        .WillOnce(Return(1))          // однократно нужно вернуть 1
        .WillRepeatedly(Return(300)); // для прочих вызовов нужно возвращать 100

    // первый ожидаемый вызов
    ASSERT_EQ(turtle.GetX(), 1);     

    // последующие вызовы
    ASSERT_EQ(turtle.GetX(), 300);   
    ASSERT_EQ(turtle.GetX(), 300);   
    ASSERT_EQ(turtle.GetX(), 300);   
}
