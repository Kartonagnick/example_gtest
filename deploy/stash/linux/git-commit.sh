#!/bin/bash

# --- Kartonagnick/example_gtest                   [deploy/stash][git-commit.sh]
# [2025-12-08][22:30:00] 001 Kartonagnick PRE
#-------------------------------------------------------------------------------

source staff.sh

setup()
{
  prepare

  eDEBUG="ON"
  eBIN_EXTENSION="jpg;png;exe;graphml"
  eTXT_EXTENSION="cpp;hpp;txt;md;bat;h;hpp;hxx;cpp;cxx;yml;.gitignore"
  eFILE_EXCLUDES="*.c"

  eDIR_COMMIT=(
    "new\boost" \
    "old\boost" \
    "icons"     \
    "sandbox-1" \
    "sandbox-2" \
    "sandbox-3" \
  )

  pushd "$eDIR_REPO" > /dev/null
}

showSetup()
{
  echo "eDIR_REPO: $eDIR_REPO"
  for a in ${eDIR_COMMIT[@]}; do
    echo "item: $a"
  done
}

show_map_commit()
{
  test_val= ${map["ololo"]}
  if [ "$test_val" = "icons" ];
  then
    echo "ololo was found"
  fi

  for key in ${!map[@]}; do
    echo "map(key): $key"
  done
  echo "map[icons] = ${map["icons"]}"
}

commitUntraced()
{
  untraced=($(git ls-files --others --exclude-standard))    
  count=${#untraced[@]}
  if [ $count = 0 ];
  then
    echo "untraced not found"
    return 0
  fi

# --- step 1: commit alone

  found=false
  for path in ${untraced[@]}; do
    found=false
    for item in ${eDIR_COMMIT[@]}; do
      if string_contain "$item" "$path"; then
        found=true
        break
      fi
    done

    if ! $found; then
      echo "untraced: $path -> alone"
      get_version "$path"

      #comment="add: " & d & " ..."
      #set result = runCmd("git commit -m " & param)
    fi
  done
  return 0

# --- make map of eDIR_COMMIT

  declare -A alone
  declare -A map

# --- sort untraced

  found=false
  for path in ${untraced[@]}; do
    found=false
    for item in ${eDIR_COMMIT[@]}; do
      if stringContain "$item" "$path"; then
        echo "untraced: $path -> $item"
        map[$item]=$path
        found=true
        break
      fi
    done

    if ! $found; then
      echo "untraced: $path -> alone"
      alone+=$path
    fi
  done

# --- experiment

}

example_version()
{
  fullpath="$1"
  echo "path: $fullpath"
  get_version        \
    "$fullpath"      \
    "eBIN_EXTENSION" \
    "eTXT_EXTENSION" \
    "eFILE_EXCLUDES"

  echo "versionMD[ver] = ${versionMD["ver"]}"
  echo "versionMD[tag] = ${versionMD["tag"]}"
}


main()
{
  setup
 #showSetup
 #commitUntraced

  local p1="$eDIR_REPO/sample.lib/CMakeLists.txt"
  local p2="$eDIR_REPO/sample.lib/sources/sample.cpp"
  local p3="$eDIR_REPO/docs/history.md"
  example_version "$p1"
  example_version "$p2"
  example_version "$p3"


 #local path="$eDIR_REPO/deploy/stash/linux/test1.cp"
 #if is_exclude_by_masks "$path" "eFILE_EXCLUDES"; then
 #  echo "exclude: $path"
 #else
 #  echo "include: $path"
 #fi

 #local path="$eDIR_REPO/docs/docs.md"
 #parse_version_md "$path"

}

#-------------------------------------------------------------------------------

clear 
echo ""
echo " ---- begin"
main
