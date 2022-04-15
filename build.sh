#!/bin/bash

# Run this script in toolchain

rm -rf glibc-deb
git clone https://github.com/osmc/glibc-deb -b bullseye-widevine
cd glibc-deb

rm build.sh # Prevents package taint

TAR="glibc_2.31.orig.tar.xz"
PKG="http://deb.debian.org/debian/pool/main/g/glibc/${TAR}"

export LANG=C

apt-get update
apt-get -y install --no-install-recommends git wget equivs build-essential devscripts quilt rdfind symlinks libaudit-dev libgd-dev gawk gperf libcap-dev libselinux-dev bison

wget "$PKG"

xz -dc "$TAR" | tar xf - --strip-components=1
mv "$TAR" ../

DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -uc -us

rm ../"$TAR"

