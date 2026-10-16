#!/usr/bin/env lua5.4
-- MIT Copyright 2026 Salvador Fandiño. Explicit lock refresh, never configure.
-- Caller supplies output; existing accepted lock is never silently overwritten.
local root=arg[0]:match('^(.*)/scripts/') or '.'
package.path=root..'/scripts/?.lua;'..package.path
local U,S=require('tool_util'),require('system_lock')
local encode=require('tool_json_encode')
local archives,output=assert(arg[1],'archive directory required'),assert(arg[2],'fresh output lock path required')
assert(not U.exists(output),'output lock must not exist')
local offline=arg[3]=='--offline'; assert(not arg[3] or offline,'unknown option')
U.run{'mkdir','-p',archives}
local base='https://archive.ubuntu.com/ubuntu/'
local function fetch(url,name)
 local dest=archives..'/'..name
 if not U.exists(dest) then
  assert(not offline,'missing offline archive '..name)
  U.run{'curl','--fail','--location','--proto','=https','--proto-redir','=https','--output',dest..'.partial',url}
  assert(os.rename(dest..'.partial',dest))
 end
 return dest
end
local lock={platform='Ubuntu 24.04 amd64',binaries={},sources={}}
for _,pkg in ipairs{'libbinutils','libsframe1','binutils-dev','libiberty-dev','libzstd1','zlib1g','libc6','libstdc++6','libgcc-s1'} do
 local raw=U.capture{'dpkg-query','-W','-f=${Version}\t${source:Package}\t${source:Version}',pkg}
 local version,src,sv=raw:match('^([^\t]+)\t([^\t]+)\t([^\t]+)$'); assert(version,'invalid package identity')
 local meta=S.fields('\n'..U.capture{'apt-cache','show',pkg..'='..version})
 local filename=assert(meta.Filename,'missing apt filename'); U.safe(filename)
 local url=base..filename; local dest=fetch(url,assert(filename:match('([^/]+)$')))
 assert(U.hash(dest)==meta.SHA256,'binary SHA256 mismatch '..pkg)
 lock.binaries[#lock.binaries+1]={package=pkg,version=version,url=url,sha256=meta.SHA256,source=src,source_version=sv}
 if not lock.sources[src] then
  local directory=base..assert(filename:match('^(.*)/'))..'/'
  local name=src..'_'..sv:gsub('^%d+:','')..'.dsc'; U.safe(name)
  local dsc=fetch(directory..name,name)
  lock.sources[src]={version=sv,dsc_url=directory..name,dsc_sha256=U.hash(dsc),archives=S.sources(U.read(dsc),directory)}
 end
end
local n,s=S.check(lock,archives,true)
U.write(output,encode(lock)..'\n')
print('Verified',n,'binary identities; locked',s,'source control documents; candidate written to',output)
