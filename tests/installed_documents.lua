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
