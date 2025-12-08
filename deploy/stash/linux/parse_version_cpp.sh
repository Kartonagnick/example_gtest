#!/bin/bash

declare -A versionMD
parse_version_cpp()
{
  local line="$1"
  local author=""
  local date=""
  local time=""
  local ver=""
  local tag=""

  #example: // [2025-09-16][05:40:00] 001 Kartonagnick PRE

  if ! [[ $line =~ [[:space:]]*(//|\'|#)[[:space:]]*(.*) ]]; then
    return 1
  fi

  line="${BASH_REMATCH[2]}"
  if ! [[ $line =~ \[(.*)\]\[(.*)\][[:space:]]+(.*) ]]; then
    return 1
  fi

  date="${BASH_REMATCH[1]}"
  time="${BASH_REMATCH[2]}"
  line="${BASH_REMATCH[3]}"
  if ! [[ $line =~ ([[:digit:]]+)[[:space:]]+([[:alnum:]_]+)[[:space:]]*([[:alnum:]]*) ]]; then
    return 1
  fi

  ver="${BASH_REMATCH[1]}"
  author="${BASH_REMATCH[2]}"
  tag="${BASH_REMATCH[3]}"

  if [ "$tag" = "" ]; then
    tag="PRE"
  fi

  versionMD["author"]="$author"
  versionMD["date"]="$date"
  versionMD["time"]="$time"
  versionMD["ver"]="$ver"
  versionMD["tag"]="$tag"
  return 0
}

load_sourse()
{            
  local line=""
  local fullpath="$1"
  while read -r line; do
    if parse_version_cpp "$line"; then
      return 0
    fi
  done < "$fullpath"
  return 1
}

example_version_source()
{
  clear 
  echo ""
  echo " ---- begin"

  #line="//[2025-09-16][05:40:00] 001 Kartonagnick REL"
  #line="'[2025-09-16][05:40:00] 001 Kartonagnick REL"
  #parse_version_cpp "$line"

  fullpath="/home/lakilea/repo/Kartonagnick/example_gtest/sample.lib/sources/sample.cpp"
  if load_sourse "$fullpath"; then
    echo "success"
  else
    echo "failed"
  fi

  echo "versionMD[date] = ${versionMD["date"]}"
  echo "versionMD[time] = ${versionMD["time"]}"
  echo "versionMD[ver] = ${versionMD["ver"]}"
  echo "versionMD[author] = ${versionMD["author"]}"
  echo "versionMD[tag] = ${versionMD["tag"]}"
}
