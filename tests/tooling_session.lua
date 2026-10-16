-- MIT Copyright 2026 Salvador Fandiño. Session transition/error fidelity.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_session')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local p=U.read(root..'/cpp/src/decompiler_pool.cpp'); R.review(raw,p)
local count=0
for _,c in ipairs{
 {'closeProgramLocked(ShutdownPolicy policy)','program_loaded_ = false','program_loaded_ = true'},
 {'closeProgramLocked(ShutdownPolicy policy)','perf_benchmarks_.clear()','perf_benchmarks_.resize(1)'},
 {'closeProgramLocked(ShutdownPolicy policy)','"SAVE_FAILED"','"OTHER"'},
 {' OpenProgram(','program_loaded_ = true','program_loaded_ = false'},
 {' OpenProgram(','revision_++;',';'},
 {' OpenProgram(','pool_->loadState(opts_.state_path)','pool_->loadState("")'},
 {' SaveProgram(','"NO_STATE_PATH"','"SAVE_FAILED"'},
 {' DiscardProgram(','{','{ program_loaded_ = false;'},
 {' Shutdown(','closed.status.code, closed.status.message','"ERROR", "changed"'},
} do
 local _,text,opening,ending=S.body(raw,c[1]); local i,j=assert(text:find(c[2],1,true)); local changed=raw:sub(1,opening-1)..text:sub(1,i-1)..c[3]..text:sub(j+1)..raw:sub(ending+1)
 assert(not pcall(R.review,changed,p),'session mutation accepted '..c[1]); count=count+1
end
local _,text,opening,ending=S.body(p,'DecompilerPool::resetAdapters(')
local changed=p:sub(1,opening)..'slot.decomp.reset();'..p:sub(opening+1)
assert(not pcall(R.review,raw,changed),'engine release accepted')
print('Lua session source transitions and '..(count+1)..' mutations PASS')
