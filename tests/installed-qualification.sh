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
  "$host" "$root/tests/m2_slice.lua" "$prefix" "$root"
  "$host" "$root/tests/m3_core.lua" "$prefix" "$root"
  "$host" "$root/tests/m3_iterators.lua" "$prefix" "$root"
  "$host" "$root/tests/m4_full_reproducer.lua" "$prefix" "$root"
  "$host" "$root/tests/m4_services.lua" "$prefix" "$root"
  "$host" "$root/tests/m4_contract.lua" "$prefix" "$root"
done
# Standalone interpreter receives same arguments as embedded C hosts.
lua5.4 "$root/tests/installed_owner.lua" "$prefix" "$root"
lua5.4 "$root/tests/m2_slice.lua" "$prefix" "$root"
lua5.4 "$root/tests/m3_core.lua" "$prefix" "$root"
lua5.4 "$root/tests/m3_iterators.lua" "$prefix" "$root"
lua5.4 "$root/tests/m4_full_reproducer.lua" "$prefix" "$root"
lua5.4 "$root/tests/m4_services.lua" "$prefix" "$root"
lua5.4 "$root/tests/m4_contract.lua" "$prefix" "$root"
LIBGHIDRA_FIXTURE_ROOT="$root" \
LUA_PATH="$prefix/share/lua/5.4/?.lua;$prefix/share/lua/5.4/?/init.lua;$prefix/share/libghidra/examples/?.lua" \
LUA_CPATH="$prefix/lib/lua/5.4/?.so" \
lua5.4 "$prefix/share/libghidra/examples/first_slice.lua"
lua5.4 "$root/tests/installed_documents.lua" "$prefix"
printf 'installed standalone/static/shared owner+Session and VM closure PASS\n'

# Persistence artifacts are disposable and must remain in the active card work root.
if [[ -n "${SAIVAGE_CARD_WORK_ROOT:-}" ]]; then
  persistence="$SAIVAGE_CARD_WORK_ROOT/m3-installed-persistence"
  mkdir -p "$persistence"
  lua5.4 "$root/tests/m3_persistence.lua" "$prefix" "$root" "$persistence"
  lua5.4 "$root/tests/m4_persistence.lua" "$prefix" "$root" "$persistence"
fi
LIBGHIDRA_FIXTURE_ROOT="$root" \
LUA_PATH="$prefix/share/lua/5.4/?.lua;$prefix/share/lua/5.4/?/init.lua;$prefix/share/libghidra/examples/?.lua" \
LUA_CPATH="$prefix/lib/lua/5.4/?.so" \
lua5.4 "$prefix/share/libghidra/examples/core_mutation.lua"
if [[ -n "${SAIVAGE_CARD_WORK_ROOT:-}" ]]; then
  branch="$SAIVAGE_CARD_WORK_ROOT/m3-branch"
  mkdir -p "$branch"
  cc -O0 -g -fno-pie -no-pie -fcf-protection=branch "$root/tests/fixtures/branch.c" -o "$branch/branch.elf"
  lua5.4 "$root/tests/m3_branch.lua" "$prefix" "$branch/branch.elf"
fi

# Independent M5 runtime profiles and absence gates; fresh per invocation.
if [[ -n "${SAIVAGE_CARD_WORK_ROOT:-}" ]]; then
  matrix=$(mktemp -d "$SAIVAGE_CARD_WORK_ROOT/installed-runtime-XXXXXX")
  bash "$root/tests/installed-profiles.sh" "$prefix" "$matrix/profiles"
  bash "$root/tests/installed-absence.sh" "$prefix" "$matrix/absence"
fi
