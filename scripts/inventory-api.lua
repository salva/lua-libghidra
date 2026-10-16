#!/usr/bin/env lua5.4
-- MIT Copyright 2026 Salvador Fandiño. Native extraction artifact, no Python.
-- Deliberately does not overwrite the reviewed semantic/runtime coverage ledger.
local root=arg[0]:match('^(.*)/scripts/') or '.'
package.path=root..'/scripts/?.lua;'..package.path
local U=require('tool_util')
local source,output=assert(arg[1],'pinned source directory required'),assert(arg[2],'fresh output JSON path required')
assert(#arg==2 or (#arg==3 and arg[3]=='--coverage'),'usage: inventory-api.lua SOURCE FRESH_JSON [--coverage]')
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
if arg[3]=='--coverage' then data=require('inventory_coverage').assemble(data,U.read(root..'/docs/COVERAGE.md')) end
U.write(output,require('tool_json_encode')(data)..'\n')
print(arg[3]=='--coverage' and 'Wrote integrated native-only source coverage (runtime evidence separate):' or 'Wrote native review artifact:',output)
