# --- Kartonagnick/example_gtest                    [sample.lib][CMakeLists.txt]
# [2025-12-04][15:00:00] 001 Kartonagnick PRE
################################################################################

cmake_minimum_required(VERSION 3.10)
project(sample_lib CXX)

get_filename_component(dir "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)

set(include "${dir}/include/sample")
set(sources "${dir}/sources"       )

add_library(sample_lib
  "${include}/sample.hpp"
  "${sources}/sample.cpp"
) 

target_include_directories(sample_lib PUBLIC 
  "${dir}/include"
)

cxx_output_name(sample_lib sample)
cxx_output_path(sample_lib STATIC_LIBRARY)

# target_compile_definitions
# target_compile_options
# target_link_libraries

add_library(sample::sample_lib ALIAS sample_lib)
add_library(sample::sample     ALIAS sample_lib)

set_target_properties(sample_lib PROPERTIES  
  DEBUG_POSTFIX "${CMAKE_DEBUG_POSTFIX}"
)

#-------------------------------------------------------------------------------

install(TARGETS sample_lib DESTINATION "lib")
install(DIRECTORY "${dir}/include/sample" DESTINATION "include")

#-------------------------------------------------------------------------------

# find_package(Doxygen)
# if("${DOXYGEN_FOUND}")
#   set(DOXYGEN_USE_MDFILE_AS_MAINPAGE README.md)
#   doxygen_add_docs(doxygen include/ src/ README.md ALL)
#   # The documentation will be in the build/html directory
#   # The main page is build/html/index.html
# endif()
