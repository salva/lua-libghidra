-- MIT Copyright 2026 Salvador Fandiño.
-- Installed core adapters: real native positives/errors and generation semantics.
local prefix,root=assert(arg[1]),assert(arg[2])
package.path=prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath=prefix..'/lib/lua/5.4/?.so'
local gh,low=require('libghidra'),require('libghidra.lowlevel')
local check=gh.check
local function reject(v,e,code) assert(v==nil and e.code==(code or 'INVALID_ARGUMENT'),e and e.message) end
for _,project in ipairs{false,true} do
 local program={program_path=root..'/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
 if project then program.project_path=root..'/tests/fixtures/project/authored.gpr' end
 local s <close> = check(gh.open{program=program})
 local n=s:native()
 for _,a in ipairs{0x401106,0x40111f,0x40113c} do assert(check(n:get_decompilation(a)).decompilation.completed) end
 local ranges={list_basic_blocks='blocks',list_cfg_edges='edges',list_symbols='symbols',list_xrefs='xrefs',list_function_signatures='signatures',get_comments='comments',list_defined_strings='strings'}
 for method,key in pairs(ranges) do
  local page=check(n[method](n,{limit=100}))
  assert(type(page[key])=='table')
  reject(n[method](n,{limit=0})); reject(n[method](n,{offset=2147483647,limit=1}))
  reject(n[method](n,{unknown=true}))
  assert(check(n[method](n,{range_start=0x401106,range_end=0,limit=1}))[key])
  assert(#check(n[method](n,{offset=1000000,limit=1}))[key]==0)
  print((project and 'project' or 'ELF')..' '..method..' records='..#page[key])
 end
 assert(#check(n:list_defined_strings{}).strings==0)
 local blocks=check(s:list_basic_blocks{limit=100}).blocks
 assert(#blocks>0 and blocks[1].function_entry:hex() and blocks[1].in_degree>=0)
 local symbols=check(s:list_symbols{limit=100}).symbols
 assert(#symbols>0 and type(symbols[1].is_primary)=='boolean' and symbols[1].symbol_id:hex())
 local symbol=check(s:get_symbol(symbols[1].address))
 assert(symbol.address==symbols[1].address)
 local mem=check(s:list_memory_blocks{limit=100}).blocks
 assert(#mem>0 and mem[1].size:hex() and type(mem[1].is_execute)=='boolean')
 reject(n:list_memory_blocks{range_start=1})
 local types=check(s:list_types('',{limit=100})).types
 assert(#types>0)
 local t=check(s:get_type(types[1].name)); assert(t.type_id:hex())
 local typepages={list_types='types',list_type_aliases='aliases',list_type_unions='unions',list_type_enums='enums',list_type_enum_members='members',list_type_members='members'}
 for method,key in pairs(typepages) do
  local text=(method=='list_type_enum_members' or method=='list_type_members') and 'missing_type' or ''
  assert(type(check(n[method](n,text,{limit=1}))[key])=='table')
  reject(n[method](n,text,{limit=2147483647,offset=1}))
  reject(n[method](n,text,{range_start=1})); reject(n[method](n,false))
 end
 local signature,err,envelope=s:get_function_signature(0x401106)
 assert(signature and signature==envelope.signature and signature.function_entry_address:hex(),err and err.message)
 local iter=s:iter_functions{page_size=2}; assert(iter())
 local gen=n:_generation()
 reject(n:rename_function(false,'bad')); assert(n:_generation_matches(gen))
 local r=check(s:rename_function(0x401106,'m3_renamed'))
 assert(r.renamed and r.name=='m3_renamed' and not n:_generation_matches(gen))
 local ok,e=pcall(iter); assert(not ok and e.code=='ITERATOR_INVALIDATED')
 r=check(s:rename_symbol(symbols[1].address,'m3_symbol')); assert(r.renamed and r.name=='m3_symbol')
 local original=check(s:read_bytes(0x404010,3))
 r=check(s:write_bytes(0x404010,'a\0b')); assert(r.bytes_written==3)
 assert(check(s:read_bytes(0x404010,3))=='a\0b')
 assert(check(n:discard_program()).discarded)
 assert(check(s:read_bytes(0x404010,3))=='a\0b') -- discard is not rollback
 -- facade rejection is pre-dispatch and does not invalidate.
 gen=n:_generation(); local v,e=s:close_program{policy='save'}; reject(v,e,'NO_STATE_PATH'); assert(n:_generation_matches(gen))
 local v,e=n:save_program(); reject(v,e,'NO_STATE_PATH'); assert(e.backend=='local')
 assert(check(n:close_program{policy='save'}).closed) -- faithful native empty-path behavior
 for method in pairs(ranges) do local v,e=n[method](n,{}); reject(v,e,'NO_PROGRAM') end
 local v,e=n:get_symbol(0x401106); reject(v,e,'NO_PROGRAM')
 assert(check(n:discard_program()).discarded) -- native no-op also when unloaded
 s:close(); local v,e=s:close_program{policy='save'}; reject(v,e,'CLOSED')
end
print('M3 core real adapters PASS')
