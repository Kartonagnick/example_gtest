# --- Kartonagnick/example_gtest                         [tests][CMakeLists.txt]
# [2025-12-04][15:00:00] 001 Kartonagnick PRE
################################################################################

cmake_minimum_required(VERSION 3.10)
project(tests CXX)

find_package(GTest REQUIRED)

get_filename_component(dir "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)

add_executable(tests
  "${dir}/classic/test-classic.cpp"
  "${dir}/classic/test-fixture.cpp"
  "${dir}/classic/test-sample.cpp"
  "${dir}/mock/test-mock1.cpp"
  "${dir}/mock/test-mock2.cpp"
  "${dir}/mock/test-mock3.cpp"
  "${dir}/main.cpp"
) 

target_include_directories(tests PRIVATE   
  "${GTEST_INCLUDE_DIRS}"
)

target_link_libraries(tests 
  PRIVATE sample::sample
  PRIVATE GTest::gtest
  PRIVATE GTest::gmock
)

cxx_output_path(tests UNIT_TEST)

# target_compile_definitions
# target_compile_options

#-------------------------------------------------------------------------------

add_test(NAME tests COMMAND tests)
