#!/bin/bash -e

# Packages required to build ISPC and Clang.
yum -y update; yum -y install centos-release-scl epel-release; yum clean all
yum install -y vim wget yum-utils gcc gcc-c++ python3 m4 bison flex patch make ncurses-devel glibc-devel.x86_64 glibc-devel.i686 xz devtoolset-7 && \
    yum install -y libtool autopoint gettext-devel texinfo help2man && \
    yum clean -y all
# These packages are required if you need to link IPSC with -static.
yum install -y ncurses-static libstdc++-static && \
    yum clean -y all

# Download and install required version of cmake (3.14) for ISPC build
wget -q --retry-connrefused --waitretry=5 --read-timeout=20 --timeout=15 -t 5 https://cmake.org/files/v3.14/cmake-3.14.0-Linux-x86_64.sh && mkdir /opt/cmake && sh cmake-3.14.0-Linux-x86_64.sh --prefix=/opt/cmake --skip-license && \
    ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake && rm cmake-3.14.0-Linux-x86_64.sh

mkdir /usr/local/src/llvm
cd /usr/local/src/llvm
[ -n "$LLVM_REPO" ] && wget -qO- --retry-connrefused --waitretry=5 --read-timeout=20 --timeout=15 -t 5 $LLVM_REPO/releases/download/llvm-$LLVM_VERSION-ispc-dev/$LLVM_TAR | tar -xvJ
export PATH=$LLVM_HOME/bin-$LLVM_VERSION/bin:$PATH

# Install newer zlib
cd /usr/local/src
git clone https://github.com/madler/zlib.git && cd zlib && mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make -j8 && make install

# Install news flex (2.6.4)
cd /usr/local/src
git clone https://github.com/westes/flex.git && cd flex && git checkout v2.6.4 && ./autogen.sh && ./configure && make -j8 && make install

# vc-intrinsics
cd /usr/local/src
git clone https://github.com/intel/vc-intrinsics.git
cd /usr/local/src/vc-intrinsics
git checkout $VC_INTRINSICS_COMMIT_SHA
mkdir -p build
cd /usr/local/src/vc-intrinsics/build
cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DLLVM_DIR=$LLVM_HOME/bin-$LLVM_VERSION/lib/cmake/llvm -DCMAKE_INSTALL_PREFIX=$GENX_DEPS ../ && make install -j`nproc`

# SPIRV Translator
cd /usr/local/src
git clone https://github.com/KhronosGroup/SPIRV-LLVM-Translator.git
cd /usr/local/src/SPIRV-LLVM-Translator
git checkout $SPIRV_TRANSLATOR_COMMIT_SHA
mkdir -p build
cd /usr/local/src/SPIRV-LLVM-Translator/build
cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DLLVM_DIR=$LLVM_HOME/bin-$LLVM_VERSION/lib/cmake/llvm/ -DCMAKE_INSTALL_PREFIX=$GENX_DEPS ../ && make install -j`nproc`

# L0
cd /usr/local/src
git clone https://github.com/oneapi-src/level-zero.git
cd /usr/local/src/level-zero
git checkout v$L0L_VER
mkdir -p build
cd /usr/local/src/level-zero/build
cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCMAKE_INSTALL_PREFIX=/usr/local ../ && make install -j`nproc`

echo "${PATH}" >> $GITHUB_PATH

