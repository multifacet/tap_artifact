#!/bin/bash

set -ex

# Keystone Requirements
sudo apt install -y autoconf automake autotools-dev bc \
bison build-essential curl expat libexpat1-dev flex gawk gcc git \
gperf libgmp-dev libmpc-dev libmpfr-dev libtool texinfo tmux \
patchutils zlib1g-dev wget bzip2 patch vim-common lbzip2 python3 \
pkg-config libglib2.0-dev libpixman-1-dev libssl-dev screen \
device-tree-compiler expect makeself unzip cpio rsync cmake ninja-build p7zip-full

# riscv-unknown-linux-musl- requirements
sudo apt install -y autoconf automake autotools-dev curl python3 \ 
python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential \
bison flex texinfo gperf libtool patchutils bc zlib1g-dev \
libexpat-dev ninja-build git cmake libglib2.0-dev

# Qemu Prereqs
sudo apt install git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev ninja-build \
git-email libaio-dev libbluetooth-dev libcapstone-dev libbrlapi-dev libbz2-dev \
libcap-ng-dev libcurl4-gnutls-dev libgtk-3-dev \
libibverbs-dev libjpeg8-dev libncurses5-dev libnuma-dev \
librbd-dev librdmacm-dev libsasl2-dev libsdl2-dev libseccomp-dev libsnappy-dev libssh-dev \
libvde-dev libvdeplug-dev libvte-2.91-dev libxen-dev liblzo2-dev \
valgrind xfslibs-dev

