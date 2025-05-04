#!/bin/bash

# --- Kartonagnick/example_gtest                   [deploy][gcc][build_gtest.sh]
# [2025-12-03][19:10:00] 001 Kartonagnick PRE
#-------------------------------------------------------------------------------

clear 
echo "."

#-------------------------------------------------------------------------------

main()
{
  echo "--------[make] run... v0.0.1 PRE"

  echo "-1- prepare"
  prepare || return 1

  echo "-2- clone"
  clone   || return 1

  echo "-3- generate"
  generate "gcc" "64" "release"  "md" || return 1
  generate "gcc" "64" "debug"    "md" || return 1

  echo "-4- build"
  build    "gcc" "64" "release"  "md" || return 1
  build    "gcc" "64" "debug"    "md" || return 1

  echo "-5- install"
  install  "gcc" "64" "release"  "md" || return 1
  install  "gcc" "64" "debug"    "md" || return 1

  echo "--------[done]"
}

get_script_dir()
{
    # https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
    local SOURCE_PATH="${BASH_SOURCE[0]}"
    local SYMLINK_DIR
    local SCRIPT_DIR
    # Resolve symlinks recursively
    while [ -L "$SOURCE_PATH" ]; do
        # Get symlink directory
        SYMLINK_DIR="$( cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd )"
        # Resolve symlink target (relative or absolute)
        SOURCE_PATH="$(readlink "$SOURCE_PATH")"
        # Check if candidate path is relative or absolute
        if [[ $SOURCE_PATH != /* ]]; then
            # Candidate path is relative, resolve to full path
            SOURCE_PATH=$SYMLINK_DIR/$SOURCE_PATH
        fi
    done
    # Get final script directory path from fully resolved source path
    SCRIPT_DIR="$(cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd)"
    echo "$SCRIPT_DIR"
}

prepare()
{
  eGCC_VER=$(gcc -dumpfullversion)
  eDIR_SCRIPT=$(get_script_dir)
  eDIR_WORK=$(readlink -f -- "$eDIR_SCRIPT/../../..")

  ePREFIX_READY=_external
  ePREFIX_BUILD=_build
  ePREFIX_REPO=_repo
  ePROJECT=gtest

  eURL_GTEST="https://github.com/google/googletest"
  eDIR_SOURCE="$eDIR_WORK/$ePREFIX_REPO/googletest"
}

clone()
{
  if [ -d "$eDIR_SOURCE" ]; then
    return 0
  fi
  git clone "$eURL_GTEST" "$eDIR_SOURCE" && return 0
  echo "[ERROR] can not clone repo"
  echo "[ERROR] check: $eDIR_SOURCE"
  return 1
}

configure()
{
  tag=$1
  bit=$2
  cfg=$3
  crt=$4

  if [ "$tag" == "gcc" ]; then  
    tag=$tag$eGCC_VER
  fi  
  eCOMPILER_TAG=$tag

  eDIR_BUILD="$eDIR_WORK/$ePREFIX_BUILD/$ePROJECT-$eCOMPILER_TAG-$bit-$cfg-$crt"
  eDIR_READY="$eDIR_WORK/$ePREFIX_READY/$ePROJECT-$eCOMPILER_TAG-$bit-$crt"
  debug_postfix=""
  shared2=""
  shared=""

  if [ "$crt" = "md" ]; then  
    shared=-D"gtest_force_shared_crt=ON"
  fi  

  if [ "$crt" = "mt" ]; then  
    shared2=-D"CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded\$<\$<CONFIG:Debug>:Debug>"
  fi  

  if [ "$cfg" = "debug" ]; then  
    debug_postfix=-D"CMAKE_DEBUG_POSTFIX=_d"
  fi  
}

generate()
{
  configure "$1" "$2" "$3" "$4"
  echo "----- generate [$tag-$bit-$cfg-$crt]"
  cmake                                  \
    -S"$eDIR_SOURCE"                     \
    -B"$eDIR_BUILD"                      \
    -D"CMAKE_INSTALL_PREFIX=$eDIR_READY" \
    -D"CMAKE_BUILD_TYPE=$cfg"            \
  $shared $shared2 $debug_postfix

  if [ $? -eq 0 ]; then
    return 0
  fi

  echo "cmake: can not generate project"
  return 1
}

build()
{
  configure "$1" "$2" "$3" "$4"
  echo "----- build [$tag-$bit-$cfg-$crt]"
  cmake --build "$eDIR_BUILD"

  if [ $? -eq 0 ]; then
    return 0
  fi

  echo "cmake: can not build project"
  return 1
}

install()
{
  configure "$1" "$2" "$3" "$4"
  echo "----- install [$tag-$bit-$cfg-$crt]"
  cmake --install "$eDIR_BUILD"

  if [ $? -eq 0 ]; then
    return 0
  fi

  echo "cmake: can not install project"
  return 1
}

#-------------------------------------------------------------------------------

main
