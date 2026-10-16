-- MIT Copyright 2026 Salvador Fandiño. Presentation is not grammar authorization.
local J=require('tool_json')
local M={}
local approved={GetStatus='get_status()',GetCapabilities='get_capabilities()',OpenProgram='open_program(program_options)',CloseProgram='close_program{policy="save"|"discard"}',GetFunction='get_function(address)',GetInstruction='get_instruction(address)',ReadBytes='read_bytes(address, size)',GetDecompilation='get_decompilation(address, options={})',ListFunctions='list_functions(options={})',ListInstructions='list_instructions(options={})'}
local grammar={GetSymbol='get_symbol(address)',GetType='get_type(path)',GetFunctionSignature='get_function_signature(address)'}
local lookups={GetFunction='function',GetDecompilation='decompilation',GetInstruction='instruction',GetSymbol='symbol',GetType='type',GetFunctionSignature='signature',ReadBytes='data'}
function M.apply(data)
 local audit={included_operations=0,excluded_operations=0,approved_first_slice_count=0,proposed_grammar={},qualification='source presentation only, not new syntax/runtime authorization'}
 for _,op in ipairs(data.operations) do
  if op.tier=='excluded' then
   audit.excluded_operations=audit.excluded_operations+1
   op.surface_contract={lowlevel=J.null,facade=J.null,disposition='excluded: inherited NOT_SUPPORTED; no Lua adapter promised'}
  else
   audit.included_operations=audit.included_operations+1
   local keys={}; for _,a in ipairs(op.request) do keys[#keys+1]=a.name end
   local call=approved[op.name] or grammar[op.name] or (op.pagination and op.lowlevel..'(options={})') or op.lowlevel..'('..table.concat(keys,', ')..')'
   local status=approved[op.name] and 'approved first-slice' or 'proposed; not approved for adapter implementation'
   if approved[op.name] then audit.approved_first_slice_count=audit.approved_first_slice_count+1 else audit.proposed_grammar[#audit.proposed_grammar+1]={operation=op.name,proposal=call,reason='inventory presentation not adapter authorization; later accepted SPEC/COVERAGE and implementation remain authoritative'} end
   local disposition='native escape hatch'
   if op.name=='OpenProgram' then disposition='module open{client={}, program=...}; returns session,nil,historical_open_response'
   elseif lookups[op.name] then disposition='direct extraction'
   elseif op.tier=='slice' or (op.tier=='core' and op.name~='DiscardProgram') then disposition='complete response convenience/page' end
   if op.name=='ListFunctionSignatures' then disposition='complete response page; no iterator' end
   if op.name=='ListDefinedStrings' then disposition='native escape hatch compatibility page; no discovery iterator' end
   local low={name=op.lowlevel,call=call,call_status=status,native_request_keys=keys,['return']='complete detached native response or nil,error',grammar={status=status,authority=approved[op.name] and 'docs/API.md Construction and return shapes' or 'inventory presentation only; docs/development/COVERAGE.md disposition is not this syntax',approved_call=approved[op.name] or J.null,proposed_call=approved[op.name] and J.null or call,native_argument_order=keys,unknown_keys='reject before dispatch; validation-only rejection does not invalidate generation',default_rule='only explicit binding defaults; preserve false, zero and empty; initializer not proof of optionality'}}
   local escape=disposition:match('^native escape')~=nil
   local facade={name=escape and J.null or op.lowlevel,disposition=disposition,extraction=disposition=='direct extraction' and lookups[op.name] or J.null,grammar_status=escape and 'native() uses lowlevel grammar; no convenience promised' or status,['return']=disposition=='direct extraction' and 'value,nil,response; optional absent -> nil,NOT_FOUND,response; native error -> nil,error' or 'complete response/error via convenience or native() as disposed'}
   if op.name=='OpenProgram' then facade.grammar_status='approved first-slice'; facade.approved_call='open{client={}, program=program_options}'; facade.rejected_keys={'project_name','read_only'} end
   if op.name=='CloseProgram' then facade.save_policy='reject empty configured state_path with binding NO_STATE_PATH before dispatch; no implicit save' end
   if op.name=='ReadBytes' then low.argument_alias='Lua size corresponds to native length; 0..INT32_MAX before dispatch/allocation' end
   if op.name=='GetDecompilation' or op.name=='ListDecompilations' then facade.timeout_policy='reject explicit timeout key; native default ignored; no deadline promise' end
   op.surface_contract={lowlevel=low,facade=facade,implementation_status='source inventory only; current runtime acceptance stored separately',iterator='no new iterator qualification; preserve accepted functions/symbols/memory_blocks only, other families pages-only'}
   for _,a in ipairs(op.request) do
    a.ignored=a.direct_argument_review and a.direct_argument_review.kind=='ignored' or false
    for _,f in ipairs(a.nested_fields) do f.ignored=op.name=='OpenProgram' and (f.name=='project_name' or f.name=='read_only') or false end
    a.binding_default=a.name=='limit' and '100' or (a.name=='offset' or a.name=='range_start') and '0' or a.name=='range_end' and 'UINT64_MAX; explicit zero sentinel only where consumer review documents it' or a.name=='timeout_ms' and '30000 (ignored)' or 'required unless explicit binding contract says otherwise'
   end
  end
 end
 assert(audit.included_operations==70 and audit.excluded_operations==40 and audit.approved_first_slice_count==10 and #audit.proposed_grammar==60,'surface closure')
 audit.grammar_accounted=audit.included_operations; data.surface_audit=audit
 return data
end
return M
