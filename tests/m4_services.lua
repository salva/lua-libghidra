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
 local leaves,e=n:list_leaf_functions{limit=100}
 if project then assert(leaves and #leaves.functions>0) else assert(not leaves and e.code=='NOT_SUPPORTED') end
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
 local members=must(n:list_type_members('M4Struct')).members
 assert(#members==1 and members[1].size:to_integer()==4)
 assert(must(n:rename_type_member('M4Struct',0,'y')).updated)
 assert(must(n:set_type_member_type('M4Struct',0,'char')).updated)
 assert(must(n:set_type_member_comment('M4Struct',0,'note\0tail')).updated)
 assert(must(n:delete_type_member('M4Struct',0)).deleted)
 assert(must(n:rename_type('M4Struct','M4Renamed')).updated)
 assert(must(n:delete_type('M4Renamed')).deleted)
 assert(must(n:create_type_alias('M4Alias','int')).updated)
 assert(must(n:set_type_alias_target('M4Alias','char')).updated)
 assert(must(n:delete_type_alias('M4Alias')).deleted)
 assert(must(n:create_type_enum('M4Enum',123,false)).updated)
 local enum=must(n:get_type('M4Enum')).type; assert(enum and enum.length~=123)
 assert(must(n:add_type_enum_member('M4Enum','zero',0)).updated)
 assert(must(n:rename_type_enum_member('M4Enum',0,'renamed')).updated)
 assert(must(n:set_type_enum_member_value('M4Enum',0,7)).updated)
 assert(must(n:set_type_enum_member_comment('M4Enum',0,'enum\0comment')).updated)
 assert(must(n:delete_type_enum_member('M4Enum',0)).deleted)
 local sig=must(n:set_function_signature(a,'int native_smoke(int value)'))
 assert(sig.updated and sig.prototype=='int native_smoke(int value)' and sig.function_name=='')
 assert(must(n:rename_function_parameter(a,0,'input')).name=='input')
 assert(must(n:set_function_parameter_type(a,0,'int')).data_type=='int')
 local locals=must(n:get_decompilation(a)).decompilation.locals
 assert(#locals>0)
 local local_id=locals[1].local_id
 assert(must(n:rename_function_local(a,local_id,'m4local')).local_id==local_id)
 assert(must(n:set_function_local_type(a,local_id,'int')).data_type=='int')
 bad(n:rename_function_parameter(a,-1,'bad'))
 assert(must(n:apply_data_type(0x404010,'int')).updated)
 local items=must(n:list_data_items{range_start=0x404010,range_end=0}).data_items
 assert(#items>0 and items[1].address:hex() and items[1].size:hex())
 assert(must(n:rename_data_item(0x404010,'m4data')).name=='m4data')
 assert(must(n:delete_data_item(0x404010)).deleted)
 must(n:apply_data_type(0x404010,'int'))
 local deleted=must(n:delete_symbol(0x404010,'mismatched ignored name'))
 assert(deleted.deleted and deleted.deleted_count==1)
 assert(must(n:set_comment(a,'eol','hello\0world')).updated)
 local comments=must(n:get_comments{range_start=a,range_end=a}).comments
 assert(#comments>0)
 assert(must(n:delete_comment(a,'eol')).deleted)
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
 assert(#records==1 and records[1].cold_ms_p50==0 and records[1].warm_ms_p95==2.5 and records[1].regression_pct==-1)
 bad(n:add_perf_benchmark{bench_id='invalid',cold_ms_p50=0/0})
 assert(must(n:delete_perf_benchmark('m4')).deleted)
 assert(must(n:clear_perf_benchmarks()).removed_count==0)
 print('M4 service batch '..(project and 'project' or 'binary')..' PASS')
end
