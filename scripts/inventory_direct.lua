-- MIT Copyright 2026 Salvador Fandiño. Exact-address and parameter mutation reviews.
local S=require('inventory_source')
local M={}
local addresses={
 ApplyDataType={'getSymbol(address)','d.nameGlobal(address, name, data_type)'},
 DeleteComment={'a.deleteComment(address, static_cast<int>(kind))'},
 DeleteDataItem={'a.deleteDataItem(address)'},DeleteSymbol={'a.deleteSymbol(address)'},
 GetDecompilation={'decompileWithLocals(address)'},GetFunction={'getFunction(address)'},
 GetFunctionSignature={'decompileAt(address)','getFunctionSignature(address)'},
 GetInstruction={'getInstruction(address)'},GetSymbol={'getSymbol(address)'},
 RenameDataItem={'a.renameDataItem(address, new_name)'},RenameFunction={'d.nameFunction(address, new_name)'},
 RenameFunctionLocal={'applyLocalRenameAllSlots(address, local_id, new_name)'},
 RenameFunctionParameter={'decompileAt(address)','getFunctionSignature(address)','d.setPrototype(address, proto)'},
 RenameSymbol={'getSymbol(address)','d.nameFunction(address, new_name)'},
 SetComment={'a.setComment(address, static_cast<int>(kind), text)'},
 SetFunctionLocalType={'applyLocalRetypeAllSlots(address, local_id, new_type)'},
 SetFunctionParameterType={'decompileAt(address)','getFunctionSignature(address)','d.setPrototype(address, proto)'},
 SetFunctionSignature={'d.setPrototype(address, prototype)'},
 ReadBytes={'readBytes(address, length)'},WriteBytes={'d.writeBytes(address, data)'},
}
local function has(code,x) assert(code:find(x,1,true),'direct consumer missing '..x) end
local function before(code,x,y) local a,b=code:find(x,1,true),code:find(y,1,true); assert(a and b and a<b,'direct consumer order changed '..x..' / '..y) end
function M.review(raw,adapter,data,fingerprint)
 local out={requests={},responses={}}
 local function add(name,arg,sem) out.requests[name]=out.requests[name] or {}; out.requests[name][arg]={kind='direct',semantics=sem} end
 for name,tokens in pairs(addresses) do
  local start,text=S.body(raw,' '..name..'('); local code=S.mask(text,false)
  for _,token in ipairs(tokens) do has(code,token); before(code,'ensure_loaded()',token) end
  if #tokens>1 and (name=='GetFunctionSignature' or name=='RenameFunctionParameter' or name=='SetFunctionParameterType') then before(code,tokens[1],tokens[2]) end
  local mutation=name:sub(1,3)~='Get' and name~='ReadBytes'
  if mutation then has(code,'revision_++;') end
  add(name,'address','required exact UInt64, literal zero NOT range sentinel; loaded guard precedes dispatch; no canonical entry/mapping/alignment/width/overflow guarantee; '..(mutation and 'dispatched mutation invalidates generation even on failure; native revision success policy separate' or 'read no native revision increment; analysis side effects possible'))
  if name=='ReadBytes' then add(name,'length','checked uint32 length further bounded <=INT32_MAX before dispatch/allocation; binary bytes, empty/short read not proof of mapped validity; raw FileBytes/address limitations retained') end
  if name=='WriteBytes' then
   has(code,'resp.bytes_written = static_cast<std::uint32_t>(data.size())')
   add(name,'data','length-preserving binary bytes; size <=UINT32_MAX before dispatch; all-slot void write acknowledgement is input size, not proof of bytes persisted; partial effects no rollback')
   out.responses[name]={semantics='bytes_written is input byte count, not verified write count'}
  end
  if name=='RenameFunctionParameter' or name=='SetFunctionParameterType' then
   local field=name=='RenameFunctionParameter' and 'name' or 'data_type'
   local arg=name=='RenameFunctionParameter' and 'new_name' or 'new_type'
   has(code,'ordinal < 0 || ordinal >= static_cast<int>(sig->parameters.size())')
   before(code,'"NOT_FOUND"','"OUT_OF_RANGE"'); before(code,'"OUT_OF_RANGE"','sig->parameters[ordinal].'..field..' = '..arg)
   before(code,'sig->parameters[ordinal].'..field..' = '..arg,'buildPrototypeString(*sig)')
   before(code,'buildPrototypeString(*sig)','d.setPrototype(address, proto)')
   has(code,'if (ok) revision_++;'); has(code,'"SET_PROTOTYPE_FAILED"')
   has(code,'resp.updated = ok'); has(code,'resp.'..field..' = '..arg)
   before(code,'"SET_PROTOTYPE_FAILED"','::FromValue(')
   add(name,'ordinal','zero-based checked signed int; reject negative/out of range; absent signature NOT_FOUND before ordinal check; not Lua array index')
   add(name,arg,'unchanged byte string assigned to existing parameter then entire prototype rebuilt; downstream parser effects not guaranteed; all-slot failure may be partial')
   out.responses[name]={semantics='successful updated=true with echoed requested '..arg..'; failed setPrototype returns SET_PROTOTYPE_FAILED rather than successful false; no rollback; filtered signature producer limitations retained'}
  end
  for _,r in pairs(out.requests[name]) do if fingerprint then r.consumer_body_sha256=fingerprint(text) end end
  local _,line=raw:sub(1,start-1):gsub('\n','')
  if out.responses[name] then out.responses[name].path='cpp/src/local_client.cpp'; out.responses[name].line=line+1; if fingerprint then out.responses[name].body_sha256=fingerprint(text) end end
 end
 for name,method in pairs{GetFunction='getFunction',GetInstruction='getInstruction',GetSymbol='getSymbol',GetFunctionSignature='getFunctionSignature',DeleteSymbol='deleteSymbol',DeleteDataItem='deleteDataItem',RenameDataItem='renameDataItem'} do
  local _,body=S.body(adapter,'ArchAdapter::'..method..'('); local code=S.mask(body,false)
  has(code,'arch_->getDefaultCodeSpace()'); has(code,'Address addr(space, static_cast<uintb>(address))')
 end
 return out
end
return M
