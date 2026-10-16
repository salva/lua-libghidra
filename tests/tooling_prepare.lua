-- MIT Copyright 2026 Salvador Fandiño. Lua-owned preparation regressions.
package.path='scripts/?.lua;'..package.path
local U,J,P=require('tool_util'),require('tool_json'),require('native_prepare')
local work=assert(arg[1]); assert(not U.exists(work),'fresh test work required'); U.run{'mkdir','-p',work}
local function rejects(f,pattern)
 local ok,e=pcall(f); assert(not ok,'unexpected success'); assert(tostring(e):find(pattern,1,true),tostring(e))
end
for _,bad in ipairs{'../escape','/absolute','root/../escape','root\\escape','root\nline','root/./file'} do rejects(function() U.safe(bad) end,'unsafe') end
local j=J.decode('{"a":false,"b":null,"s":"\\uD834\\uDD1E","v":[0,-2,1.5e2]}')
assert(j.a==false and j.b==J.null and j.s==utf8.char(0x1d11e) and j.v[3]==150)
for _,bad in ipairs{'{"a":1,"a":2}','[1,]','{"x":}','true false','"\\uD800"','01','1e','1.'} do rejects(function() J.decode(bad) end,'') end
local root=work..'/fixture'; local archives=work..'/archives'
U.run{'mkdir','-p',root..'/payload/top',root..'/spec/top/Ghidra/Processors/Test/data/languages',archives}
U.write(root..'/payload/top/source','source bytes\0\255')
U.write(root..'/spec/top/Ghidra/Processors/Test/data/languages/test.sla','spec bytes\0\255')
U.run{'tar','-czf',archives..'/engine.tar.gz','-C',root..'/payload','top'}
U.run{'sh','-c','cd '..U.quote(root..'/spec')..' && zip -qr '..U.quote(archives..'/specs.zip')..' top'}
local function lock(enginehash)
 U.write(root..'/native-inputs.lock.json','{"inputs":[{"name":"engine","directory":"engine","revision":"engine-pin","sha256":"'..(enginehash or U.hash(archives..'/engine.tar.gz'))..'"},{"name":"specs","directory":"engine","sha256":"'..U.hash(archives..'/specs.zip')..'"}]}')
end
lock()
local out=work..'/good'
P.prepare(root,archives,out,'unmodified',true)
assert(U.read(out..'/engine/source')=='source bytes\0\255')
assert(U.read(out..'/engine/Ghidra/Processors/Test/data/languages/test.sla')=='spec bytes\0\255')
rejects(function() P.prepare(root,archives,out,'unmodified',true) end,'output must not exist')
lock(string.rep('0',64))
rejects(function() P.prepare(root,archives,work..'/badhash','unmodified',true) end,'SHA256 mismatch')
assert(not U.exists(work..'/badhash'))
lock(); U.run{'mv',archives..'/engine.tar.gz',archives..'/saved'}
rejects(function() P.prepare(root,archives,work..'/missing','unmodified',true) end,'missing offline archive')
assert(not U.exists(work..'/missing')); U.run{'mv',archives..'/saved',archives..'/engine.tar.gz'}
U.run{'ln','-s','/tmp/escape',root..'/payload/top/link'}
U.run{'tar','-czf',archives..'/engine.tar.gz','-C',root..'/payload','top'}; lock()
rejects(function() P.prepare(root,archives,work..'/link','unmodified',true) end,'links or special files')
assert(not U.exists(work..'/link'))
U.write(root..'/native-patched.lock.json','{"base_lock_sha256":"wrong"}')
rejects(function() P.prepare(root,archives,work..'/profile','bfd-sleigh-target-autodetect',true) end,'base lock changed')
assert(not U.exists(work..'/profile'))
print('Lua JSON, path/hash/missing/profile/link fail-closed and binary overlay preparation PASS')
-- Real archive traversal is rejected before output, not merely helper tested.
U.run{'rm',root..'/payload/top/link'}
U.run{'tar','-czf',archives..'/engine.tar.gz','--transform=s|top/source|top/../../escape|','-C',root..'/payload','top'}; lock()
rejects(function() P.prepare(root,archives,work..'/traversal','unmodified',true) end,'unsafe archive component')
assert(not U.exists(work..'/traversal') and not U.exists(work..'/escape'))
U.run{'tar','-czf',archives..'/engine.tar.gz','-C',root..'/payload','top'}; lock()
U.write(root..'/native-patched.lock.json','{"base_lock_sha256":"'..U.hash(root..'/native-inputs.lock.json')..'","engine_revision":"wrong"}')
rejects(function() P.prepare(root,archives,work..'/revision','bfd-sleigh-target-autodetect',true) end,'profile revision mismatch')
assert(not U.exists(work..'/revision'))
-- Quoting must survive shell metacharacters and spaces without side effects.
local odd=work.."/a 'quoted; file"
U.write(odd,'quoted'); assert(U.capture{'cat',odd}=='quoted')
print('Real archive traversal, revision and shell-argument regression PASS')
