-- MIT Copyright 2026 Salvador Fandiño. All producer fields and defaults drift closed.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_records')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_arch_adapter.cpp'); local types=S.header('models.hpp',U.read(root..'/cpp/include/libghidra/models.hpp')); local reviews=R.review(raw,types)
local methods,count=0,0
for _,r in pairs(reviews) do
 methods=methods+1
 local _,text,opening,ending=S.body(raw,'ArchAdapter::'..r.method..'('); local variable=r.model=='ParameterRecord' and 'prec' or 'rec'
 for field in pairs(r.fields) do
  local needle=variable..'.'..field; local i,j=assert(text:find(needle,1,true))
  local changed=raw:sub(1,opening-1)..text:sub(1,i-1)..variable..'.fabricated'..text:sub(j+1)..raw:sub(ending+1)
  assert(not pcall(R.review,changed,types),'record field mutation accepted '..r.method..'.'..field); count=count+1
 end
end
assert(methods==15)
print('Lua 15 record producers and '..count..' real field mutations PASS')
