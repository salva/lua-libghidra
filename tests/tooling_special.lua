-- MIT Copyright 2026 Salvador Fandiño. Constant/bytes/capability fidelity.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_special')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local types=S.header('models.hpp',U.read(root..'/cpp/include/libghidra/models.hpp'))
R.review(raw,types)
local count=0
for _,c in ipairs{
 {'ReadBytes','resp.data = std::move(data)','resp.data = {}'},
 {'ListDefinedStrings','{','{ resp.strings = {};'},
 {'ListDefinedStrings','{','{ primaryAdapter();'},
 {'ListDataItems','{','{ rec.value_repr = "rendered";'},
 {'GetCapabilities','"health", "supported"','"health", "partial"'},
 {'GetCapabilities','"xrefs", "partial"','"xrefs", "supported"'},
 {'GetCapabilities','"health", "supported"','"session", "supported"'},
 {'GetCapabilities','pool_->size() > 1','pool_->size() >= 1'},
} do
 local _,text,opening,ending=S.body(raw,' '..c[1]..'('); local i,j=assert(text:find(c[2],1,true)); local changed=raw:sub(1,opening-1)..text:sub(1,i-1)..c[3]..text:sub(j+1)..raw:sub(ending+1)
 assert(not pcall(R.review,changed,types),'special source mutation accepted '..c[1]); count=count+1
end
print('Lua special producer reviews and '..count..' source mutations PASS')
