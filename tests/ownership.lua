-- MIT Copyright 2026 Salvador Fandiño.
local low, high = require'libghidra.lowlevel', require'libghidra'
local function code(expected, value, err)
 assert(value == nil and err.code == expected, err and (err.code..': '..err.message))
 return err
end
local program = {project_path=arg[1]..'/tests/fixtures/project/authored.gpr',
 program_path=arg[1]..'/tests/fixtures/inputs/authored.elf'}
for i=1,3 do
 local s, e, opened=high.open{program=program}; assert(s, e and e.message)
 local c=s:native(); assert(c:get_status().ok)
 assert(type(opened.has_entry_point)=='boolean')
 code('CLIENT_IN_USE',low.local_client())
 local gen=c:_generation()
 code('INVALID_ARGUMENT',c:read_bytes(0,2147483648))
 code('INVALID_ARGUMENT',c:read_bytes(0,4294967295))
 assert(c:_generation()==gen)
 local b,err=c:read_bytes(0x401106,1); assert(b,err and err.message); assert(#b.data==1)
 assert(s:close_program{policy='discard'}.closed)
 assert(c:_generation()==gen:add(1))
 code('NO_PROGRAM',c:read_bytes(0,0))
 assert(c:get_status().ok); code('CLIENT_IN_USE',low.local_client())
 local r,e=c:open_program(program); assert(r,e and e.message)
 assert(c:_generation()==gen:add(2)); assert(opened.program_name==r.program_name)
 s=nil; collectgarbage(); assert(c:get_status().ok)
 assert(c:shutdown{policy='discard'}.accepted)
 code('NO_PROGRAM',c:read_bytes(0,0))
 assert(c:close() and c:close()); code('CLOSED',c:get_status())
 c=nil; collectgarbage()
end
local alias
local marker={}
local ok,e=pcall(function()
 local c <close> = assert(low.local_client())
 alias=c; error(marker)
end)
assert(not ok and e==marker); code('CLOSED',alias:get_status())
local c=assert(low.local_client()); local gen=c:_generation()
code('INVALID_ARGUMENT',c:open_program{})
assert(c:_generation()==gen)
local r,e=c:open_program{program_path='/no/such/file'}
assert(not r and e.backend=='local'); assert(c:_generation()==gen:add(1))
print('native open failure preserved: '..e.code)
c=nil; collectgarbage(); assert(low.local_client()):close()
local s,e=high.open{program={program_path='/no/such/file'}}
assert(not s and e.backend=='local'); assert(low.local_client()):close()
print('ownership: sequential real engines, shared aliases, lifecycle, errors PASS')
local c=assert(low.local_client())
for _, size in ipairs{0,2147483647} do code('NO_PROGRAM',c:read_bytes(0,size)) end
for _, size in ipairs{2147483648,4294967295} do code('INVALID_ARGUMENT',c:read_bytes(0,size)) end
c:close()
