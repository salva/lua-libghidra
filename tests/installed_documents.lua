-- MIT Copyright 2026 Salvador Fandiño.
local here = assert(arg[0]:match('^(.*)/[^/]+$'), 'invoke with explicit script path')
local policy = dofile(here .. '/../scripts/package-documents.lua')
local mode, root, source, manifest
if arg[1]=='source' and #arg==3 then
  mode,root,source,manifest='source',arg[2],arg[2],arg[3]
elseif arg[1]=='installed' and #arg==4 then
  mode,root,source,manifest='installed',arg[2],arg[3],arg[4]
else
  error('usage: source SOURCE_ROOT MANIFEST | installed DOCUMENT_ROOT SOURCE_ROOT MANIFEST',0)
end
local ok, result=pcall(policy.check,mode,root,source,manifest)
if not ok then io.stderr:write(result,'\n'); os.exit(1) end
print(mode .. ' documents PASS: ' .. result .. ' manifest members; graph/content' ..
  (mode=='installed' and '/membership/bytes' or ''))
