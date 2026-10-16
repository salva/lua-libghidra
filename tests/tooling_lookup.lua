-- MIT Copyright 2026 Salvador Fandiño. Lookup producer/error/absence drift.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_lookup')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local a=U.read(root..'/cpp/src/local_arch_adapter.cpp')
local types=S.header('models.hpp',U.read(root..'/cpp/include/libghidra/models.hpp'))
local r=R.review(raw,a,types); assert(r.GetFunction.default_only.prototype and r.GetSymbol.default_only.symbol_id)
local count=0
local function reject(input,signature,needle,replacement,where)
 local _,text,opening,ending=S.body(input,signature); local i,j=assert(text:find(needle,1,true))
 local changed=input:sub(1,opening-1)..text:sub(1,i-1)..replacement..text:sub(j+1)..input:sub(ending+1)
 assert(not pcall(R.review,where=='local' and changed or raw,where=='adapter' and changed or a,types),'lookup mutation accepted '..signature..' '..needle); count=count+1
end
for _,method in ipairs{'getFunction','getSymbol','getType','getInstruction','getFunctionSignature','readBytes'} do reject(a,'ArchAdapter::'..method..'(','catch (...)','catch (std::exception& e)','adapter') end
reject(a,'ArchAdapter::readBytes(','result.resize(length)','result.resize(0)','adapter')
reject(a,'ArchAdapter::readBytes(','static_cast<int4>(length)','length','adapter')
reject(a,'ArchAdapter::readBytes(','result.clear()','result.resize(1)','adapter')
reject(a,'ArchAdapter::getType(','findByName(name)','findByName("")','adapter')
reject(raw,' GetFunctionSignature(','pool_->primary().decompileAt(address);',';','local')
reject(raw,' GetDecompilation(','resp.decompilation->completed = false','resp.decompilation->completed = true','local')
reject(raw,' GetDecompilation(','resp.decompilation->error_message = dl.error','resp.decompilation->error_message = ""','local')
reject(raw,' ListDefinedStrings(','{','{ resp.strings = {};','local')
print('Lua eight lookup/constant-empty response reviews and '..count..' real source mutations PASS')
