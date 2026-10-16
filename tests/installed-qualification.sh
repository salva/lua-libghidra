#!/usr/bin/env bash
# MIT Copyright 2026 Salvador Fandiño.
# Exercise installed Lua paths only with ordinary standalone/static/shared VMs.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
build=${1:-"$root/build"}
prefix="$build/installed-qualification"
cmake --build "$build" -j4
cmake --install "$build" --prefix "$prefix"
module="$prefix/lib/lua/5.4/libghidra/_native.so"
guard="$prefix/lib/lua/5.4/libghidra/libllg_process_guard.so.1"
readelf -d "$module" | grep 'Shared library: \[libllg_process_guard.so.1\]'
readelf -d "$module" | grep '\$ORIGIN'
# Module must borrow Lua from its host, never link another VM.
if readelf -d "$module" | grep -E 'NEEDED.*liblua'; then exit 1; fi
if nm -D --defined-only "$module" "$guard" | grep -E ' [TW] lua(L)?_'; then exit 1; fi
nm -D "$module" | grep ' U lua_newuserdatauv'
ldd "$module"
if readelf -d "$build/boundary_static_host" | grep -E 'NEEDED.*liblua'; then exit 1; fi
readelf -d "$build/boundary_shared_host" | grep -E 'NEEDED.*liblua5.4'
export LD_BIND_NOW=1
for host in "$build/boundary_static_host" "$build/boundary_shared_host"; do
  "$host" "$root/tests/installed_owner.lua" "$prefix" "$root"
done
# Standalone interpreter receives same arguments as embedded C hosts.
lua5.4 "$root/tests/installed_owner.lua" "$prefix" "$root"
printf 'installed standalone/static/shared owner+Session and VM closure PASS\n'
