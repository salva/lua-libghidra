-- Red-only focused M2 surface check; no mock or Python oracle.
local prefix, root = assert(arg[1]), assert(arg[2])
package.path = prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath = prefix..'/lib/lua/5.4/?.so'
local low, gh = require('libghidra.lowlevel'), require('libghidra')
local missing = 0
local function surface(label, view, iterator)
  local names={'get_function','list_functions','get_instruction','list_instructions','get_decompilation'}
  if iterator then names[#names+1]='iter_functions' end
  for _,name in ipairs(names) do
    if type(view[name])~='function' then
      missing=missing+1; print('GAP '..label..':'..name..' absent')
    end
  end
end
for _,project in ipairs{false,true} do
  local program={program_path=root..'/tests/fixtures/inputs/authored.elf',
    language_id='x86:LE:64:default',compiler_spec_id='gcc'}
  if project then program.project_path=root..'/tests/fixtures/project/authored.gpr' end
  local label=project and 'project' or 'binary'
  do
    local client <close> = assert(low.local_client{})
    local opened=assert(client:open_program(program))
    assert(type(opened.has_entry_point)=='boolean')
    assert(client:read_bytes(0x401106,4).data=='\xf3\x0f\x1e\xfa')
    assert(client:get_status().ok and #client:get_capabilities()>0)
    surface(label..'/lowlevel',client,false)
    assert(client:close_program{policy='discard'}.closed)
  end
  do
    local session <close>, err, opened = gh.open{program=program}
    assert(session,err and err.message)
    assert(type(opened.has_entry_point)=='boolean')
    local bytes,e,envelope=session:read_bytes(0x401106,4)
    assert(bytes=='\xf3\x0f\x1e\xfa' and e==nil and envelope.data==bytes)
    surface(label..'/Session',session,true)
    assert(session:close_program{policy='discard'}.closed)
  end
  print('CONTROL '..label..' installed real open/known bytes/status/close PASS')
end
assert(missing==0, ('M2 missing required methods: %d observations'):format(missing))
