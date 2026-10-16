-- MIT Copyright 2026 Salvador Fandiño. Lock refresh/equivalence/failure tests.
package.path='scripts/?.lua;'..package.path
local U,J,S=require('tool_util'),require('tool_json'),require('system_lock')
local encode=require('tool_json_encode')
local function equal(a,b)
 assert(type(a)==type(b),'type mismatch')
 if type(a)~='table' then assert(a==b,'value mismatch'); return end
 for k,v in pairs(a) do assert(b[k]~=nil,'missing key'); equal(v,b[k]) end
 for k in pairs(b) do assert(a[k]~=nil,'extra key') end
end
local function reject(f,needle) local ok,e=pcall(f); assert(not ok and tostring(e):find(needle,1,true),tostring(e)) end
local lock=J.decode(U.read('native-system.lock.json'))
equal(lock,J.decode(U.read(assert(arg[1],'candidate lock path required'))))
equal(lock,J.decode(encode(lock)))
local escaped={a='\0\1\n\r\t"\\',b=false,c={1,2,3}}; equal(escaped,J.decode(encode(escaped)))
reject(function() encode(0/0) end,'nonfinite'); reject(function() encode({[1]=1,k=2}) end,'mixed')
assert(S.fields('\nFilename: pool/file\nSHA256: abc\n').Filename=='pool/file')
reject(function() S.fields('\nSHA256: a\nSHA256: b\n') end,'conflicting')
for _,bad in ipairs{'missing','Checksums-Sha256:\n bogus\nX: y','Checksums-Sha256:\n '..string.rep('a',64)..' 1 ../escape\nX: y'} do reject(function() S.sources(bad,'https://example.invalid/') end,'') end
local archives=assert(arg[2],'archives required')
local n,s=S.check(lock,archives,true); assert(n==9 and s==6)
local function copy() return J.decode(encode(lock)) end
local changed=copy(); changed.binaries[1].sha256=string.rep('0',64)
reject(function() S.check(changed,archives,true) end,'binary SHA256 mismatch')
changed=copy(); changed.binaries[1].version='not-installed'
reject(function() S.check(changed,archives,true) end,'installed package identity mismatch')
changed=copy(); local name=next(changed.sources); changed.sources[name].dsc_sha256=string.rep('0',64)
reject(function() S.check(changed,archives,true) end,'source control SHA256 mismatch')
changed=copy(); name=next(changed.sources); changed.sources[name].archives[1].bytes=0
reject(function() S.check(changed,archives,true) end,'source checksum differs')
print('Lua system lock equivalence/roundtrip/metadata/hash/identity/source corruption PASS')
