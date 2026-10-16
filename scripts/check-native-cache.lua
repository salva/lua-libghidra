#!/usr/bin/env lua5.4
-- MIT Copyright 2026 Salvador Fandiño. Isolated cold/warm/read-only cache.
local root=arg[0]:match('^(.*)/scripts/') or '.'
package.path=root..'/scripts/?.lua;'..package.path
local C=require('native_probe_checks')
local probe,elf,home,address=C.absolute(assert(arg[1])),C.absolute(assert(arg[2])),C.absolute(assert(arg[3])),assert(arg[4])
C.ordinary()
-- Logs remain in a caller-owned sibling; HOME itself must start absent.
local work=home..'-logs'; C.fresh(work)
C.cache(work,home,function(label) C.run(work,label,{probe,'',elf,address,''},home) end)
print('Sentinel/files unchanged; ordinary-user read-only cache reuse verified')
