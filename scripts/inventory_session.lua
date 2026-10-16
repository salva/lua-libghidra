-- MIT Copyright 2026 Salvador Fandiño. Logical program closure is not owner release.
local S=require('inventory_source')
local M={}
function M.review(raw,pool,fingerprint)
 local result={}
 local function has(c,x) assert(c:find(x,1,true),'session branch missing '..x) end
 local function before(c,x,y) local a,b=c:find(x,1,true),c:find(y,1,true); assert(a and b and a<b,'session transition order changed '..x) end
 local function get(name,signature)
  local start,text=S.body(raw,signature or ' '..name..'('); local _,line=raw:sub(1,start-1):gsub('\n',''); local r={path='cpp/src/local_client.cpp',line=line+1,qualification='source transitions only; retain independent runtime evidence'}
  if fingerprint then r.body_sha256=fingerprint(text) end; result[name]=r; return S.mask(text,false),r
 end
 local close,r=get('CloseHelper','closeProgramLocked(ShutdownPolicy policy)')
 before(close,'"SAVE_FAILED"','pool_->resetAdapters()'); before(close,'pool_->resetAdapters()','program_loaded_ = false'); before(close,'program_loaded_ = false','perf_benchmarks_.clear()')
 has(close,'should_save && !opts_.state_path.empty()'); assert(not close:find('revision_++',1,true),'close increments native revision')
 r.semantics='SAVE_FAILED before logical close preserves access/benchmarks; success drops adapters/loaded/benchmarks but retains engines/owner; nonsave policies close; empty state path skips save'
 local _,reset=S.body(pool,'DecompilerPool::resetAdapters('); reset=S.mask(reset,false); has(reset,'slot.adapter.reset()'); assert(not reset:find('slot.decomp.reset()',1,true),'logical close releases engines')
 local open,o=get('OpenProgram')
 before(open,'loadProject(','loadBinary('); before(open,'"LOAD_FAILED"','pool_->loadState(opts_.state_path)'); before(open,'pool_->loadState(opts_.state_path)','program_loaded_ = true'); before(open,'program_loaded_ = true','revision_++')
 has(open,'resp.compiler_spec = request.compiler_spec_id'); has(open,'request.language_id.empty() ? opts_.default_arch : request.language_id')
 o.semantics='project precedence; failure before loaded/revision; best-effort state load ignored; success increments revision; language/compiler are request/default echoes not detected identity'
 local save,s=get('SaveProgram'); before(save,'"NO_PROGRAM"','"NO_STATE_PATH"'); before(save,'"NO_STATE_PATH"','pool_->saveState(opts_.state_path)'); before(save,'"SAVE_FAILED"','::FromValue('); assert(not save:find('revision_++',1,true),'save revision changed'); s.semantics='save does not close or advance native revision; missing state path error distinct from failed save'
 local discard,d=get('DiscardProgram'); assert(not discard:find('program_loaded_',1,true) and not discard:find('revision_++',1,true),'discard state changed'); has(discard,'resp.discarded = true'); d.semantics='acknowledges even unloaded; no rollback/reload/reset/version change'
 local shutdown,sh=get('Shutdown'); has(shutdown,'if (program_loaded_)'); has(shutdown,'closeProgramLocked(policy)'); before(shutdown,'closed.status.code, closed.status.message','resp.accepted = true'); sh.semantics='unloaded accepted; loaded helper failure propagated unchanged; not host termination/owner release'
 return result
end
return M
