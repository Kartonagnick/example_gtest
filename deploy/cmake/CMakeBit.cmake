# --- Kartonagnick/example_gtest                         [cmake][CMakeBit.cmake]
# [2024-12-03][19:10:00] 001 Kartonagnick PRE
#-------------------------------------------------------------------------------
#
# gADDRESS_MODEL определяет битность сборки: 32 или 64
#
# переменную gADDRESS_MODEL можно задать при запуске cmake:
#   cmake               ^
#     -S"%eDIR_SOURCE%" ^
#     -B"%eDIR_BUILD%"  ^
#     -G"%eGENERATOR%"  ^
#     -D"gADDRESS_MODEL=64"
#
# либо можно определить переменную окружения среды,
# и тогда, при запуске cmake, параметр можно не указывать:
#   set eADDRESS_MODEL=64
#   cmake               ^
#     -S"%eDIR_SOURCE%" ^
#     -B"%eDIR_BUILD%"  ^
#     -G"%eGENERATOR%"  ^
#
# если ничего не было заданно, тогда по умолчанию
# адресная модель будет вычисляться сначала по названию генератора:
#  - CMAKE_GENERATOR_PLATFORM

# если по генератору вычислить адрессную модель не удалось, 
# тогда она будет вычислена на основании размера указтеля:  
#  - CMAKE_SIZEOF_VOID_P  
#

#-------------------------------------------------------------------------------

function(cxx_address_model)

  if("${gADDRESS_MODEL}" STREQUAL "64")
    return()
  elseif("${gADDRESS_MODEL}" STREQUAL "32")
    return()
  elseif(NOT "${gADDRESS_MODEL}" STREQUAL "")
    message("[ERROR] gADDRESS_MODEL: ${gADDRESS_MODEL}")
    message("[ERROR] gADDRESS_MODEL: invalid value")
    message(FATAL_ERROR "gADDRESS_MODEL: invalid value")
  endif()

  set(eADDRESS_MODEL "$ENV{eADDRESS_MODEL}")
  if(eADDRESS_MODEL STREQUAL "")
    # nothing
  elseif("${eADDRESS_MODEL}" STREQUAL "32")
    # nothing
  elseif("${eADDRESS_MODEL}" STREQUAL "64")
    # nothing
  else()
    message("[ERROR] eADDRESS_MODEL: ${eADDRESS_MODEL}")
    message("[ERROR] eADDRESS_MODEL: invalid value")
    message(FATAL_ERROR "eADDRESS_MODEL: invalid value")
  endif()

  if(NOT eADDRESS_MODEL STREQUAL "")
    set(gADDRESS_MODEL "${eADDRESS_MODEL}" PARENT_SCOPE)
    return()
  endif()

  if(CMAKE_GENERATOR_PLATFORM MATCHES "x64")
    set(gADDRESS_MODEL "64")
  elseif(CMAKE_GENERATOR_PLATFORM MATCHES "Win32")
    set(gADDRESS_MODEL "32" )
  elseif(CMAKE_SIZEOF_VOID_P)  
    # available only after call `project(${gNAME_PROJECT} CXX)`
    if(CMAKE_SIZEOF_VOID_P MATCHES "8")
      set(gADDRESS_MODEL "64")    
    elseif(CMAKE_SIZEOF_VOID_P MATCHES "4")
      set(gADDRESS_MODEL "32")
    endif()
  endif()

  if(gADDRESS_MODEL STREQUAL "")
    message("gADDRESS_MODEL: can not detected")
    message(FATAL_ERROR "invalid address model")
 endif()

 set(gADDRESS_MODEL "${gADDRESS_MODEL}" PARENT_SCOPE)
endfunction()

#-------------------------------------------------------------------------------
