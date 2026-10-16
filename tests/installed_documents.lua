-- MIT Copyright 2026 Salvador Fandiño.
-- Regression for the red-stage missing installed shipping artifacts.
local prefix = assert(arg[1], 'installed prefix required')
-- LuaRocks retains non-module CMake data in its versioned package prefix.
-- Optional second argument is that explicit package prefix, not a search fallback.
local root = (arg[2] or prefix) .. '/share/doc/lua-libghidra/'
local function read(path)
  local f = assert(io.open(path, 'rb'), 'missing installed artifact: ' .. path)
  local s = f:read('*a'); f:close(); assert(#s > 0); return s
end
for _, path in ipairs{
  'LICENSE', 'README.md', 'native-inputs.lock.json', 'native-patched.lock.json',
  'native-system.lock.json', 'docs/API.md', 'docs/NOTICES.md',
  'docs/INSTALLED-CORE.md', 'docs/SPEC.md', 'docs/M3-CORE.md',
  'api/FIELDS.md', 'api/coverage.json', 'api/runtime-evidence-m3.json',
  'api/history/coverage-m3.json', 'docs/evidence/native-toolchain.txt',
} do read(root .. path) end
for _, name in ipairs{'libghidra','engine','protobuf','abseil','utf8-range',
  'httplib','binutils','zlib1g','libzstd1','libc6','libstdc++6','lua'} do
  read(root .. 'docs/evidence/native-notices/' .. name .. '.txt')
end
local api = read(root .. 'docs/API.md')
assert(api:find('pages%-only') and api:find('CLIENT_IN_USE', 1, true))
local notices = read(root .. 'docs/NOTICES.md')
assert(notices:find('Elias Bachaalany', 1, true))
assert(notices:find('not a\nredistribution clearance', 1, true))
local readme = read(root .. 'README.md')
assert(not readme:find('no binding implementation', 1, true))
assert(not readme:find('sol2 is provisional', 1, true))
print('installed API/fields/notices/provenance and honest current summaries PASS')

-- Operator YES/19d0945 is narrow SOURCE-build authority, not runtime permission.
local spec = read(root .. 'docs/SPEC.md')
assert(spec:find('approved one narrow exception', 1, true))
assert(spec:find('unchanged pinned upstream `cpp/embed_specs.py`', 1, true))
assert(spec:find('SDK-consumer builds or installed Lua runtime', 1, true))
for _,path in ipairs{'docs/SPEC.md','docs/DESIGN.md','docs/PLAN.md',
  'docs/PACKAGE-FOUNDATION.md','docs/PACKAGE-HANDOFF.md'} do
 local text=read(root..path)
 assert(not text:find('pending operator approval',1,true), 'obsolete pending decision in '..path)
 assert(not text:find('pending authority',1,true), 'obsolete pending decision in '..path)
 assert(not text:find('Neither option is preapproved',1,true), 'obsolete pending decision in '..path)
 if arg[3] then assert(text==read(arg[3]..'/'..path), 'stale installed policy: '..path) end
end
local foundation=read(root..'docs/PACKAGE-FOUNDATION.md')
assert(foundation:find('Record Python/zlib identities',1,true))
print('installed narrow source-generator authority and exclusions PASS')
if arg[3] then
 local launch=read(arg[3]..'/workflows/LAUNCH.md')
 assert(launch:find('spec generator approved',1,true))
 assert(not launch:find('pending operator approval',1,true))
end
