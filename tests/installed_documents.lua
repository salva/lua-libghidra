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

-- R1: technical source-build success is not retained-generator permission.
-- Keep the original red-stage claim probes; also require the pending disposition.
local policy={
 {'docs/SPEC.md','approved one narrow exception'},
 {'docs/DESIGN.md','is explicitly approved'},
 {'docs/PLAN.md','The operator approved the unchanged pinned upstream'},
 {'docs/PACKAGE-FOUNDATION.md','explicitly approved this narrow'},
 {'docs/PACKAGE-HANDOFF.md','The operator approved this unchanged pinned'},
}
for _, row in ipairs(policy) do
 local text=read(root..row[1])
 assert(not text:find(row[2],1,true), 'unsupported generator authority: '..row[1])
 assert(not text:find('operator-approved exception',1,true))
 assert(not text:find('Operator decision: **accepted**',1,true))
 assert(not text:find('generator decision — resolved',1,true))
 -- Normalize line wrapping, not meaning.
 local normalized=text:gsub('%s+',' ')
 assert(normalized:find('pending operator approval',1,true), row[1])
 assert(normalized:find('separately authorized and qualified',1,true), row[1])
 assert(normalized:find('Neither option is preapproved',1,true), row[1])
 if arg[3] then
  assert(text==read(arg[3]..'/'..row[1]), 'stale installed policy: '..row[1])
 end
end
if arg[3] then
 local launch=read(arg[3]..'/workflows/LAUNCH.md')
 assert(not launch:find('This resolves the specific external policy blocker',1,true))
 assert(not launch:find('spec generator approved',1,true))
 assert(launch:find('pending operator approval',1,true))
 assert(launch:find('remains unresolved',1,true))
end
print('installed retained-generator pending authority and optional source freshness PASS')
