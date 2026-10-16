-- MIT Copyright 2026 Salvador Fandiño.
-- Installed paths only: do not fall back to source/build or ambient Lua modules.
local prefix = assert(arg[1])
package.path = prefix .. '/share/lua/5.4/?.lua;' .. prefix .. '/share/lua/5.4/?/init.lua'
package.cpath = prefix .. '/lib/lua/5.4/?.so'
local low = require('libghidra.lowlevel')
local facade = require('libghidra')
assert(low.u64 == facade.u64)
assert(low.u64('18446744073709551615'):decimal() == '18446744073709551615')
for i=1,8 do
  local a = assert(low.local_client())
  assert(a:get_status())
  local caps = assert(a:get_capabilities())
  assert(#caps > 0)
  local b, err = low.local_client()
  assert(b == nil and err.code == 'CLIENT_IN_USE' and err.backend == 'binding')
  local bytes, failure = a:read_bytes(0,0)
  assert(bytes == nil and failure.code == 'NO_PROGRAM')
  assert(a:close()); assert(a:close())
  local closed, e = a:get_status()
  assert(closed == nil and e.code == 'CLOSED')
  local fresh = assert(low.local_client())
  assert(fresh:get_status()); assert(fresh:close())
  collectgarbage('collect')
end
-- arg[2] is an authored fixture root only, never a Lua module search path.
local root = assert(arg[2], 'authored fixture root required')
local program = {project_path=root .. '/tests/fixtures/project/authored.gpr',
                 program_path=root .. '/tests/fixtures/inputs/authored.elf'}
for i=1,3 do
  local session, err, opened = facade.open{program=program}
  assert(session, err and err.message)
  local alias = session:native()
  assert(alias:get_status().ok and type(opened.has_entry_point)=='boolean')
  local generation = alias:_generation()
  local data, failure, envelope = session:read_bytes(0x401106,1)
  assert(type(data)=='string' and #data==1 and failure==nil and envelope.data==data)
  local direct = assert(alias:read_bytes(0x401106,1))
  assert(direct.data==data)
  assert(session:close_program{policy='discard'}.closed)
  assert(alias:_generation()==generation:add(1))
  local absent, e = session:read_bytes(0,0)
  assert(absent==nil and e.code=='NO_PROGRAM')
  assert(alias:open_program(program))
  assert(alias:_generation()==generation:add(2))
  assert(session:read_bytes(0x401106,1)==data)
  -- Session collection must not destroy a retained native alias.
  session=nil; collectgarbage('collect')
  assert(alias:get_status().ok)
  assert(alias:close())
  local fresh = assert(low.local_client()); assert(fresh:close())
end
print('installed existing-VM analyzed Session, detached bytes and shared aliases PASS')
print('installed existing-VM values, owner exclusion, native errors and lifecycle PASS')
