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
 local original
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
  local locals=must(n:get_decompilation(a)).decompilation.locals
  for _,l in ipairs(locals) do if l.kind=='local' then
   assert(must(n:rename_function_local(a,l.local_id,'persist_local')).updated); break
  end end
  assert(must(n:set_comment(a,'eol','m4-persist-comment')).updated)
  assert(must(n:apply_data_type(data,'int')).updated)
  assert(must(n:rename_data_item(data,'m4_persist_data')).updated)
  assert(must(n:add_perf_benchmark{bench_id='persist-bench',cold_ms_p50=1.25}).added)
  assert(must(n:patch_bytes_batch{{address=data,data='Q\0RS'}}).bytes_written==4)
  assert(must(n:save_program()).saved)
  assert(must(n:discard_program()).discarded)
  assert(must(n:read_bytes(data,4)).data=='Q\0RS')
  assert(must(n:shutdown{policy='save'}).accepted)
 end
 do
  local s <close> =open(); local n=s:native()
  local struct=must(n:get_type('M4PersistStruct')).type
  assert(struct and struct.kind=='struct' and struct.length==0)
  assert(not must(n:get_type('M4PersistAlias')).type)
  assert(not must(n:get_type('M4PersistEnum')).type)
  assert(#must(n:list_type_members('M4PersistStruct')).members==0)
  assert(#must(n:list_type_enum_members('M4PersistEnum')).members==0)
  assert(#must(n:list_type_aliases('M4PersistAlias')).aliases==0)
  assert(#must(n:get_comments{range_start=a,range_end=a}).comments==0)
  assert(#must(n:list_data_items{range_start=data,range_end=data+3}).data_items==0)
  local sig=must(n:get_function_signature(a)).signature
  assert(sig and not sig.prototype:find('persist',1,true))
  assert(#must(n:list_perf_benchmarks()).records==0)
  assert(must(n:read_bytes(data,4)).data==original)
  local d=must(n:get_decompilation(a)).decompilation
  assert(d.completed)
  for _,l in ipairs(d.locals) do assert(l.name~='persist_local' and l.name~='persist_parameter') end
  print('M4 persistence '..profile..' limited reload: struct shell only; other new categories absent/reset PASS')
 end
end
