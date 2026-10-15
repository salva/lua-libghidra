#!/bin/sh
# MIT Copyright 2026 Salvador Fandiño. Preserve failures; require semantic content.
set -eu
build=$1
root=$2
address=0x$(nm "$build/native_smoke" | awk '$2 == "T" && $3 == "native_smoke" {print $1}')
# Empty language hint deliberately exercises unmodified BFD autodetection.
output=$("$build/native_probe" "$root" "$build/native_smoke" "$address" '')
printf '%s\n' "$output"
printf '%s\n' "$output" | grep -F 'completed=1 fallback=0'
printf '%s\n' "$output" | grep -F 'param_1 * 3 + 7'
