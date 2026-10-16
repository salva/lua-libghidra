-- MIT Copyright 2026 Salvador Fandiño.
-- This host opens the real native client and seeds through native test-only calls.
local root=assert(arg[1])
package.path=root..'/lua/?.lua;'..root..'/lua/?/init.lua'
local gh=require('libghidra'); local check=gh.check
for _,project in ipairs{false,true} do
 local p={program_path=root..'/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
 if project then p.project_path=root..'/tests/fixtures/project/authored.gpr' end
 local s <close> =check(gh.open{program=p})
 local u=check(s:list_type_unions('M3',{limit=2})).unions
 assert(#u==0) -- native CreateType union is NOT_SUPPORTED (host asserts it)
 local a=check(s:list_type_aliases('M3',{limit=2})).aliases
 assert(#a==1 and a[1].name=='M3Alias' and a[1].path_name=='/M3Alias' and a[1].type_id:hex())
 local e=check(s:list_type_enums('M3',{limit=2})).enums
 assert(#e==1 and e[1].name=='M3Enum' and e[1].width:hex() and type(e[1].is_signed)=='boolean')
 local m=check(s:list_type_enum_members('M3Enum',{limit=2})).members
 assert(#m==1 and m[1].name=='ONE' and m[1].value==1 and m[1].ordinal:decimal()=='0')
 local m=check(s:list_type_members('M3Struct',{limit=2})).members
 assert(#m==1 and m[1].name=='field' and m[1].ordinal:decimal()=='0' and math.type(m[1].offset)=='integer')
 -- Exact/partial/end pages retain zero-based native ordinal semantics.
 for _,method in ipairs{'list_type_aliases','list_type_enums','list_type_enum_members','list_type_members'} do
  local query=method=='list_type_enum_members' and 'M3Enum' or method=='list_type_members' and 'M3Struct' or 'M3'
  local field=method=='list_type_aliases' and 'aliases' or method=='list_type_enums' and 'enums' or 'members'
  assert(#check(s[method](s,query,{limit=1,offset=0}))[field]==1)
  assert(#check(s[method](s,query,{limit=1,offset=1}))[field]==0)
 end
 local c=check(s:get_comments{range_start=0x401106,range_end=0x401106,limit=2}).comments
 assert(#c==1 and c[1].kind=='eol' and c[1].text=='native fixture comment')
 local sig=check(s:get_function_signature(0x401106))
 assert(sig.function_entry_address:hex()=='0x0000000000401106' and type(sig.parameters)=='table')
 for _,r in ipairs(sig.parameters) do assert(math.type(r.ordinal)=='integer' and type(r.is_auto_parameter)=='boolean') end
 print((project and 'project' or 'ELF')..' real native-seeded Lua populated aliases/enums/members/comments/signature PASS')
end

-- Reopen through real Lua with seeding explicitly OFF: never reseed lost data.
for _,project in ipairs{false,true} do
 local state=fixture_work..(project and '/project.xml' or '/elf.xml')
 os.remove(state)
 local p={program_path=root..'/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
 if project then p.project_path=root..'/tests/fixtures/project/authored.gpr' end
 set_fixture_seed(true)
 do
  local s <close> =check(gh.open{client={state_path=state},program=p})
  assert(#check(s:list_type_aliases('M3',{limit=10})).aliases==1)
  assert(#check(s:list_type_enums('M3',{limit=10})).enums==1)
  assert(#check(s:list_type_members('M3Struct',{limit=10})).members==1)
  assert(#check(s:list_type_enum_members('M3Enum',{limit=10})).members==1)
  assert(#check(s:get_comments{range_start=0x401106,range_end=0x401106}).comments==1)
  local sig=check(s:get_function_signature(0x401106));assert(#sig.parameters==1 and sig.parameters[1].name=='x')
  assert(check(s:save_program()).saved)
 end
 set_fixture_seed(false)
 do
  local s <close> =check(gh.open{client={state_path=state},program=p})
  assert(#check(s:list_type_aliases('M3',{limit=10})).aliases==0)
  assert(#check(s:list_type_enums('M3',{limit=10})).enums==0)
  assert(#check(s:list_type_members('M3Struct',{limit=10})).members==0)
  assert(#check(s:list_type_enum_members('M3Enum',{limit=10})).members==0)
  assert(#check(s:get_comments{range_start=0x401106,range_end=0x401106}).comments==0)
  -- GetFunctionSignature decompiles before extraction: observe its actual result,
  -- unlike the direct probe's immediate no-analysis restoration observation.
  local sig=check(s:get_function_signature(0x401106))
  assert(#sig.parameters==0 and sig.return_type=='void')
  print((project and 'project' or 'ELF')..' Lua save/reopen category loss; analyzed signature='..sig.prototype)
 end
 os.remove(state)
end
