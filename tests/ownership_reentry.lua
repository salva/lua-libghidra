-- MIT Copyright 2026 Salvador Fandiño.
local low=require'libghidra.lowlevel'
-- Finalizers run from allocations in detached conversion. A native result must
-- remain valid even when the finalizer releases or destroys its source owner.
for _, finalize in ipairs{false,true} do
 local c=assert(low.local_client()); local ran=false
 local gc=debug.getmetatable(c).__gc
 collectgarbage('stop')
 do
  local pending=setmetatable({}, {__gc=function()
   ran=true
   if finalize then gc(c) else c:close() end
  end})
 end
 collectgarbage('incremental',100,1000,0)
 collectgarbage('restart')
 local saw
 for i=1,1000 do
  local status,err=c:get_status()
  if status then assert(type(status.service_name)=='string'); saw=status end
  if ran then break end
  -- Additional Lua allocations advance GC without explicit collect in call.
  local pressure={string.rep('x',1000),{}}
 end
 assert(ran,'allocation-triggered finalizer never ran')
 local status,e=c:get_status(); assert(not status and e.code=='CLOSED')
 if saw then assert(type(saw.service_name)=='string') end
 assert(low.local_client()):close()
end
collectgarbage('collect')
print('ownership allocation-triggered release/manual gc reentry PASS')
