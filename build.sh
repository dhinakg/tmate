#!/usr/bin/env bash

set -e
set -x

LDFLAGS="-Ldeps/lib" LIBS="-lz -lcrypto" PKG_CONFIG_PATH=deps/lib/pkgconfig ./configure --prefix=$(readlink -f out)
make -j "$(nproc)"