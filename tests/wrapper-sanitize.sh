#!/usr/bin/env bash
# MIT Copyright 2026 Salvador Fandiño.
# Instrument wrapper/hosts; use the unchanged pinned installed SDK and C Lua.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
build="$root/build/wrapper-sanitize"
sdk=${1:-"$root/.cache/native-sdk-patched"}
flags='-fsanitize=address,undefined -fno-omit-frame-pointer'
cmake -S "$root" -B "$build" -G Ninja -DLIBGHIDRA_USE_SDK=ON \
  -DCMAKE_PREFIX_PATH="$sdk" -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_FLAGS="$flags" -DCMAKE_CXX_FLAGS="$flags" \
  -DCMAKE_EXE_LINKER_FLAGS=-fsanitize=address,undefined \
  -DCMAKE_SHARED_LINKER_FLAGS=-fsanitize=address,undefined \
  -DCMAKE_MODULE_LINKER_FLAGS=-fsanitize=address,undefined
cmake --build "$build" -j4
# Required for the ordinary system lua executable loading the instrumented DSO.
# Do not preload into compiler/build commands.
export ASAN_OPTIONS=detect_leaks=1:halt_on_error=1
export UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1
export LD_PRELOAD="$(gcc -print-file-name=libasan.so):$(gcc -print-file-name=libubsan.so)"
ctest --test-dir "$build" --output-on-failure
