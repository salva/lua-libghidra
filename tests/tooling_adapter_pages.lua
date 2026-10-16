-- MIT Copyright 2026 Salvador Fandiño. Real adapter source and corruption paths.
package.path='scripts/?.lua;'..package.path
local U,S,P=require('tool_util'),require('inventory_source'),require('inventory_adapter_pages')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local a,l,h,p=U.read(root..'/cpp/src/local_arch_adapter.cpp'),U.read(root..'/cpp/src/local_client.cpp'),U.read(root..'/cpp/src/local_arch_adapter.hpp'),U.read(root..'/cpp/src/decompiler_pool.cpp')
local r=P.review(a,l,h,p); local n=0; for _ in pairs(r) do n=n+1 end; assert(n==15)
local mutations=0
local function mutate(input,signature,needle,replacement)
 local _,body,opening,ending=S.body(input,signature)
 local i,j=assert(body:find(needle,1,true)); local changed=body:sub(1,i-1)..replacement..body:sub(j+1)
 return input:sub(1,opening-1)..changed..input:sub(ending+1)
end
local function reject(a1,l1,h1,p1)
 assert(not pcall(P.review,a1,l1,h1,p1),'mutation accepted'); mutations=mutations+1
end
for _,method in ipairs{'getComments','listDataItems','listFunctions','listSymbols','listInstructions'} do reject(mutate(a,'ArchAdapter::'..method..'(','normalize_range_end(range_end)','range_end'),l,h,p) end
for _,method in ipairs{'listTypes','listTypeAliases','listTypeUnions','listTypeEnums'} do reject(mutate(a,'ArchAdapter::'..method..'(','tf->dependentOrder(deporder)','tf->wrongOrder(deporder)'),l,h,p) end
for _,method in ipairs{'listTypeMembers','listTypeEnumMembers'} do reject(mutate(a,'ArchAdapter::'..method..'(','ordinal++','ordinal'),l,h,p) end
reject(mutate(a,'ArchAdapter::decompileAndExtractCFG(','collectBasicBlocks(structure.getBlock(i), basics)','wrongCollector(structure.getBlock(i), basics)'),l,h,p)
reject(mutate(a,'ArchAdapter::listXrefsForFunction(','CPUI_LOAD','CPUI_STORE'),l,h,p)
reject(a,l,h,mutate(p,'DecompilerPool::decompileMany(','results[i].completed = false','results[i].completed = true'))
reject(a,l,h,mutate(p,'DecompilerPool::decompileMany(','results(addresses.size())','results(0)'))
assert(mutations==15)
print('Lua adapter traversal/CFG/xref/batch reviews and 15 real source-corruption paths PASS')
