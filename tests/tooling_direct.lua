-- MIT Copyright 2026 Salvador Fandiño. Direct consumer/related result drift.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_direct')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local a=U.read(root..'/cpp/src/local_arch_adapter.cpp')
local r=R.review(raw,a,{}); local count=0; for _,args in pairs(r.requests) do for _ in pairs(args) do count=count+1 end end; assert(count==26)
local function reject(name,needle,replacement)
 local _,text,opening,ending=S.body(raw,' '..name..'('); local i,j=assert(text:find(needle,1,true))
 local changed=raw:sub(1,opening-1)..text:sub(1,i-1)..replacement..text:sub(j+1)..raw:sub(ending+1)
 assert(not pcall(R.review,changed,a,{}),'direct source mutation accepted '..name..' '..needle)
end
for name,args in pairs(r.requests) do
 reject(name,'ensure_loaded()','false')
end
reject('GetFunction','getFunction(address)','getFunction(0)')
reject('GetFunctionSignature','decompileAt(address)','decompileAt(0)')
reject('RenameFunctionLocal','applyLocalRenameAllSlots(address, local_id, new_name)','applyLocalRenameAllSlots(0, local_id, new_name)')
reject('SetFunctionLocalType','applyLocalRetypeAllSlots(address, local_id, new_type)','applyLocalRetypeAllSlots(0, local_id, new_type)')
for _,name in ipairs{'RenameFunctionParameter','SetFunctionParameterType'} do
 reject(name,'ordinal < 0 || ordinal >= static_cast<int>(sig->parameters.size())','ordinal > 100')
 reject(name,'"NOT_FOUND"','"OUT_OF_RANGE"')
 reject(name,'buildPrototypeString(*sig)','new_name')
 reject(name,'resp.updated = ok','resp.updated = true')
 reject(name,'if (ok) revision_++;','revision_++;')
end
reject('WriteBytes','static_cast<std::uint32_t>(data.size())','0')
reject('ReadBytes','readBytes(address, length)','readBytes(address, 0)')
print('Lua 26 direct request consumers and related parameter/write result semantics, 36 source mutations PASS')
