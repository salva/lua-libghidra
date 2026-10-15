-- Accepted red-stage module-load reproducer, preserved verbatim in behavior.
package.path='./lua/?.lua;./lua/?/init.lua'
package.cpath='./build/?.so'
local n=0
for _,m in ipairs{'libghidra._native','libghidra.lowlevel','libghidra'} do
  local ok,v=pcall(require,m); print(m,ok,v); if not ok then n=n+1 end
end
assert(n==0,'required foundation modules unavailable')
