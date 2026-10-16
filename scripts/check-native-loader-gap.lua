#!/usr/bin/env lua5.4
-- MIT Copyright 2026 Salvador Fandiño. Known unmodified gap, NOT readiness.
local root=arg[0]:match('^(.*)/scripts/') or '.'
package.path=root..'/scripts/?.lua;'..package.path
local U,C=require('tool_util'),require('native_probe_checks')
local build,specs,work=C.absolute(assert(arg[1])),C.absolute(assert(arg[2])),C.absolute(assert(arg[3]))
U.run{'mkdir','-p',work}
local probe,elf,raw=build..'/native_probe',build..'/native_smoke',work..'/smoke-text.raw'
U.run{'objcopy','-O','binary','--only-section=.text',elf,raw}
local address=assert(U.capture{'nm',elf}:match('(%x+)%s+%w%s+native_smoke\n'))
local base=assert(U.capture{'objdump','-h',elf}:match('%s%d+%s+%.text%s+%x+%s+(%x+)'))
for _,r in ipairs{{'elf-explicit',elf,'','0'},{'elf-format-raw',elf,'raw','0'},{'raw-explicit',raw,'raw','0x'..base}} do
 C.run(work,r[1],{probe,specs,r[2],'0x'..address,'x86:LE:64:default',r[3],r[4]},nil,4,'Unable to open image file:')
end
C.run(work,'elf-auto control',{probe,specs,elf,'0x'..address,''})
print('KNOWN GAP CONFIRMED, NOT READINESS PASS')
