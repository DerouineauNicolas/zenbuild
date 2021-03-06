#!/bin/bash

set -euo pipefail
trap "echo Failure" EXIT

function main {
  readonly targetPackages="$@"

  echo "#!/bin/bash"
  echo "# This file was generated by zenbuild,"
  echo "# with the following command:"
  echo "# $0 $* "
  echo "#"

  allPackages=$(get_all_needed_packages $targetPackages | sort -u)

  echo "# This script builds the following packages:"
  for pkg in $allPackages ; do
    echo "# - $pkg"
  done
  echo "#"

  for pkg in $allPackages ; do
    cat zen-$pkg.sh | grep -v "^#"
  done

  echo "#####################################"
  echo "# ZenBuild utility functions"
  echo "#####################################"

  cat zenbuild.sh | grep -v "^ *importPkgScript " | grep -v "^#" | grep -v "^main "

  for pkg in $allPackages ; do
    echo "main extra $pkg \$1"
  done
}

function get_deps {
  local pkg=$1
  if [ ! -f "zen-$pkg.sh" ] ; then
    echo "Package '$pkg' does not have a zenbuild script."
    exit 1
  fi

  source zen-$pkg.sh
  local deps=$(${pkg}_get_deps)
  for depPkg in $deps ; do
    echo $depPkg
    get_deps $depPkg
  done | sort -u
}

function get_all_needed_packages {
  local packages=$*
  for pkg in $packages ; do
    echo $pkg
    get_deps $pkg
  done | sort -u
}

main "$@"

trap - EXIT
