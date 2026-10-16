#!/usr/bin/env lua5.4
-- MIT Copyright 2026 Salvador Fandiño. Offline exact system identity gate.
local root=arg[0]:match('^(.*)/scripts/') or '.'
package.path=root..'/scripts/?.lua;'..package.path
local U,J,S=require('tool_util'),require('tool_json'),require('system_lock')
local lock=arg[2] or root..'/native-system.lock.json'
local n,s=S.check(J.decode(U.read(lock)),assert(arg[1],'archive directory required'),true)
print('Verified',n,'installed/binary identities and',s,'source control documents (not source archives)')
