-- MIT Copyright 2026 Salvador Fandiño.
local entry,err=package.loadlib(assert(arg[1]),'luaopen_llg_abi_probe')
assert(entry,err)
local ok,result=pcall(entry)
assert(ok,result)
assert(result==true,'ABI probe did not return true')
print('selected host compatibility PASS')
