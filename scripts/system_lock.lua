-- MIT Copyright 2026 Salvador Fandiño. Debian metadata and locked closure checks.
local U=require('tool_util')
local M={}
function M.fields(raw)
 local t={}
 for k,v in raw:gmatch('\n([%w%-]+): ([^\n]*)') do assert(not t[k] or t[k]==v,'conflicting apt metadata '..k); t[k]=v end
 return t
end
function M.sources(text,directory)
 local section=assert(text:match('Checksums%-Sha256:\n(.-)\n[^ ]'),'no source checksums')
 local rows={}
 for line in section:gmatch('[^\n]+') do
  local hash,size,name=line:match('^ (%x+) (%d+) (%S+)$')
  assert(hash and #hash==64,'invalid source checksum row'); U.safe(name); assert(not name:find('/',1,true),'source filename must be a basename')
  rows[#rows+1]={url=directory..name,sha256=hash,bytes=assert(tonumber(size))}
 end
 assert(#rows>0,'no source checksums'); return rows
end
function M.check(lock,archives,installed)
 local count=0
 for _,r in ipairs(lock.binaries) do
  local path=archives..'/'..assert(r.url:match('/([^/]+)$'))
  assert(U.hash(path)==r.sha256,'binary SHA256 mismatch '..r.package)
  if installed then
   local actual=U.capture{'dpkg-query','-W','-f=${Version}\t${source:Package}\t${source:Version}',r.package}
   assert(actual==r.version..'\t'..r.source..'\t'..r.source_version,'installed package identity mismatch '..r.package)
  end
  count=count+1
 end
 local sources=0
 for name,r in pairs(lock.sources) do
  local path=archives..'/'..assert(r.dsc_url:match('/([^/]+)$'))
  assert(U.hash(path)==r.dsc_sha256,'source control SHA256 mismatch '..name)
  local rows=M.sources(U.read(path),assert(r.dsc_url:match('^(.*)/'))..'/')
  assert(#rows==#r.archives,'source checksum count mismatch '..name)
  for i,a in ipairs(rows) do for _,key in ipairs{'url','sha256','bytes'} do assert(a[key]==r.archives[i][key],'source checksum differs '..name..' '..key) end end
  sources=sources+1
 end
 return count,sources
end
return M
