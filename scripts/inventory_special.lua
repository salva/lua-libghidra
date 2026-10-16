-- MIT Copyright 2026 Salvador Fandiño. Coarse capability is not qualification.
local S=require('inventory_source')
local M={}
function M.review(raw,types,fingerprint)
 local out={}
 local function has(c,t) assert(c:find(t,1,true),'special producer missing '..t) end
 for _,name in ipairs{'ReadBytes','ListDefinedStrings','ListDataItems','GetCapabilities'} do
  local start,text=S.body(raw,' '..name..'('); local code=S.mask(text,false)
  local _,line=raw:sub(1,start-1):gsub('\n',''); local r={path='cpp/src/local_client.cpp',line=line+1,qualification='source-only special results, no new runtime approval'}
  if name=='ReadBytes' then
   has(code,'resp.data = std::move(data)'); has(code,'readBytes(address, length)')
   r.semantics='binary string preserves NUL/length; empty success for zero/caught read failure; preallocation length <=INT32_MAX; raw FileBytes/extreme-address limitations retained'
  elseif name=='ListDefinedStrings' then
   has(code,'ListDefinedStringsResponse resp;')
   assert(not code:find('%f[%w_]resp%.') and not code:find('primaryAdapter(',1,true) and not code:find('paginate(',1,true),'constant-empty producer changed')
   r.semantics='always empty vector loaded success; nested DefinedStringRecord unreachable schema, not observed encoding/length/address; no discovery iterator'
  elseif name=='ListDataItems' then
   assert(not code:find('rec.value_repr',1,true),'value renderer producer changed')
   has(code,'resp.data_items.push_back(std::move(rec))')
   local found=false; for _,f in ipairs(types.DataItemRecord.fields) do if f.name=='value_repr' then assert(f.native_default=='empty'); found=true end end; assert(found)
   r.semantics='value_repr unassigned empty initializer, not decoded memory'
  else
   local names,statuses={},{}
   for id,status in code:gmatch('{%s*"([%w_]+)"%s*,%s*"([%w_]+)"') do names[#names+1]=id; statuses[#statuses+1]=status end
   assert(table.concat(names,',')=='health,session,decompiler,functions,symbols,types,signatures,memory,listing,xrefs','capability row order changed')
   assert(table.concat(statuses,',')=='supported,supported,supported,supported,supported,supported,supported,supported,supported,partial','capability statuses changed')
   for _,t in ipairs{'pool_->size() > 1','std::to_string(pool_->size())',': "supported"'} do has(code,t) end
   local fields={}; for _,f in ipairs(types.Capability.fields) do fields[f.name]=true end; assert(fields.id and fields.status and fields.note and #types.Capability.fields==3)
   r.entries=names; r.semantics='fixed coarse native subsystem claims, not per-operation completeness or fixture acceptance; notes literal except size-dependent decompiler text; binding pool_size=1 still required'
  end
  if fingerprint then r.body_sha256=fingerprint(text) end; out[name]=r
 end
 return out
end
return M
