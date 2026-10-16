-- MIT Copyright 2026 Salvador Fandiño. Representation and operation reachability.
-- Explicit spellings inspected in slice_convert.hpp/core_convert.hpp and owner.cpp.
local M={}
M.enums={
 CommentKind={'unspecified','eol','pre','post','plate','repeatable'},
 DecompileLocalKind={'unspecified','param','local','temp'},
 DecompileTokenKind={'unspecified','keyword','comment','type','function','variable','const','parameter','global','default','error','special'},
 ShutdownPolicy={'save','discard'}, -- accepted request strings, not a response converter
}
function M.base(t)
 t=t:gsub('const%s+',''):gsub('&',''):match('^%s*(.-)%s*$')
 while t:match('^std::optional<') or t:match('^std::vector<') do t=t:match('^std::%w+<(.*)>$') end
 return t
end
function M.named(t,context)
 if context.types[t] then return 'table model '..t end
 if context.enums[t] then
  local names=M.enums[t]
  if not names then return 'native enum '..t..' (no supported Lua conversion)' end
  local quoted={}; for _,n in ipairs(names) do quoted[#quoted+1]='"'..n..'"' end
  return 'enum '..t..': '..table.concat(quoted,', ')..(t=='ShutdownPolicy' and ' (request strings only)' or '; unknown values remain Lua integers')
 end
 error('unknown native field type: '..t)
end
function M.classify(data)
 for name in pairs(data.types) do assert(not data.enums[name],'ambiguous model/enum category: '..name) end
 local S=require('inventory_source')
 for _,model in pairs(data.types) do for _,f in ipairs(model.fields) do f.lua=S.lua(f.native_type,data) end end
end
function M.reachability(data)
 local included,excluded={},{}
 local function visit(t,seen)
  local name=M.base(t)
  if seen[name] then return end
  if data.types[name] then
   seen[name]=true
   for _,f in ipairs(data.types[name].fields) do visit(f.native_type,seen) end
  elseif data.enums[name] then seen[name]=true end
 end
 for _,op in ipairs(data.operations) do
  local seen=op.tier=='excluded' and excluded or included
  visit(op.response.native_type,seen)
  for _,a in ipairs(op.request) do visit(a.native_type,seen) end
 end
 visit('LocalClientOptions',included)
 for _,collection in ipairs{data.types,data.enums} do
  for name,v in pairs(collection) do
   v.lua_scope=included[name] and 'included' or 'native-only'
   v.operation_reachability=included[name] and (excluded[name] and 'included and excluded' or 'included') or (excluded[name] and 'excluded only' or 'no operation reference')
  end
 end
end
return M
