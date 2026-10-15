#!/bin/sh
# MIT Copyright 2026 Salvador Fandiño.
# Build directories are caller-selected; disposable runs belong under card work.
set -eu
if [ "$#" != 2 ]; then echo "usage: $0 BUILD SDK_PREFIX" >&2; exit 2; fi
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cmake -S "$root" -B "$1" -G Ninja -DLIBGHIDRA_USE_SDK=ON \
  -DCMAKE_PREFIX_PATH="$2" -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build "$1" -j4
ctest --test-dir "$1" --output-on-failure
