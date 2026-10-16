-- MIT Copyright 2026 Salvador Fandiño. Native-only operation/field assembly.
local S,J=require('inventory_source'),require('tool_json')
local M={}
local null=J.null
local function copy(v) if type(v)~='table' then return v end; local t={}; for k,x in pairs(v) do t[k]=copy(x) end; return t end
local function base(t)
 t=S.norm(t:gsub('%f[%w]const%f[%W]',''):gsub('&',''))
 while t:match('^std::optional<') or t:match('^std::vector<') do t=t:match('^.-<(.*)>$') end
 return t
end
function M.assemble(native,coverage_table)
 local tiers={}
 for line in coverage_table:gmatch('[^\n]+') do
  if line:sub(1,1)=='|' then local columns={}; for c in (line..'|'):gmatch('(.-)|') do columns[#columns+1]=c end
   for name in (columns[4] or ''):gmatch('%u[%w]+') do if native.declarations[name] then assert(not tiers[name] or tiers[name]==S.norm(columns[3]):lower(),'conflicting tier'); tiers[name]=S.norm(columns[3]):lower() end end
  end
 end
 local function expand(t,prefix,trail)
  local model=base(t); if not native.types[model] then return {} end
  assert(not trail[model],'recursive model'); trail=copy(trail); trail[model]=true
  local out={}; for _,f in ipairs(native.types[model].fields) do
   local row=copy(f); row.model=model; row.path=prefix..f.name; out[#out+1]=row
   for _,child in ipairs(expand(f.native_type,row.path..'.',trail)) do out[#out+1]=child end
  end; return out
 end
 local function check_assignments(name,variable,expected)
  local code=S.mask(assert(native.implementations[name]).body,false); local seen={}
  for key,value in code:gmatch('%f[%w_]'..variable..'%.([%w_]+)%s*=%s*([^;]+);') do
   assert(expected[key] and S.norm(value)==expected[key],'conversion assignment changed '..name..'.'..key); seen[key]=true
  end
  for key in pairs(expected) do assert(seen[key],'conversion assignment missing '..name..'.'..key) end
 end
 check_assignments('ListDataItems','rec',{address='d.address',name='d.name',data_type='d.data_type',size='d.size',end_address='d.size > 0 ? d.address + d.size - 1 : d.address'})
 check_assignments('GetComments','rec',{address='c.address',kind='static_cast<CommentKind>(c.kind)',text='c.text'})
 check_assignments('OpenProgram','resp',{program_name='request.program_path.empty() ? request.project_path : request.program_path',language_id='request.language_id.empty() ? opts_.default_arch : request.language_id',compiler_spec='request.compiler_spec_id'})
 local records={}
 for _,r in pairs(native.record_reviews) do records[r.method..':'..r.model]=r end
 local producers={ListFunctions='listFunctions',ListLeafFunctions='listFunctions',GetFunction='getFunction',ListSymbols='listSymbols',GetSymbol='getSymbol',GetInstruction='getInstruction',ListInstructions='getInstruction',ListMemoryBlocks='listMemoryBlocks',GetType='getType',ListTypes='listTypes',ListTypeAliases='listTypeAliases',ListTypeEnums='listTypeEnums',ListTypeUnions='listTypeUnions',ListTypeMembers='listTypeMembers',ListTypeEnumMembers='listTypeEnumMembers',GetFunctionSignature='getFunctionSignature',ListFunctionSignatures='getFunctionSignature'}
 local p=native.producer_reviews
 local decomp={function_entry_address='candidate input address copied unchanged, not normalized entry',function_name='single default empty; batch candidate name when supplied, both branches',pseudocode='printer output on success; failure empty initializer, partial output discarded',completed='true iff dl.ok/nonempty print; false still PRESENT record',error_message='actual dl.error on failure; empty initializer on success',locals='collected before cleanup only on success; partial failure discarded',prototype='never assigned, empty initializer',is_fallback='never assigned, false initializer; not measured',tokens='never populated, empty vector, nested token schema unreachable'}
 local open={program_name='request program_path unless empty then project_path; not detected name',language_id='request language_id unless empty then default_arch; not detected architecture',compiler_spec='request compiler_spec_id echo, not detected compiler'}
 local function response_semantics(name,f)
  local model,key=f.model,f.name
  if f.path==key and native.container_reviews[name] and native.container_reviews[name].field==key then return native.container_reviews[name].semantics,native.container_reviews[name] end
  if model=='PerfBenchmarkRecord' then return assert(native.performance_reviews[name].record_fields[key]),native.performance_reviews[name] end
  if native.performance_reviews[name] then return native.performance_reviews[name].semantics,native.performance_reviews[name] end
  if native.mutation_reviews[name] and native.mutation_reviews[name].semantics[key] then return native.mutation_reviews[name].semantics[key],native.mutation_reviews[name] end
  if native.status_reviews[name] then
   local r=native.status_reviews[name]; local default=false; for _,v in ipairs(r.default_only) do if v==key then default=true end end; assert(r.assigned[key] or default,'unaccounted status field '..name..'.'..key)
   return default and 'unassigned initializer '..f.native_default..'; '..r.semantics or r.semantics,r
  end
  if name=='OpenProgram' then return open[key] or 'unassigned OpenProgram model initializer '..f.native_default..'; not detected loader identity/metadata',native.session_reviews.OpenProgram end
  if name=='GetCapabilities' then return native.special_reviews[name].semantics,native.special_reviews[name] end
  if name=='ListDefinedStrings' then return native.special_reviews[name].semantics,native.special_reviews[name] end
  if name=='ReadBytes' then return native.special_reviews[name].semantics,native.special_reviews[name] end
  if name=='ListDataItems' then
   if key=='value_repr' then return native.special_reviews[name].semantics,native.special_reviews[name] end
   -- LocalClient constructs data records, independently of adapter model producers.
   local fields={address='mapped nonfunction symbol offset',name='native symbol name',data_type='datatype name or undefined when absent',size='datatype size or zero; signed native conversion qualification retained',end_address='inclusive address+size-1 if positive else address; uint64 wrap possible'}
   return assert(fields[key],'unreviewed data record field '..key),native.container_reviews[name]
  end
  if name=='GetComments' then
   local fields={comments='dense response array',address='stored adapter comment address',kind='stored adapter integer kind cast to CommentKind',text='stored comment text unchanged, including empty'}
   return assert(fields[key],'unreviewed comment field '..key),native.container_reviews[name]
  end
  if model=='BasicBlockRecord' then return assert(p.CFG.blocks[key]),p.CFG end
  if model=='CFGEdgeRecord' then return assert(p.CFG.edges[key]),p.CFG end
  if model=='XrefRecord' then return p.Xrefs.fields[key] or 'unassigned model initializer '..assert(p.Xrefs.default_only[key])..'; not measured metadata',p.Xrefs end
  if model=='DecompilationRecord' then return assert(decomp[key]),name=='GetDecompilation' and p.SingleDecompilation or p.BatchDecompilation end
  if model=='DecompileLocalRecord' then return assert(p.Locals.fields[key]),p.Locals end
  if model=='DecompileTokenRecord' then return 'unreachable token schema: no producer appends tokens; initializer '..f.native_default..' not observed output',p.Extraction end
  local r=records[(producers[name] or '')..':'..model]
  assert(r,'missing response producer '..name..'.'..f.path..' model '..model)
  return r.fields[key] or 'not assigned; initializer '..assert(r.default_only[key])..'; not measured metadata or durable identity',r
 end
 local names={}; for name in pairs(native.declarations) do names[#names+1]=name end; table.sort(names)
 local data={format=2,qualification='native-only source semantic accounting; no generated runtime qualification',sources=copy(native.sources),types=copy(native.types),enums=copy(native.enums),operations={},native_reviews=native,
  acceptance_basis={authority='SPEC/DESIGN/COVERAGE and real Lua/native acceptance, not Python parity',runtime='not inferred or regenerated; api/history/coverage-m3.json and api/runtime-evidence-m3.json retain historical evidence separately'},
  request_audit={direct_argument_review_missing={}},semantic_audit={response_field_semantics_unreviewed={},wrapper_transition_review_missing={}},
  lifecycle={factory_fields={},factory='CreateLocalClient(LocalClientOptions), unique native owner; process slot/binding lifetime independent of logical program access',owner_close='binding close/__close/GC releases owner; aliases CLOSED; no autosave',native_close='CloseProgram/Shutdown logical access closure retains engines; no binding CLOSED'},
  error_envelope={native='StatusOr status.ok and value present',lua='response or nil,error; unknown codes/messages retained; native and binding domains separate; allocation remains Lua error',facade='lookup extraction plus complete third response; absent optional synthetic NOT_FOUND distinct from native error'}}
 for _,f in ipairs(native.types.LocalClientOptions.fields) do local row=copy(f); row.path=f.name; row.semantics=assert(native.factory_reviews.fields[f.name]); row.producer_review=copy(native.factory_reviews.consumers); data.lifecycle.factory_fields[#data.lifecycle.factory_fields+1]=row end
 for _,name in ipairs(names) do
  local d=native.declarations[name]; local impl=native.implementations[name]; local included=impl~=nil
  local snake=name:gsub('(%u+)(%u%l)','%1_%2'):gsub('(%l)(%u)','%1_%2'):lower()
  local dispatch=(name=='OpenProgram' or name=='CloseProgram' or name=='Shutdown') and 'lifecycle' or name:match('^(%u%l+)')
  local mut={Set=true,Add=true,Clear=true,Delete=true,Create=true,Rename=true,Apply=true,Write=true,Patch=true,Save=true,Discard=true}
  dispatch=dispatch=='lifecycle' and dispatch or mut[dispatch] and 'mutation' or 'read'
  local op={name=name,tier=included and assert(tiers[name],'missing normative tier '..name) or 'excluded',declaration=copy(d),implementation=impl and copy(impl) or null,lowlevel=included and snake or null,dispatch=included and dispatch or 'excluded',generation=included and dispatch~='read' and 'invalidate before dispatch including errors/partial effects; validation rejection unchanged' or 'unchanged',request={},response={native_type=d.response_type,lua=S.lua(d.response_type),fields=expand(d.response_type,'',{})},evidence={positive={status='unqualified',fixture=null,command=null},negative={status='unqualified',fixture=null,command=null}}}
  -- Source bodies are diagnostic input, not duplicated in the outbound contract.
  if included then op.implementation.body=nil end
  for _,arg in ipairs(S.split(d.arguments)) do
   local t,key=arg:match('^(.-)%s+([%w_]+)$'); assert(t and key,'invalid declaration argument')
   local a={name=key,native_type=S.norm(t),lua=S.lua(t),nested_fields=expand(t,'',{})}
   if included then
    if #a.nested_fields==0 then a.direct_argument_review=assert(native.request_reviews.reviewed[name] and native.request_reviews.reviewed[name][key],'unreviewed direct request '..name..'.'..key); a.semantics=a.direct_argument_review.semantics
    else for _,f in ipairs(a.nested_fields) do local review=assert(native.request_reviews.reviewed[name] and native.request_reviews.reviewed[name][key..'.'..f.path],'unreviewed nested request '..name..'.'..f.path); f.semantics=review.semantics; f.consumer_review=copy(review) end end
   end
   op.request[#op.request+1]=a
  end
  if included then
   op.program_state={qualification='source guard/helper policy, not binding owner state',override_loaded_guard=impl.body:find('ensure_loaded()',1,true)~=nil,helper=native.session_reviews[name] or native.status_reviews[name] or null}
   op.state_transitions=native.session_reviews[name] or native.page_wrapper_reviews[name] or native.mutation_reviews[name] or native.status_reviews[name] or native.performance_reviews[name] or native.lookup_reviews[name] or native.request_reviews.type_reconstruction_reviews[name] or native.special_reviews[name]
   assert(op.state_transitions,'unreviewed wrapper transition '..name)
   for _,f in ipairs(op.response.fields) do f.semantics,f.producer_review=response_semantics(name,f); assert(type(f.semantics)=='string' and #f.semantics>0,'empty field semantics') end
   local page=native.page_wrapper_reviews[name]
   if page then op.pagination={wrapper=page,adapter=native.adapter_page_reviews[name] or null,qualification='source sequence only; only previously accepted serial iterator families enabled'} end
   op.surface_contract={lowlevel={name=snake,grammar_authority='current SPEC/COVERAGE and implemented Lua facade; this inventory adds no syntax'},facade={disposition='see accepted COVERAGE public-layer mapping; no new conveniences/iterators inferred'},qualification='source accounting, not new grammar approval'}
  else op.surface_contract={lowlevel=null,facade=null,disposition='excluded inherited NOT_SUPPORTED; no local adapter promised'} end
  data.operations[#data.operations+1]=op
 end
 require("inventory_surfaces").apply(data)
 data.completeness_audit=require('inventory_completeness').validate(data)
 return data
end
return M
