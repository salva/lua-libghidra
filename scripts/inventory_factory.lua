-- MIT Copyright 2026 Salvador Fandiño. Native factory consumers, not owner approval.
local S=require('inventory_source')
local M={}
local meanings={
 ghidra_root='empty chooses default engine constructor per slot; nonempty unchanged; no consumer path expansion; invalid path/embedded availability separate qualification',
 pool_size='native clamps <=0 to 1 before size_t conversion; independent engines for >1 alter order; binding MUST reject all but exact 1 before owner allocation',
 default_arch='native empty initializer; binary route only when request language_id empty; nonempty request overrides; project response echo not detected architecture proof',
 state_path='empty disables best-effort load/close-save; explicit SaveProgram NO_STATE_PATH; unchanged nonempty loadState return ignored; failed save precedes reset; default destructor not autosave',
}
local function has(code,needle) assert(code:find(needle,1,true),'factory consumer missing '..needle) end
function M.review(local_source,pool,types,fingerprint)
 local code=S.mask(local_source,false); local p=S.mask(pool,false)
 local fields=assert(types.LocalClientOptions).fields; local expected={}; local count=0
 for _,f in ipairs(fields) do assert(meanings[f.name],'unreviewed factory field '..f.name); expected[f.name]=true; count=count+1 end
 assert(count==4,'factory field count')
 local actual={}; for name in code:gmatch('opts_%.([%w_]+)') do actual[name]=true end
 for name in pairs(actual) do assert(expected[name],'unreviewed factory option consumer') end
 for name in pairs(expected) do assert(actual[name],'unconsumed factory option') end
 has(code,'std::max(opts_.pool_size, 1), opts_.ghidra_root'); has(code,'~LocalClient() override = default;')
 has(p,'std::size_t n = std::max<std::size_t>(pool_size, 1);'); has(p,'slots_.resize(n);'); has(p,'if (ghidra_root.empty())')
 has(p,'std::make_unique<ghidra_standalone::Decompiler>();'); has(p,'std::make_unique<ghidra_standalone::Decompiler>(ghidra_root)')
 local bodies={}; local reviews={}
 for name,signature in pairs{factory='CreateLocalClient(LocalClientOptions options)',open=' OpenProgram(',save=' SaveProgram(',close='StatusOr<CloseProgramResponse> closeProgramLocked(ShutdownPolicy policy)'} do
  local start,text=S.body(local_source,signature); bodies[name]=S.mask(text,false)
  local _,line=local_source:sub(1,start-1):gsub('\n',''); local r={path='cpp/src/local_client.cpp',line=line+1}
  if fingerprint then r.body_sha256=fingerprint(text) end; reviews[name]=r
 end
 has(bodies.factory,'return std::make_unique<LocalClient>(std::move(options));')
 has(bodies.open,'pool_->loadState(opts_.state_path)'); has(bodies.save,'pool_->saveState(opts_.state_path)'); has(bodies.close,'pool_->saveState(opts_.state_path)')
 return {fields=meanings,consumers=reviews,qualification='source consumers only; factory construction exceptions may escape; preserve independent binding owner/failure cleanup tests and runtime evidence'}
end
return M
