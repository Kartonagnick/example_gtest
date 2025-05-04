
# --- Kartonagnick/example_gtest                        [deploy][CMakeLists.txt]
# [2025-12-04][15:00:00] 001 Kartonagnick    
# [2025-12-02][11:19:56] registered on github
# [2025-11-29][13:42:02] birthday of the project
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.17)

project(
  example_gtest 
  VERSION 0.0.1
  LANGUAGES CXX
)

get_filename_component(dir "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)
set(settings "${dir}/deploy/cmake")

include("${settings}/CMakeBit.cmake")
include("${settings}/CMakeCRT.cmake")
include("${settings}/CMakeKeys.cmake")
include("${settings}/CMakePath.cmake")

cxx_runtime()
cxx_output_path_global()
cxx_address_model()
cxx_compile_keys()

# message("crt: ${gRUNTIME_CPP}")
# message("bit: ${gADDRESS_MODEL}")

#-------------------------------------------------------------------------------

add_subdirectory("${dir}/sample.lib")
add_subdirectory("${dir}/sample.exe")

#-------------------------------------------------------------------------------

include(CTest)
if(BUILD_TESTING)
  add_subdirectory("${dir}/tests")
endif()

#-------------------------------------------------------------------------------
