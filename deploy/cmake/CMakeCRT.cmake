# --- Kartonagnick/example_gtest                         [cmake][CMakeCRT.cmake]
# [2024-12-03][19:10:00] 001 Kartonagnick PRE
#-------------------------------------------------------------------------------
#
# gRUNTIME_CPP определяет модель используемого рантайма c++
#   - dynamic: динамический рантайм (MultiThreadedDLL, /MD или /MDd)
#   - static : статический рантайм  (MultiThreaded, /MT или /MTd)
#     - используется по умолчанию
#
# переменную gRUNTIME_CPP можно задать при запуске cmake:
#   cmake               ^
#     -S"%eDIR_SOURCE%" ^
#     -B"%eDIR_BUILD%"  ^
#     -G"%eGENERATOR%"  ^
#     -D"gRUNTIME_CPP=static"
#
# либо можно определить переменную окружения среды,
# и тогда, при запуске cmake, параметр можно не указывать:
#   set eRUNTIME_CPP=static
#   cmake               ^
#     -S"%eDIR_SOURCE%" ^
#     -B"%eDIR_BUILD%"  ^
#     -G"%eGENERATOR%"  ^

function(cxx_detect_runtimecpp)
  if(gRUNTIME_CPP STREQUAL "static")
    return()
  elseif(gRUNTIME_CPP STREQUAL "dynamic")
    return()
  elseif(NOT gRUNTIME_CPP STREQUAL "")
    message("[ERROR] gRUNTIME_CPP: ${gRUNTIME_CPP}")
    message("[ERROR] gRUNTIME_CPP: invalid value")
    message(FATAL_ERROR "gRUNTIME_CPP: invalid value")
  endif()

  set(eRUNTIME_CPP "$ENV{eRUNTIME_CPP}")
  if(eRUNTIME_CPP STREQUAL "")
    set(eRUNTIME_CPP "static")
  elseif(eRUNTIME_CPP STREQUAL "static")
    # nothing
  elseif(eRUNTIME_CPP STREQUAL "dynamic")
    # nothing
  else()
    message("[ERROR] eRUNTIME_CPP: ${eRUNTIME_CPP}")
    message("[ERROR] eRUNTIME_CPP: invalid value")
    message(FATAL_ERROR "eRUNTIME_CPP: invalid value")
  endif()
  set(gRUNTIME_CPP "${eRUNTIME_CPP}" PARENT_SCOPE)
endfunction()

function(cxx_runtime)
  cxx_detect_runtimecpp()
  if(NOT MSVC)
      return()
  endif()
  if(gRUNTIME_CPP STREQUAL "dynamic")
    # message("crt: dynamic")
    add_compile_options(
      $<$<CONFIG:>:/MD>
      $<$<CONFIG:Debug>:/MDd>
      $<$<CONFIG:Release>:/MD>
    )
  else()
    # message("crt: static")
    add_compile_options(
      $<$<CONFIG:>:/MT>
      $<$<CONFIG:Debug>:/MTd>
      $<$<CONFIG:Release>:/MT>
    )
  endif()
endfunction()

#-------------------------------------------------------------------------------

#
# Examples:
#
#   Global default: /MD  
#   set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL$<$<CONFIG:Debug>:Debug>")  
#
# Target 1: Use default /MD  
#   add_executable(AppMD src/app1.cpp)  
#
# Target 2: Use /MT  
#   add_executable(AppMT src/app2.cpp)  
#   set_target_properties(AppMT PROPERTIES 
#     MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>"
#   )  
# 
