-- MIT Copyright 2026 Salvador Fandiño. Consumer/status/lifecycle negative paths.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_remaining_inputs')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local a=U.read(root..'/cpp/src/local_arch_adapter.cpp')
local r=R.review(raw,a); local count=0; for _,args in pairs(r) do for _ in pairs(args) do count=count+1 end end; assert(count==14)
local cases={
 {' RenameFunction(','d.nameFunction(address, new_name)','d.nameFunction(address, "")'},
 {' RenameDataItem(','a.renameDataItem(address, new_name)','a.renameDataItem(address, "")'},
 {' RenameSymbol(','d.nameFunction(address, new_name)','d.nameFunction(address, "")'},
 {' ApplyDataType(','d.nameGlobal(address, name, data_type)','d.nameGlobal(address, name, "")'},
 {' SetFunctionSignature(','d.setPrototype(address, prototype)','d.setPrototype(address, "")'},
 {' RenameFunctionLocal(','applyLocalRenameAllSlots(address, local_id, new_name)','applyLocalRenameAllSlots(address, "", new_name)'},
 {' SetFunctionLocalType(','"INVALID_TYPE"','"NOT_FOUND"'},
 {' RenameFunctionLocal(','"DECOMPILE_FAILED"','"NOT_FOUND"'},
 {' SetComment(','static_cast<int>(kind)','0'},
 {' DeleteComment(','static_cast<int>(kind)','0'},
 {' CloseProgram(','closeProgramLocked(policy)','closeProgramLocked(ShutdownPolicy::kDiscard)'},
 {' Shutdown(','if (!closed.ok())','if (false)'},
 {'StatusOr<CloseProgramResponse> closeProgramLocked(ShutdownPolicy policy)','policy == ShutdownPolicy::kSave','policy != ShutdownPolicy::kDiscard'},
 {'StatusOr<CloseProgramResponse> closeProgramLocked(ShutdownPolicy policy)','pool_->saveState(opts_.state_path)','pool_->saveState("")'},
}
for _,c in ipairs(cases) do
 local _,text,opening,ending=S.body(raw,c[1]); local i,j=assert(text:find(c[2],1,true))
 local changed=raw:sub(1,opening-1)..text:sub(1,i-1)..c[3]..text:sub(j+1)..raw:sub(ending+1)
 assert(not pcall(R.review,changed,a),'consumer mutation accepted '..c[1])
end
print('Lua 14 string/local/comment/policy inputs and 14 source mutations PASS')
