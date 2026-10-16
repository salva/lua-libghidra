-- MIT Copyright 2026 Salvador Fandiño.
local ghidra=require('libghidra')
local fixture=require('fixture_manifest')
local check=ghidra.check
local address=check(ghidra.u64(fixture.function_address))
local alias,metadata
 do
 local session <close>,opened=check(ghidra.open{
  client={ghidra_root=fixture.spec_root,pool_size=1},
  program={program_path=fixture.binary_path,project_path=fixture.project_path,
   language_id=fixture.language_id,compiler_spec_id=fixture.compiler_spec_id},
 })
 metadata=opened; alias=session:native()
 print(opened.program_name,opened.has_entry_point,opened.entry_point:hex())
 local dec,env=check(session:get_decompilation(address))
 assert(dec==env.decompilation and dec.completed and not dec.is_fallback)
 assert(dec.pseudocode:find('* 3 + 7',1,true))
 local fn,response=check(session:get_function(address)); assert(fn==response['function'])
 local bytes,response=check(session:read_bytes(address,16)); assert(bytes==response.data)
 assert(bytes:sub(1,4)=='\xf3\x0f\x1e\xfa')
 for _,record in ipairs(check(session:list_functions{limit=2}).functions) do print(record.name) end
 assert(#check(session:list_instructions{range_start=address,range_end=0,limit=2}).instructions==2)
 local iter=session:iter_functions{page_size=2}
 for record in iter do print(record.entry_address:hex(),record.name) end
 check(alias:close_program{policy='discard'})
 local value,err=session:get_function(address); assert(value==nil and err.code=='NO_PROGRAM')
 check(alias:get_status())
 check(alias:open_program{program_path=fixture.binary_path,project_path=fixture.project_path,
  language_id=fixture.language_id,compiler_spec_id=fixture.compiler_spec_id})
 check(session:get_decompilation(address)); check(session:get_function(address))
 local ok,err=pcall(iter); assert(not ok and err.code=='ITERATOR_INVALIDATED')
 check(session:close_program{policy='discard'})
 end
local status,err=alias:get_status(); assert(status==nil and err.code=='CLOSED')
print(metadata.program_name)
