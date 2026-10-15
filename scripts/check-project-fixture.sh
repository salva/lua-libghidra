#!/bin/sh
# MIT Copyright 2026 Salvador Fandiño. No Java/Python/network at qualification.
set -eu
sdk=$1
specs=$2
build=$3
cmake -S tests/installed-sdk -B "$build" -G Ninja -DCMAKE_PREFIX_PATH="$sdk"
cmake --build "$build" --target project_probe native_probe
"$build/native_probe" "$specs" tests/fixtures/inputs/authored.elf 0x401106 x86:LE:64:default
"$build/project_probe" "$specs" tests/fixtures/project/authored.gpr tests/fixtures/inputs/authored.elf
