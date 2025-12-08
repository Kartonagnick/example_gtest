#!/bin/bash

# --- Kartonagnick/example_gtest                    [deploy/stash][docs.view.sh]
# [2025-12-08][22:30:00] 001 Kartonagnick PRE
#-------------------------------------------------------------------------------

source staff.sh
main()
{
  echo "--------[docs.view]"
  readme_md="$eDIR_REPO/README.md"
  echo "doc: $readme_md"
  exec yandex-browser "$readme_md"
  echo "--------[docs.view]"
}

#-------------------------------------------------------------------------------

clear 
echo ""
prepare
main
