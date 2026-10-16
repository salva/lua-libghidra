-- MIT Copyright 2026 Salvador Fandiño.
-- Export-derived routing and filesystem boundary primitives shared by site tools.
-- This module deliberately owns neither the package inventory nor heading IDs.
local M = {}
function M.quote(s)
  assert(type(s)=='string' and not s:find('%z'), 'invalid shell argument')
  return "'"..s:gsub("'", "'\\''").."'"
end
function M.command(command)
  local ok, why, code=os.execute(command)
  assert(ok, 'command failed ('..tostring(why)..' '..tostring(code)..'): '..command)
end
function M.capture(command)
  local p=assert(io.popen(command,'r'))
  local s=p:read('*a'); local ok,why,code=p:close()
  assert(ok,'command failed ('..tostring(why)..' '..tostring(code)..'): '..command)
  return s
end
function M.read(path)
  local f=assert(io.open(path,'rb')); local s=f:read('*a'); assert(f:close()); return s
end
function M.write(path, s)
  local f=assert(io.open(path,'wb')); assert(f:write(s)); assert(f:close())
end
function M.relative(path)
  assert(type(path)=='string' and path~='' and path:sub(1,1)~='/'
    and not path:find('[^%w%._/+%-]') and not path:find('//',1,true)
    and path:sub(-1)~='/', 'unsafe relative path: '..tostring(path))
  for part in path:gmatch('[^/]+') do
    assert(part~='.' and part~='..', 'unsafe relative path: '..path)
  end
  return path
end
function M.absolute(path)
  assert(type(path)=='string' and path:sub(1,1)=='/' and path~='/'
    and not path:find('[%z\r\n]'), 'absolute non-root path required')
  path=path:gsub('/+$','')
  for part in path:gmatch('[^/]+') do
    assert(part~='.' and part~='..','noncanonical absolute path')
  end
  assert(not path:find('//',1,true),'noncanonical absolute path')
  return path
end
-- lstat every existing ancestor; never follow source/output/report symlinks.
-- Existing ancestors must be directories, with a regular file at a file leaf.
function M.safe_path(path, leaf)
  path=M.absolute(path)
  local current=''
  local parts={}; for part in path:gmatch('[^/]+') do parts[#parts+1]=part end
  for i,part in ipairs(parts) do
    current=current..'/'..part
    local q=M.quote(current)
    M.command('test ! -L '..q)
    local kind=i==#parts and leaf or 'directory'
    if kind=='fresh' then
      M.command('test ! -e '..q)
    elseif kind=='file' then
      M.command('test -f '..q)
    elseif kind=='directory' then
      M.command('test -d '..q)
    else error('unknown path kind') end
  end
  return path
end
function M.disjoint(a,b)
  a=M.absolute(a); b=M.absolute(b)
  assert(a~=b and a:sub(1,#b+1)~=b..'/' and b:sub(1,#a+1)~=a..'/',
    'overlapping paths: '..a..' and '..b)
end
function M.baseurl(base)
  assert(base=='' or (base:sub(1,1)=='/' and base:sub(-1)~='/'
    and not base:find('[^%w/_%-]') and not base:find('//',1,true)), 'invalid baseurl')
  return base
end
function M.origin(origin)
  assert(origin:match('^https://[%w%.%-]+$'), 'HTTPS origin without path required')
  return origin
end
-- No hand-maintained page selection: each exported member is classified once.
function M.routes(documents, examples)
  local example_set, routes, outputs={}, {}, {}
  assert(#examples==2,'expected exactly two public examples')
  for _,path in ipairs(examples) do
    M.relative(path)
    assert(path:match('^examples/[%w_%-]+%.lua$') and not example_set[path],
      'invalid/duplicate exported example: '..path)
    example_set[path]=true
  end
  for _,path in ipairs(documents) do
    M.relative(path)
    assert(not routes[path],'duplicate exported document: '..path)
    local output,kind
    if path:match('%.md$') then
      assert(path=='README.md' or path:match('^docs/[%w_%-]+%.md$')
        or path=='api/FIELDS.md','unsupported Markdown route: '..path)
      output=path=='README.md' and 'index.html' or path:gsub('%.md$','.html')
      kind='markdown'
    elseif example_set[path] then output=path; kind='example'
    elseif path=='LICENSE' or path:match('^native%-[%w_%-]+%.lock%.json$')
      or path:match('^docs/notices/[%w_+%.%-]+%.txt$') then
      output=path; kind='asset'
    else error('unknown exported class: '..path) end
    assert(not outputs[output],'output collision: '..output)
    routes[path]={source=path,output=output,kind=kind}; outputs[output]=path
  end
  for path in pairs(example_set) do assert(routes[path],'example missing from combined export: '..path) end
  assert(routes['README.md'],'landing page absent from export')
  for _,output in ipairs{'assets/style.css','.nojekyll'} do
    assert(not outputs[output],'reserved output collision: '..output)
    outputs[output]=false
  end
  return routes,outputs
end
local navigation={
  {'Home','README.md'}, {'Install','docs/INSTALL.md'}, {'Tutorial','docs/TUTORIAL.md'},
  {'Examples','docs/EXAMPLES.md'}, {'API','docs/API.md'}, {'Fields','api/FIELDS.md'},
  {'Notices','docs/NOTICES.md'},
}
function M.navigation(routes)
  local result={}
  for _,item in ipairs(navigation) do
    local route=assert(routes[item[2]],'missing navigation member: '..item[2])
    result[#result+1]={label=item[1],source=route.source,output=route.output}
  end
  return result
end
function M.page_relative(from,to)
  M.relative(from); M.relative(to)
  local a,b={},{}
  for part in from:gmatch('[^/]+') do a[#a+1]=part end
  for part in to:gmatch('[^/]+') do b[#b+1]=part end
  table.remove(a)
  while #a>0 and #b>0 and a[1]==b[1] do table.remove(a,1); table.remove(b,1) end
  return string.rep('../',#a)..table.concat(b,'/')
end
-- URL resolution remains in source space. Only local document links are routed;
-- caller validates the resulting fragment against actual rendered IDs.
function M.decode(s)
  local remainder=s:gsub('%%%x%x','')
  assert(not remainder:find('%%'), 'malformed percent escape')
  s=s:gsub('%%(%x%x)', function(h) return string.char(tonumber(h,16)) end)
  assert(not s:find('[%z\1-\32\127\\]'),'unsafe decoded URL')
  return s
end
function M.link(source,url,routes)
  assert(routes[source],'unknown source route')
  if url:match('^[%a][%w+%.%-]*:') then
    assert(url:match('^https?://') or url:match('^mailto:'),'unsupported URL scheme')
    return url, true
  end
  assert(url:sub(1,1)~='/' and url:sub(1,2)~='//','root-relative URL forbidden')
  local path, suffix=url:match('^([^?#]*)(.*)$')
  path=M.decode(path)
  assert(path:sub(1,1)~='/', 'encoded root-relative URL forbidden')
  local parts={}
  if path~='' then
    for part in (source:match('^(.*)/') or ''):gmatch('[^/]+') do parts[#parts+1]=part end
    for part in path:gmatch('[^/]+') do
      if part=='..' then assert(#parts>0,'escaping URL'); table.remove(parts)
      elseif part~='.' then parts[#parts+1]=part end
    end
    path=table.concat(parts,'/')
  else path=source end
  local target=assert(routes[path],'unselected URL target: '..path)
  -- Validate encoding in query and fragment without conflating it with the path.
  M.decode(suffix)
  local result=M.page_relative(routes[source].output,target.output)..suffix
  return result,false,target.output
end
-- Inputs whose identity affects generation or verification. This is tooling
-- provenance, not a second document inventory. Builder/checker share the list.
M.tool_inputs={
  'site/content.lua','site/cli.lua','site/html.lua','site/links.lua',
  'site/template.html','site/style.css','site/toolchain.lock.json',
  'site/export-documents.cmake','site/inspect-documents.cmake','site/prepare-toolchain.sh',
  'scripts/build-site.lua','scripts/check-site.lua','scripts/package-documents.lua',
  'scripts/render-fields.lua','scripts/tool_json.lua','scripts/tool_json_encode.lua',
  'tests/installed_documents.lua','cmake/PackageDocuments.cmake',
}
return M
