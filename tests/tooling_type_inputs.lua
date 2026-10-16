-- MIT Copyright 2026 Salvador Fandiño. Type family real-source drift checks.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_type_inputs')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local a=U.read(root..'/cpp/src/local_arch_adapter.cpp')
local data={declarations={}}
for path in U.capture{'find',root..'/cpp/include/libghidra','-name','*.hpp'}:gmatch('[^\n]+') do local _,_,d=S.header(path,U.read(path)); for k,v in pairs(d) do data.declarations[k]=v end end
local r=R.review(raw,a,data); local inputs,methods=0,0
for _,args in pairs(r.requests) do methods=methods+1; for _ in pairs(args) do inputs=inputs+1 end end
assert(inputs==43 and methods==21)
local count=0
local function reject(name,needle,replacement)
 local _,text,opening,ending=S.body(raw,' '..name..'('); local i,j=assert(text:find(needle,1,true))
 local changed=raw:sub(1,opening-1)..text:sub(1,i-1)..replacement..text:sub(j+1)..raw:sub(ending+1)
 assert(not pcall(R.review,changed,a,data),'type input mutation accepted '..name..' '..needle); count=count+1
end
for name in pairs(r.reconstruction) do reject(name,'if (!ensure_loaded())','if (false)') end
for _,name in ipairs{'DeleteTypeMember','RenameTypeMember','SetTypeMemberType','DeleteTypeEnumMember','RenameTypeEnumMember','SetTypeEnumMemberValue'} do
 reject(name,'ordinal >= existing.size()','ordinal > existing.size()')
 reject(name,'revision_++;',';')
end
for _,name in ipairs{'DeleteType','RenameType','AddTypeMember','DeleteTypeAlias','SetTypeAliasTarget'} do reject(name,'name = name.substr(1)','name = name.substr(2)') end
reject('CreateType','kind == "struct"','kind == "union"')
reject('AddTypeMember','static_cast<int>(m.offset) + static_cast<int>(m.size)','0')
reject('AddTypeEnumMember','entries.push_back({name, static_cast<uint64_t>(value)})','entries.push_back({name, 0})')
reject('SetTypeMemberComment','a.setTypeMemberComment(name, ordinal, comment)','a.setTypeMemberComment(name, 0, comment)')
reject('SetTypeEnumMemberComment','a.setTypeEnumMemberComment(name, ordinal, comment)','a.setTypeEnumMemberComment(name, 0, comment)')
reject('DeletePerfBenchmark','r.bench_id == bench_id','r.bench_id != bench_id')
reject('DeletePerfBenchmark','if (deleted) revision_++;','revision_++;')
print('Lua 43 final direct type/benchmark consumers and '..count..' real branch mutations PASS')
reject('AddTypeMember','std::string name = parent','std::string name = ""')
reject('DeleteTypeAlias','std::string name = alias_name','std::string name = ""')
reject('SetTypeEnumMemberValue','std::string type_name = type_id_or_path','std::string type_name = ""')
print('Explicit service/native parent-input origin mutations PASS')
