#!/bin/sh
# MIT Copyright 2026 Salvador Fandiño.
# Local package regression; SDK and disposable work root are explicit inputs.
set -eu
root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
sdk=$(realpath "$1")
work=$2
mkdir -p "$work"
work=$(realpath "$work")
cd "$root"
host=$(realpath "$(command -v lua5.4)")
include=
for flag in $(pkg-config --cflags-only-I lua5.4); do
 case "$flag" in -I*) candidate=${flag#-I}
  if test -f "$candidate/lua.h" && test -f "$candidate/lauxlib.h" && test -f "$candidate/luaconf.h"; then include=$candidate; break; fi;; esac
done
: "${include:?missing Lua headers}"
# Driver must fail before configuring when input selection is absent/ambiguous.
if env -u LLG_SDK_PREFIX -u LLG_INPUT_ROOT LLG_BUILD_DIR="$work/rejected" \
  lua5.4 scripts/luarocks-build.lua build /unused /unused/lib /unused/lua "$host" "$include"; then exit 1; fi
if LLG_BUILD_DIR="$work/rejected" LLG_SDK_PREFIX="$sdk" LLG_INPUT_ROOT="$sdk" \
  lua5.4 scripts/luarocks-build.lua build /unused /unused/lib /unused/lua "$host" "$include"; then exit 1; fi
test ! -e "$work/rejected"
LLG_BUILD_DIR="$work/build" LLG_SDK_PREFIX="$sdk" \
  luarocks --lua-version=5.4 --tree="$work/rocks" make --deps-mode=none --no-manifest
module="$work/rocks/lib/lua/5.4/libghidra/_native.so"
guard="$work/rocks/lib/lua/5.4/libghidra/libllg_process_guard.so.1"
test -f "$guard" && test ! -L "$guard"
readelf -d "$module" | grep 'Shared library: \[libllg_process_guard.so.1\]'
readelf -d "$module" | grep '\$ORIGIN'
if readelf -d "$module" | grep -E 'NEEDED.*liblua'; then exit 1; fi
if nm -D --defined-only "$module" "$guard" | grep -E ' [TW] lua(L)?_'; then exit 1; fi
# Fresh cwd; tests set installed-only module search paths.
cd "$work"
for suite in installed_owner m2_slice m3_core m3_iterators; do
  LD_BIND_NOW=1 lua5.4 "$root/tests/$suite.lua" "$work/rocks" "$root"
done
printf 'LuaRocks installed local SDK package regression PASS\n'
