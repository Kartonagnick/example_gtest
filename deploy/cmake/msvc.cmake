# --- Kartonagnick/example_gtest                             [cmake][msvc.cmake]
# [2024-12-03][19:10:00] 001 Kartonagnick    
#-------------------------------------------------------------------------------
#
# установка ключей для компиляторов msvc
#

function(msvc_apply_keys variable)
  set(keys "${${variable}}")
  if(keys STREQUAL "")
    return()
  endif()
  
  string(REGEX REPLACE "/W[0-4]" "" keys ${keys})
  string(REGEX REPLACE "/Zi" "" keys ${keys})
  string(REGEX REPLACE "/EH.*" "" keys ${keys})

  if(gRUNTIME_CPP STREQUAL "dynamic")
     string(REPLACE "/MT" "/MD" keys "${keys}")
  elseif(gRUNTIME_CPP STREQUAL "static")
     string(REPLACE "/MD" "/MT" keys "${keys}")
  else()
    message(FATAL_ERROR "invalid 'gRUNTIME_CPP': ${gRUNTIME_CPP}")
  endif()
  set(${variable} "${keys}" PARENT_SCOPE)
endfunction()

#-------------------------------------------------------------------------------

function(cxx_compiler_keys)

  msvc_apply_keys(CMAKE_C_FLAGS)
  msvc_apply_keys(CMAKE_CXX_FLAGS)
  foreach(cfg ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER "${cfg}" CONFIG)
    msvc_apply_keys(CMAKE_CXX_FLAGS_${CONFIG})
    msvc_apply_keys(CMAKE_C_FLAGS_${CONFIG})
  endforeach()

  set(post_keys)
  if(MSVC_VERSION GREATER "1900")
    # msvc[2017 - new]
    set(post_keys "/permissive-")
  endif()

  if(MSVC_VERSION GREATER "1900" AND MSVC_VERSION LESS_EQUAL "1916")
    # msvc2017 only
    set(post_keys "${post_keys} /Zc:twoPhase-")
  endif()

  if(MSVC_VERSION GREATER "1500")
    # msvc[2010 - new]
    set(begin_keys "/MP")
  endif()

  if(MSVC_VERSION GREATER "1600")
    # msvc[2012 - new]
    set(begin_keys "/sdl ${begin_keys}")
  endif()

  if (MSVC_VERSION GREATER_EQUAL 1914)
    # msvc2017 (15.7) or latest
    set(post_keys "${post_keys} /Zc:__cplusplus")
  endif()

  set(post_keys    "${post_keys} /D_UNICODE /DUNICODE")
  set(common_keys  "${begin_keys} /GR /W4 /WX /nologo /openmp /FC /EHa")
  set(release_keys "/Gy /Oi /O2 /Ob2 /Ot /Oy /DNDEBUG")
  set(debug_keys   "/Od /Ob0 /Zi /RTC1 /DDEBUG /D_DEBUG")

  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${common_keys} ${release_keys} ${post_keys}" PARENT_SCOPE)
  set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG}   ${common_keys} ${debug_keys}   ${post_keys}" PARENT_SCOPE)
  set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS}         ${common_keys} ${post_keys}"                 PARENT_SCOPE)

  set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${common_keys} ${release_keys} ${post_keys}" PARENT_SCOPE)
  set(CMAKE_C_FLAGS_DEBUG   "${CMAKE_C_FLAGS_DEBUG}   ${common_keys} ${debug_keys}   ${post_keys}" PARENT_SCOPE)
  set(CMAKE_C_FLAGS         "${CMAKE_C_FLAGS}         ${common_keys} ${post_keys}"                 PARENT_SCOPE)
endfunction()
