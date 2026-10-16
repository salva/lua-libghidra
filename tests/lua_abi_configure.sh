#!/bin/sh
# MIT Copyright 2026 Salvador Fandiño.
set -eu
root=$1 sdk=$2 work=$3 good=$4 include=$5 bad=$6
mkdir -p "$work"
configure() {
 dir=$1; shift
 cmake -S "$root" -B "$work/$dir" -G Ninja -DLIBGHIDRA_USE_SDK=ON \
  -DCMAKE_PREFIX_PATH="$sdk" -DBUILD_TESTING=OFF "$@" > "$work/$dir.log" 2>&1
}
reject() {
 name=$1 diagnostic=$2; shift 2
 if configure "$name" "$@"; then echo "unexpected configure success: $name" >&2; exit 1; fi
 tr '\n' ' ' < "$work/$name.log" | tr -s ' ' | grep -F "$diagnostic"
}
configure explicit -DLUA_EXECUTABLE="$good" -DLLG_LUA_INCLUDE_DIR="$include"
configure default
reject missing-headers 'Missing complete Lua headers' -DLUA_EXECUTABLE="$good" -DLLG_LUA_INCLUDE_DIR="$work/absent"
reject missing-host 'Selected Lua executable must exist' -DLUA_EXECUTABLE="$work/absent" -DLLG_LUA_INCLUDE_DIR="$include"
reject mismatch 'core and library have incompatible numeric types' -DLUA_EXECUTABLE="$bad" -DLLG_LUA_INCLUDE_DIR="$include"
# Same directory, changed executable: cached success must not survive.
if configure explicit -DLUA_EXECUTABLE="$bad" -DLLG_LUA_INCLUDE_DIR="$include"; then exit 1; fi
tr '\n' ' ' < "$work/explicit.log" | tr -s ' ' | grep -F 'core and library have incompatible numeric types'
configure explicit -DLUA_EXECUTABLE="$good" -DLLG_LUA_INCLUDE_DIR="$include"
# Same directory, changed headers: cached compile success must not survive.
badinclude=$(dirname "$(dirname "$bad")")/include
if configure explicit -DLUA_EXECUTABLE="$good" -DLLG_LUA_INCLUDE_DIR="$badinclude"; then exit 1; fi
grep -F 'Requires ordinary Lua 5.4 signed-int64/double headers' "$work/explicit.log"
configure explicit -DLUA_EXECUTABLE="$good" -DLLG_LUA_INCLUDE_DIR="$include"
echo 'Lua configure explicit/default/missing/numeric/changed-cache PASS'
