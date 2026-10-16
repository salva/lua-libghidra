-- MIT Copyright 2026 Salvador Fandiño. Related string/local/policy consumers.
local S=require('inventory_source')
local M={}
local function has(c,x) assert(c:find(x,1,true),'input consumer missing '..x) end
local function before(c,a,b) local x,y=c:find(a,1,true),c:find(b,1,true); assert(x and y and x<y,'input branch order changed') end
function M.review(raw,adapter,fingerprint)
 local out={}
 local function record(name,args,tokens,sem)
  local _,text=S.body(raw,' '..name..'('); local code=S.mask(text,false)
  for _,token in ipairs(tokens) do has(code,token); before(code,'ensure_loaded()',token) end
  out[name]={}
  for _,arg in ipairs(args) do local r={kind='direct',semantics=sem}; if fingerprint then r.consumer_body_sha256=fingerprint(text) end; out[name][arg]=r end
  return code
 end
 for name,token in pairs{RenameFunction='d.nameFunction(address, new_name)',RenameDataItem='a.renameDataItem(address, new_name)',RenameSymbol='d.nameFunction(address, new_name)'} do
  record(name,{'new_name'},{token},'unchanged requested byte-string name, not canonical readback; native false status error; runtime NUL/namespace/downstream parsing not inferred')
 end
 record('ApplyDataType',{'data_type'},{'d.nameGlobal(address, name, data_type)'},'unchanged native datatype string; existing symbol name or DAT_hex fallback; downstream parser/layout not wrapper guarantee')
 record('SetFunctionSignature',{'prototype'},{'d.setPrototype(address, prototype)'},'unchanged complete native prototype string; false SET_PROTOTYPE_FAILED, echoed not canonical; all-slot partial failure no rollback')
 for name,c in pairs{RenameFunctionLocal={'local_id','new_name','applyLocalRenameAllSlots(address, local_id, new_name)'},SetFunctionLocalType={'local_id','data_type','applyLocalRetypeAllSlots(address, local_id, new_type)'}} do
  local code=record(name,{c[1],c[2]},{c[3]},'function-scoped local resolver input, no binding ID reinterpretation; unchanged requested name/type; tolerant native aliases not canonical IDs; status failures before revision; all-slot partial effects possible')
  for _,error in ipairs{'"NOT_FOUND"','"DECOMPILE_FAILED"'} do has(code,error); before(code,error,'revision_++') end
  if name=='SetFunctionLocalType' then has(code,'"INVALID_TYPE"'); before(code,'"INVALID_TYPE"','revision_++') end
 end
 for _,name in ipairs{'SetComment','DeleteComment'} do
  local method=name=='SetComment' and 'setComment' or 'deleteComment'
  local code=record(name,name=='SetComment' and {'kind','text'} or {'kind'},{'a.'..method..'(address, static_cast<int>(kind)'},'literal address/native signed enum key in adapter side-map, no native enum membership/address check; unknown response value preservation not arbitrary input approval; empty text stored, not deletion; persistence separate')
  local _,producer=S.body(adapter,'ArchAdapter::'..method..'('); producer=S.mask(producer,false)
  has(producer,name=='SetComment' and 'comments_[{address, kind}] = text;' or 'comments_.erase({address, kind}) > 0')
 end
 for _,name in ipairs{'CloseProgram','Shutdown'} do
  local _,text=S.body(raw,' '..name..'('); local code=S.mask(text,false)
  has(code,'closeProgramLocked(policy)')
  local _,helper=S.body(raw,'StatusOr<CloseProgramResponse> closeProgramLocked(ShutdownPolicy policy)'); helper=S.mask(helper,false)
  has(helper,'policy == ShutdownPolicy::kSave'); has(helper,'should_save && !opts_.state_path.empty()')
  before(helper,'pool_->saveState(opts_.state_path)','pool_->resetAdapters();')
  if name=='Shutdown' then has(code,'if (program_loaded_)'); has(code,'if (!closed.ok())') else has(helper,'if (!program_loaded_)'); has(helper,'"NO_PROGRAM"'); before(helper,'"NO_PROGRAM"','policy == ShutdownPolicy::kSave') end
  out[name]={policy={kind='direct',semantics='explicit policy, facade save/discard only; native only kSave saves, others nonsave; empty state path skips native save but facade rejects save-close; SAVE_FAILED before reset; logical close not owner release or autosave; dispatched lifecycle invalidates generation on error'}}
  if fingerprint then out[name].policy.consumer_body_sha256=fingerprint(text) end
 end
 return out
end
return M
