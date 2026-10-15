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
print('installed existing-VM values, owner exclusion, native errors and lifecycle PASS')
