# --- Kartonagnick/example_gtest                             [cmake][msvc.cmake]
# [2024-12-03][19:10:00] 001 Kartonagnick    
#-------------------------------------------------------------------------------
#
# установка ключей для компиляторов gcc
#

function(gcc_apply_keys variable)
  set(keys "${${variable}}")

  set(keys1 "-pedantic -pedantic-errors -Wall -Weffc++ -Wextra -Werror")
  set(keys2 "-Wcast-align -Wold-style-cast -Wconversion -Wsign-conversion -Wcast-qual") 
  set(keys3 "-Woverloaded-virtual -Wctor-dtor-privacy -Wnon-virtual-dtor") 
  set(keys4 "-Winit-self -Wunreachable-code -Wunused-parameter -Wshadow")
  set(keys5 "-Wpointer-arith -Wreturn-type -Wswitch -Wformat -Wundef")
  set(keys6 "-Wwrite-strings -Wchar-subscripts -Wredundant-decls")
  set(keys7 "-Wparentheses -Wmissing-include-dirs -Wempty-body -Wextra")

  set(keys "${keys} ${keys1} ${keys2} ${keys3} ${keys4} ${keys5} ${keys6} ${keys7}")

  if(gRUNTIME_CPP STREQUAL "dynamic")
    if(keys)
      string(REGEX REPLACE "-static-libstdc\\+\\+"  ""  keys  "${value}")
      string(REGEX REPLACE "-static-libgcc"         ""  keys  "${value}")
      string(REGEX REPLACE "-static"                ""  keys  "${value}")
    endif()
  elseif(gRUNTIME_CPP STREQUAL "static")
    set(keys "${keys} -static-libgcc -static -static-libstdc++ ")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc -static -static-libstdc++ ")
  else()
    message(FATAL_ERROR "invalid 'gRUNTIME_CPP': ${gRUNTIME_CPP}")
  endif()

  set(${variable} "${keys}" PARENT_SCOPE)
endfunction()

#-------------------------------------------------------------------------------

function(cxx_compiler_keys)

   if(NOT gVERBOSE_OUTPUT)
     set (pre_keys "-ftrack-macro-expansion=0 -fno-diagnostics-show-caret")
   endif()

   #if(NOT gENABLE_MACRO_OUTPUT)
   #  add_definitions(-DdHIDE_MINGW_MESSAGES=1)
   #  add_definitions(-DdHIDE_CLANG_MESSAGES=1)
   #  add_definitions(-DdHIDE_GCC_MESSAGES=1)
   #endif()

   if(gADDRESS_MODEL EQUAL "32")
     set(pre_keys "${pre_keys} -m32")
   elseif(gADDRESS_MODEL EQUAL "64")
     set(pre_keys "${pre_keys} -m64")
   else()
     message(STATUS "[gADDRESS_MODEL] ... ${gADDRESS_MODEL}")
     message(FATAL_ERROR "invalid address model")
   endif()

   set(post_keys "-fopenmp -D_UNICODE -DUNICODE")
   set(CMAKE_CXX_FLAGS_RELEASE "${pre_keys} ${CMAKE_CXX_FLAGS_RELEASE} -O3 -DNDEBUG              ${post_keys}")
   set(CMAKE_CXX_FLAGS_DEBUG   "${pre_keys} ${CMAKE_CXX_FLAGS_DEBUG}   -O0 -g3 -DDEBUG -D_DEBUG  ${post_keys}")
   set(CMAKE_CXX_FLAGS         "${pre_keys} ${CMAKE_CXX_FLAGS}                                   ${post_keys}")

   set(CMAKE_C_FLAGS_RELEASE   "${pre_keys} ${CMAKE_C_FLAGS_RELEASE}   -O3 -DNDEBUG              ${post_keys}")
   set(CMAKE_C_FLAGS_DEBUG     "${pre_keys} ${CMAKE_C_FLAGS_DEBUG}     -O0 -g3 -DDEBUG -D_DEBUG  ${post_keys}")
   set(CMAKE_C_FLAGS           "${pre_keys} ${CMAKE_C_FLAGS}                                     ${post_keys}")

   # --- for gcc(5.4.0 - 8.1.0)
   if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 5.4)
     if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 8.1)
       link_libraries(stdc++fs)
     endif()
   endif()

   # link_libraries(crypt32)  # secure.hpp
   # link_libraries(urlmon)   # tools/url.hpp
   # link_libraries(psapi)    # tools/seh.hpp

   gcc_apply_keys(CMAKE_C_FLAGS)
   gcc_apply_keys(CMAKE_CXX_FLAGS)
   foreach(cfg ${CMAKE_CONFIGURATION_TYPES})
     string(TOUPPER "${cfg}" CONFIG)
     gcc_apply_keys(CMAKE_CXX_FLAGS_${CONFIG})
     gcc_apply_keys(CMAKE_C_FLAGS_${CONFIG})
   endforeach()

   set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}" PARENT_SCOPE)
   set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG}"   PARENT_SCOPE)
   set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS}"         PARENT_SCOPE)

   set(CMAKE_C_FLAGS_RELEASE   "${CMAKE_C_FLAGS_RELEASE}"   PARENT_SCOPE)
   set(CMAKE_C_FLAGS_DEBUG     "${CMAKE_C_FLAGS_DEBUG}"     PARENT_SCOPE)
   set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS}"           PARENT_SCOPE)
endfunction()
