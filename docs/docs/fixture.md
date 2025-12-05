[![logo](../logo.png)](../docs.md "documentation") 

[H]: ../docs.md        "родитель"
[P]: ../icons/progress.png  "в процессе..."
[S]: ../icons/success.png   "ошибок не обнаружено"
   
[![P]][H] fixture v0.0.1
========================
Фиксирующие классы - вспомогательные классы, которые используются в ситуациях,  
когда перед проведением каждого теста нужно выполнить некоторую подготовительную работу,  
а по окончанию теста нужно выполнить некоторую зачистку.  

Пример:  

```cpp
#include <gtest/gtest.h>
#include <iostream>

struсt Foo
{
    Foo() noexcept: i(0)
    {
        std::cout << "CONSTRUCTED" << std::endl;
    }
    ~Foo()
    {
        std::cout << "DESTRUCTED" << std::endl;
    }
    int i;
};

class fixture : public testing::Test
{
protected:
    fixture(const fixture&)            = delete;
    fixture& operator=(const fixture&) = delete;
    fixture() noexcept: foo(){}

    void SetUp()
    {
        foo = new Foo;
        foo->i = 5;
    }
    void TearDown()
    {
        delete foo;
    }
    Foo* foo;
};

TEST_F(fixture, example_001)
{
    ASSERT_EQ(foo->i, 5);
    foo->i = 10;
}

TEST_F(fixture, example_002)
{
    ASSERT_EQ(foo->i, 5);
}
```

Обратите внимание: во втором тесте значение `foo->i` снова равно 5  
<br/>


История изменений 
-----------------

|  ID  |    дата    | время |      ветка      | status  |  длительность  |
|:----:|:----------:|:-----:|:---------------:|:-------:|:--------------:|
| 0001 | 2025-12-05 | 22:20 | [#3-dev-sample] | VERSION | 22 часа 50 мин |

[#3-dev-sample]: ../history.md#-v003-dev
