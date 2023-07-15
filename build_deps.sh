#!/usr/bin/env bash

set -e
set -x

export PKG_CONFIG_PATH=deps/lib/pkgconfig

rm -rf deps depbuild
mkdir deps depbuild

DEPS_OUT=$(realpath deps)

pushd depbuild || exit 1

# TODO: Should we use LibreSSL instead?
mkdir -p openssl
curl -LO https://www.openssl.org/source/openssl-3.1.1.tar.gz
tar -xf openssl*.tar.gz -C openssl --strip-components=1
pushd openssl || exit 1
./Configure --prefix="$DEPS_OUT" -static
make build_libs -j "$(nproc)"
make install_dev

popd || exit 1

mkdir -p libssh/build
curl -LO https://www.libssh.org/files/0.10/libssh-0.10.5.tar.xz
tar -xf libssh*.tar.xz -C libssh --strip-components=1
pushd libssh/build || exit 1
cmake -DCMAKE_PREFIX_PATH="$DEPS_OUT" -DCMAKE_INSTALL_PREFIX:PATH="$DEPS_OUT" -DBUILD_SHARED_LIBS=OFF -DWITH_SFTP=OFF -DWITH_SERVER=OFF -DWITH_PCAP=OFF -DWITH_GSSAPI=OFF ..
make -j "$(nproc)"
make install

popd || exit 1

mkdir -p libevent/build
curl -LO https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
tar -xf libevent*.tar.gz -C libevent --strip-components=1
pushd libevent/build || exit 1
cmake -DCMAKE_PREFIX_PATH="$DEPS_OUT" -DCMAKE_INSTALL_PREFIX:PATH="$DEPS_OUT" -DBUILD_SHARED_LIBS=OFF -DEVENT__LIBRARY_TYPE=STATIC -DEVENT__DISABLE_BENCHMARK=ON -DEVENT__DISABLE_REGRESS=ON -DEVENT__DISABLE_SAMPLES=ON -DEVENT__DISABLE_TESTS=ON ..
make -j "$(nproc)"
make install

popd || exit 1

mkdir -p msgpack-c/build
curl -LO https://github.com/msgpack/msgpack-c/releases/download/c-6.0.0/msgpack-c-6.0.0.tar.gz
tar -xf msgpack-c*.tar.gz -C msgpack-c --strip-components=1
pushd msgpack-c/build || exit 1
cmake -DCMAKE_PREFIX_PATH="$DEPS_OUT" -DCMAKE_INSTALL_PREFIX:PATH="$DEPS_OUT" -DBUILD_SHARED_LIBS=OFF -DMSGPACK_BUILD_EXAMPLES=OFF -DMSGPACK_BUILD_TESTS=OFF ..
make -j "$(nproc)"
make install

popd || exit 1

popd || exit 1