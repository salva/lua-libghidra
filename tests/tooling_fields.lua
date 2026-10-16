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
-- Exercise the owning renderer, not a parallel classification implementation.
local R=require('render-fields')
local groups=R.partition(d)
local seen,total={},0
for i,names in ipairs(groups) do
 local previous
 for _,name in ipairs(names) do
  assert(not seen[name] and (not previous or previous<name),'partition duplicate/order')
  seen[name]=i; previous=name; total=total+1
 end
end
local expected=0
for name in pairs(d.types) do expected=expected+1; assert(seen[name]) end
for name in pairs(d.enums) do expected=expected+1; assert(seen[name]) end
assert(total==expected)
assert(seen.HealthStatus==1 and seen.Capability==1 and seen.BytePatch==2)
assert(seen.LocalClientOptions==2 and seen.PcodeRecord==5 and seen.PcodeMaturity==6)
local actual={}
for name in text:gmatch('\n### ([%w_]+)\n') do
 assert(not actual[name],'duplicate rendered model'); actual[name]=true
end
for name in pairs(seen) do assert(actual[name],'missing rendered model '..name) end
local cursor=1
for _,names in ipairs(groups) do
 for _,name in ipairs(names) do
  local start,finish=text:find('\n### '..name..'\n',cursor,true)
  assert(start,'rendered partition order '..name); cursor=finish+1
  assert(text:find('['..name..'](#'..name:lower()..')',1,true),'missing index '..name)
 end
end
-- Nested model and enum links must all resolve to unique emitted headings.
for target in text:gmatch('%]%(%#([%w_]+)%)') do
 local found=false
 for name in pairs(actual) do if name:lower()==target then found=true end end
 assert(found,'broken nested/index link '..target)
end
local function reject(change,needle)
 local copy=require('tool_json').decode(U.read'api/coverage.json')
 change(copy)
 local ok,err=pcall(R.render,copy)
 assert(not ok and tostring(err):find(needle,1,true),tostring(err))
end
reject(function(c) c.types.FunctionRecord.lua_scope='unknown' end,'unknown scope')
reject(function(c) c.enums.CommentKind.lua_scope=nil end,'unknown scope')
reject(function(c) c.types.Unassigned={lua_scope='included'} end,'unassigned included model')
reject(function(c) c.enums.FunctionRecord={lua_scope='included'} end,'duplicate model')
reject(function(c) c.types.HealthStatus.lua_scope='native-only' end,'wrong exception partition')
reject(function(c) c.types.Capability=nil end,'wrong exception partition')
reject(function(c) c.types.BytePatch.lua_scope='native-only' end,'wrong exception partition')
local copy=require('tool_json').decode(U.read'api/coverage.json')
copy.types.NativeLookingRecord={lua_scope='native-only',fields={},operation_reachability='test only'}
copy.enums.NativeLookingEnum={lua_scope='native-only',values='test',operation_reachability='test only'}
local native=R.partition(copy)
local function contains(names,name) for _,n in ipairs(names) do if n==name then return true end end end
assert(contains(native[5],'NativeLookingRecord') and contains(native[6],'NativeLookingEnum'))
-- Freshness comparison is exact; field changes cannot retain old output.
copy=require('tool_json').decode(U.read'api/coverage.json')
copy.types.FunctionRecord.fields[1].native_default='sensitivity marker'
assert(R.render(copy)~=text,'field change must invalidate freshness')
print('Scope-first exhaustive renderer partition, exceptions, ordered index, nested links and rejection sensitivity PASS')
