-- MIT Copyright 2026 Salvador Fandiño.
-- M4 red baseline: installed real Lua/native surface, not mock support evidence.
local prefix, root = assert(arg[1]), assert(arg[2])
package.path = prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath = prefix..'/lib/lua/5.4/?.so'
local low, gh = require('libghidra.lowlevel'), require('libghidra')
local full = {
  'list_decompilations','list_leaf_functions','delete_symbol',
  'create_type','delete_type','rename_type','create_type_alias','delete_type_alias',
  'set_type_alias_target','create_type_enum','add_type_enum_member',
  'delete_type_enum_member','rename_type_enum_member','set_type_enum_member_value',
  'set_type_enum_member_comment','add_type_member','delete_type_member',
  'rename_type_member','set_type_member_type','set_type_member_comment',
  'set_function_signature','rename_function_parameter','set_function_parameter_type',
  'rename_function_local','set_function_local_type','apply_data_type',
  'set_comment','delete_comment','list_data_items','rename_data_item','delete_data_item',
  'patch_bytes_batch','add_perf_benchmark','list_perf_benchmarks',
  'clear_perf_benchmarks','delete_perf_benchmark','shutdown',
}
local gaps = 0
local function inspect(label, view)
  local missing = {}
  for _, name in ipairs(full) do
    if type(view[name]) ~= 'function' then missing[#missing+1] = name end
  end
  gaps = gaps + #missing
  print(('SURFACE %s: %d/%d absent: %s'):format(label,#missing,#full,table.concat(missing,', ')))
end
local function unloaded(view)
  local r,e = view:read_bytes(0x401106,4)
  assert(r == nil and e.code == 'NO_PROGRAM' and e.backend == 'local')
end
for _, project in ipairs{false,true} do
  local program = {program_path=root..'/tests/fixtures/inputs/authored.elf',
    language_id='x86:LE:64:default', compiler_spec_id='gcc'}
  if project then program.project_path=root..'/tests/fixtures/project/authored.gpr' end
  local label = project and 'project' or 'binary'
  do
    local client <close> = assert(low.local_client{})
    inspect(label..'/lowlevel/unloaded',client)
    unloaded(client)
    assert(client:open_program(program))
    assert(client:read_bytes(0x401106,4).data == '\xf3\x0f\x1e\xfa')
    inspect(label..'/lowlevel/loaded',client)
    assert(client:close_program{policy='discard'}.closed)
  end
  do
    local session <close>, err = gh.open{program=program}
    assert(session,err and err.message)
    assert(session:read_bytes(0x401106,4) == '\xf3\x0f\x1e\xfa')
    inspect(label..'/Session/native',session:native())
    -- Shutdown already exists: distinguish logical closure from owner release.
    assert(session:native():shutdown{policy='discard'}.accepted)
    unloaded(session:native())
    assert(session:get_status())
    assert(session:native():open_program(program))
    assert(session:read_bytes(0x401106,4) == '\xf3\x0f\x1e\xfa')
  end
  print('CONTROL '..label..' real bytes, NO_PROGRAM, shutdown/status/reopen PASS')
end
assert(gaps == 0, ('M4 missing-method observations: %d'):format(gaps))
