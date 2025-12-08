#!/bin/bash

declare -A versionMD
parse_version_md()
{
  local tag=""
  local val=""
  local ver=""
  local line="$1"

  # example: [![S]][H] Хронология v0.0.4
  # example: [![S]][H] **v0.0.4 (dev)**

  if ! [[ $line =~ .*\[!\[(S|P)\]\]\[H\].*([0-9]+\.[0-9]+\.[0-9]+) ]];then
    return 1
  else
    tag="${BASH_REMATCH[1]}"
    val="${BASH_REMATCH[2]}"
  fi

  tag=$(echo "$pre" | sed 's/./\L&/g')

  if [ "$pre" = "p" ]; then
    tag="PRE"
  elif [ "$pre" = "s" ]; then
    tag="REL"
  elif [ "$pre" = "b" ]; then
    tag="BUG"
  elif [ "$pre" = "d" ]; then
    tag="DOC"
  elif [ "$pre" = "t" ]; then
    tag="TST"
  else
    tag="REL"
  fi

  ver="${val//./}"
  versionMD["tag"]="$tag"
  versionMD["val"]="$val"
  versionMD["ver"]="$ver"
  return 0
}

load_markdown()
{            
  local line=""
  local fullpath="$1"

#  echo "load_markdown: $fullpath"

  while read -r line; do
    if parse_version_md "$line"; then
      return 0
    fi
  done < "$fullpath"
  return 1
}

example_version_md()
{
  clear 
  echo ""
  echo " ---- begin"

  fullpath="/home/lakilea/repo/Kartonagnick/example_gtest/docs/docs.md"
  if load_markdown "$fullpath"; then
    echo "success"
  else
    echo "failed"
  fi

  echo "versionMD[val] = ${versionMD["val"]}"
  echo "versionMD[tag] = ${versionMD["tag"]}"
  echo "versionMD[ver] = ${versionMD["ver"]}"
}
