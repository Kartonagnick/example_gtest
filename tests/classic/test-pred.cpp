// --- Kartonagnick/example_gtest                         [tests][test-pred.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================
// https://google.github.io/googletest/reference/assertions.html

#include <gtest/gtest.h>
#include <algorithm>

// Returns the smallest prime common divisor of m and n,
// or 1 when m and n are mutually prime.
int SmallestPrimeCommonDivisor(int a, int b) 
{
    for (int i = 2; i <= (std::min)(a, b); ++i)
    {
        if ((a % i == 0) && (b % i == 0))
            return i;
    }
    return 1;
}

// Функция для вычисления наибольшего общего делителя (НОД) 
// с помощью алгоритма Евклида
int gcd(int a, int b) 
{
    while (b != 0)
    {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

// Функция MutuallyPrime, возвращающая true, если числа взаимно просты
bool MutuallyPrime(int num1, int num2)
{
    return gcd(num1, num2) == 1;
}

// A predicate-formatter for asserting that two integers are mutually prime.
testing::AssertionResult AssertMutuallyPrime(
    const char* m_expr, 
    const char* n_expr, 
    int m, 
    int n) 
{
    if (MutuallyPrime(m, n)) 
      return testing::AssertionSuccess();

    return testing::AssertionFailure() 
        << m_expr << " and " << n_expr
        << " (" << m << " and " << n << ") "
        << "are not mutually prime, "
        << "as they have a common divisor " 
        << SmallestPrimeCommonDivisor(m, n);
}

TEST(pred, 001)
{
    const int a = 3;
    const int b = 4;
    const int c = 10;
    (void) c;

    // Succeeds
    EXPECT_PRED_FORMAT2(AssertMutuallyPrime, a, b);  

    #if 0
    // Fails
    EXPECT_PRED_FORMAT2(AssertMutuallyPrime, b, c);  
    

    // test-pred.cpp(68): error: b and c (4 and 10) are not mutually prime, 
    // as they have a common divisor 2
    #endif
}


bool check(int v1, int v2, int v3)
{
    return v1 > v2 && v2 > v3;
}

TEST(pred, 002)
{
    ASSERT_PRED3(check, 4, 3, 2);
}

testing::AssertionResult
foo(const char* s1, const char* s2, const char* s3, int v1, int v2, int v3)
{
    if(v1 > v2 && v2 > v3)
        return testing::AssertionSuccess();

    return testing::AssertionFailure() 
        << "v1: " << s1 << "\n"
        << "v2: " << s2 << "\n"
        << "v3: " << s3 << "\n";
}

TEST(pred, 003)
{
    ASSERT_PRED_FORMAT3(foo, 4, 3, 2);
}
