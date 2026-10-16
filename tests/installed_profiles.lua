-- MIT Copyright 2026 Salvador Fandiño.
-- Installed-only constructor profile: real ELF + analyzed database semantics.
local prefix, root = assert(arg[1]), assert(arg[2])
package.path=prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath=prefix..'/lib/lua/5.4/?.so'
local low=require('libghidra.lowlevel')
local spec=assert(os.getenv('LLG_PROFILE_ROOT')) -- empty explicitly selects embedded
local expect=os.getenv('LLG_PROFILE_EXPECT') or 'success'
local function check(v,e) assert(v,e and (e.code..': '..e.message)); return v end
local owner,e=low.local_client{ghidra_root=spec}
if not owner then
 assert(expect=='failure' and spec=='',e and e.message)
 assert(e.backend=='local' or e.backend=='binding')
 assert(e.message:lower():find('spec',1,true), e.message)
 print('expected constructor failure',e.code,e.message); return
end
local success=false
for _,project in ipairs{false,true} do
 local p={program_path=root..'/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
 if project then p.project_path=root..'/tests/fixtures/project/authored.gpr' end
 local opened,err=owner:open_program(p)
 if not opened then
  assert(expect=='failure',err and err.message)
  assert(err.code=='LOAD_FAILED' and err.backend=='local')
  assert(err.message:find('No sleigh specification',1,true),err.message)
  print('expected open failure',err.code,err.message)
 else
  assert(expect=='success','unexpected open success')
  local bytes=check(owner:read_bytes(0x401106,4)).data
  assert(bytes=='\xf3\x0f\x1e\xfa')
  local d=check(owner:get_decompilation(0x401106)).decompilation
  assert(d.completed and not d.is_fallback)
  -- Authored arithmetic, not merely nonempty pseudocode.
  local code=d.pseudocode
  assert(type(code)=='string', 'missing decompilation code')
  assert(code:find('* 3',1,true) and code:find('+ 7',1,true),code)
  print(project and 'project' or 'ELF','completed/nonfallback arithmetic and exact bytes PASS')
  success=true
  check(owner:close_program{policy='discard'})
 end
end
check(owner:close())
assert(success==(expect=='success'))
print('installed constructor profile',spec=='' and 'embedded' or 'external',expect,'PASS')
