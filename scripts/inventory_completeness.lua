-- MIT Copyright 2026 Salvador Fandiño. Independent cross-ledger assertions.
local J=require('tool_json')
local S=require('inventory_source')
local M={}
function M.validate(data)
 local names={}; local included,excluded,direct,nested,response=0,0,0,0,0
 local function expand(native,prefix,trail)
  local base=S.norm(native:gsub('%f[%w]const%f[%W]',''):gsub('&',''))
  while base:match('^std::optional<') or base:match('^std::vector<') do base=base:match('^.-<(.*)>$') end
  if not data.types[base] then return {} end
  assert(not trail[base],'recursive model'); local nexttrail={}; for k,v in pairs(trail) do nexttrail[k]=v end; nexttrail[base]=true
  local result={}
  for _,f in ipairs(data.types[base].fields) do
   local path=prefix..f.name; result[#result+1]={path=path,native_type=f.native_type,lua=f.lua}
   for _,v in ipairs(expand(f.native_type,path..'.',nexttrail)) do result[#result+1]=v end
  end
  return result
 end
 local function match(actual,expected,label)
  assert(#actual==#expected,label..' field count')
  for i,f in ipairs(expected) do for _,k in ipairs{'path','native_type','lua'} do assert(actual[i][k]==f[k],label..' '..k) end end
 end
 for _,op in ipairs(data.operations) do
  assert(not names[op.name],'duplicate operation'); names[op.name]=true
  match(op.response.fields,expand(op.response.native_type,'',{}),'response expansion '..op.name)
  for _,a in ipairs(op.request) do match(a.nested_fields,expand(a.native_type,'',{}),'request expansion '..op.name) end
  if op.tier=='excluded' then
   excluded=excluded+1
   assert(op.surface_contract.lowlevel==J.null and op.surface_contract.facade==J.null,'excluded surface')
  else
   included=included+1
   for _,k in ipairs{'implementation','program_state','dispatch','generation'} do assert(op[k] and op[k]~=J.null,'missing '..k) end
   for _,a in ipairs(op.request) do
    if #a.nested_fields==0 then direct=direct+1; assert(a.direct_argument_review and a.semantics,'direct review') end
    nested=nested+#a.nested_fields
   end
   response=response+#op.response.fields
   for _,f in ipairs(op.response.fields) do assert(f.semantics and f.semantics~='native field preserved; no truthiness substitution','response semantics') end
   for _,slot in ipairs{'positive','negative'} do
    local e=op.evidence[slot]; if e.status=='unqualified' then
     assert(e.fixture==J.null and e.command==J.null,'false runtime evidence')
    else
     local allowed=slot=='positive' and 'real Lua/native supported paths exercised; field completeness additionally converter-tested, not every native field populated' or 'exercised scoped paths; not exhaustive native error oracle'
     assert((e.status==allowed or (op.name=='ListTypeUnions' and slot=='positive' and e.status=='real Lua success-empty only; practical native public union producer limitation')) and type(e.fixture)=='string' and type(e.command)=='string','false runtime evidence')
    end
   end
  end
 end
 if data.format==2 then
  assert(data.surface_audit and data.surface_audit.grammar_accounted==70,'surface audit')
  local approved,proposed=0,0
  for _,op in ipairs(data.operations) do if op.tier~='excluded' then
   local low=assert(op.surface_contract.lowlevel); local grammar=assert(low.grammar)
   assert(#grammar.native_argument_order==#op.request,'surface argument count')
   for n,a in ipairs(op.request) do assert(grammar.native_argument_order[n]==a.name,'surface argument order') end
   assert((grammar.approved_call~=J.null)~=(grammar.proposed_call~=J.null),'ambiguous grammar')
   if grammar.approved_call~=J.null then approved=approved+1 else proposed=proposed+1 end
  end end
  assert(approved==10 and proposed==60,'grammar disposition count')
 end
 assert(included==70 and excluded==40,'operation count')
 assert(direct==156 and nested==20 and response==345,'request/response count')
 assert(#data.request_audit.direct_argument_review_missing==0,'direct audit')
 assert(#data.semantic_audit.response_field_semantics_unreviewed==0,'response audit')
 assert(#data.semantic_audit.wrapper_transition_review_missing==0,'transition audit')
 assert(#data.lifecycle.factory_fields==4,'factory fields')
 return {included_operations=included,excluded_operations=excluded,direct_request_paths=direct,nested_request_paths=nested,expanded_response_paths=response}
end
return M
