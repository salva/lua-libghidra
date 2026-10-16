-- MIT Copyright 2026 Salvador Fandiño.
-- Full-operation negative, dispatch and lifecycle matrix against real installed Lua.
local prefix,root=assert(arg[1]),assert(arg[2])
package.path=prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath=prefix..'/lib/lua/5.4/?.so'
local gh=require'libghidra'; local low=require'libghidra.lowlevel'
local function must(r,e) assert(r,e and (e.code..': '..e.message)); return r end
local rows={
 {'create_type',{'T','struct',0}}, {'delete_type',{'T'}}, {'rename_type',{'T','U'}},
 {'create_type_alias',{'A','int'}}, {'delete_type_alias',{'A'}}, {'set_type_alias_target',{'A','char'}},
 {'create_type_enum',{'E',0,false}}, {'add_type_enum_member',{'E','a',0}},
 {'delete_type_enum_member',{'E',0}}, {'rename_type_enum_member',{'E',0,'b'}},
 {'set_type_enum_member_value',{'E',0,0}}, {'set_type_enum_member_comment',{'E',0,''}},
 {'add_type_member',{'T','m','int',0}}, {'delete_type_member',{'T',0}},
 {'rename_type_member',{'T',0,'n'}}, {'set_type_member_type',{'T',0,'char'}}, {'set_type_member_comment',{'T',0,''}},
 {'set_function_signature',{0,'int f()'}}, {'rename_function_parameter',{0,0,'p'}},
 {'set_function_parameter_type',{0,0,'int'}}, {'rename_function_local',{0,'arg0','p'}},
 {'set_function_local_type',{0,'arg0','int'}}, {'apply_data_type',{0,'int'}},
 {'list_decompilations',{{limit=1}}}, {'list_leaf_functions',{{limit=1}}},
 {'delete_symbol',{0,''}}, {'set_comment',{0,'eol',''}}, {'delete_comment',{0,'eol'}},
 {'list_data_items',{{limit=1}}}, {'rename_data_item',{0,'d'}}, {'delete_data_item',{0}},
 {'add_perf_benchmark',{{bench_id='x'}}}, {'list_perf_benchmarks',{}},
 {'clear_perf_benchmarks',{}}, {'delete_perf_benchmark',{'x'}}, {'patch_bytes_batch',{{}}},
}
do
 local n <close> = must(low.local_client{})
 local reads={list_decompilations=true,list_leaf_functions=true,list_data_items=true,list_perf_benchmarks=true}
 for _,row in ipairs(rows) do
  local before=n:_generation()
  local r,e=n[row[1]](n,table.unpack(row[2]));
  assert(n:_generation()==(reads[row[1]] and before or assert(before:add(1))),row[1])
  local after=n:_generation() assert(not r and e.code=='NO_PROGRAM' and e.backend=='local',row[1])
  -- Required scalar/table arguments reject a wrong first type before dispatch.
  if #row[2]>0 then
   r,e=n[row[1]](n,false); assert(n:_generation()==after,row[1]); assert(not r and e.code=='INVALID_ARGUMENT' and e.backend=='binding',row[1])
  end
 end
 local r,e=n:shutdown{policy=false}; assert(not r and e.code=='INVALID_ARGUMENT')
 must(n:close())
 for _,row in ipairs(rows) do local r,e=n[row[1]](n,table.unpack(row[2])); assert(not r and e.code=='CLOSED',row[1]) end
end
local program={program_path=root..'/tests/fixtures/inputs/authored.elf',project_path=root..'/tests/fixtures/project/authored.gpr',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
do
 local s <close> =must(gh.open{program=program}); local n=s:native(); local a=0x401106
 for _,args in ipairs{
  {bench_id='all\0fields',query_family='q\0family',dataset_profile='',status='s\0t',cold_ms_p50=0,cold_ms_p95=1.5,warm_ms_p50=2.5,warm_ms_p95=3.5,throughput_qps=4.5,regression_pct=-5.5},
  {bench_id='defaults'},
 } do
  assert(must(n:add_perf_benchmark(args)).added)
  local found
  for _,r in ipairs(must(n:list_perf_benchmarks()).records) do if r.bench_id==args.bench_id then found=r end end
  assert(found)
  for _,k in ipairs{'bench_id','query_family','dataset_profile','status'} do assert(found[k]==(args[k] or '')) end
  for _,k in ipairs{'cold_ms_p50','cold_ms_p95','warm_ms_p50','warm_ms_p95','throughput_qps','regression_pct'} do assert(found[k]==(args[k] or 0)) end
 end
 assert(must(n:clear_perf_benchmarks()).removed_count==2)
 assert(not must(n:delete_perf_benchmark('absent')).deleted) -- false preserved
 local r,e=n:add_perf_benchmark{}; assert(not r and e.backend=='local')
 for _,opts in ipairs{{limit=0},{offset=-1},{limit=2,offset=2147483646},{unknown=1}} do
  for _,name in ipairs{'list_decompilations','list_leaf_functions','list_data_items'} do local r,e=n[name](n,opts); assert(not r and e.code=='INVALID_ARGUMENT') end
 end
 local r,e=n:list_decompilations({}, {timeout_ms=-1}); assert(not r and e.code=='INVALID_ARGUMENT')
 r,e=n:list_decompilations({}, {timeout_ms=0,unknown=true}); assert(not r and e.code=='INVALID_ARGUMENT')
 assert(must(n:patch_bytes_batch{}).patch_count==0)
 local r=must(n:patch_bytes_batch{{address=0x404010,data='A'},{address=0x404010,data=''}})
 assert(r.patch_count==2 and r.bytes_written==1 and must(n:read_bytes(0x404010,1)).data=='A')
 assert(must(n:create_type_enum('Limits',0,false)).updated)
 for _,v in ipairs{math.mininteger,math.maxinteger,0} do
  assert(must(n:add_type_enum_member('Limits','value',v)).updated)
  local m=must(n:list_type_enum_members('Limits')).members; assert(#m==1 and m[1].value==v)
  assert(must(n:delete_type_enum_member('Limits',0)).deleted)
 end
 for _,kind in ipairs{'unspecified','eol','pre','post','plate','repeatable'} do
  assert(must(n:set_comment(a,kind,'text\0tail')).updated)
  local found=false
  for _,c in ipairs(must(n:get_comments{range_start=a,range_end=a}).comments) do if c.kind==kind then assert(c.text=='text\0tail'); found=true end end
  assert(found); assert(must(n:delete_comment(a,kind)).deleted)
 end
 -- Bounded normal failure alongside successful records in one native batch.
 assert(must(n:get_decompilation(a)).decompilation.completed)
 assert(must(n:rename_function(0x500000,'bounded_unmapped')).renamed)
 local records=must(n:list_decompilations{range_start=a,range_end=0x500000,limit=100}).decompilations
 local failed,completed=false,false
 for _,d in ipairs(records) do
  assert(type(d.locals)=='table' and type(d.tokens)=='table' and d.is_fallback==false)
  if d.function_entry_address==assert(gh.u64(a)) then assert(d.completed); completed=true end
  if d.function_entry_address==assert(gh.u64(0x500000)) then assert(not d.completed and #d.error_message>0); failed=true end
 end
 assert(failed and completed)
 assert(must(n:shutdown{policy='discard'}).accepted)
 local r,e=s:get_function(a); assert(not r and e.code=='NO_PROGRAM')
 must(n:open_program(program)); assert(must(s:read_bytes(a,4))=='\xf3\x0f\x1e\xfa')
end
print('M4 full operation negative/default/field/lifecycle contract PASS')
