-- MIT Copyright 2026 Salvador Fandiño. Explicit status producer/default branches.
local S=require('inventory_source')
local M={}
local contracts={
 GetRevision={'RevisionResponse','resp',{modification_number='revision_'},{'program_id','program_path','file_id','file_version','file_last_modified_time'}},
 GetStatus={'HealthStatus','hs',{ok='(pool_ != nullptr)',service_name='"local-decompiler"',service_version='"1.0.0"',host_mode='"local"',modification_number='revision_'},{'warnings'}},
 SaveProgram={'SaveProgramResponse','resp',{saved='ok'},{}},
 DiscardProgram={'DiscardProgramResponse','resp',{discarded='true'},{}},
 CloseProgram={'CloseProgramResponse','resp',{closed='true'},{}},
 Shutdown={'ShutdownResponse','resp',{accepted='true'},{}},
}
local meanings={
 GetRevision='revision snapshot under lock, usable unloaded; default-only project/file fields are not detected identity/timestamps; not binding generation',
 GetStatus='ok is pool pointer existence only, not loaded/loader readiness; literal local-decompiler/1.0.0/local are not detected upstream identity; empty warnings not health scan',
 SaveProgram='success saved true after saveState; constructed false discarded in SAVE_FAILED; loaded and nonempty state_path required; no native revision increment',
 DiscardProgram='literal true even unloaded; acknowledgement not rollback/reload/state deletion; no revision increment',
 CloseProgram='logical close after resetAdapters/loaded=false/benchmark clear; SAVE_FAILED precedes closure; not owner release or binding CLOSED',
 Shutdown='acknowledgement after successful logical close or already unloaded; propagates save failure; engines retained, not binding CLOSED',
}
local function has(code,x) assert(code:find(x,1,true),'status branch missing '..x) end
local function before(code,x,y)
 local a,b=code:find(x,1,true),code:find(y,1,true); assert(a and b and a<b,'status branch order changed')
end
function M.review(raw,types,fingerprint)
 local result={}
 for name,c in pairs(contracts) do
  local model,var,assigned,defaults=table.unpack(c)
  local method=name=='CloseProgram' and 'closeProgramLocked' or name
  local signature=name=='CloseProgram' and 'StatusOr<CloseProgramResponse> closeProgramLocked(' or ' '..name..'('
  local start,text=S.body(raw,signature); local code=S.mask(text,false)
  local actual={}
  for field,value in code:gmatch('%f[%w_]'..var..'%.([%w_]+)%s*=%s*([^;]+);') do
   assert(not actual[field],'duplicate status assignment '..field); actual[field]=S.norm(value)
  end
  for field,value in pairs(assigned) do assert(actual[field]==value,'status assignment changed '..name..'.'..field) end
  for field in pairs(actual) do assert(assigned[field],'unexpected status assignment '..field) end
  local remaining={}; for _,field in ipairs(types[model].fields) do if not assigned[field.name] then remaining[field.name]=field.native_default end end
  for _,field in ipairs(defaults) do assert(remaining[field],'status default missing '..field); remaining[field]=nil end
  assert(next(remaining)==nil,'unexpected status default')
  if name=='CloseProgram' then
   local _,wrapper=S.body(raw,' CloseProgram('); has(S.mask(wrapper,false),'return closeProgramLocked(policy)')
   before(code,'"SAVE_FAILED"','pool_->resetAdapters()'); before(code,'pool_->resetAdapters()','resp.closed = true')
  elseif name=='Shutdown' then
   has(code,'if (program_loaded_)'); has(code,'if (!closed.ok())'); before(code,'closed.status.code, closed.status.message','resp.accepted = true')
  elseif name=='SaveProgram' then has(code,'if (!ok)'); before(code,'"SAVE_FAILED"','::FromValue(') end
  local _,line=raw:sub(1,start-1):gsub('\n','')
  local r={path='cpp/src/local_client.cpp',line=line+1,method=method,assigned=assigned,default_only=defaults,semantics=meanings[name],qualification='source review only; preserve separately retained runtime evidence'}
  if fingerprint then r.body_sha256=fingerprint(text) end
  result[name]=r
 end
 return result
end
return M
