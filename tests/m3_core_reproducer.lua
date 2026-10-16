-- MIT Copyright 2026 Salvador Fandiño.
-- Red-node M3 coverage reproducer. Uses installed real native module; no mocks.
local prefix, root = assert(arg[1]), assert(arg[2])
package.path = prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath = prefix..'/lib/lua/5.4/?.so'
local low, gh = require('libghidra.lowlevel'), require('libghidra')
-- docs/development/COVERAGE.md core rows, including already implemented GetRevision.
local core = {
  'save_program','discard_program','get_revision','rename_function',
  'list_basic_blocks','list_cfg_edges','get_symbol','list_symbols','rename_symbol',
  'list_xrefs','list_memory_blocks','write_bytes','get_type','list_types',
  'list_type_aliases','list_type_unions','list_type_enums','list_type_enum_members',
  'list_type_members','get_function_signature','list_function_signatures',
  'get_comments','list_defined_strings',
}
local gaps = 0
local function inspect(label, view)
  local missing = {}
  for _, name in ipairs(core) do
    if type(view[name]) ~= 'function' then missing[#missing+1] = name end
  end
  gaps = gaps + #missing
  print(('GAP %s: %d/%d core methods absent: %s'):format(
    label, #missing, #core, table.concat(missing, ', ')))
end
for _, project in ipairs{false,true} do
  local program = {program_path=root..'/tests/fixtures/inputs/authored.elf',
    language_id='x86:LE:64:default', compiler_spec_id='gcc'}
  if project then program.project_path=root..'/tests/fixtures/project/authored.gpr' end
  local label = project and 'project' or 'binary'
  do
    local client <close> = assert(low.local_client{})
    inspect(label..'/lowlevel/unloaded',client)
    local absent, err = client:read_bytes(0x401106,4)
    assert(absent == nil and err.code == 'NO_PROGRAM')
    assert(client:open_program(program))
    assert(client:read_bytes(0x401106,4).data == '\xf3\x0f\x1e\xfa')
    assert(client:get_revision())
    inspect(label..'/lowlevel/loaded',client)
    assert(client:close_program{policy='discard'}.closed)
  end
  do
    local session <close>, err = gh.open{program=program}
    assert(session,err and err.message)
    assert(session:read_bytes(0x401106,4) == '\xf3\x0f\x1e\xfa')
    -- Explicit native() disposition must still expose the complete core tier.
    inspect(label..'/Session/native',session:native())
    -- SPEC section 4: facade must reject save-close with empty state_path.
    local result, failure = session:close_program{policy='save'}
    if result ~= nil or not failure or failure.code ~= 'NO_STATE_PATH' then
      gaps = gaps + 1
      print(('GAP %s/Session empty-state save-close: closed=%s error=%s; expected NO_STATE_PATH'):format(
        label,tostring(result and result.closed),tostring(failure and failure.code)))
    end
  end
  print('CONTROL '..label..' real loaded bytes/revision and unloaded NO_PROGRAM PASS')
end
assert(gaps == 0, ('M3 acceptance gaps: %d observations'):format(gaps))
