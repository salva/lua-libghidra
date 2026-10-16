-- MIT Copyright 2026 Salvador Fandiño.
package.path='scripts/?.lua;'..package.path
local U,S,F=require'tool_util',require'inventory_source',require'inventory_fields'
local d=require('tool_json').decode(U.read'api/coverage.json')
local function field(model,name) for _,f in ipairs(d.types[model].fields) do if f.name==name then return f end end error(name) end
assert(field('RevisionResponse','file_version').lua=='checked Lua integer (std::int32_t)')
assert(field('RevisionResponse','program_id').lua=='exact UInt64')
assert(field('ReadBytesResponse','data').lua=='binary Lua string (length preserving)')
assert(field('GetDecompilationResponse','decompilation').lua=='optional table model DecompilationRecord (absence=nil)')
assert(field('DecompilationRecord','locals').lua=='dense 1-based array of table model DecompileLocalRecord')
assert(field('DecompileTokenRecord','kind').lua:find('"const"',1,true))
assert(field('DecompileLocalRecord','kind').lua:find('"param"',1,true))
assert(field('CommentRecord','kind').lua:find('unknown values remain Lua integers',1,true))
assert(d.types.GetPcodeResponse.lua_scope=='native-only' and d.types.PcodeRecord.lua_scope=='native-only')
assert(d.enums.PcodeMaturity.lua_scope=='native-only')
assert(d.types.DecompileTokenRecord.lua_scope=='included') -- reachable even though producer never fills tokens
assert(not pcall(S.lua,'MissingRecord',d))
assert(not pcall(F.classify,{types={Ambiguous={fields={}}},enums={Ambiguous={}}}))
assert(not pcall(S.lua,'std::optional<std::vector<MissingEnum>>',d))
local fake={types={Outer={fields={{native_type='std::optional<std::vector<Inner>>'}}},Inner={fields={}},Unused={fields={}}},enums={},operations={{tier='core',response={native_type='Outer'},request={}}}}
F.reachability(fake); assert(fake.types.Inner.lua_scope=='included'); assert(fake.types.Unused.lua_scope=='native-only')
local text=U.read'api/FIELDS.md'
assert(text:find('[DecompilationRecord](#decompilationrecord)',1,true))
assert(text:find('Native-only schema; no supported Lua conversion claim.',1,true))
assert(not text:find('table/enum',1,true) and not text:find('M3-CORE',1,true))
-- Guard explicit public enum spelling mappings against converter drift.
for _,item in ipairs{{'src/slice_convert.hpp','DecompileLocalKind'},{'src/slice_convert.hpp','DecompileTokenKind'},{'src/core_convert.hpp','CommentKind'}} do
 local source=U.read(item[1]); local quoted={}
 for _,n in ipairs(F.enums[item[2]]) do quoted[#quoted+1]='"'..n..'"' end
 assert(source:find('{'..table.concat(quoted,',')..'}',1,true),'converter spellings changed: '..item[2])
 assert(source:find('else lua_pushinteger(L,int(v.kind))',1,true),'numeric fallback changed')
end
U.run{'lua5.4','scripts/render-fields.lua','--check'}
print('Field scalar/model/enum, recursive reachability, native-only, converter spelling/fallback and fresh rendering PASS')
