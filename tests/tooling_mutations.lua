-- MIT Copyright 2026 Salvador Fandiño. Every mutation result assignment drifts closed.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_mutations')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local data={types={},declarations={}}
for path in U.capture{'find',root..'/cpp/include/libghidra','-name','*.hpp'}:gmatch('[^\n]+') do local t,_,d=S.header(path,U.read(path)); for k,v in pairs(t) do data.types[k]=v end; for k,v in pairs(d) do data.declarations[k]=v end end
local r=R.review(raw,data); local count,methods=0,0
for name,review in pairs(r) do
 methods=methods+1
 local _,text,opening,ending=S.body(raw,' '..name..'(')
 for field in pairs(review.assignments) do
  local first,last=text:find('resp%.'..field..'%s*=%s*[^;]+;'); assert(first)
  local body=text:sub(1,first-1)..'resp.'..field..' = fabricated;'..text:sub(last+1)
  assert(not pcall(R.review,raw:sub(1,opening-1)..body..raw:sub(ending+1),data),'changed response accepted '..name..'.'..field)
  count=count+1
 end
end
assert(methods==32)
print('Lua '..methods..' mutation result reviews and '..count..' exact assignment mutations PASS')
for _,name in ipairs{'RenameFunction','DeleteType','SetFunctionSignature','RenameFunctionLocal','SetComment'} do
 local _,text,opening,ending=S.body(raw,' '..name..'(')
 local needle=name=='SetComment' and 'revision_++;' or name=='RenameFunctionLocal' and 'switch (' or 'if (!ok)'
 local first,last=assert(text:find(needle,1,true))
 local changed=raw:sub(1,opening-1)..text:sub(1,first-1)..'removed_branch'..text:sub(last+1)..raw:sub(ending+1)
 assert(not pcall(R.review,changed,data),'result branch mutation accepted '..name)
end
print('Mutation failure/local/side-map branch regressions PASS')
