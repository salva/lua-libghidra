-- MIT Copyright 2026 Salvador Fandiño. Native extraction migration regressions.
package.path='scripts/?.lua;'..package.path
local U,J,S=require('tool_util'),require('tool_json'),require('inventory_source')
local source=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local ledger=J.decode(U.read('api/coverage.json'))
local function reject(f,needle) local ok,e=pcall(f); assert(not ok and tostring(e):find(needle,1,true),tostring(e)) end
local raw='void caller() { helper(x); if(x) { wrong(); } }\n// helper(int x) {decoy}\nvoid helper(int x) { const char* s="}"; /* } */ const char* r=R"tag({ } })tag"; if(x) { run(); } }'
local _,body=S.body(raw,'helper('); assert(body:match('if%(x%) { run%(%)%; } }$'))
reject(function() S.body('void caller() { helper(x); if(x) { wrong(); } }','helper(') end,'expected one')
reject(function() S.body('void helper() {} void helper() {}','helper(') end,'expected one')
reject(function() S.body('void helper() {','helper(') end,'unbalanced')
assert(#S.mask(raw,true)==#raw)
assert(#S.split('const std::vector<std::pair<int, int>>& x, int y')==2)
local types,enums,declarations={},{},{}
for path in U.capture{'find',source..'/cpp/include/libghidra','-maxdepth','1','-name','*.hpp','-type','f'}:gmatch('[^\n]+') do
 local rel=path:sub(#source+2); local t,e,d=S.header(rel,U.read(path))
 for name,v in pairs(t) do assert(not types[name]); types[name]=v end
 for name,v in pairs(e) do assert(not enums[name]); enums[name]=v end
 for name,v in pairs(d) do assert(not declarations[name]); declarations[name]=v end
end
local n,fields=0,0
for name,t in pairs(types) do
 n=n+1; local expected=assert(ledger.types[name],'unexpected type '..name)
 assert(#t.fields==#expected.fields,'field count '..name)
 for i,f in ipairs(t.fields) do
  fields=fields+1
  for _,k in ipairs{'name','native_type','native_default','optional','lua'} do assert(f[k]==expected.fields[i][k],name..'.'..f.name..' '..k) end
 end
 assert(t.source.path==expected.source.path and t.source.line==expected.source.line,'type citation '..name)
end
assert(n==160 and fields==466)
local operations={}; for _,op in ipairs(ledger.operations) do operations[op.name]=op end
local count=0
for name,d in pairs(declarations) do
 count=count+1; local op=assert(operations[name]); local expected=op.declaration
 assert(d.response_type==expected.response_type and d.arguments==expected.arguments,'declaration '..name)
 assert(d.source.path==expected.source.path and d.source.line==expected.source.line,'declaration citation '..name)
end
assert(count==110)
local impl=S.implementations('cpp/src/local_client.cpp',U.read(source..'/cpp/src/local_client.cpp'))
count=0; for name in pairs(impl) do count=count+1; assert(declarations[name],'unknown implementation') end; assert(count==70)
for name,e in pairs(enums) do assert(e.values==ledger.enums[name].values,'enum '..name) end
local _,_,changed=S.header('test.hpp','virtual StatusOr<Changed> GetFunction(int x) = 0;')
assert(changed.GetFunction.response_type=='Changed','mutation not extracted')
reject(function() S.header('test.hpp','struct Bad { int (*callback)();\n};') end,'unparsed field')
print('Lua native extraction: 160 types/466 fields/110 declarations/70 overrides, citations, lexer and corruption PASS')
local C=require('inventory_completeness')
assert(C.validate(ledger).expanded_response_paths==345)
local function clone(v)
 if v==J.null then return v end
 if type(v)~='table' then return v end
 local t={}; for k,x in pairs(v) do t[k]=clone(x) end; return t
end
for _,kind in ipairs{'response','direct','evidence','excluded'} do
 local d=clone(ledger); local op
 for _,v in ipairs(d.operations) do if v.name=='GetFunction' then op=v end end
 if kind=='response' then table.remove(op.response.fields)
 elseif kind=='direct' then op.request[1].direct_argument_review=nil
 elseif kind=='evidence' then op.evidence.positive.status='qualified'
 else for _,v in ipairs(d.operations) do if v.tier=='excluded' then v.surface_contract.lowlevel={call='invented()'}; break end end end
 reject(function() C.validate(d) end,'')
end
local native=clone(ledger); native.python=nil; native.python_reconciliation=nil
assert(C.validate(native).included_operations==70)
print('Lua cross-ledger expansions/counts/false-evidence/excluded-surface corruption and no Python research dependency PASS')
-- Regression: a StatusOr<T>::FromValue expression before another method must
-- never become part of that method's response type.
local methods=S.implementations('fixture.cpp',[[
StatusOr<A> First(int x) override { return StatusOr<A>::FromValue(x); }
StatusOr<B> Second(int) override { return StatusOr<B>::FromValue(0); }
]])
assert(methods.First.response_type=='A' and methods.Second.response_type=='B')
local assembled=require('inventory_native').inventory(source)
assert(assembled.sources['cpp/src/local_client.cpp']==U.hash(source..'/cpp/src/local_client.cpp'))
assert(assembled.implementations.ListLeafFunctions.response_type=='ListFunctionsResponse')
assert(assembled.implementations.DeleteTypeAlias.arguments:find('alias_name',1,true))
assert(assembled.implementations.ListDecompilations.arguments:match('int$'))
assert(assembled.python==nil and assembled.python_reconciliation==nil)
print('Native-only assembly/default closure/source hashes/return-expression regression PASS')
