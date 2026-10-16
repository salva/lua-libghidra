-- MIT Copyright 2026 Salvador Fandiño. Native acknowledgements are not readback.
local S=require('inventory_source')
local M={}
local contracts={
 RenameFunction={renamed='ok',name='new_name'},RenameSymbol={renamed='ok',name='new_name'},
 RenameDataItem={updated='ok',name='new_name'},RenameType={updated='ok',name='new_name'},
 RenameFunctionParameter={updated='ok',name='new_name'},SetFunctionParameterType={updated='ok',data_type='new_type'},
 SetFunctionSignature={updated='ok',prototype='prototype'},ApplyDataType={updated='ok',data_type='data_type'},
 RenameFunctionLocal={updated='true',local_id='local_id',name='new_name'},SetFunctionLocalType={updated='true',local_id='local_id',data_type='new_type'},
 DeleteSymbol={deleted='ok',deleted_count='ok ? 1 : 0'},WriteBytes={bytes_written='static_cast<std::uint32_t>(data.size())'},
 PatchBytesBatch={patch_count='static_cast<std::uint32_t>(patches.size())',bytes_written='total_bytes'},
}
for _,n in ipairs{'CreateType','CreateTypeAlias','CreateTypeEnum','AddTypeMember','AddTypeEnumMember','RenameTypeMember','SetTypeMemberType','RenameTypeEnumMember','SetTypeEnumMemberValue','SetTypeAliasTarget'} do contracts[n]={updated='ok'} end
for _,n in ipairs{'DeleteType','DeleteTypeAlias','DeleteTypeMember','DeleteTypeEnumMember','DeleteComment','DeleteDataItem'} do contracts[n]={deleted='ok'} end
local side={SetComment=true,SetTypeMemberComment=true,SetTypeEnumMemberComment=true}
for n in pairs(side) do contracts[n]={updated='true'} end
local function has(code,x) assert(code:find(x,1,true),'mutation result branch missing '..x) end
local function before(code,a,b) local x,y=code:find(a,1,true),code:find(b,1,true); assert(x and y and x<y,'mutation result ordering changed '..a) end
function M.review(raw,data,fingerprint)
 local result={}
 for name,expected in pairs(contracts) do
  local start,text=S.body(raw,' '..name..'('); local code=S.mask(text,false)
  local actual={}; for field,value in code:gmatch('%f[%w_]resp%.([%w_]+)%s*=%s*([^;]+);') do assert(not actual[field],'duplicate response assignment'); actual[field]=S.norm(value) end
  for f,v in pairs(expected) do assert(actual[f]==v,'mutation assignment changed '..name..'.'..f) end
  for f in pairs(actual) do assert(expected[f],'unexpected mutation assignment '..name..'.'..f) end
  local model=assert(data.types[data.declarations[name].response_type]); local defaults={}; local fields={}
  for _,f in ipairs(model.fields) do fields[f.name]=f; if not expected[f.name] then defaults[f.name]=f.native_default end end
  if name=='SetFunctionSignature' then assert(defaults.function_name,'signature default missing'); defaults.function_name=nil end
  assert(next(defaults)==nil,'unreviewed mutation default '..name)
  local returned='return StatusOr<'..data.declarations[name].response_type..'>::FromValue'
  has(code,returned)
  for _,v in pairs(expected) do if v=='ok' then
   before(code,'if (!ok)',returned)
   local first=assert(code:find('if (!ok)',1,true)); local last=assert(code:find(returned,1,true))
   has(code:sub(first,last),'::FromError(')
  end end
  if name=='RenameFunctionLocal' or name=='SetFunctionLocalType' then
   before(code,'switch (','revision_++'); before(code,'revision_++','resp.updated = true')
   has(code:sub(1,assert(code:find('revision_++',1,true))),'::FromError(')
  end
  if side[name] then
   assert(not code:find('if (!ok)',1,true) and not code:find('ordinal >= ',1,true),'side-map acknowledgement changed')
   has(code,'return true;'); before(code,'revision_++','resp.updated = true')
  end
  local semantics={}
  for f,v in pairs(expected) do
   semantics[f]=side[name] and 'literal true after unchecked side-map setter; same/empty text stored; no existence/kind/address/ordinal guarantee or project persistence proof'
    or (f=='updated' or f=='renamed' or f=='deleted') and 'native success acknowledgement true only; failed status is error not false success; no readback/rollback/atomicity proof'
    or f=='deleted_count' and 'successful address-only DeleteSymbol exactly 1; ignored name_filter not guard'
    or f=='local_id' and 'unchanged supplied local ID echo, not canonical resolved identity'
    or name=='WriteBytes' and 'input length cast uint32, not observed persisted count; empty write revision increments; bound input <=UINT32_MAX'
    or name=='PatchBytesBatch' and 'input-order patch count/uint32 byte sum, not observed writes; bound each/summed length/count <=UINT32_MAX; partial effects possible'
    or 'unchanged request echo '..v..', not canonical or post-edit readback'
  end
  if name=='SetFunctionSignature' then semantics.function_name='unassigned model initializer, not parsed or looked up from supplied prototype' end
  local _,line=raw:sub(1,start-1):gsub('\n','')
  local r={path='cpp/src/local_client.cpp',line=line+1,assignments=expected,semantics=semantics,qualification='source-only result accounting; preserve independent runtime evidence'}
  if fingerprint then r.body_sha256=fingerprint(text) end
  result[name]=r
 end
 return result
end
return M
