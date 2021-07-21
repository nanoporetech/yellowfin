#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script will make you up and running for testing and/or development on the Yellowfin project.
## usage:
##  bootstrap.sh --development
##  bootstrap.sh --testing
##  bootstrap.sh --build
##
##  options:
##    -d, --development Install the dependencies for building and installing Yellowfin theme
##    -t, --testing     Install the dependencies for testing an already installed Yellowfin theme
##    -b, --build       Build Yellowfin theme
##    -p [version], --package [version]   Package Yellowfin theme
##    -c, --clean       Clean the build directory

cd `dirname "${BASH_SOURCE[0]}"`
PACKAGE_DIR=build/pkg

# No-arguments is not allowed
[ $# -eq 0 ] && sed -ne 's/^## \(.*\)/\1/p' $0 && exit 1

# Converting long-options into short ones
for arg in "$@"; do
  shift
  case "$arg" in
"--development") set -- "$@" "-d";;
"--testing") set -- "$@" "-t";;
"--build") set -- "$@" "-b";;
"--package") set -- "$@" "-p";;
"--clean") set -- "$@" "-c";;
  *) set -- "$@" "$arg"
  esac
done

function print_illegal() {
    echo Unexpected flag in command line \"$@\"
}

# Parsing flags and arguments
while getopts 'hdtbpc' OPT; do
    case $OPT in
        h) sed -ne 's/^## \(.*\)/\1/p' $0
           exit 1 ;;
        d) _development=1 ;;
        t) _testing=1 ;;
        b) _build=1 ;;
        p) _package=1 ;;
        c) _clean=1 ;;
        \?) print_illegal $@ >&2;
            echo "---"
            sed -ne 's/^## \(.*\)/\1/p' $0
            exit 1
            ;;
    esac
done
# CLInt GENERATED_CODE: end

# TODO choose between apt and dnf (at least initially)
INSTALLER="apt install"

function log {
  echo "[+]" $@
}

development_deps=(meson dart-sass libgtk-3-dev)
testing_deps=(libgtk-3-dev gtk-3-examples gnome-tweaks)

function install {
  target=$1
  shift
  deps=($@)
  log "the following application will be installed for $target Yellowfin"
  for d in ${deps[@]}; do
    echo - $d
  done
  log "Press ENTER to continue"
  read
  sudo ${INSTALLER} ${deps[@]}
}

function build {
  if [ ! -d build ]; then
    meson build
  fi
  ninja -C build install
  mkdir -p $PACKAGE_DIR
  DESTDIR=`realpath $PACKAGE_DIR` meson install -C build
}

function package {
  if [ ! -d ./build ]; then
    echo "You may want to run --build (-b) first!"
    exit 1
  fi
  ver=""
  if [[ $1 != "" ]]; then
    if [[ $1 =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
      ver=$1
      sed -i "s/Version: [0-9]\+\.[0-9]\+\.[0-9]\+/Version: $ver/" ./DEBIAN/control
    fi
  fi
  if [[ $ver == "" ]]; then
    SUB=`(( i = $(awk -F"[ .]" '/Version: /{print $4}' ./DEBIAN/control) +1 ));echo $i`
    sed -i "/Version: /s/\([0-9]\+\.[0-9]\+\.\)[0-9]\+/\1$SUB/" ./DEBIAN/control
  fi
  VERSION=$(awk '/Version: /{print $2}' ./DEBIAN/control)
  echo "Copying control data"
  rsync -au DEBIAN $PACKAGE_DIR
  echo "Generating MD5 Checksums"
  find $PACKAGE_DIR -type f ! -regex '.*\(\bDEBIAN\b\).*' -exec md5sum {} \; | sed 's%$PACKAGE_DIR/%%' > $PACKAGE_DIR/DEBIAN/md5sums
  echo "Setting perms"
	chmod 644 $PACKAGE_DIR/DEBIAN/* $PACKAGE_DIR/DEBIAN/md5sums
  chmod 755 $PACKAGE_DIR/DEBIAN/post* $PACKAGE_DIR/DEBIAN/pre*
  mkdir -p dist
	fakeroot dpkg -b $PACKAGE_DIR dist/yellowfin-$VERSION.deb
}

function clean {
  rm -rf ./build
}

shift $(($OPTIND - 1))

[ ! -z $_development ] && install "building and installing" ${development_deps[@]}
[ ! -z $_testing ] && install "testing" ${testing_deps[@]}
[ ! -z $_clean ] && clean
[ ! -z $_build ] && build
[ ! -z $_package ] && package $1

exit 0