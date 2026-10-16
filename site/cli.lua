-- MIT Copyright 2026 Salvador Fandiño.
local M={}
function M.options(arguments, names)
  local allowed={}; for _,name in ipairs(names) do allowed[name]=true end
  local options={}
  assert(#arguments%2==0,'options require explicit values')
  for i=1,#arguments,2 do
    local name=arguments[i]
    assert(allowed[name] and options[name]==nil,'unknown/duplicate option: '..tostring(name))
    options[name]=arguments[i+1]
  end
  for name in pairs(allowed) do assert(options[name]~=nil,'missing option: '..name) end
  return options
end
return M
