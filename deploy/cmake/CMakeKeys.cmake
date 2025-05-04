# --- Kartonagnick/example_gtest                        [cmake][CMakeKeys.cmake]
# [2024-12-03][19:10:00] 001 Kartonagnick    
################################################################################
#
# здесь определяются ключи компилятора
#

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  include("${CMAKE_CURRENT_LIST_DIR}/gcc.cmake")
elseif(MINGW)
  include("${CMAKE_CURRENT_LIST_DIR}/gcc.cmake")
elseif(MSVC)
  include("${CMAKE_CURRENT_LIST_DIR}/msvc.cmake")
else()
  message(WARNING "unknown compiler")
endif()

#...............................................................................

function(cxx_remove_duplicate variable)
  set(value ${${variable}})
  if(value STREQUAL "")
    return()
  endif()
  set(result)
  separate_arguments(value)
  list(REMOVE_DUPLICATES value)
  foreach(cur ${value})
    set(result "${result} ${cur}")
  endforeach()
  string(STRIP "${result}" result)
  set(${variable} "${result}" PARENT_SCOPE) 
endfunction()

macro(cxx_clean_keys)
  cxx_remove_duplicate(CMAKE_C_FLAGS)
  cxx_remove_duplicate(CMAKE_CXX_FLAGS)
  foreach(cfg ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${cfg} CONFIG)
    cxx_remove_duplicate(CMAKE_CXX_FLAGS_${CONFIG})
    cxx_remove_duplicate(CMAKE_C_FLAGS_${CONFIG})
  endforeach()
endmacro()

#...............................................................................

macro(cxx_standart)
  if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.25")  
    set(CMAKE_CXX_STANDARD 26)
  elseif(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.20")
    set(CMAKE_CXX_STANDARD 23)
  elseif(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.12")
    set(CMAKE_CXX_STANDARD 20)
  elseif(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.08")
    set(CMAKE_CXX_STANDARD 17)
  else()
    set(CMAKE_CXX_STANDARD 14)
  endif()
  set(CMAKE_CXX_EXTENSIONS        OFF)
  set(CMAKE_CXX_STANDARD_REQUIRED OFF)
endmacro()

#...............................................................................

macro(cxx_compile_keys)
  cxx_standart()
  cxx_compiler_keys()
  cxx_clean_keys()
endmacro()
