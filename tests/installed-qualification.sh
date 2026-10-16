#!/usr/bin/env bash
# MIT Copyright 2026 Salvador Fandiño.
# Explicit installed qualification. Document integration lands with B in batch 5.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
usage() { echo 'Usage: installed-qualification.sh --build DIR --prefix DIR --work-root DIR [--mode full|reduced] [--external-specs DIR]'; }
usage_error() { echo "usage: $*" >&2; usage >&2; exit 2; }
prerequisite() { echo "prerequisite: $*" >&2; exit 1; }
declare -A seen=()
build= prefix= work_root= external_specs= mode=full
while (($#)); do
 key=$1; shift
 case "$key" in
 --help) (($# == 0 && ${#seen[@]} == 0)) || usage_error '--help must be used alone'; usage; exit 0 ;;
 --build|--prefix|--work-root|--mode|--external-specs)
  [[ ! ${seen[$key]+yes} ]] || usage_error "duplicate $key"
  seen[$key]=1
  (($#)) && [[ $1 != --* && -n $1 ]] || usage_error "missing value for $key"
  value=$1; shift
  case "$key" in --build) build=$value;; --prefix) prefix=$value;; --work-root) work_root=$value;; --mode) mode=$value;; --external-specs) external_specs=$value;; esac ;;
 *) usage_error "unknown or legacy argument: $key" ;;
 esac
done
[[ -n $build && -n $prefix && -n $work_root ]] || usage_error '--build, --prefix and --work-root are required'
[[ $mode == full || $mode == reduced ]] || usage_error '--mode must be full or reduced'
[[ ! -e $prefix && ! -L $prefix ]] || prerequisite "prefix already exists: $prefix"
[[ -d $build && -r $build/CMakeCache.txt ]] || prerequisite "configured build/cache missing: $build"
build=$(realpath "$build")
manifest="$build/package-documents.txt"
[[ -f $manifest && -r $manifest ]] || prerequisite "selected-build manifest missing/unreadable: $manifest"
grep -q '^BUILD_TESTING:BOOL=ON$' "$build/CMakeCache.txt" || prerequisite "BUILD_TESTING must be ON: $build"
[[ -d $work_root && -w $work_root && -x $work_root ]] || prerequisite "work-root must be an existing writable directory: $work_root"
work_root=$(realpath "$work_root")
[[ -d $(dirname "$prefix") && -w $(dirname "$prefix") ]] || prerequisite "prefix parent must exist and be writable: $prefix"
prefix=$(realpath -m "$prefix")
for tool in cmake lua5.4 readelf nm ldd sha256sum mktemp; do command -v "$tool" >/dev/null || prerequisite "missing tool: $tool"; done
(cd "$root" && sha256sum -c tests/fixtures/SHA256SUMS) || prerequisite 'fixture hash check failed'
for host in boundary_static_host boundary_shared_host; do [[ -x $build/$host ]] || prerequisite "selected build host missing: $build/$host"; done
if [[ $mode == full ]]; then
 [[ $(id -u) != 0 ]] || prerequisite 'full mode requires non-root permission semantics'
 [[ -n $external_specs && -d $external_specs/Ghidra/Processors && -r $external_specs/Ghidra/Processors ]] || prerequisite '--external-specs must name a prepared engine tree with Ghidra/Processors'
 external_specs=$(realpath "$external_specs")
 for tool in cc unshare mount; do command -v "$tool" >/dev/null || prerequisite "missing full-mode tool: $tool"; done
 unshare -Urnm -- bash -c 'mount --make-rprivate /' || prerequisite 'user/mount/network namespaces unavailable'
fi
run=$(mktemp -d "$work_root/llg-integration.XXXXXX")
group=initialization
trap 'rc=$?; if ((rc)); then printf "FAILED group=%s run=%s prefix=%s exit=%s\n" "$group" "$run" "$prefix" "$rc" >&2; fi' EXIT
mkdir "$run/home" "$run/cwd"
export HOME="$run/home" LD_BIND_NOW=1
unset LUA_INIT LUA_INIT_5_4 LUA_PATH LUA_PATH_5_4 LUA_CPATH LUA_CPATH_5_4
cd "$run/cwd"
printf 'mode=%s prefix=%s run=%s\n' "$mode" "$prefix" "$run"
for group in closure services examples pristine-documents; do echo "SELECT $group"; done
for group in document-mutations persistence branch profiles absence; do
 if [[ $mode == full ]]; then echo "SELECT $group"; else echo "OMIT $group"; fi
done
group=closure
cmake --build "$build" -j4
cmake --install "$build" --prefix "$prefix"
module="$prefix/lib/lua/5.4/libghidra/_native.so"
guard="$prefix/lib/lua/5.4/libghidra/libllg_process_guard.so.1"
readelf -d "$module" > "$run/module-dynamic.txt"
grep 'Shared library: \[libllg_process_guard.so.1\]' "$run/module-dynamic.txt"
grep '\$ORIGIN' "$run/module-dynamic.txt"
! grep -E 'NEEDED.*liblua' "$run/module-dynamic.txt"
nm -D --defined-only "$module" "$guard" > "$run/module-symbols.txt"
! grep -E ' [TW] lua(L)?_' "$run/module-symbols.txt"
nm -D "$module" | grep ' U lua_newuserdatauv'
ldd "$module"
readelf -d "$build/boundary_static_host" > "$run/static-dynamic.txt"
! grep -E 'NEEDED.*liblua' "$run/static-dynamic.txt"
readelf -d "$build/boundary_shared_host" | grep -E 'NEEDED.*liblua5.4'
echo 'COMPLETE closure'
group=services
for host in "$(command -v lua5.4)" "$build/boundary_static_host" "$build/boundary_shared_host"; do
 for test in installed_owner m2_slice m3_core m3_iterators m4_full_reproducer m4_services m4_contract; do
  echo "RUN host=$host test=$test"
  "$host" "$root/tests/$test.lua" "$prefix" "$root"
 done
done
echo 'COMPLETE services'
group=examples
for example in first_slice core_mutation; do
 LIBGHIDRA_FIXTURE_ROOT="$root" \
 LUA_PATH="$prefix/share/lua/5.4/?.lua;$prefix/share/lua/5.4/?/init.lua;$prefix/share/libghidra/examples/?.lua" \
 LUA_CPATH="$prefix/lib/lua/5.4/?.so" \
 lua5.4 "$prefix/share/libghidra/examples/$example.lua"
done
echo 'COMPLETE examples'
# Deliberate stage boundary, not a compatibility adapter or success-shaped skip.
# B's manifest export/checker and C's exact new document callers land together.
group=pristine-documents
prerequisite "batch-5 document caller integration not landed; retained run=$run"
