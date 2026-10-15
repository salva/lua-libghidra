-- MIT Copyright 2026 Salvador Fandiño.
-- /dev/null is a non-directory on the qualified Linux profile: opening a child
-- must fail even as root. No permissions assumption or temporary output needed.
package.path=arg[1]..'/lua/?.lua;'..arg[1]..'/lua/?/init.lua'
package.cpath=arg[2]..'/?.so'
local low, high = require'libghidra.lowlevel', require'libghidra'
local path='/dev/null/lua-libghidra-state.xml'
local expected='Unable to open file for writing: '..path
local program={project_path=arg[1]..'/tests/fixtures/project/authored.gpr',
 program_path=arg[1]..'/tests/fixtures/inputs/authored.elf'}
local s,e,opened=high.open{client={state_path=path},program=program}
assert(s,e and e.message)
local c=s:native()
local original=assert(c:read_bytes(0x401106,1)).data
assert(#original==1)
local generation=c:_generation()
-- Exercise the facade forwarding and the native escape hatch on the SAME
-- owner. Native save failure must not fabricate successful logical closure.
for _,case in ipairs{{s,'close_program'},{c,'shutdown'}} do
 local receiver,op=case[1],case[2]
 local response,err=receiver[op](receiver,{policy='save'})
 assert(response==nil and type(err)=='table')
 assert(err.code=='SAVE_FAILED' and err.backend=='local')
 assert(err.operation==op and err.message==expected)
 generation=generation:add(1)
 assert(c:_generation()==generation)
 assert(c:get_status().ok and s:get_status().ok)
 assert(c:read_bytes(0x401106,1).data==original)
 assert(s:read_bytes(0x401106,1)==original)
 local other,busy=low.local_client()
 assert(other==nil and busy.code=='CLIENT_IN_USE')
 assert(type(opened.program_name)=='string')
end
-- A subsequent explicit discard really closes program access but not owner.
assert(s:close_program{policy='discard'}.closed)
assert(c:_generation()==generation:add(1))
local response,err=c:read_bytes(0x401106,1)
assert(not response and err.code=='NO_PROGRAM' and err.backend=='local')
assert(c:get_status().ok)
local other,busy=low.local_client()
assert(not other and busy.code=='CLIENT_IN_USE')
assert(c:close())
assert(low.local_client()):close()
print('native SAVE_FAILED close/shutdown: exact errors, generation and shared program/slot preservation PASS')
