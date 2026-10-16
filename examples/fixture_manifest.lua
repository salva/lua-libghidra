-- MIT Copyright 2026 Salvador Fandiño.
-- Test data only. Caller supplies the checkout containing locked fixture bytes.
local root=assert(os.getenv('LIBGHIDRA_FIXTURE_ROOT'),'set LIBGHIDRA_FIXTURE_ROOT')
return {
 binary_path=root..'/tests/fixtures/inputs/authored.elf',
 project_path=root..'/tests/fixtures/project/authored.gpr',
 spec_root='', language_id='x86:LE:64:default', compiler_spec_id='gcc',
 function_address='0x401106', absent_function_address='18446744073709551615',
}
