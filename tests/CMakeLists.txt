# --- Kartonagnick/example_gtest                         [tests][CMakeLists.txt]
# [2025-12-05][20:20:00] 002 Kartonagnick    
# [2025-12-04][15:00:00] 001 Kartonagnick
################################################################################

cmake_minimum_required(VERSION 3.10)
project(tests CXX)

find_package(GTest REQUIRED)

get_filename_component(dir "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)

add_executable(tests
  "${dir}/classic/test-classic.cpp"
  "${dir}/classic/test-fixture.cpp"
  "${dir}/classic/test-sample.cpp"
  "${dir}/classic/test-trace.cpp"
  "${dir}/classic/test-pred.cpp"
  "${dir}/mock/test-matcher.cpp"
  "${dir}/mock/test-const-ref.cpp"
  "${dir}/mock/test-const-ptr.cpp"
  "${dir}/mock/test-array.cpp"
  "${dir}/mock/test-fake1.cpp"
  "${dir}/mock/test-mock1.cpp"
  "${dir}/mock/test-mock2.cpp"
  "${dir}/mock/test-mock3.cpp"
  "${dir}/turtle/test-turtle.hpp"
  "${dir}/turtle/test-turtle-general.cpp"
  "${dir}/turtle/test-turtle-example.cpp"
  "${dir}/turtle/test-turtle-sequences.cpp"
  "${dir}/turtle/test-turtle-sticky.cpp"
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
