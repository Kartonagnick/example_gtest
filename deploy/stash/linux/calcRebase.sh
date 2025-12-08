#!/bin/bash

# --- Kartonagnick/example_gtest                   [deploy/stash][calcRebase.sh]
# [2025-12-08][22:30:00] 001 Kartonagnick PRE
#-------------------------------------------------------------------------------

calculate()
{
  echo "--------[calcRebase]"
  version_end=3
  version_beg=2

  let delta="$version_end - $version_beg"
  let result="$delta * 2 + 2"

  echo "result = $result"
  echo "--------[calcRebase]"
}

#-------------------------------------------------------------------------------

clear
echo ""
calculate
