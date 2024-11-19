#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config

set -ex

export CC=$(basename "$CC")

build_with_libnl=""
if [[ "$target_platform" == linux-* ]]; then
  echo "Build with libnl support"
  build_with_libnl=" --with-libnl=$PREFIX "
fi

if [[ "$target_platform" == osx-arm64 ]]; then
  # fix outdated config.sub on mac arm
  echo 'echo arm64-apple-darwin' > config/config.sub
fi

./configure \
    --prefix=$PREFIX \
    --docdir=$PWD/noinst/doc \
    --mandir=$PWD/noinst/man \
    $build_with_libnl \
    --disable-static \
    --disable-psm3 \
    --disable-opx

make -j"${CPU_COUNT}"

if [[ "$target_platform" == linux-* ]]; then
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  make check
fi
fi

make install

