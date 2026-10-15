#!/bin/sh
# MIT Copyright 2026 Salvador Fandiño.
# Inputs: prepared source root, fresh disposable build root, SDK prefix.
set -eu
inputs=$(realpath "$1")
work=$2
prefix=$3
project=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
cmake -S "$inputs/protobuf" -B "$work/protobuf" -G Ninja \
 -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=20 \
 -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX="$prefix" \
 -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_BUILD_PROTOC_BINARIES=OFF \
 -Dprotobuf_BUILD_LIBUPB=OFF -Dprotobuf_WITH_ZLIB=OFF -Dprotobuf_INSTALL=ON \
 -DABSL_ROOT_DIR="$inputs/abseil" -DABSL_ENABLE_INSTALL=ON -DABSL_PROPAGATE_CXX_STD=ON
cmake --build "$work/protobuf" -j "${BUILD_JOBS:-8}"
cmake --install "$work/protobuf"
cmake -S "$project" -B "$work/local" -G Ninja \
 -DNATIVE_INPUT_ROOT="$inputs" -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX="$prefix" -DFETCHCONTENT_FULLY_DISCONNECTED=ON
cmake --build "$work/local" -j "${BUILD_JOBS:-8}"
cmake --install "$work/local"
cmake -S "$project/tests/installed-sdk" -B "$work/consumer" -G Ninja \
 -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$prefix"
cmake --build "$work/consumer" -j "${BUILD_JOBS:-8}"
"$project/scripts/check-native-smoke.sh" "$work/consumer" "$inputs/engine"
