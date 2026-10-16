-- MIT Copyright 2026 Salvador Fandiño. Type reconstruction consumers and limits.
local S=require('inventory_source')
local M={}
-- Exact native calls are reviewed, not generated from operation spelling.
local calls={
 GetType={'getType(name)'},ListTypeMembers={'listTypeMembers(name)'},ListTypeEnumMembers={'listTypeEnumMembers(name)'},
 CreateType={'kind == "struct"','d.defineStruct(name, {})','"NOT_SUPPORTED"'},
 CreateTypeAlias={'a.createTypeAlias(alias_name, target_name)'},CreateTypeEnum={'d.defineEnum(name, std::vector<ghidra_standalone::EnumValue>{})'},
 DeleteType={'a.deleteType(name)'},RenameType={'a.renameType(name, new_name)'},DeleteTypeAlias={'a.deleteTypeAlias(name)'},SetTypeAliasTarget={'a.setTypeAliasTarget(name, new_target_name)'},
 AddTypeMember={'listTypeMembers(name)','fields.push_back({member_name, member_type, off})','static_cast<int>(m.offset) + static_cast<int>(m.size)','d.defineStruct(name, fields)'},
 AddTypeEnumMember={'listTypeEnumMembers(type_name)','entries.push_back({name, static_cast<uint64_t>(value)})','d.defineEnum(type_name, entries)'},
 DeleteTypeMember={'listTypeMembers(name)','if (i == ordinal) continue;','d.defineStruct(name, fields)'},
 RenameTypeMember={'listTypeMembers(name)','(i == ordinal) ? new_name : existing[i].name','d.defineStruct(name, fields)'},
 SetTypeMemberType={'listTypeMembers(name)','(i == ordinal) ? member_type : existing[i].member_type','d.defineStruct(name, fields)'},
 DeleteTypeEnumMember={'listTypeEnumMembers(type_name)','if (i == ordinal) continue;','d.defineEnum(type_name, entries)'},
 RenameTypeEnumMember={'listTypeEnumMembers(type_name)','(i == ordinal) ? new_name : existing[i].name','d.defineEnum(type_name, entries)'},
 SetTypeEnumMemberValue={'listTypeEnumMembers(type_name)','static_cast<uint64_t>(value)','d.defineEnum(type_name, entries)'},
 SetTypeMemberComment={'a.setTypeMemberComment(name, ordinal, comment)'},SetTypeEnumMemberComment={'a.setTypeEnumMemberComment(name, ordinal, comment)'},
}
local normalize={ListTypeMembers='name',ListTypeEnumMembers='name',DeleteType='name',RenameType='name',DeleteTypeAlias='name',SetTypeAliasTarget='name',AddTypeMember='name',AddTypeEnumMember='type_name',DeleteTypeMember='name',RenameTypeMember='name',SetTypeMemberType='name',DeleteTypeEnumMember='type_name',RenameTypeEnumMember='type_name',SetTypeEnumMemberValue='type_name',SetTypeMemberComment='name',SetTypeEnumMemberComment='name'}
local reconstruct={DeleteTypeMember='DELETE_MEMBER_FAILED',RenameTypeMember='RENAME_MEMBER_FAILED',SetTypeMemberType='SET_MEMBER_TYPE_FAILED',DeleteTypeEnumMember='DELETE_ENUM_MEMBER_FAILED',RenameTypeEnumMember='RENAME_ENUM_MEMBER_FAILED',SetTypeEnumMemberValue='SET_ENUM_VALUE_FAILED'}
local comments={SetTypeMemberComment='setTypeMemberComment',SetTypeEnumMemberComment='setTypeEnumMemberComment'}
local function has(c,x) assert(c:find(x,1,true),'type consumer missing '..x) end
local function before(c,x,y) local a,b=c:find(x,1,true),c:find(y,1,true); assert(a and b and a<b,'type branch ordering changed '..x) end
function M.review(raw,adapter,data,fingerprint)
 local requests,reviews={},{}
 for name,tokens in pairs(calls) do
  local start,text=S.body(raw,' '..name..'('); local code=S.mask(text,false)
  has(code,'if (!ensure_loaded())')
  for _,token in ipairs(tokens) do has(code,token); before(code,'ensure_loaded()',token) end
  local origins={GetType="getType(name)",ListTypeMembers="std::string name = type_id_or_path",ListTypeEnumMembers="std::string name = type_id_or_path",DeleteType="std::string name = type_id_or_path",RenameType="std::string name = type_id_or_path",DeleteTypeAlias="std::string name = alias_name",SetTypeAliasTarget="std::string name = alias_name",AddTypeMember="std::string name = parent",AddTypeEnumMember="std::string type_name = type_id_or_path",DeleteTypeMember="std::string name = parent_type_id_or_path",RenameTypeMember="std::string name = parent_type_id_or_path",SetTypeMemberType="std::string name = parent_type_id_or_path",DeleteTypeEnumMember="std::string type_name = type_id_or_path",RenameTypeEnumMember="std::string type_name = type_id_or_path",SetTypeEnumMemberValue="std::string type_name = type_id_or_path",SetTypeMemberComment="std::string name = parent_type_id_or_path",SetTypeEnumMemberComment="std::string name = type_id_or_path"}
  if origins[name] then has(code,origins[name]) end
  local sem='unchanged native byte-string names/types; no canonical readback, full-layout or persistence guarantee; '
  local var=normalize[name]
  if var then has(code,var..' = '..var..'.substr(1)'); sem=sem..'strip exactly one leading slash for parent lookup, no numeric-ID resolution; ' end
  if name=='GetType' then assert(not code:find('substr',1,true),'literal lookup changed'); sem=sem..'literal name, generated slash path not lookup proof; ' end
  if name=='CreateType' then sem=sem..'only struct kind supported; requested size ignored; ' end
  if name=='CreateTypeEnum' then sem=sem..'empty enum define; width/signedness ignored; practical public union/enum producer limitations retained; ' end
  if name=='AddTypeMember' then sem=sem..'append at maximum existing offset+size with signed-int casts/sum; require each and sum <=INT_MAX; requested size ignored; ' end
  if reconstruct[name] then
   has(code,'ordinal >= existing.size()'); has(code,'"NOT_FOUND"'); has(code,'"'..reconstruct[name]..'"')
   before(code,'ordinal >= existing.size()','applyDecompilerMutationAllSlots'); before(code,'if (!ok)','revision_++')
   sem=sem..'zero-based exact UInt64 ordinal of current traversal, not stable ID; missing/wrong-kind parent may yield NOT_FOUND; full reconstruction all slots, no rollback; '
   if name:find('Enum',1,true) then sem=sem..'signed int64 values cast to uint64 unchanged bit pattern; ' else has(code,'static_cast<int>(existing[i].offset)'); sem=sem..'existing signed offsets must fit int; offsets retained, deletion does not compact gaps; ' end
   sem=sem..'side-map comments not remapped; '
  end
  if comments[name] then
   assert(not code:find('existing.size()',1,true),'comment ordinal now validated'); has(code,'return true;'); has(code,'revision_++;')
   local _,body=S.body(adapter,'ArchAdapter::'..comments[name]..'('); local producer=S.mask(body,false)
   has(producer,'[{type_name, ordinal}] = comment'); assert(not producer:find('findByName',1,true),'comment existence changed')
   sem=sem..'unchecked type/ordinal side-map write, empty text stored not deleted; same value still revision; not native project comment persistence; '
  end
  if name=='AddTypeEnumMember' then sem=sem..'append signed value cast uint64 then redefine entire enum; missing/wrong kind can enumerate empty, no early NOT_FOUND; ' end
  local d=assert(data.declarations[name]); local args=S.split(d.arguments); local ignored=name=='CreateType' and {size=true} or name=='AddTypeMember' and {size=true} or name=='CreateTypeEnum' and {width=true,is_signed=true} or {}
  requests[name]={}
  for _,arg in ipairs(args) do
   local field=assert(arg:match('([%w_]+)$'))
   -- Page length/offset already have a separate bounded-input review.
   if not ignored[field] and field~='limit' and field~='offset' then
    local r={kind='direct',semantics=sem..'source review only; independent typed Lua validation/runtime evidence retained'}
    if fingerprint then r.consumer_body_sha256=fingerprint(text) end
    requests[name][field]=r
   end
  end
  local _,line=raw:sub(1,start-1):gsub('\n',''); local r={path='cpp/src/local_client.cpp',line=line+1,semantics=sem,qualification='source consumers/reconstruction only, not runtime approval'}
  if fingerprint then r.body_sha256=fingerprint(text) end; reviews[name]=r
 end
 -- Benchmark delete has a distinct absent-ID successful false acknowledgement.
 local start,text=S.body(raw,' DeletePerfBenchmark('); local code=S.mask(text,false)
 for _,x in ipairs{'if (!program_loaded_)','bench_id.empty()','"invalid_argument"','r.bench_id == bench_id','if (deleted) revision_++;','resp.deleted = deleted'} do has(code,x) end
 before(code,'"NO_PROGRAM"','bench_id.empty()'); before(code,'bench_id.empty()','r.bench_id == bench_id')
 requests.DeletePerfBenchmark={bench_id={kind='direct',semantics='required nonempty exact case-sensitive byte-string ID; empty lowercase invalid_argument; deletes all equal in-memory rows; absent nonempty successful false and no native revision; dispatched generation still invalidates'}}
 if fingerprint then requests.DeletePerfBenchmark.bench_id.consumer_body_sha256=fingerprint(text) end
 return {requests=requests,reconstruction=reviews}
end
return M
