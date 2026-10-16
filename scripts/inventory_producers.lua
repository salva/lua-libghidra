-- MIT Copyright 2026 Salvador Fandiño. Branch-specific graph/decompile producers.
local S=require('inventory_source')
local M={}
local function has(c,x) assert(c:find(x,1,true),'producer branch missing '..x) end
local function before(c,a,b) local x,y=c:find(a,1,true),c:find(b,1,true); assert(x and y and x<y,'producer order changed '..a) end
local function assignments(c,pattern) local set={}; for f in c:gmatch(pattern or '%f[%w_]rec%.([%w_]+)%s*=') do set[f]=true end; return set end
local function exact(actual,list)
 local expected={}; for _,f in ipairs(list) do expected[f]=true; assert(actual[f],'producer assignment missing '..f) end
 for f in pairs(actual) do assert(expected[f],'unexpected producer assignment '..f) end
end
local function fragment(c,first,last)
 local i=assert(c:find(first,1,true)); local j=assert(c:find(last,i, true)); return c:sub(i,j-1)
end
function M.review(local_source,adapter,pool,types,fingerprint)
 local out={}
 local function get(source,signature,path,key)
  local start,text=S.body(source,signature); local _,line=source:sub(1,start-1):gsub('\n','')
  local r={path=path,line=line+1,qualification='source population only; no new runtime completeness/producer approval'}
  if fingerprint then r.body_sha256=fingerprint(text) end
  out[key]=r; return S.mask(text,false),r,text
 end
 local cfg,g=get(adapter,'ArchAdapter::decompileAndExtractCFG(','cpp/src/local_arch_adapter.cpp','CFG')
 local blocks=fragment(cfg,'BasicBlockRecord rec;','result.blocks.push_back')
 local edges=fragment(cfg,'CFGEdgeRecord rec;','result.edges.push_back')
 local bf={'function_entry','start_address','end_address','in_degree','out_degree'}
 local ef={'function_entry','src_block_start','dst_block_start','edge_kind'}
 exact(assignments(blocks),bf); exact(assignments(edges),ef)
 local function model(name,fields) local a={}; for _,f in ipairs(assert(types[name]).fields) do a[f.name]=true end; exact(a,fields) end
 model('BasicBlockRecord',bf); model('CFGEdgeRecord',ef)
 for _,t in ipairs{'rec.end_address = stop.isInvalid() ? rec.start_address : stop.getOffset()','static_cast<std::uint32_t>(bb->sizeIn())','static_cast<std::uint32_t>(bb->sizeOut())','dst_bb->getIndex() <= bb->getIndex()','(j == 0) ? "FALSE" : "TRUE"'} do has(cfg,t) end
 before(cfg,'if (structure.getSize() > 0)','else if (raw.getSize() > 0)')
 g.blocks={function_entry='input candidate entry, not block start',start_address='valid BlockBasic start offset',end_address='inclusive stop offset; invalid stop uses start, not stop+1',in_degree='raw sizeIn uint32, not emitted edge count',out_degree='raw sizeOut uint32, includes skipped destinations'}
 g.edges={function_entry='input candidate entry',src_block_start='valid source start',dst_block_start='first-child structured descent to basic destination; invalid/nonbasic skipped',edge_kind='heuristic BACK by index priority, else two-output FALSE/TRUE by edge index, else FALL_THROUGH; not semantic branch proof'}
 g.limits='structured preferred, raw fallback; invalid starts/destinations skipped; no dedup; partial output on caught error; explicit clearAnalysis not exceptional-cleanup guarantee; pages only'
 local xref,x=get(adapter,'ArchAdapter::listXrefsForFunction(','cpp/src/local_arch_adapter.cpp','Xrefs')
 local fragments={}; local cursor=1
 while true do local i,j=xref:find('XrefRecord rec;',cursor,true); if not i then break end; local last=assert(xref:find('result.push_back',j+1,true)); fragments[#fragments+1]=xref:sub(j+1,last-1); cursor=last+1 end
 assert(#fragments==3,'xref construction branch count')
 exact(assignments(fragments[1]),{'from_address','to_address','ref_type','is_flow','is_primary','source'})
 for i=2,3 do exact(assignments(fragments[i]),{'from_address','to_address','ref_type','is_memory','source'}); has(fragments[i],'rec.is_memory = true') end
 for _,t in ipairs{'(op->code() == CPUI_CALLIND) ? "COMPUTED_CALL"','rec.is_primary = true','rec.is_flow = true'} do has(fragments[1],t) end
 has(fragments[2],'rec.ref_type = "DATA"'); has(fragments[3],'rec.ref_type = "WRITE"')
 for _,f in ipairs(fragments) do has(f,'rec.source = "ANALYSIS"') end
 x.fields={from_address='pcode instruction address',to_address='call spec entry or constant input1 varnode offset, no space-ID validity guarantee',ref_type='CALLIND computed else unconditional call; LOAD DATA; STORE WRITE',is_primary='true calls; data model false',is_flow='true calls; data model false',is_memory='call model false; data true',source='literal ANALYSIS'}
 x.default_only={}; for _,f in ipairs(types.XrefRecord.fields) do if not x.fields[f.name] then x.default_only[f.name]=f.native_default end end
 x.limits='calls then constant LOAD/STORE subset, not reference DB; duplicate/partial success possible; same-instance analysis; pages only'
 local single,s=get(local_source,' GetDecompilation(','cpp/src/local_client.cpp','SingleDecompilation')
 local cut=assert(single:find('} else {',1,true)); local failure,success=single:sub(1,cut-1),single:sub(cut)
 exact(assignments(success),{'function_entry_address','pseudocode','locals','completed'})
 exact(assignments(failure,'resp%.decompilation%->([%w_]+)%s*='),{'function_entry_address','completed','error_message'})
 for _,t in ipairs{'error_message = dl.error','completed = false'} do has(failure,t) end
 for _,t in ipairs{'rec.completed = true','rec.locals = std::move(dl.locals)','rec.pseudocode = std::move(dl.pseudocode)'} do has(success,t) end
 s.success_assigned={'function_entry_address','pseudocode','locals','completed'}; s.failure_assigned={'function_entry_address','completed','error_message'}
 s.limits='both success/failure present record, actual dl.error on failure; single function_name empty; partial adapter output discarded on failure'
 local batch,b=get(pool,'DecompilerPool::decompileMany(','cpp/src/decompiler_pool.cpp','BatchDecompilation')
 exact(assignments(batch,'results%[i%]%.([%w_]+)%s*='),{'function_entry_address','function_name','pseudocode','locals','completed','error_message'})
 for _,t in ipairs{'if (i < names.size()) results[i].function_name = names[i]','results[i].error_message = dl.error','results[i].completed = false','results[i].completed = true'} do local _,n=batch:gsub(t:gsub('([^%w])','%%%1'),''); assert(n==2,'serial/parallel producer differs '..t) end
 has(batch,'std::vector<DecompilationRecord> results(addresses.size())'); has(batch,'f.get();')
 b.limits='same-size indexed batch; names assigned both branches when index exists; failed records retained completed=false, not absent'
 local collect,c,ct=get(adapter,'void collect_function_locals(','cpp/src/local_arch_adapter.cpp','Locals')
 local extract,e,et=get(adapter,'ArchAdapter::decompileWithLocals(','cpp/src/local_arch_adapter.cpp','Extraction')
 local lf={'local_id','kind','name','data_type','storage','ordinal'}; exact(assignments(collect),lf); model('DecompileLocalRecord',lf)
 for _,t in ipairs{'if (sym->isHiddenReturn()) return','if (!seen_ids.insert(rec.local_id).second) return','if (rec.name.empty()) rec.name = rec.local_id','dt->getName() : ""','static_cast<int>(sym->getCategoryIndex())',': -1'} do has(collect,t) end
 before(collect,'local->begin()','local->beginDynamic()')
 before(extract,'reapplyLocalRenames(func_entry, fd)','docFunction(fd)'); before(extract,'docFunction(fd)','collect_function_locals(arch_, fd, pairs)')
 has(extract,'result.ok = !result.pseudocode.empty()'); has(extract,'result.error = describe_current_exception()')
 c.fields={local_id='opaque canonical category/storage/first-use snapshot, no cross-generation identity promise',kind='native parameter/temp/local enum classification',name='symbol name or canonical local_id when empty',data_type='datatype name or empty, not undefined',storage='native display string, not stable address object',ordinal='parameter category index signed int, nonparameter -1 not array index'}
 c.order='mapped then dynamic traversal; hidden returns skipped, first symbol/ID retained; no sorted order guarantee'
 e.limits='find/create and analyze; renamed locals reapplied before print; ok iff nonempty print; exceptions diagnosed; native RAII cleanup and opaque ID narrowing boundaries retain qualification limits'
 local df={'function_entry_address','function_name','pseudocode','completed','error_message','locals','prototype','is_fallback','tokens'}; model('DecompilationRecord',df)
 s.default_only={'function_name','prototype','is_fallback','tokens'}; b.default_only={'prototype','is_fallback','tokens'}
 s.unreachable='tokens never populated; token schema fields not observed outputs'; b.unreachable=s.unreachable
 if fingerprint then e.combined_locals_extraction_sha256=fingerprint(ct..et) end
 return out
end
return M
