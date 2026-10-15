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
-- Check complete structured ordered-error envelopes, not just pcall failure.
local function raised(op, f)
  local ok, err=pcall(f)
  assert(not ok and type(err)=='table' and err.code=='INVALID_ARGUMENT')
  assert(err.backend=='binding' and err.operation==op and #err.message>0)
end
local exact={}
for i,s in ipairs(values) do exact[i]=assert(a.u64(s)) end
for i,x in ipairs(exact) do
  for j,y in ipairs(exact) do
    assert((x==y)==(i==j) and (x<y)==(i<j) and (x<=y)==(i<=j))
    assert((x>y)==(i>j) and (x>=y)==(i>=j))
  end
end
local wrong={false,0,0.0,'0',{},function() end}
for _,other in ipairs(wrong) do
  assert(z~=other and other~=z)
  raised('__lt',function() return z<other end)
  raised('__lt',function() return other<z end)
  raised('__le',function() return z<=other end)
  raised('__le',function() return other<=z end)
end
raised('__lt',function() return z<nil end)
raised('__le',function() return nil<=z end)
raised('__newindex',function() z.n=1 end)
assert(getmetatable(z)=='UInt64')
local ok=pcall(function() return z+z end); assert(not ok) -- no arithmetic metamethod
-- Named helpers are callable as functions: invalid receiver must return nil,
-- error rather than raising; both bad receiver and bad delta branches matter.
for _,name in ipairs{'hex','decimal','to_integer','add','sub'} do
  for _,other in ipairs(wrong) do
    local v,err=z[name](other,0)
    bad(v,err); assert(err.operation==name)
  end
  local v,err=z[name](nil,0)
  bad(v,err); assert(err.operation==name)
end
for _,name in ipairs{'add','sub'} do
  for _,delta in ipairs{-1,1.0,'1',false,{}} do
    local v,err=z[name](z,delta)
    bad(v,err); assert(err.operation==name)
  end
  local v,err=z[name](z,nil); bad(v,err); assert(err.operation==name)
end
-- Exact carry/borrow across the signed boundary and overflow at unsigned max.
local signed=assert(a.u64(math.maxinteger))
local high=assert(signed:add(1))
assert(high:decimal()=='9223372036854775808' and high:sub(1)==signed)
assert(signed:add(math.maxinteger):decimal()=='18446744073709551614')
assert(max:sub(math.maxinteger)==high)
assert(max:sub(1):add(1)==max and z:add(1):sub(1)==z)
local v,err=high:to_integer(); bad(v,err); assert(err.operation=='to_integer')
for _,text in ipairs{'0x0000000000000000','0xFFFFFFFFFFFFFFFF','0000'} do
  assert(a.u64(text))
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
