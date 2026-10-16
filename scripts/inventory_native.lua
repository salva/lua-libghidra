-- MIT Copyright 2026 Salvador Fandiño. Native-only inventory assembly.
local U,S=require('tool_util'),require('inventory_source')
local M={}
function M.inventory(source,fingerprint)
 local data={format=1,qualification='native grammar extraction only; semantic reviews and runtime qualification separate',sources={},types={},enums={},declarations={},implementations={}}
 local function read(path)
  data.sources[path]=U.hash(source..'/'..path)
  return U.read(source..'/'..path)
 end
 local function merge(dest,items)
  for name,v in pairs(items) do assert(not dest[name],'duplicate native definition '..name); dest[name]=v end
 end
 local paths={}
 for path in U.capture{'find',source..'/cpp/include/libghidra','-maxdepth','1','-type','f','-name','*.hpp','-print0'}:gmatch('([^\0]+)\0') do paths[#paths+1]=path:sub(#source+2) end
 table.sort(paths); assert(#paths>0,'no native headers')
 for _,path in ipairs(paths) do
  local t,e,d=S.header(path,read(path)); merge(data.types,t); merge(data.enums,e); merge(data.declarations,d)
 end
 local path='cpp/src/local_client.cpp'
 data.implementations=S.implementations(path,read(path))
 data.page_wrapper_reviews=require('inventory_pages').review(U.read(source..'/'..path),fingerprint)
 data.status_reviews=require('inventory_status').review(U.read(source..'/'..path),data.types,fingerprint)
 data.lookup_reviews=require("inventory_lookup").review(U.read(source.."/"..path),U.read(source.."/cpp/src/local_arch_adapter.cpp"),data.types,fingerprint)
 data.mutation_reviews=require("inventory_mutations").review(U.read(source.."/"..path),data,fingerprint)
 data.factory_reviews=require('inventory_factory').review(U.read(source..'/'..path),U.read(source..'/cpp/src/decompiler_pool.cpp'),data.types,fingerprint)
 data.adapter_page_reviews=require('inventory_adapter_pages').review(read('cpp/src/local_arch_adapter.cpp'),U.read(source..'/'..path),read('cpp/src/local_arch_adapter.hpp'),read('cpp/src/decompiler_pool.cpp'),fingerprint)
 data.request_reviews=require("inventory_requests").review(U.read(source.."/"..path),U.read(source.."/cpp/src/local_arch_adapter.cpp"),data,fingerprint)
 for name,impl in pairs(data.implementations) do
  local d=assert(data.declarations[name],'undeclared local override '..name)
  assert(impl.response_type==d.response_type,'override response differs '..name)
  local a,b=S.split(impl.arguments),S.split(d.arguments)
  assert(#a==#b,'override arity differs '..name)
  for i,v in ipairs(a) do
   local function argtype(x)
    if x=="int" or x=="bool" or x=="double" or x:match("^std::[%w_]+$") then return x end
    return S.norm(x:gsub("[%w_]+$",""))
   end
   assert(argtype(v)==argtype(b[i]),"override argument type differs "..name)
  end
 end
 local defaults=S.implementations('cpp/include/libghidra/api.hpp',read('cpp/include/libghidra/api.hpp'))
 for name in pairs(defaults) do assert(data.declarations[name],'unknown default '..name) end
 for name in pairs(data.declarations) do assert(defaults[name],'missing default '..name) end
 return data
end
return M
