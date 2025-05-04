# --- Kartonagnick/example_gtest                        [cmake][CMakePath.cmake]
# [2024-12-03][19:10:00] 001 Kartonagnick    
#-------------------------------------------------------------------------------

# пример того, как можно подправить пути к каталогам
# где нужно разместить результаты сборки

macro(cxx_output_path_global)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY         "${CMAKE_BINARY_DIR}/lib") 
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_BINARY_DIR}/lib/debug") 
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/lib/release") 

  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY         "${CMAKE_BINARY_DIR}/lib")
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_BINARY_DIR}/lib/debug")
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/lib/release")

  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY         "${CMAKE_BINARY_DIR}/bin")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_BINARY_DIR}/bin/debug")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin/release")
endmacro()


# Usage:
#   cxx_output_name("${TARGET_NAME}" "sample_exe" "sample_exe")

macro(cxx_output_name target output)

  set_target_properties(${target} PROPERTIES 
    OUTPUT_NAME "${output}"
  )

  foreach(conf ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${conf} CONFIG ) 
    set_target_properties(${target} PROPERTIES 
      OUTPUT_NAME_${CONFIG} "${output}"
    )
  endforeach()
endmacro()

# Usage:
#   cxx_output_path("${TARGET_NAME}" "EXECUTABLE"     "dir")
#   cxx_output_path("${TARGET_NAME}" "SHARED_LIBRARY" "dir")
#   cxx_output_path("${TARGET_NAME}" "STATIC_LIBRARY" "dir")
#   cxx_output_path("${TARGET_NAME}" "HEADER_ONLY"    "dir")
#   cxx_output_path("${TARGET_NAME}" "UNIT_TEST"      "dir")

function(cxx_output_path target type)
  if(type STREQUAL "EXECUTABLE")
    cxx_ouput_path_(${target} "RUNTIME_OUTPUT_DIRECTORY" "bin")

  elseif(type STREQUAL "UNIT_TEST")
    cxx_ouput_path_(${target} "RUNTIME_OUTPUT_DIRECTORY" "bin")

  elseif(type STREQUAL "SHARED_LIBRARY")
    cxx_ouput_path_(${target} "RUNTIME_OUTPUT_DIRECTORY" "bin")
    cxx_ouput_path_(${target} "LIBRARY_OUTPUT_DIRECTORY" "lib")
    cxx_ouput_path_(${target} "ARCHIVE_OUTPUT_DIRECTORY" "lib")
  elseif(type STREQUAL "STATIC_LIBRARY")
    cxx_ouput_path_(${target} "ARCHIVE_OUTPUT_DIRECTORY" "lib")

  elseif(type STREQUAL "HEADER_ONLY")
    cxx_ouput_path_(${target} "RUNTIME_OUTPUT_DIRECTORY" "bin")
    cxx_ouput_path_(${target} "LIBRARY_OUTPUT_DIRECTORY" "lib")
    cxx_ouput_path_(${target} "ARCHIVE_OUTPUT_DIRECTORY" "lib")

  else()
    message(FATAL_ERROR "${target}: invalid type: ${type}")
  endif()
endfunction()

function(cxx_ouput_path_ target property dir_output)

  set_target_properties(${target} PROPERTIES 
    ${property} "${CMAKE_BINARY_DIR}"
  )

  foreach(conf ${CMAKE_CONFIGURATION_TYPES})
    string(TOLOWER ${conf} CONFIG) 
    set_target_properties(${target} PROPERTIES 
      ${property}_${CONFIG} "${CMAKE_BINARY_DIR}/${CONFIG}"
    )
  endforeach()
endfunction()
