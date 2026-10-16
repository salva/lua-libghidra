-- MIT Copyright 2026 Salvador Fandiño.
-- Isolated wrapper state, never write fixture/project files.
local prefix,root,work=assert(arg[1]),assert(arg[2]),assert(arg[3])
package.path=prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath=prefix..'/lib/lua/5.4/?.so'
local gh=require'libghidra'
local function must(r,e) assert(r,e and (e.code..': '..e.message)); return r end
for _,project in ipairs{false,true} do
 local profile=project and 'project' or 'binary'
 local state=work..'/m4-'..profile..'.xml'; os.remove(state)
 local program={program_path=root..'/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
 if project then program.project_path=root..'/tests/fixtures/project/authored.gpr' end
 local function open() return must(gh.open{client={state_path=state},program=program}) end
 local a,data=0x401106,0x404010
 local original,before
 do
  local s <close> =open(); local n=s:native()
  assert(must(n:get_decompilation(a)).decompilation.completed)
  original=must(n:read_bytes(data,4)).data
  assert(must(n:create_type('M4PersistStruct','struct',99)).updated)
  assert(must(n:add_type_member('M4PersistStruct','item','int',99)).updated)
  assert(must(n:set_type_member_comment('M4PersistStruct',0,'member-persist')).updated)
  assert(must(n:create_type_alias('M4PersistAlias','int')).updated)
  assert(must(n:create_type_enum('M4PersistEnum',1,false)).updated)
  assert(must(n:add_type_enum_member('M4PersistEnum','seven',7)).updated)
  assert(must(n:set_type_enum_member_comment('M4PersistEnum',0,'enum-persist')).updated)
  assert(must(n:set_function_signature(a,'int native_smoke(int persist_arg)')).updated)
  assert(must(n:rename_function_parameter(a,0,'persist_parameter')).updated)
  local d=must(n:get_decompilation(a)).decompilation; assert(d.completed and not d.is_fallback)
  local selected
  for _,l in ipairs(d.locals) do if l.kind=='local' then assert(not selected); selected=l end end
  if project then
   assert(selected and selected.local_id=='local:register:0x38:-1' and selected.name=='unaff_EDI' and selected.data_type=='int4')
   assert(must(n:rename_function_local(a,selected.local_id,'persist_local')).updated)
  else
   assert(not selected) -- binary int prototype exposes only param, not a true local
  end
  assert(must(n:set_comment(a,'eol','m4-persist-comment')).updated)
  assert(must(n:apply_data_type(data,'int')).updated)
  assert(must(n:rename_data_item(data,'m4_persist_data')).updated)
  assert(must(n:add_perf_benchmark{bench_id='persist-bench',cold_ms_p50=1.25}).added)
  assert(must(n:patch_bytes_batch{{address=data,data='Q\0RS'}}).bytes_written==4)
  -- Detached, identity-keyed scalar snapshots BEFORE save; no acknowledgement-only loss claims.
  local function find(rows,key,value)
   local result
   for _,v in ipairs(rows) do if v[key]==value then assert(not result); result=v end end
   return assert(result,'missing pre-save identity '..value)
  end
  local struct=assert(must(n:get_type('M4PersistStruct')).type)
  assert(struct.kind=='struct' and struct.path_name=='/M4PersistStruct' and struct.length==0) -- generic shell length, not member size
  local member=find(must(n:list_type_members('M4PersistStruct')).members,'parent_type_path_name','/M4PersistStruct')
  assert(member.ordinal:hex()=='0x0000000000000000' and member.name=='item' and member.member_type=='int' and member.size:to_integer()==4 and member.comment=='member-persist')
  local alias=find(must(n:list_type_aliases('M4PersistAlias')).aliases,'path_name','/M4PersistAlias')
  assert(alias.target_type=='int')
  local enum=find(must(n:list_type_enums('M4PersistEnum')).enums,'path_name','/M4PersistEnum')
  assert(enum.width:to_integer()==8 and enum.is_signed==false) -- width only; no ignored-sign inference
  local em=find(must(n:list_type_enum_members('M4PersistEnum')).members,'type_path_name','/M4PersistEnum')
  assert(em.ordinal:hex()=='0x0000000000000000' and em.name=='seven' and em.value==7 and em.comment=='enum-persist')
  local sig=assert(must(n:get_function_signature(a)).signature)
  assert(sig.function_entry_address:hex()=='0x0000000000401106' and sig.prototype==(project and 'int native_smoke(int persist_parameter)' or 'int func_0x00401106(int persist_parameter)'))
  local parameter=find(sig.parameters,'ordinal',0); assert(parameter.name=='persist_parameter' and parameter.data_type=='int')
  local comment=find(must(n:get_comments{range_start=a,range_end=a}).comments,'kind','eol')
  assert(comment.address:hex()=='0x0000000000401106' and comment.text=='m4-persist-comment')
  local item=find(must(n:list_data_items{range_start=data,range_end=data}).data_items,'name','m4_persist_data')
  assert(item.address:hex()=='0x0000000000404010' and item.data_type=='int' and item.size:to_integer()==4)
  local bench=find(must(n:list_perf_benchmarks()).records,'bench_id','persist-bench'); assert(bench.cold_ms_p50==1.25)
  local overlay=must(n:read_bytes(data,4)).data; assert(overlay=='Q\0RS' and overlay~=original)
  local local_name,local_id
  local observed=must(n:get_decompilation(a)).decompilation
  assert(observed.completed and not observed.is_fallback)
  if project then
   local v=find(observed.locals,'local_id',selected.local_id)
   assert(v.kind=='local' and v.name=='persist_local' and v.data_type=='int4')
   local_name,local_id=v.name,v.local_id
  else
   for _,v in ipairs(observed.locals) do assert(v.kind=='param') end
  end
  before={local_name=local_name,local_id=local_id,struct=struct.path_name,member=member.ordinal:hex(),alias=alias.path_name,enum=enum.path_name,
   enum_member=em.ordinal:hex(),signature=sig.prototype,parameter=parameter.name,comment=comment.text,
   data_name=item.name,bench=bench.bench_id,overlay=overlay}
  assert(must(n:save_program()).saved)
  assert(must(n:discard_program()).discarded)
  assert(must(n:read_bytes(data,4)).data=='Q\0RS')
  assert(must(n:shutdown{policy='save'}).accepted)
 end
 do
  local s <close> =open(); local n=s:native()
  local struct=must(n:get_type('M4PersistStruct')).type
  assert(struct and struct.path_name==before.struct and struct.kind=='struct' and struct.length==0)
  assert(not must(n:get_type('M4PersistAlias')).type)
  assert(not must(n:get_type('M4PersistEnum')).type)
  assert(#must(n:list_type_members('M4PersistStruct')).members==0)
  assert(#must(n:list_type_enum_members('M4PersistEnum')).members==0)
  assert(#must(n:list_type_aliases('M4PersistAlias')).aliases==0)
  assert(#must(n:get_comments{range_start=a,range_end=a}).comments==0)
  assert(#must(n:list_data_items{range_start=data,range_end=data+3}).data_items==0)
  local sig=must(n:get_function_signature(a)).signature
  assert(sig and sig.function_entry_address:hex()=='0x0000000000401106' and sig.prototype~=before.signature and not sig.prototype:find('persist',1,true))
  assert(#must(n:list_perf_benchmarks()).records==0)
  assert(must(n:read_bytes(data,4)).data==original and original~=before.overlay)
  local d=must(n:get_decompilation(a)).decompilation
  assert(d.completed)
  for _,l in ipairs(d.locals) do assert(l.name~=before.parameter); if project and l.local_id==before.local_id then assert(l.name=='unaff_EDI' and l.name~=before.local_name) end end
  -- Missing member/enum cannot isolate comment loss independently of container/member loss.
  print('M4 persistence '..profile..' limited reload: struct shell only; other new categories absent/reset PASS')
 end
end
