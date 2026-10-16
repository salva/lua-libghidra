-- MIT Copyright 2026 Salvador Fandiño.
-- Installed-only M2 regression, with authored expectations, no Python oracle.
local prefix, root = assert(arg[1]), assert(arg[2])
package.path=prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath=prefix..'/lib/lua/5.4/?.so'
local gh, low=require('libghidra'),require('libghidra.lowlevel')
local check, u=gh.check, gh.u64
local address=check(u(0x401106))
local function rejects(value,err,code) assert(value==nil and err.code==(code or 'INVALID_ARGUMENT')) end
for _,project in ipairs{false,true} do
 local program={program_path=root..'/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
 if project then program.project_path=root..'/tests/fixtures/project/authored.gpr' end
 local session <close>, err, opened=gh.open{program=program}
 assert(session,err and err.message)
 local owner=session:native()
 -- Native binary loading does not eagerly discover functions. Decompilation
 -- materializes them; preserve the initial optional/empty result faithfully.
 if not project then
  assert(check(owner:get_function(address))['function']==nil)
  assert(#check(owner:list_functions{}).functions==0)
 end
 for _,a in ipairs{0x401106,0x40111f,0x40113c} do
  local d=check(owner:get_decompilation(a)).decompilation
  assert(d.completed and not d.is_fallback)
 end
 local historical=opened.program_name
 assert(type(opened.has_entry_point)=='boolean' and opened.image_base:hex())
 for _,view in ipairs{owner,session} do
  assert(check(view:get_status()).ok and #check(view:get_capabilities())>0)
  local f=check(view:get_function(address))
  if view==owner then f=f['function'] end
  assert(f.entry_address==address and f.start_address:hex() and f.end_address:hex() and f.size:hex())
  assert(type(f.name)=='string' and type(f.is_thunk)=='boolean' and math.type(f.parameter_count)=='integer')
  local inst=check(view:get_instruction(address)); if view==owner then inst=inst.instruction end
  assert(inst.length==4 and inst.address==address and inst.mnemonic:lower()=='endbr64')
  local bytes=check(view:read_bytes(address,4)); if view==owner then bytes=bytes.data end
  assert(bytes=='\xf3\x0f\x1e\xfa')
  for _,end_value in ipairs{0,check(u(0)),check(u('18446744073709551615'))} do
   local functions=check(view:list_functions{range_start=address,range_end=end_value,limit=2}).functions
   assert(#functions==2 and functions[1].entry_address==address)
   local instructions=check(view:list_instructions{range_start=address,range_end=end_value,limit=2}).instructions
   assert(#instructions==2 and instructions[1].length==4)
  end
  assert(#check(view:list_instructions{range_start=address,range_end=address,limit=2}).instructions==1)
  assert(#check(view:list_instructions{range_start=0,limit=2}).instructions==0)
  assert(#check(view:list_functions{range_start=address,range_end=address}).functions==1)
  assert(#check(view:list_functions{range_start=address,limit=2}).functions==2)
  for _,size in ipairs{2147483648,4294967295} do
   local v,e=view:read_bytes(address,size); rejects(v,e)
  end
  for _,page in ipairs{{limit=0},{offset=2147483647,limit=1},{range_start=2,range_end=1},{unexpected=true}} do
   local v,e=view:list_functions(page); rejects(v,e)
   v,e=view:list_instructions(page); rejects(v,e)
  end
  local dec=check(view:get_decompilation(address)); if view==owner then dec=dec.decompilation end
  assert(dec.completed and not dec.is_fallback and dec.pseudocode:find('* 3 + 7',1,true))
  assert(dec.function_entry_address==address and type(dec.locals)=='table' and type(dec.tokens)=='table')
  for _,v in ipairs(dec.locals) do assert(math.type(v.ordinal)=='integer' and type(v.kind)=='string') end
  for _,v in ipairs(dec.tokens) do assert(math.type(v.line_number)=='integer' and math.type(v.column_offset)=='integer') end
 end
 local fn,_,env=session:get_function(address); assert(fn==env['function'])
 local missing,e,response=session:get_function(check(u('18446744073709551615')))
 rejects(missing,e,'NOT_FOUND'); assert(response['function']==nil)
 local v,e=session:get_decompilation(address,{timeout_ms=1}); rejects(v,e)
 local all=check(owner:list_functions{limit=100}).functions
 local iter=session:iter_functions{page_size=2}
 for _,f in ipairs(all) do assert(iter().entry_address==f.entry_address) end
 assert(iter()==nil and iter()==nil)
 local stale=session:iter_functions{page_size=2}; assert(stale())
 assert(check(owner:close_program{policy='discard'}).closed)
 local v,e=session:get_function(address); rejects(v,e,'NO_PROGRAM')
 assert(check(session:get_status()).ok)
 local second,e=low.local_client(); rejects(second,e,'CLIENT_IN_USE')
 check(owner:open_program(program)); check(session:get_decompilation(address)); assert(check(session:get_function(address)))
 local ok,e=pcall(stale); assert(not ok and e.code=='ITERATOR_INVALIDATED')
 assert(opened.program_name==historical)
 check(session:close_program{policy='discard'})
 local v,e=owner:get_instruction(address); rejects(v,e,'NO_PROGRAM')
 check(session:close()); local v,e=owner:get_status(); rejects(v,e,'CLOSED')
 local replacement <close> = check(low.local_client())
 assert(opened.program_name==historical)
 print('M2 installed real '..(project and 'project' or 'binary')..' both surfaces PASS')
end
