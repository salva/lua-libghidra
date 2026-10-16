#!/usr/bin/env bash
# MIT Copyright 2026 Salvador Fandiño.
set -euo pipefail
fail() { echo "installed-examples: $*" >&2; exit 1; }
declare -A seen=()
lua= lua_modules= c_modules= examples= source= work= external=
while (($#)); do
 key=$1; shift
 [[ ! ${seen[$key]+yes} ]] || fail "duplicate $key"
 seen[$key]=1
 (($#)) || fail "missing value for $key"
 value=$1; shift
 [[ $value == /* && $value != *';'* && $value != *'?'* && $value != *$'\n'* ]] || fail "absolute, unambiguous path required: $key"
 case $key in
 --lua) lua=$value;; --lua-module-dir) lua_modules=$value;; --c-module-dir) c_modules=$value;;
 --example-root) examples=$value;; --source) source=$value;; --work) work=$value;;
 --external-specs) external=$value;; *) fail "unknown argument $key";;
 esac
done
[[ -n $lua && -n $lua_modules && -n $c_modules && -n $examples && -n $source && -n $work ]] || fail 'required: --lua --lua-module-dir --c-module-dir --example-root --source --work'
[[ -x $lua && -f $lua && ! -e $work && ! -L $work ]] || fail 'host must exist; work must be fresh'
for file in "$lua_modules/libghidra/init.lua" "$lua_modules/libghidra/lowlevel.lua" "$c_modules/libghidra/_native.so" "$c_modules/libghidra/libllg_process_guard.so.1"; do
 [[ -f $file ]] || fail "missing installed file: $file"
done
for name in decompile inspect_function; do
 [[ -f $examples/$name.lua && ! -L $examples/$name.lua ]] || fail "missing/nonregular example: $name"
 cmp "$source/examples/$name.lua" "$examples/$name.lua" || fail "stale example: $name"
done
[[ -z $external || -d $external/Ghidra/Processors ]] || fail 'external specs must contain Ghidra/Processors'
(cd "$source" && sha256sum -c tests/fixtures/SHA256SUMS)
mkdir -p "$work"; mkdir "$work/cwd" "$work/home"
readelf -d "$c_modules/libghidra/_native.so" > "$work/module-dynamic.txt"
grep -F 'Shared library: [libllg_process_guard.so.1]' "$work/module-dynamic.txt"
grep -F '$ORIGIN' "$work/module-dynamic.txt"
! grep -E 'NEEDED.*liblua' "$work/module-dynamic.txt" || fail 'module links another Lua VM'
unset LUA_INIT LUA_INIT_5_4 LUA_PATH LUA_PATH_5_4 LUA_CPATH LUA_CPATH_5_4
export LUA_PATH="$lua_modules/?.lua;$lua_modules/?/init.lua" LUA_CPATH="$c_modules/?.so"
export HOME="$work/home" LD_BIND_NOW=1
cd "$work/cwd"
printf 'selected_lua=%s\n' "$lua"
sha256sum "$lua" "$c_modules/libghidra/_native.so" "$c_modules/libghidra/libllg_process_guard.so.1" > "$work/identities.txt"
"$lua" -e 'assert(_VERSION=="Lua 5.4" and math.maxinteger==9223372036854775807 and string.packsize("n")==8); print(_VERSION,math.maxinteger,string.packsize("n")); assert(require("libghidra")); assert(require("libghidra.lowlevel"))' > "$work/host.txt"
cat "$work/host.txt" "$work/identities.txt"
"$lua" "$source/tests/decompile_example.lua" "$source"
"$lua" "$source/tests/inspect_function_example.lua" "$source"
# Locked ELF LOAD R E segment is 0x401000..0x40115c; entry ENDBR64 is four bytes.
readelf -l "$source/tests/fixtures/inputs/authored.elf" > "$work/fixture-segments.txt"
for mode in embedded external; do
 if [[ $mode == external && -z $external ]]; then echo 'OMIT external examples (no --external-specs)'; continue; fi
 spec=(); [[ $mode == embedded ]] || spec=("$external")
 for name in decompile inspect_function; do
  args=("$source/tests/fixtures/inputs/authored.elf" 0x401106 x86:LE:64:default gcc)
  [[ $name != inspect_function ]] || args+=(0x401000 0x40115c 4 0x401109 1)
  "$lua" "$examples/$name.lua" "${args[@]}" "${spec[@]}" > "$work/$mode-$name.out" 2> "$work/$mode-$name.err"
  [[ ! -s $work/$mode-$name.err ]] || fail "unexpected diagnostic: $mode $name"
  "$lua" - "$work/$mode-$name.out" "$name" <<'LUA'
local f=assert(io.open(arg[1],'rb'));local text=f:read('a');f:close()
assert(text:find('address=0x0000000000401106\nresult=complete\n',1,true)==1)
assert(text:find('completed=true\nis_fallback=false\n',1,true))
if arg[2]=='decompile' then
 assert(text:find('* 3 + 7',1,true),'known arithmetic semantics')
else
 assert(text:find('function_name="func_0x00401106"\n',1,true))
 assert(text:find('function_entry_address=0x0000000000401106\n',1,true))
 assert(text:find('function_start_address=0x0000000000401106\n',1,true))
 assert(text:find('function_end_address=0x000000000040111e\n',1,true))
 assert(text:find('bytes_hex=f30f1efa\n',1,true))
 local addresses={};for address in text:gmatch('\ninstruction_address=([^\n]+)') do addresses[#addresses+1]=address end
 assert(#addresses==1 and addresses[1]=='0x0000000000401106')
end
LUA
  echo "PASS installed $mode $name"
 done
done
# Source-only safe lifecycle/invalidation regressions load their helper explicitly.
for name in first_slice core_mutation; do
 LIBGHIDRA_FIXTURE_ROOT="$source" "$lua" - "$source" "$name" <<'LUA'
local root,name=arg[1],arg[2]
package.preload.fixture_manifest=function() return dofile(root..'/tests/examples/fixture_manifest.lua') end
dofile(root..'/tests/examples/'..name..'.lua')
LUA
done
echo 'PASS installed examples (focused qualification, not full driver)'
