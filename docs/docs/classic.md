[![logo](../logo.png)](../docs.md "documentation") 

[H]: ../docs.md        "родитель"
[P]: ../icons/progress.png  "в процессе..."
[S]: ../icons/success.png   "ошибок не обнаружено"
   
[![P]][H] classic v0.0.1
========================
Классические юнит-тесты - простые тесты публичного интерфейса юнита,  
которые не используют ни фейковые, ни мок-объекты.  

Самое главное, что нужно понять: задача юнит-теста не только, и даже не столько в том,  
что бы проконтролировать работоспобность юнита, сколько в том,  
что бы проиллюстрировать как с ним работать.  

Хороший юнит-тест наглядный, он показывает дизайн использования юнита.  
Его можно читать вместо документации.  
Поэтому, хороший тест не должен быть чрезмерно сложным, когда не понятно,  
что относится собственно к юниту, а что является лишь тестовыми декорациями.  

Хороший юнит-тест защищает от регрессии.  
Взять к примеру функцию сопоставления образца с группой масок:  

```cpp
template<class s1, class s2>
bool match_group(const s1& symbol, const s2& mask) noexcept;
```
Допустим, нужно расширить возможности этой функции.  
Для этого программист вносит правки в исходники функции.  
Такие изменения - это всегда риск сломать рабочий код.  
Однако при наличии юнит-тестов, появляются определенные гарантии,  
что изменения нигде ничего не поломали.  

Таким образом, хороший юнит-тест иллюстрирует дизайн использования,  
и показывает возможные поломки, которые могут происходить в ходе рефакторинга,  
или доработки тестируемого кода.  


Описание типичного теста
------------------------
Типичный юнит-тест выглядит как то так:  

```cpp
#include <gtest/gtest.h>
#include <tools/group.hpp>

TEST(classic, example)
{
    const char* group = "EUR*,!EUR*NH";
    ASSERT_TRUE( me::match_group("EURUSD", group));
    ASSERT_TRUE( me::match_group("EURASD", group));
    ASSERT_TRUE( me::match_group("EURHHH", group));
    ASSERT_TRUE(!me::match_group("EURNNH", group));
    ASSERT_TRUE(!me::match_group("EURNH" , group));
}
```
В примере выше тестируется функция `match_group`  
В строке `TEST(classic, example)` определяется название юнит-теста  
Первое слово `classic` - название тестового набора.  
Второе слово `example` - название конкретного сценария из набора `classic`  

Общая идея простого юнит-теста заключается в том,  
что нужно запустить тестируемую функциональность на выполнение,  
и далее проверить совпадает ли реальный результат с ожидаемым эталоном.  

Для этого гугло-тесты предлагают использовать ряд макросов,  
Которые можно разделить на четыре категории:  

  - Макросы которые начинаются на `ASSERT_`, например `ASSERT_TRUE`  
    если макрос провалился, то дальнейшее выполнение теста прекращается.  
    Я рекомендую использовать именно такие макросы везде, где только можно.  

  - Макросы которые начинаются на `EXPECT_`, например `EXPECT_TRUE`  
    если макрос провалился, то итоговый результат теста будет "не пройден",  
    однако при этом сам тест продолжит выполнение.  
    Такой макрос можно использовать, когда нужно выполнить некоторый код,  
    независимо от успеха/провала основной проверки.  

  - Макросы которые ловят эксепшены.  
    С помощью этих макросов удобно описывать в каких случаях какие ожидаются эксепшены:  
      - `ASSERT_THROW(statement, exception_type)`  
      - `ASSERT_ANY_THROW(statement)`  
      - `ASSERT_NO_THROW(statement)`  

  - Смертельные тесты. Применяются в ситуациях, когда ожидается гибель процесса.  
    Например, что бы убедиться в том, что assert-проверки успешно срабатывают:  
      - `ASSERT_DEATH(statement, descript)`  

Каталог макросов
----------------
Гугло-тесты предлагают множество макросов.  
Сравнение чего угодно:  
  - `ASSERT_TRUE(condition)`  
  - `ASSERT_FALSE(condition)`  
  - `ASSERT_EQ(expected, actual)` аналогично: `if a == b`  
  - `ASSERT_NE(val1, val2)` аналогично: `if a != b`  
  - `ASSERT_LT(val1, val2)` аналогично: `if a < b`  
  - `ASSERT_LE(val1, val2)` аналогично: `if a <= b`  
  - `ASSERT_GT(val1, val2)` аналогично: `if a > b`  
  - `ASSERT_GE(val1, val2)` аналогично: `if a >= b`  

Сравнения строк:  
  - `ASSERT_STREQ(str, etalon)` аналогично: `if a == b`  
  - `ASSERT_STRNE(str, etalon)` аналогично: `if a != b`  
  - `ASSERT_STRCASEEQ(str, etalon)` регистронезависимо  
  - `ASSERT_STRCASENE(str, etalon)` регистронезависимо  

Сравнения дробных:  
  - `ASSERT_FLOAT_EQ(expected, actual)`  
     - неточное сравнение float  
  - `ASSERT_DOUBLE_EQ(expected, actual)`  
     - неточное сравнение double  
  - `ASSERT_NEAR(val1, val2, absval)`  
     - разница между val1 и val2 не превышает погрешность absval  

Виндузятные `HRESULT`:  
  - `EXPECT_HRESULT_SUCCEEDED(expression)`  
  - `ASSERT_HRESULT_SUCCEEDED(expression)`  

Тесты предикатов:  
  - `ASSERT_PREDN(pred, val1, val2, ..., valN)` N <= 5  
  - `ASSERT_PRED_FORMATN(pred_format, val1, val2, ..., valN)`  
    работает аналогично предыдущему, но позволяет контролировать вывод  

Вызов отказа или успеха:  
  - `ADD_FAILURE_AT("path", line_number)`  
  - `ADD_FAILURE()`  
  - `SUCCEED()`  
  - `FAIL()`  


Макросы сопоставления:  

```cpp
#include <gmock/gmock.h>

using ::testing::AllOf;
using ::testing::Gt;
using ::testing::Lt;
using ::testing::MatchesRegex;
using ::testing::StartsWith;
...
EXPECT_THAT(value1, StartsWith("Hello"));
EXPECT_THAT(value2, MatchesRegex("Line \\d+"));
ASSERT_THAT(value3, AllOf(Gt(5), Lt(10)));
```


Можно написать собственную функцию, возвращающую `AssertionResult`  
Обратите внимание, что AssertionSuccess/AssertionFailure  
способны принимать текст с описанием ситуативного момента:  

```cpp
using testing::AssertionResult
using testing::AssertionSuccess
using testing::AssertionFailure

AssertionResult check(const bool val)
{
	if (val)
		return AssertionSuccess();
	else
		return AssertionFailure() 
            << "can add a description of the error\n"
            << "unexcpected: " << val << '\n';
}

TEST(examle, custom_result)
{
	ASSERT_TRUE(check(false));
}
```

static_assert
---
Гугло-тесты предлагают собственный аналог проверки времени компиляции вида:  
```
static_assert(std::is_same<T, U>::value, "error"); 
```
В исполнении гугло-тестов она выглядит так:  
```cpp
template <typename T> struct Foo 
{
    void Bar() { testing::StaticAssertTypeEq<int, T>(); }
};
```

SCOPED_TRACE
---
Что бы продебажить какую то сложно-замороченную логику,  
можно ставить метки так: `SCOPED_TRACE(message)`  
Текст метки выводится только в том случае, когда макро-тест проваливается.  
Например в этом случае тест будет успешным, и поэтому текст метки выводиться не будет:  

```cpp
#include <gtest/gtest.h>

TEST(trace, 001)
{
    const bool ok = true;
    SCOPED_TRACE("check: ok");
    EXPECT_TRUE(ok);
}
```
Вывод в консоль:  
```
[----------] 1 test from trace
[ RUN      ] trace.001
[       OK ] trace.001 (0 ms)
[----------] 1 test from trace (0 ms total)
```

Однако в случае ошибки, текст `SCOPED_TRACE` добавляется в отчет:  

```cpp
#include <gtest/gtest.h>

static bool check(int n)
{
    return n < 0;
}

TEST(trace, 002)
{
    for (size_t n = 0; n < 3; ++n)
    {
        SCOPED_TRACE(n);
        EXPECT_PRED1(check, n);
    }
}
```

Вывод в консоль:  

```
[ RUN      ] trace.002
test-trace.cpp(27): error: check(n) evaluates to false, where
n evaluates to 0
Google Test trace:
test-trace.cpp(26): 0

test-trace.cpp(27): error: check(n) evaluates to false, where
n evaluates to 1
Google Test trace:
test-trace.cpp(26): 1

test-trace.cpp(27): error: check(n) evaluates to false, where
n evaluates to 2
Google Test trace:
test-trace.cpp(26): 2

[  FAILED  ] trace.002 (0 ms)
```
<br/>

предикат
---
Пример использования предикатов:  

```cpp
#include <gtest/gtest.h>

bool check(int v1, int v2, int v3)
{
    return v1 > v2 && v2 > v3;
}

TEST(pred, 001)
{
    ASSERT_PRED3(check, 4, 3, 2);
}

testing::AssertionResult 
foo(const char* s1, const char* s2, const char* s3, int v1, int v2, int v3)
{
    if(v1 > v2 && v2 > v3)
        return testing::AssertionSuccess();
    return testing::AssertionFailure() 
        << "v1: " << s1 << '\n'
        << "v2: " << s2 << '\n'
        << "v3: " << s3 << '\n';
}

TEST(pred, 002)
{
    ASSERT_PRED_FORMAT3(foo, 4, 3, 2);
}
```
<br/>


История изменений 
-----------------

|  ID  |    дата    | время |      ветка      | status  |  длительность  |
|:----:|:----------:|:-----:|:---------------:|:-------:|:--------------:|
| 0001 | 2025-12-05 | 22:20 | [#3-dev-sample] | VERSION | 22 часа 50 мин |

[#3-dev-sample]: ../history.md#-v003-dev
