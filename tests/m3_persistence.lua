-- MIT Copyright 2026 Salvador Fandiño.
-- Caller supplies a purpose-named disposable directory, never fixture state.
local prefix,root,work=assert(arg[1]),assert(arg[2]),assert(arg[3])
package.path=prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath=prefix..'/lib/lua/5.4/?.so'
local gh=require('libghidra'); local check=gh.check
local program={program_path=root..'/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
local state=work..'/core-state.xml'; os.remove(state)
local function open() return check(gh.open{client={state_path=state},program=program}) end
local original
-- Save symbol/function name and byte overlay separately: saved flag is not all-category persistence.
do
 local s <close> =open(); assert(check(s:get_decompilation(0x401106)).completed)
 original=check(s:read_bytes(0x404010,3))
 assert(check(s:rename_function(0x401106,'persisted_m3_name')).renamed)
 assert(check(s:write_bytes(0x404010,'a\0b')).bytes_written==3)
 assert(check(s:save_program()).saved)
 assert(check(s:native():discard_program()).discarded)
 assert(check(s:read_bytes(0x404010,3))=='a\0b')
 assert(check(s:close_program{policy='save'}).closed)
end
do
 local s <close> =open()
 local f=check(s:get_function(0x401106)); assert(f.name=='persisted_m3_name')
 assert(check(s:read_bytes(0x404010,3))==original) -- overlay was not persisted
 assert(check(s:rename_function(0x401106,'must_not_autosave')).renamed)
end -- destructor no save
do
 local s <close> =open(); assert(check(s:get_function(0x401106)).name=='persisted_m3_name')
end
os.remove(state)
print('M3 saved function/symbol name, overlay nonpersistence, discard no-op, destructor no-save PASS')
