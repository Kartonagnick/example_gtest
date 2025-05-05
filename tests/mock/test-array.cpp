// --- Kartonagnick/example_gtest                        [tests][test-array.cpp]
// [2025-12-05][20:20:00] 001 Kartonagnick    
//==============================================================================
//==============================================================================
// https://gitlab.inria.fr/Phylophile/Treerecs/blob/3caf718fdf0f4352b5773daf5898e3708a847484/tests/gtest/googlemock/docs/CookBook.md

#include <gmock/gmock.h>
#include <vector>
#include <string>

#ifdef __GNUC__
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Weffc++"
#endif


struct MockMutator
{
    MOCK_METHOD2(Mutate, void(int* values, int count));

    using vec_t = std::vector<std::string>;
    using arg_t = std::back_insert_iterator<vec_t>;
    MOCK_METHOD(void, GetNames, (arg_t));
};

#ifdef __GNUC__
    #pragma GCC diagnostic pop
#endif

using ::testing::_;
using ::testing::NotNull;
using ::testing::SetArrayArgument;

TEST(Mutator, array)
{
    MockMutator mutator;
    int etalon[5] = { 1, 2, 3, 4, 5 };
    EXPECT_CALL(mutator, Mutate(NotNull(), 5))
      .WillOnce(SetArrayArgument<0>(etalon, etalon + 5));

    int src[5] = { 6, 7, 8, 9, 0 };
    mutator.Mutate(src, 5);

    for(size_t i = 0; i != 5; ++i)
    {
        ASSERT_EQ(src[i], etalon[i]);
    }
}

TEST(Mutator, vector)
{
    using vec_t = std::vector<std::string>;
    using insert_t = std::back_insert_iterator<vec_t>;

    MockMutator mutator;
    
    vec_t names;
    names.push_back("George");
    names.push_back("John");
    names.push_back("Thomas");

    EXPECT_CALL(mutator, GetNames(_))
        .WillOnce(SetArrayArgument<0>(names.begin(), names.end()));

    vec_t src;
    const insert_t insert(src);
    mutator.GetNames(insert);
    ASSERT_EQ(src.size(), 3u);
    ASSERT_EQ("George", src[0]);
    ASSERT_EQ("John"  , src[1]);
    ASSERT_EQ("Thomas", src[2]);
}
