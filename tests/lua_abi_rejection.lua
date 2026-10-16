-- MIT Copyright 2026 Salvador Fandiño.
-- Bounded amd64 PUC 5.4.6 int64/float32 rejection experiment, not float support.
local build=assert(arg[1])
assert(_VERSION=='Lua 5.4' and string.packsize('j')==8 and string.packsize('n')==4)
local registry=debug.getregistry()
local function unpublished()
  assert(registry['libghidra.UInt64']==nil and registry['libghidra.owner']==nil)
  assert(package.loaded['libghidra._native']==nil)
end
for _,case in ipairs{{'/lua-abi-probe.so','luaopen_llg_abi_probe'},
                       {'/libghidra/_native.so','luaopen_libghidra__native'}} do
  unpublished()
  local entry,err=package.loadlib(build..case[1],case[2]); assert(entry,err)
  local ok,result=pcall(entry)
  assert(not ok and type(result)=='string' and
    result:find('core and library have incompatible numeric types',1,true),tostring(result))
  unpublished()
  local t={answer=40+2}; assert(t.answer==42 and math.type(t.answer)=='integer')
  collectgarbage('collect')
  print(case[2]..': protected numeric rejection; no publication; usable host PASS')
end
