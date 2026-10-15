-- Focused M1 prerequisite check: load real built module through ordinary C Lua.
package.path = arg[1] .. '/lua/?.lua;' .. arg[1] .. '/lua/?/init.lua'
package.cpath = arg[2] .. '/?.so'
local low = require('libghidra.lowlevel')
local facade = require('libghidra')
local native = require('libghidra._native')
assert(type(native.u64) == 'function', 'control: native module not loaded')
assert(low.u64 == facade.u64, 'control: inconsistent modules')
local missing = 0
for _, check in ipairs{
  {'lowlevel.local_client', low.local_client},
  {'libghidra.open', facade.open},
} do
  local ok = type(check[2]) == 'function'
  print(check[1] .. ': ' .. (ok and 'present' or ('MISSING (' .. type(check[2]) .. ')')))
  if not ok then missing = missing + 1 end
end
assert(missing == 0, 'M1 ownership prerequisites absent: cannot construct shared owner or Session; lifecycle branches unreachable')
