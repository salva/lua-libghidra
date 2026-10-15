-- MIT Copyright 2026 Salvador Fandiño.
-- Two actual separately loaded DSO files must share the process-wide slot.
local build = assert(arg[1])
local a = assert(package.loadlib(build .. '/libghidra/_native.so',
                               'luaopen_libghidra__native'))()
local b = assert(package.loadlib(build .. '/loaded-copy/_native.so',
                               'luaopen_libghidra__native'))()
for _, pair in ipairs({{a,b}, {b,a}}) do
  local first = assert(pair[1].local_client())
  local second, err = pair[2].local_client()
  -- Cleanup even when the exclusion assertion will fail. Do not let teardown
  -- order hide the primary competing-construction failure.
  if second then assert(second:close()) end
  assert(first:close())
  assert(second == nil, 'separate loaded copy admitted a second native owner')
  assert(type(err) == 'table' and err.code == 'CLIENT_IN_USE'
         and err.backend == 'binding', 'wrong competing-construction error')
  local retry = assert(pair[2].local_client())
  assert(retry:get_status())
  assert(retry:close())
end
collectgarbage('collect')
print('loaded-copy process guard and reversed teardown PASS')
