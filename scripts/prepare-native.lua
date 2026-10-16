#!/usr/bin/env lua5.4
-- MIT Copyright 2026 Salvador Fandiño. Explicit online/offline preparation.
local root=assert(arg[0]:match('^(.*)/scripts/[^/]+$') or (arg[0]:match('^scripts/') and '.'),'invoke using a project scripts path')
package.path=root..'/scripts/?.lua;'..package.path
local U=require('tool_util')
root=U.capture{'realpath',root}:gsub('\n$','')
local a={profile='unmodified'}; local i=1
while i<=#arg do
 local k=arg[i]; if k=='--offline' then a.offline=true
 else assert(k=='--archives' or k=='--output' or k=='--profile','unknown option: '..k); i=i+1; a[k:sub(3)]=assert(arg[i],'missing option value') end
 i=i+1
end
local function absolute(p)
 assert(p,'--archives and --output required')
 return U.capture{'realpath','-m','--',p}:gsub('\n$','')
end
require('native_prepare').prepare(root,absolute(a.archives),absolute(a.output),a.profile,a.offline)
