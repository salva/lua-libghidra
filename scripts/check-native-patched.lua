#!/usr/bin/env lua5.4
-- MIT Copyright 2026 Salvador Fandiño. Actual patched SDK controls.
local root=arg[0]:match('^(.*)/scripts/') or '.'
package.path=root..'/scripts/?.lua;'..package.path
local U,C=require('tool_util'),require('native_probe_checks')
local build,specs,work=C.absolute(assert(arg[1])),C.absolute(assert(arg[2])),C.absolute(assert(arg[3]))
C.ordinary(); C.fresh(work)
local probe,elf=build..'/native_probe',build..'/native_smoke'
local address=assert(U.capture{'nm',elf}:match('(%x+)%s+%w%s+native_smoke\n'),'native_smoke symbol absent')
for _,hint in ipairs{'x86:LE:64:default',''} do
 local tag=hint=='' and 'auto' or 'explicit'
 local external=work..'/external-home-'..tag
 local function run(label,spec,home,expected,diagnostic)
  C.run(work,label..'-'..tag,{probe,spec,elf,'0x'..address,hint},home,expected,diagnostic)
 end
 run('external',specs,external); assert(not U.exists(external),'external path used HOME cache')
 local home=work..'/embedded-home-'..tag
 C.cache(work,home,function(label) run('embedded-'..label,'',home) end)
 run('embedded-cold-unwritable','','/proc',4,'failed to create cache dir')
 run('external-missing',work..'/absent',external,4,'No sleigh specification')
 local unreadable=work..'/unreadable-'..tag; U.run{'mkdir',unreadable}; U.run{'chmod','000',unreadable}
 local ok,e=xpcall(function() run('external-unreadable',unreadable,external,4,'No sleigh specification') end,debug.traceback)
 U.run{'chmod','700',unreadable}; assert(ok,e)
end
print('ALL PATCHED PROFILE CONTROLS PASSED')
