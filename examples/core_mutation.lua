-- MIT Copyright 2026 Salvador Fandiño.
-- Only run on disposable inputs/state; caller supplies the locked fixture root.
local gh=require('libghidra')
local f=require('fixture_manifest')
local s <close> =gh.check(gh.open{program={program_path=f.binary_path,
 language_id=f.language_id,compiler_spec_id=f.compiler_spec_id}})
local address=gh.check(gh.u64(f.function_address))
assert(gh.check(s:get_decompilation(address)).completed)
local iterator=s:iter_functions{page_size=2}
assert(iterator())
assert(gh.check(s:native():rename_function(address,'fixture_renamed')).renamed)
local ok,e=pcall(iterator)
assert(not ok and e.code=='ITERATOR_INVALIDATED')
print('installed M3 native mutation/buffered invalidation PASS')
