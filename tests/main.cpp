// --- Kartonagnick/example_gtest                              [tests][main.cpp]
// [2025-12-04][15:00:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <gmock/gmock.h>

int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  ::testing::InitGoogleMock(&argc, argv);
  return RUN_ALL_TESTS();
}

#if 0
int main(int argc, char** argv)
{
    // example settings:
    //   test.ext --gtest_filter=tools.stopwatch* --stress
    //   testing::GTEST_FLAG(filter) = "tools.stopwatch_*";
    return ::testing::run(argc, argv);
}
#endif

#if 0
// запустить все тесты набора TestCaseName за исключением SomeTest
// test.exe --gtest_filter=TestCaseName.*-TestCaseName.SomeTest 

// запустить тестирующую программу 1000 раз и остановиться при первой неудаче
// test.exe --gtest_repeat=1000 --gtest_break_on_failure

// помимо выдачи в std::out будет создан out.xml - XML отчет с результатами выполнения тестовой программы
// test.exe --gtest_output="xml:out.xml"

// запускать тесты в случайном порядке
// test.exe --gtest_shuffle 
#endif
