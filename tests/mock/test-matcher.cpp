// --- Kartonagnick/example_gtest                      [tests][test-matcher.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================

#include <gtest/gtest.h>
#include <gmock/gmock.h>

class IPrinter
{
public:
    virtual ~IPrinter(){}
    virtual void Print(int ) = 0;
    virtual void Print(char) = 0;
};

#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Weffc++"
#endif

struct MockPrinter: public IPrinter 
{
  MOCK_METHOD(void, Print, (int n ), (override) );
  MOCK_METHOD(void, Print, (char c), (override) );
};
#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

using ::testing::An;      // Any, ожидается любое значение указанного типа
using ::testing::Matcher; // Ожидается значение, которое можно сопоставить шаблону
using ::testing::TypedEq; // Ожидается значение определенного типа
using ::testing::Lt;      // Ожидается значение, которое меньше чем указанное в ожидании

TEST(PrinterTest, Print) 
{
    MockPrinter printer;

    EXPECT_CALL(printer, Print(An<int>()));            // void Print(int);
    EXPECT_CALL(printer, Print(Matcher<int>(Lt(5))));  // void Print(int);    assert(arg < 5)
    EXPECT_CALL(printer, Print(TypedEq<char>('a')));   // void Print(char);

    printer.Print(6);       // ok: An<int>()
    printer.Print(3);       // ok: Matcher<int>(Lt(5))
    printer.Print('a');     // ok: TypedEq<char>('a')
}
