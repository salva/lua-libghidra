#!/usr/bin/env lua5.4
-- MIT Copyright 2026 Salvador Fandiño. Native extraction artifact, no Python.
-- Deliberately does not overwrite the reviewed semantic/runtime coverage ledger.
local root=arg[0]:match('^(.*)/scripts/') or '.'
package.path=root..'/scripts/?.lua;'..package.path
local U=require('tool_util')
local source,output=assert(arg[1],'pinned source directory required'),assert(arg[2],'fresh output JSON path required')
assert(#arg==2,'usage: inventory-api.lua SOURCE FRESH_NATIVE_JSON')
assert(not U.exists(output),'output must not exist')
local scratch=output..'.body-hash'
assert(not U.exists(scratch),'fingerprint scratch must not exist')
local ok,data=xpcall(function()
 return require('inventory_native').inventory(source,function(body)
  U.write(scratch,body)
  return U.hash(scratch)
 end)
end,debug.traceback)
if U.exists(scratch) then assert(os.remove(scratch)) end
assert(ok,data)
U.write(output,require('tool_json_encode')(data)..'\n')
print('Wrote native extraction and page branch reviews; remaining semantic migration open:',output)
