-- MIT Copyright 2026 Salvador Fandiño.
-- Shared package/site policy. No inventory lives here: consume CMake's export.
local M = {}
local function fail(category, path, detail)
  error(category .. ': ' .. path .. (detail and (' -> ' .. detail) or ''), 0)
end
local function read(path, category)
  local f = io.open(path, 'rb')
  if not f then fail(category or 'missing-member', path) end
  local text = f:read('*a'); f:close(); return text
end
local function quote(s) return "'" .. s:gsub("'", "'\\''") .. "'" end
function M.absolute(path)
  if type(path) ~= 'string' or path:sub(1,1) ~= '/' or path:find('%z') then
    fail('invalid-argument', tostring(path), 'absolute path required')
  end
  return path:gsub('/+$', '')
end
-- Same lexical policy for selected document paths and all document bytes.
-- Ordinary build/source/license vocabulary is deliberately not prohibited.
local function forbidden(text)
  local lower=text:lower()
  for _,pattern in ipairs{'saivage', 'card://', 'record://', 'work://', '%[%[card:', 'card%-[a-z]+'} do
    if lower:find(pattern) then return pattern end
  end
end
function M.manifest(path)
  M.absolute(path)
  local text = read(path, 'invalid-manifest')
  if text == '' or text:sub(-1) ~= '\n' then fail('invalid-manifest', path, 'final newline required') end
  local list, set = {}, {}
  for entry in text:gmatch('([^\n]*)\n') do
    if entry == '' or entry:sub(1,1) == '/' or entry:find('[^%w%._/+%-]')
      or entry:find('//',1,true) or entry:sub(-1) == '/' then
      fail('invalid-manifest', path, entry)
    end
    for part in entry:gmatch('[^/]+') do
      if part == '.' or part == '..' then fail('invalid-manifest', path, entry) end
    end
    if set[entry] then fail('invalid-manifest', path, 'duplicate ' .. entry) end
    local marker=forbidden(entry)
    if marker then fail('forbidden-filename',entry,marker) end
    set[entry] = true; list[#list+1] = entry
  end
  return list, set
end
local credit = 'Saivage was used in creating this project.'
local function content(path, text)
  local first=text:find(credit,1,true)
  local stripped=text
  if first then
    if path~='README.md' or text:find(credit,first+#credit,true) then
      fail('invalid-credit',path)
    end
    -- Only a complete literal line in an acknowledgment section is exempt.
    -- Track fenced code/comments so fake headings cannot grant an exemption.
    local section, fence, fence_length, comment, previous = false, nil, 0, false, nil
    local offset, permitted = 1, false
    for line in (text..'\n'):gmatch('(.-)\n') do
      local run=line:match('^%s*(```+)') or line:match('^%s*(~~~+)')
      local hidden=comment or line:find('<!--',1,true)
      if line:find('<!--',1,true) then comment=true end
      if line:find('-->',1,true) then comment=false end
      if run and not hidden and (not fence or (run:sub(1,1)==fence and #run>=fence_length)) then
        if fence then fence=nil else fence=run:sub(1,1); fence_length=#run end
      elseif not fence and not hidden then
        local heading=line:match('^#+%s+(.+)')
        if not heading and (line:match('^===+%s*$') or line:match('^%-%-%-+%s*$')) then heading=previous end
        if heading then
          heading=heading:gsub('%s+#+%s*$',''):lower()
          section=heading=='acknowledgment' or heading=='acknowledgments'
            or heading=='acknowledgement' or heading=='acknowledgements'
        end
        if line==credit and offset==first and section then permitted=true end
      end
      previous=(not fence and not hidden and line~='') and line or nil
      offset=offset+#line+1
    end
    if not permitted then fail('invalid-credit',path) end
    stripped=text:sub(1,first-1)..text:sub(first+#credit)
  end
  local marker=forbidden(stripped)
  if marker then fail('forbidden-content',path,marker) end
end
-- Strip only Markdown code for graph analysis, never for the all-byte policy.
local function prose(text)
  local lines, fence, length = {}, nil, 0
  for line in (text .. '\n'):gmatch('(.-)\n') do
    local run = line:match('^%s*(```+)') or line:match('^%s*(~~~+)')
    if run and (not fence or (run:sub(1,1) == fence and #run >= length)) then
      if fence then fence=nil else fence=run:sub(1,1); length=#run end
      lines[#lines+1]=''
    elseif not fence and not line:match('^    ') and not line:match('^\t') then
      lines[#lines+1]=line
    else lines[#lines+1]='' end
  end
  return table.concat(lines, '\n')
end
local function decode(s, path)
  if s:find('%%[^%x]') or s:find('%%$') or s:find('%%[A-Fa-f0-9]$') then
    fail('unsupported-markup', path, s)
  end
  return (s:gsub('%%(%x%x)', function(h) return string.char(tonumber(h,16)) end))
end
local function slug(s)
  return s:lower():gsub('`',''):gsub('[^%w%s_%-]',''):gsub('%s','-')
end
-- One allocator per document. Preserve per-base suffix counting, including
-- collisions with literal suffixed bases; consumers share this exact policy.
function M.heading_ids()
  local counts = {}
  return function(heading)
    local base=slug(heading); local n=counts[base] or 0
    counts[base]=n+1
    return base .. (n>0 and ('-'..n) or '')
  end
end
-- Raw source spellings in encounter order, before inline rendering. Keep this
-- extraction authoritative for package fragments and site Header assignment.
function M.heading_texts(text)
  local headings = {}
  local previous
  for line in (prose(text)..'\n'):gmatch('(.-)\n') do
    local heading = line:match('^%s*#+%s+(.+)')
    if not heading and (line:match('^===+%s*$') or line:match('^%-%-%-+%s*$')) then
      heading=previous
    end
    previous=line~='' and line or nil
    if heading then
      heading=heading:gsub('%s+#+%s*$','')
      headings[#headings+1]=heading
    end
  end
  return headings
end
local function anchors(text)
  local found, id = {}, M.heading_ids()
  for _,heading in ipairs(M.heading_texts(text)) do
    found[id(heading)]=true
  end
  return found
end
local function normalize(path, target)
  local dir = path:match('^(.*)/') or ''
  local parts={}
  if target:sub(1,1)=='/' then fail('missing-link-target',path,target) end
  for part in ((dir ~= '' and (dir..'/') or '')..target):gmatch('[^/]+') do
    if part=='..' then
      if #parts==0 then fail('missing-link-target',path,target) end
      table.remove(parts)
    elseif part~='.' then parts[#parts+1]=part end
  end
  return table.concat(parts,'/')
end
local function refkey(s) return s:lower():gsub('%s+',' '):match('^%s*(.-)%s*$') end
local function graph(path, text, files, headings)
  local body=('\n'..prose(text)):gsub('(`+)(.-)%1', '')
  -- We support Markdown links, not hidden HTML/MDX link or anchor semantics.
  local html=body:lower()
  if html:find('<%s*/?[a-z][a-z0-9]*%s+[^>]*>') or html:find('<!')
    or html:find('<%s*/?a[/>]') or html:find('<%s*/?img[/>]')
    or html:find('<%s*/?div[/>]') or html:find('<%s*/?span[/>]') then
    fail('unsupported-markup',path,'HTML')
  end
  local refs={}
  body=body:gsub('\n%s*%[([^%]\n]+)%]:%s*([^\n]+)', function(key,value)
    refs[refkey(key)]=value; return '\n'
  end)
  local function link(raw)
    local target = raw:match('^%s*<([^>]+)>') or raw:match('^%s*(%S+)')
    if not target then fail('unsupported-markup',path,raw) end
    -- Optional quoted titles are harmless; arbitrary trailing markup is not.
    local rest=raw:match('^%s*<[^>]+>%s*(.-)%s*$') or raw:match('^%s*%S+%s*(.-)%s*$')
    if rest~='' and not rest:match('^".*"$') and not rest:match("^'.*'$") then
      fail('unsupported-markup',path,raw)
    end
    if target:match('^[%a][%w+%.%-]*:') or target:sub(1,2)=='//' then return end
    target=decode(target,path)
    if target:find('[%z\r\n]') or target:find('?',1,true) or target:find('\\',1,true) then
      fail('unsupported-markup',path,target)
    end
    local dest,fragment=target:match('^(.-)#(.*)$')
    dest=dest or target
    dest=dest=='' and path or normalize(path,dest)
    if not files[dest] then fail('missing-link-target',path,target) end
    if fragment and fragment~='' and not (headings[dest] or {})[fragment] then
      fail('missing-fragment',path,target)
    end
  end
  body=body:gsub('!?%[([^%]\n]*)%]%(([^\n]-)%)', function(_,target) link(target); return '' end)
  body=body:gsub('!?%[([^%]\n]+)%]%[([^%]\n]*)%]', function(label,key)
    key=key=='' and label or key
    if not refs[refkey(key)] then fail('missing-link-target',path,'reference '..key) end
    link(refs[refkey(key)]); return ''
  end)
  body=body:gsub('!?%[([^%]\n]+)%]', function(key)
    if refs[refkey(key)] then link(refs[refkey(key)]) end
    return ''
  end)
  if body:find('%]%(') or body:find('%]%[') then fail('unsupported-markup',path,'unparsed link') end
end
function M.check(mode, root, source, manifest)
  root=M.absolute(root); source=M.absolute(source)
  local list,set=M.manifest(manifest)
  -- Enforce required product membership before graph traversal, so removing a
  -- page and its manifest entry cannot turn a policy obligation into a link error.
  if set['native-inputs.lock.json'] or set['native-patched.lock.json'] or set['native-system.lock.json'] or set['api/FIELDS.md'] then
    for _,path in ipairs{'README.md','docs/API.md','docs/NOTICES.md','docs/EXAMPLES.md',
      'docs/INSTALL.md','docs/TUTORIAL.md','examples/decompile.lua','examples/inspect_function.lua',
      'native-inputs.lock.json','native-patched.lock.json','native-system.lock.json','api/FIELDS.md'} do
      if not set[path] then fail('missing-policy',path,'required product member') end
    end
  end
  local files,headings={},{}
  -- Membership and existence always precede graph/content and freshness.
  -- Inspect file kinds before opening: never follow a link or block on a FIFO.
  if mode=='installed' then
    local p=assert(io.popen('find '..quote(root)..' -mindepth 1 -printf '..quote('%y %P\\0'),'r'))
    local output=p:read('*a'); assert(p:close())
    for item in output:gmatch('([^%z]+)%z') do
      local kind,relative=item:sub(1,1),item:sub(3)
      if kind~='d' then
        if not set[relative] or kind~='f' then
          fail('unlisted-document',relative,'nonmember or nonregular file')
        end
      end
    end
  end
  for _,path in ipairs(list) do files[path]=read(root..'/'..path) end
  for _,path in ipairs(list) do
    content(path,files[path])
    if path:match('%.md$') then headings[path]=anchors(files[path]) end
  end
  for _,path in ipairs(list) do
    if path:match('%.md$') then graph(path,files[path],files,headings) end
  end
  -- Substantive current safety/scope obligations; independent of prose wrapping.
  local function require_facts(path, facts)
    local text=assert(files[path], 'missing policy member '..path):gsub('%s+',' ')
    for _,fact in ipairs(facts) do
      if not text:find(fact,1,true) then fail('missing-policy',path,fact) end
    end
  end
  -- Product manifests are recognized by any stable product asset, not a page
  -- conjunction that renaming/removing a policy page could disable.
  if files['native-inputs.lock.json'] or files['native-patched.lock.json'] or
     files['native-system.lock.json'] or files['api/FIELDS.md'] then
    for _,path in ipairs{'README.md','docs/API.md','docs/NOTICES.md','docs/EXAMPLES.md',
      'docs/INSTALL.md','docs/TUTORIAL.md','examples/decompile.lua','examples/inspect_function.lua',
      'native-inputs.lock.json','native-patched.lock.json','native-system.lock.json','api/FIELDS.md'} do
      if not files[path] then fail('missing-policy',path,'required product member') end
    end
    require_facts('README.md', {'no HTTP, SWIG', 'upstream Python-binding dependency',
      'signed', 'eight-byte double'})
    require_facts('docs/INSTALL.md', {'Python >=3.10', 'zlib/XML', 'Protobuf', 'PIC', '$ORIGIN', 'LUA_MODULE_DIR', 'deploy_lua_dir'})
    -- Beginner safety stays at the first call; advanced limits live in API.
    require_facts('docs/TUTORIAL.md', {'crash the process', 'Only one owner', 'synchronous'})
    require_facts('docs/EXAMPLES.md', {'BYTE_COUNT', 'INSTRUCTION_END', 'INSTRUCTION_COUNT', 'NOT_FOUND', 'Close scopes'})
    require_facts('docs/API.md', {'CLIENT_IN_USE', 'pages-only', 'native process crash',
      'FileBytes', 'True-local retyping', 'no autosave'})
    require_facts('docs/NOTICES.md', {'Elias Bachaalany', 'redistribution clearance',
      'SOURCE builds only', 'cpp/embed_specs.py', 'Python >=3.10', 'zlib/XML',
      'SDK consumers and Lua runtime'})
  end
  if mode=='installed' then
    for _,path in ipairs(list) do
      if files[path]~=read(source..'/'..path) then fail('stale-bytes',path) end
    end
  end
  return #list
end
return M
