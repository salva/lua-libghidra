-- MIT Copyright 2026 Salvador Fandiño.
local prefix,root=assert(arg[1]),assert(arg[2])
package.path=prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath=prefix..'/lib/lua/5.4/?.so'
local gh=require'libghidra'
local function must(r,e) assert(r,e and (e.code..': '..e.message)); return r end
local function bad(r,e) assert(r==nil and e.backend=='binding' and e.code=='INVALID_ARGUMENT') end
for _,project in ipairs{false,true} do
 local program={program_path=root..'/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
 if project then program.project_path=root..'/tests/fixtures/project/authored.gpr' end
 local session <close> = must(gh.open{program=program}); local n=session:native()
 local a=0x401106
 for _,entry in ipairs{a,0x40111f,0x40113c} do assert(must(n:get_decompilation(entry)).decompilation.completed) end
 assert(#must(n:list_decompilations{range_start=a,range_end=a,limit=1}).decompilations==1)
 -- Authored oracle: project_probe.cpp and fixtures/README.md, not adapter sampling.
 local function leaves(first,last,limit,offset,expected)
  local page=must(n:list_leaf_functions{range_start=first,range_end=last,limit=limit,offset=offset}).functions
  for _,v in ipairs(page) do assert(v.entry_address:hex()~='0x000000000040111f','leaf caller exclusion') end
  assert(#page==#expected,'leaf count')
  for i,v in ipairs(page) do assert(v.entry_address:hex()==expected[i],'leaf identity/order offset='..offset) end
 end
 if project then
  local first,last='0x0000000000401106','0x000000000040113c'
  leaves(a,0x40113f,100,0,{first,last})
  leaves(a,0x40113f,1,0,{first}); leaves(a,0x40113f,1,1,{last}); leaves(a,0x40113f,1,2,{})
  leaves(a,a,100,0,{first}); leaves(0x40113c,0x40113c,100,0,{last})
  leaves(0x40111f,0x40111f,100,0,{}); leaves(a+1,0x40113f,100,0,{last})
 else local r,e=n:list_leaf_functions{limit=100}; assert(not r and e.code=='NOT_SUPPORTED') end
 -- Identity-keyed readbacks: positions in a Lua array are not native ordinals.
 local function member()
  local result
  for _,v in ipairs(must(n:list_type_members('M4Struct')).members) do
   if v.parent_type_path_name=='/M4Struct' and v.ordinal:hex()=='0x0000000000000000' then assert(not result); result=v end
  end
  return result
 end
 local function alias()
  for _,v in ipairs(must(n:list_type_aliases('M4Alias')).aliases) do if v.path_name=='/M4Alias' then return v end end
 end
 local function enum_member()
  for _,v in ipairs(must(n:list_type_enum_members('M4Enum')).members) do
   if v.type_path_name=='/M4Enum' and v.ordinal:hex()=='0x0000000000000000' then return v end
  end
 end
 local function parameter()
  local sig=assert(must(n:get_function_signature(a)).signature)
  assert(sig.function_entry_address:hex()=='0x0000000000401106')
  for _,v in ipairs(sig.parameters) do if v.ordinal==0 then return v end end
  error('parameter ordinal zero missing')
 end
 local function local_record(id)
  local d=must(n:get_decompilation(a)).decompilation; assert(d.completed and not d.is_fallback)
  for _,v in ipairs(d.locals) do if v.local_id==id then return v end end
  error('local identity missing: '..id)
 end
 local it=session:iter_functions{page_size=2}; assert(it())
 bad(n:create_type('invalid','struct',-1)); assert(it())
 assert(must(n:create_type('M4Struct','struct',999)).updated)
 local ok,err=pcall(it); assert(not ok and err.code=='ITERATOR_INVALIDATED')
 local failed_it=session:iter_functions{page_size=2}; assert(failed_it())
 local unsupported,ue=n:create_type('M4Union','union',0); assert(not unsupported and ue.code=='NOT_SUPPORTED')
 local good,failure=pcall(failed_it); assert(not good and failure.code=='ITERATOR_INVALIDATED')
 local missing,me=n:delete_type_member('missing', '18446744073709551615')
 assert(not missing and me.code=='NOT_FOUND')
 assert(must(n:add_type_member('M4Struct','x','int',999)).updated)
 local struct=assert(must(n:get_type('M4Struct')).type)
 assert(struct.kind=='struct' and struct.path_name=='/M4Struct' and struct.length==0)
 assert(member().name=='x' and member().member_type=='int' and member().size:to_integer()==4)
 assert(must(n:rename_type_member('M4Struct',0,'y')).updated)
 assert(member().name=='y','member rename readback')
 assert(must(n:set_type_member_type('M4Struct',0,'char')).updated)
 assert(member().member_type=='char' and member().size:to_integer()==1,'member retype readback')
 assert(must(n:set_type_member_comment('M4Struct',0,'note\0tail')).updated)
 assert(member().comment=='note\0tail','member binary comment readback')
 assert(must(n:delete_type_member('M4Struct',0)).deleted); assert(not member())
 assert(must(n:rename_type('M4Struct','M4Renamed')).updated)
 assert(not must(n:get_type('M4Struct')).type)
 assert(must(n:get_type('M4Renamed')).type.path_name=='/M4Renamed')
 assert(must(n:delete_type('M4Renamed')).deleted); assert(not must(n:get_type('M4Renamed')).type)
 assert(must(n:create_type_alias('M4Alias','int')).updated); assert(alias().name=='M4Alias' and alias().target_type=='int')
 assert(must(n:set_type_alias_target('M4Alias','char')).updated); assert(alias().target_type=='char')
 assert(must(n:delete_type_alias('M4Alias')).deleted); assert(not alias())
 assert(must(n:create_type_enum('M4Enum',123,false)).updated)
 local enum=must(n:get_type('M4Enum')).type; assert(enum and enum.kind=='int' and enum.path_name=='/M4Enum' and enum.length==8)
 -- Exact ignored-width observation; false input + false output does NOT test ignored signedness.
 local enums=must(n:list_type_enums('M4Enum')).enums; assert(#enums==1 and enums[1].path_name=='/M4Enum' and enums[1].width:to_integer()==8 and enums[1].is_signed==false)
 assert(must(n:add_type_enum_member('M4Enum','zero',0)).updated); assert(enum_member().name=='zero' and enum_member().value==0)
 assert(must(n:rename_type_enum_member('M4Enum',0,'renamed')).updated); assert(enum_member().name=='renamed')
 assert(must(n:set_type_enum_member_value('M4Enum',0,7)).updated); assert(enum_member().value==7)
 assert(must(n:set_type_enum_member_comment('M4Enum',0,'enum\0comment')).updated); assert(enum_member().comment=='enum\0comment')
 assert(must(n:delete_type_enum_member('M4Enum',0)).deleted); assert(not enum_member())
 local sig=must(n:set_function_signature(a,'int native_smoke(int value)'))
 assert(sig.updated and sig.prototype=='int native_smoke(int value)' and sig.function_name=='')
 assert(parameter().name=='value' and parameter().data_type=='int')
 assert(must(n:rename_function_parameter(a,0,'input')).name=='input'); assert(parameter().name=='input')
 local original_type=parameter().data_type
 assert(must(n:set_function_parameter_type(a,0,'char')).data_type=='char')
 assert(parameter().data_type=='char' and parameter().data_type~=original_type,'parameter retype readback')
 local d=must(n:get_decompilation(a)).decompilation; assert(d.completed and not d.is_fallback)
 local selected
 for _,v in ipairs(d.locals) do if v.kind=='local' then assert(not selected); selected=v end end
 assert(selected and selected.local_id==(project and 'local:register:0x38:-1' or 'local:register:0x39:-1') and selected.name==(project and 'unaff_EDI' or 'in_EDI') and selected.data_type==(project and 'int4' or ''))
 local local_id=selected.local_id
 assert(must(n:rename_function_local(a,local_id,'m4local')).local_id==local_id)
 assert(local_record(local_id).kind=='local' and local_record(local_id).name=='m4local','true-local rename readback')
 -- Pinned upstream applyLocalRetype rejects this inferred register local. No echo-only success claim.
 local retyped,re=n:set_function_local_type(a,local_id,'char')
 assert(not retyped and re.backend=='local' and re.code=='DECOMPILE_FAILED')
 assert(local_record(local_id).data_type==selected.data_type and local_record(local_id).name=='m4local')
 print('true-local rename observed; true-local char retype DECOMPILE_FAILED (unqualified)')
 bad(n:rename_function_parameter(a,-1,'bad'))
 assert(must(n:apply_data_type(0x404010,'int')).updated)
 local function data_item()
  for _,v in ipairs(must(n:list_data_items{range_start=0x404010,range_end=0x404010}).data_items) do
   if v.address:hex()=='0x0000000000404010' then return v end
  end
 end
 assert(data_item() and data_item().data_type=='int' and data_item().size:to_integer()==4)
 assert(must(n:rename_data_item(0x404010,'m4data')).name=='m4data'); assert(data_item().name=='m4data')
 assert(must(n:delete_data_item(0x404010)).deleted); assert(data_item().name=='iRam0000000000404010' and data_item().data_type=='int4') -- rediscovered inferred data, not the deleted named symbol
 must(n:apply_data_type(0x404010,'int'))
 local deleted=must(n:delete_symbol(0x404010,'mismatched ignored name'))
 assert(deleted.deleted and deleted.deleted_count==1)
 assert(must(n:set_comment(a,'eol','hello\0world')).updated)
 local comments=must(n:get_comments{range_start=a,range_end=a}).comments
 assert(#comments==1 and comments[1].address:hex()=='0x0000000000401106' and comments[1].kind=='eol' and comments[1].text=='hello\0world')
 assert(must(n:delete_comment(a,'eol')).deleted); assert(#must(n:get_comments{range_start=a,range_end=a}).comments==0)
 bad(n:set_comment(a,'unknown','bad'))
 local before=must(n:read_bytes(a,4)).data
 local patch_it=session:iter_functions{page_size=2}; assert(patch_it())
 local patch=must(n:patch_bytes_batch{{address=a,data='\0A'},{address=a+2,data='\0B'}})
 assert(patch.patch_count==2 and patch.bytes_written==4)
 local good,failure=pcall(patch_it); assert(not good and failure.code=='ITERATOR_INVALIDATED')
 -- Native sequential overlap: later patch wins, not an atomic disjoint patch API.
 assert(must(n:patch_bytes_batch{{address=a,data='AB'},{address=a+1,data='CD'}}).bytes_written==4)
 assert(must(n:read_bytes(a,3)).data=='ACD')
 must(n:patch_bytes_batch{{address=a,data='\0A\0B'}})
 assert(must(n:read_bytes(a,4)).data=='\0A\0B')
 bad(n:patch_bytes_batch{[2]={address=a,data='x'}})
 bad(n:patch_bytes_batch{{address=a,data='x',unknown=true}})
 must(n:patch_bytes_batch{{address=a,data=before}})
 assert(must(n:add_perf_benchmark{bench_id='m4',cold_ms_p50=0,warm_ms_p95=2.5,regression_pct=-1}).added)
 local records=must(n:list_perf_benchmarks()).records
 assert(#records==1 and records[1].bench_id=='m4' and records[1].cold_ms_p50==0 and records[1].warm_ms_p95==2.5 and records[1].regression_pct==-1)
 bad(n:add_perf_benchmark{bench_id='invalid',cold_ms_p50=0/0})
 assert(must(n:delete_perf_benchmark('m4')).deleted); assert(#must(n:list_perf_benchmarks()).records==0)
 assert(must(n:clear_perf_benchmarks()).removed_count==0)
 print('M4 service batch '..(project and 'project' or 'binary')..' PASS')
end
