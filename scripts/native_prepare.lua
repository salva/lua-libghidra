-- MIT Copyright 2026 Salvador Fandiño.
-- Verify every archive before extraction. Only locked regular-file/directory
-- archives are supported; links/devices are rejected rather than followed.
local U=require('tool_util')
local J=require('tool_json')
local M={}
function M.prepare(root,archives,output,profile,offline)
 assert(profile=='unmodified' or profile=='bfd-sleigh-target-autodetect','unknown profile')
 assert(not U.exists(output),'output must not exist: use a fresh directory')
 local lock=J.decode(U.read(root..'/native-inputs.lock.json'))
 U.run{'mkdir','-p',archives}
 for _,r in ipairs(lock.inputs) do
  local file=archives..'/'..r.name..(r.name=='specs' and '.zip' or '.tar.gz')
  if not U.exists(file) then
   assert(not offline,'missing offline archive: '..file)
   -- Separate explicit preparation only; configure never calls this downloader.
   U.run{'curl','--fail','--location','--proto','=https','--proto-redir','=https','--output',file..'.partial',r.url}
   assert(os.rename(file..'.partial',file))
  end
  assert(U.hash(file)==r.sha256,'SHA256 mismatch: '..file)
  print(r.name,r.sha256)
 end
 local p
 if profile~='unmodified' then
  p=J.decode(U.read(root..'/native-patched.lock.json'))
  assert(U.hash(root..'/native-inputs.lock.json')==p.base_lock_sha256,'base lock changed; requalify patched profile')
  for _,r in ipairs(lock.inputs) do
   if r.name=='libghidra' then assert(r.revision==p.patch_source_revision,'profile revision mismatch') end
   if r.name=='engine' then assert(r.revision==p.engine_revision,'profile revision mismatch') end
  end
 end
 -- Preflight all paths and entry kinds before creating output. GNU tar's
 -- escaped listings are rejected by safe(), never interpreted as raw names.
 local overlays={}
 for _,r in ipairs(lock.inputs) do
  U.safe(r.directory)
  local file=archives..'/'..r.name..(r.name=='specs' and '.zip' or '.tar.gz')
  if r.name=='specs' then
   for name in U.capture{'unzip','-Z1',file}:gmatch('[^\n]+') do
    U.safe(name)
    if name:find('/data/languages/',1,true) and name:sub(-1)~='/' then
     assert(not name:find('[*?%[%]]'),'unsupported zip wildcard name')
     overlays[#overlays+1]={name=name,relative=U.safe(assert(name:match('^[^/]+/(.+)$')))}
    end
   end
   assert(#overlays>0,'no spec language files')
  else
   local top
   for name in U.capture{'tar','-tzf',file}:gmatch('[^\n]+') do
    U.safe(name); local first=name:match('^([^/]+)'); top=top or first; assert(top==first,'mixed archive roots')
   end
   for line in U.capture{'tar','-tvzf',file}:gmatch('[^\n]+') do
    assert(line:sub(1,1)=='-' or line:sub(1,1)=='d','archive links or special files are unsupported')
   end
  end
 end
 U.run{'mkdir',output}
 for _,r in ipairs(lock.inputs) do
  if r.name~='specs' then
   local dest=output..'/'..r.directory; U.run{'mkdir',dest}
   U.run{'tar','-xzf',archives..'/'..r.name..'.tar.gz','--strip-components=1','--no-same-owner','--no-same-permissions','-C',dest}
  else
   for _,entry in ipairs(overlays) do
    local dest=output..'/engine/'..entry.relative
    U.run{'mkdir','-p',assert(dest:match('^(.*)/'))}
    U.write(dest,U.capture{'unzip','-p',archives..'/specs.zip',entry.name})
   end
  end
 end
 if p then
  local lib
  for _,r in ipairs(lock.inputs) do if r.name=='libghidra' then lib=r.directory end end
  local patch=output..'/'..assert(lib)..'/'..p.patch_path
  assert(U.hash(patch)==p.patch_sha256,'patch digest mismatch')
  U.run{'patch','--batch','--fuzz=0','-p1','-d',output..'/engine','-i',patch}
  U.write(output..'/native-profile.json',U.read(root..'/native-patched.lock.json'))
 end
 print('Prepared',output,profile)
end
return M
