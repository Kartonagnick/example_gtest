# --- Kartonagnick/example_gtest                    [sample.lib][CMakeLists.txt]
# [2024-12-04][15:00:00] 001 Kartonagnick PRE
################################################################################

cmake_minimum_required(VERSION 3.10)
project(sample_exe CXX)

get_filename_component(dir "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)

set(include "${dir}/include/sample")
set(sources "${dir}/sources"       )

add_executable(sample_exe
  "${sources}/main.cpp"
) 

cxx_output_name(sample_exe sample)
cxx_output_path(sample_exe EXECUTABLE)

target_include_directories(sample_exe PUBLIC 
  "${dir}/include"
)

target_link_libraries(sample_exe 
  PRIVATE sample::sample_lib
)

#-------------------------------------------------------------------------------

install(TARGETS sample_exe DESTINATION "bin")

#-------------------------------------------------------------------------------

