#!/usr/bin/env lua5.4
-- MIT Copyright 2026 Salvador Fandiño. Exact locked profile source accounting.
-- Reconstruct the authorized profile from verified archives, then compare all
-- files, including unexpected additions. Only normal generated metadata excluded.
local root=arg[0]:match('^(.*)/scripts/') or '.'
package.path=root..'/scripts/?.lua;'..package.path
local U,C=require('tool_util'),require('native_probe_checks')
local archives,inputs,work=C.absolute(assert(arg[1])),C.absolute(assert(arg[2])),C.absolute(assert(arg[3],'fresh comparison work required'))
C.fresh(work)
local expected=work..'/expected'
require('native_prepare').prepare(C.absolute(root),archives,expected,'bfd-sleigh-target-autodetect',true)
local function files(dir)
 local result={}
 for p in U.capture{'find',dir,'-type','f','-print0'}:gmatch('([^\0]+)\0') do result[p:sub(#dir+2)]=true end
 return result
end
for _,name in ipairs{'libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d','engine','protobuf','abseil','httplib'} do
 local want,actual=expected..'/'..name,inputs..'/'..name
 local a,b=files(want),files(actual)
 local excluded='python/src/libghidra/known_languages.py'
 if name:match('^libghidra') then a[excluded]=nil; b[excluded]=nil end
 for p in pairs(a) do assert(b[p],'missing source '..name..'/'..p); assert(U.read(want..'/'..p)==U.read(actual..'/'..p),'source bytes differ '..name..'/'..p) end
 for p in pairs(b) do assert(a[p],'unexpected source '..name..'/'..p) end
 -- No hidden link/special-file substitutions accepted in prepared inputs.
 assert(U.capture{'find',actual,'!','-type','f','!','-type','d','-print'}=='','unexpected source entry kind')
 print(name,'all authored source/spec bytes match exact authorized profile')
end
assert(U.read(inputs..'/native-profile.json')==U.read(expected..'/native-profile.json'),'profile marker differs')
print('ALL LOCKED PROFILE INPUTS MATCH (generated language metadata excluded)')
