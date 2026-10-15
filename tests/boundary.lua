-- MIT Copyright 2026 Salvador Fandiño.
local a, b = require('libghidra'), require('libghidra.lowlevel')
local n = require('libghidra._native')
assert(a.u64 == b.u64 and a.check == b.check)
local function bad(v, e)
  assert(v == nil and type(e) == 'table' and e.code == 'INVALID_ARGUMENT'
    and e.backend == 'binding' and type(e.operation) == 'string' and type(e.message) == 'string')
end
local values = {'0','9007199254740991','9007199254740992','9007199254740993',
  '9223372036854775807','9223372036854775808','9223372036854775809','18446744073709551615'}
for _, s in ipairs(values) do
  local u = a.check(a.u64(s))
  assert(u:decimal() == s and #u:hex() == 18 and tostring(u) == u:hex())
  assert(u == a.check(a.u64(u:hex())) and u == a.check(a.u64(u)))
  assert(u:add(0) == u and u:sub(0) == u)
end
for _, v in ipairs{'','-1','+1',' 1','1 ','1\0','0x','0X1','18446744073709551616','0x10000000000000000',1.0,-1,false,{}} do bad(a.u64(v)) end
bad(a.u64(nil))
local z, max = a.check(a.u64(0)), a.check(a.u64(values[#values]))
bad(z:sub(1)); bad(max:add(1)); bad(max:to_integer()); bad(z:add('1')); bad(z:add(1.0))
assert(a.check(a.u64(math.maxinteger)):to_integer() == math.maxinteger)
assert(z < max and z <= z and max ~= 0 and z ~= '0')
for _, f in ipairs{function() return z < 1 end, function() return 1 <= z end,
  function() z.n = 1 end, function() return z + z end} do
  local ok, e = pcall(f); assert(not ok)
end
assert(a.check(false) == false and a.check(0) == 0)
local ok, e = pcall(a.check, nil, {code='TEST'}); assert(not ok and e.code == 'TEST')
for _, v in ipairs{0,2147483647} do assert(n._validate_read_size(v) == v) end
for _, v in ipairs{2147483648,4294967295,-1,0.0,'0',false} do bad(n._validate_read_size(v)) end
local p = a.check(n._validate_page())
assert(p.limit == 100 and p.offset == 0 and p.range_start == z and p.range_end == max)
p = a.check(n._validate_page{range_start=1,range_end=0,limit=2147483647})
assert(p.range_end == max)
assert(n._validate_page{limit=1, offset=2147483646})
assert(n._validate_page({page_size=1}, true))
for _, v in ipairs{{foo=1},{limit=0},{limit=1.0},{offset=-1},{limit=2,offset=2147483646},
 {limit=1,offset=2147483647},{range_start=2,range_end=1},{[1]=1},{['limit\0']=1}} do bad(n._validate_page(v)) end
print('boundary: exact UInt64, errors, page and no-buffer size validation PASS')
