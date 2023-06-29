FROM ubuntu:18.04 as base

ENV DEBIAN_FRONTEND=noninteractive

# URL of the Action Service server
ARG actionURL

# URL of the Trigger Service server
ARG triggerURL

RUN apt update
RUN apt install -y sudo autoconf automake autotools-dev bc \
bison build-essential curl expat libexpat1-dev flex gawk gcc git \
gperf libgmp-dev libmpc-dev libmpfr-dev libtool texinfo tmux \
patchutils zlib1g-dev wget bzip2 patch vim-common lbzip2 python3 \
pkg-config libglib2.0-dev libpixman-1-dev libssl-dev screen \
device-tree-compiler expect makeself unzip cpio rsync cmake ninja-build p7zip-full

