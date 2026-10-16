-- MIT Copyright 2026 Salvador Fandiño. Status assignment/default/error regressions.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_status')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local types=S.header('models.hpp',U.read(root..'/cpp/include/libghidra/models.hpp'))
-- HealthStatus/RevisionResponse are model structs, not StatusOr internals.
local r=R.review(raw,types); assert(#r.GetRevision.default_only==5 and #r.GetStatus.default_only==1)
local mutations=0
local function reject(signature,needle,replacement)
 local _,body,opening,ending=S.body(raw,signature)
 local i,j=assert(body:find(needle,1,true)); body=body:sub(1,i-1)..replacement..body:sub(j+1)
 local ok=pcall(R.review,raw:sub(1,opening-1)..body..raw:sub(ending+1),types)
 assert(not ok,'status mutation accepted '..needle); mutations=mutations+1
end
reject(' GetRevision(','resp.modification_number = revision_','resp.modification_number = 0')
reject(' GetStatus(','hs.ok = (pool_ != nullptr)','hs.ok = true')
reject(' GetStatus(','"1.0.0"','"0.0.9"')
reject(' SaveProgram(','resp.saved = ok','resp.saved = true')
reject(' DiscardProgram(','resp.discarded = true','resp.discarded = false')
reject('StatusOr<CloseProgramResponse> closeProgramLocked(','resp.closed = true','resp.closed = false')
reject(' Shutdown(','resp.accepted = true','resp.accepted = false')
reject(' Shutdown(','if (!closed.ok())','if (false)')
reject(' CloseProgram(','return closeProgramLocked(policy)','return closeProgramLocked(ShutdownPolicy::kDiscard)')
reject('StatusOr<CloseProgramResponse> closeProgramLocked(','pool_->resetAdapters()','pool_->noop()')
print('Lua status producer/default/error reviews and '..mutations..' source mutations PASS')
