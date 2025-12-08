#!/bin/bash

# --- Kartonagnick/example_gtest                        [deploy/stash][staff.sh]
# [2025-12-08][22:30:00] 001 Kartonagnick PRE
#-------------------------------------------------------------------------------

source parse_version_cpp.sh
source parse_version_md.sh

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

string_contain() 
{
  case $2 in 
    *$1* ) 
      return 0;; 
    *) 
      return 1;; 
  esac ;
}

string_split_text()
{
  for item in $(echo "$1" | tr ";" "\n")
  do
    echo "$item"
  done
}

string_split_variable()
{
  local text="$1"
  eval text="\$$text"
  for item in $(echo "$text" | tr ";" "\n")
  do
    echo "$item"
  done
}

is_exclude_by_masks1()
{
  local fullpath="$1"
  local exc_list=$(string_split_variable "$2")
  local filename=$(basename -- "$fullpath")

  count=${#exc_list[@]}
  if [ $count = 0 ]; then #list of exclude is empty
    return 1
  fi

  for mask in ${exc_list[@]}; do
    if [[ "$filename" == $mask ]]; then
      return 0
    fi
  done
  return 1
}

is_exclude_by_masks2()
{
  local fullpath="$1"
  local exc_list=$(string_split_variable "$2")
  local filename=$(basename -- "$fullpath")

  count=${#exc_list[@]}
  if [ $count = 0 ]; then #list of exclude is empty
    return 1
  fi

  for mask in ${exc_list[@]}; do
    case $filename in
      $mask) return 0;;
    esac
  done
  return 1
}

is_exclude_by_masks()
{
  if is_exclude_by_masks1 "$1" "$2"; then
    return 0
  fi
  return 1
}

is_exclude_by_extension()
{
  local fullpath="$1"
  local exc_list=$(string_split_variable "$2")
  local filename=$(basename -- "$fullpath")
  local extension="${filename##*.}"
  local filename="${filename%.*}"

  count=${#exc_list[@]}

  if [ $count = 0 ]; then
    return 1
  fi

  for ext in ${exc_list[@]}; do
    echo "element: $ext"
    if [ "$ext" = "$extension" ]; then
      return 0
    fi
  done
  return 1
}

is_include_by_extension()
{
  local fullpath="$1"
  local inc_list=$(string_split_variable "$2")
  local filename=$(basename -- "$fullpath")
  local extension="${filename##*.}"
  local filename="${filename%.*}"

  count=${#inc_list[@]}

  if [ $count = 0 ]; then
    return 0
  fi

  for ext in ${inc_list[@]}; do
    # echo "element: $ext"
    if [ "$ext" = "$extension" ]; then
      return 0
    fi
  done
  return 1
}

is_binary_heuristic()
{
  local path="$1"  
  local list_bin="$2"  
  local list_txt="$3"  
  if is_include_by_extension "$path" "list_bin"; then # binary file
    return 0
  fi

  if is_include_by_extension "$path" "list_txt"; then # text file
    return 1
  fi

  if file "$path" | grep -iq ASCII ; then # text file
    return 1
  fi

  # binary file
  return 0
}

get_version()
{
  local fullpath="$1"
  local list_bin="$2"  
  local list_txt="$3"  
  local exc_masks="$4"

  if ! [ -f "$1" ]; then # file not exist
    # echo "file not exist: $fullpath"
    return 1
  fi

  local filename=$(basename -- "$fullpath")
  local extension="${filename##*.}"
  local filename="${filename%.*}"

  if [ "$extension" == "md" ]; then  # this is markdown
    # echo "load_markdown: $fullpath"
    if load_markdown "$fullpath"; then
      return 0
    else
      return 1
    fi
  fi

  if is_exclude_by_masks "$path" "exc_masks"; then
    # echo "is_exclude_by_masks: $fullpath"
    return 1
  fi

  if ! is_binary_heuristic "$path" "list_bin" "list_txt"; then
    # echo "is_binary_heuristic: $fullpath"
    return 1
  fi

  if load_sourse "$fullpath"; then
    # echo "load_sourse: $fullpath"
    return 0
  else
    # echo "load_sourse failed: $fullpath"
    return 1
  fi
}

prepare()
{
  eDIR_SCRIPT=$(get_script_dir)
  eNAME=$(basename "${eDIR_SCRIPT}")
  eDIR_REPO=$(readlink -f -- "$eDIR_SCRIPT/../../$eNAME")
}
