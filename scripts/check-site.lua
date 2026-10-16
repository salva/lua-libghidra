-- MIT Copyright 2026 Salvador Fandiño.
package.path='site/?.lua;scripts/?.lua;'..package.path
local c=require('content'); local cli=require('cli'); local html=require('html')
local json=require('tool_json')
local policy=dofile('scripts/package-documents.lua')
local o=cli.options(arg,{'--root','--baseurl','--report','--source'})
local root=c.safe_path(o['--root'],'directory')
local source=o['--source']=='.' and c.capture('pwd -P'):gsub('\n$','') or c.absolute(o['--source'])
c.safe_path(source,'directory'); c.baseurl(o['--baseurl'])
local report=json.decode(c.read(c.safe_path(o['--report'],'file')))
assert(report.schema==1 and report.baseurl==o['--baseurl'],'report configuration mismatch')
c.origin(report.origin)
-- Obtain current selection from the authority, never from the report alone.
local manifest=c.capture('cmake -DLLG_SITE_INSPECT=1 -P '..c.quote(source..'/site/inspect-documents.cmake'))
local documents,examples={},{}
local mode='documents'
for path in manifest:gmatch('[^\n]+') do
  if path=='--examples--' then mode='examples'
  elseif mode=='documents' then documents[#documents+1]=path else examples[#examples+1]=path end
end
local routes,outputs=c.routes(documents,examples)
local encode=require('tool_json_encode')
assert(encode(documents)==encode(report.documents) and encode(examples)==encode(report.examples),'stale selection')
local function hash(path)
  return assert(c.capture('sha256sum '..c.quote(path)):match('^(%x+)'))
end
-- Exact membership including nonregular paths; directories may not be symlinks.
local seen={}
for item in c.capture('find '..c.quote(root).." -mindepth 1 -printf '%y %P\\0'"):gmatch('([^%z]+)%z') do
  local kind,path=item:sub(1,1),item:sub(3)
  if kind~='d' then
    assert(kind=='f' and outputs[path]~=nil,'unlisted or nonregular output: '..path)
    seen[path]=true
  end
end
local ids,links={},{}
local external={}
for path in pairs(outputs) do
  assert(seen[path],'missing output: '..path)
  c.safe_path(root..'/'..path,'file')
  assert(report.files[path]==hash(root..'/'..path),'stale output/report: '..path)
  if path:match('%.html$') then
    local decoded
    ids[path],links[path],decoded=html.inspect(c.read(root..'/'..path),path)
    html.policy(path,decoded)
  end
end
for path in pairs(report.files) do assert(outputs[path]~=nil,'unlisted report member: '..path) end
for _,path in ipairs(documents) do
  c.safe_path(source..'/'..path,'file')
  assert(report.sources[path]==hash(source..'/'..path),'stale source: '..path)
  local route=routes[path]
  if route.kind~='markdown' then
    assert(c.read(root..'/'..route.output)==c.read(source..'/'..path),'altered download: '..path)
  end
end
for path in pairs(report.sources) do assert(routes[path],'unlisted report source') end
for _,path in ipairs{'site/content.lua','site/links.lua','site/template.html','site/style.css',
  'site/toolchain.lock.json','site/export-documents.cmake','scripts/build-site.lua',
  'scripts/check-site.lua','scripts/package-documents.lua','cmake/PackageDocuments.cmake'} do
  c.safe_path(source..'/'..path,'file')
  assert(report.tools[path]==hash(source..'/'..path),'stale tooling: '..path)
end
assert(c.read(root..'/assets/style.css')==c.read(source..'/site/style.css'),'stale stylesheet')
assert(c.read(root..'/.nojekyll')=='','invalid .nojekyll')
for page,targets in pairs(links) do
  for _,target in ipairs(targets) do
    local url=target.value
    if url:match('^[%a][%w+%.%-]*:') then
      if target.canonical then
        assert(url==report.origin..report.baseurl..'/'..page,'wrong canonical URL')
      else
        assert(not target.asset and (url:match('^https?://') or url:match('^mailto:')),'remote/unsafe asset or URL')
        external[url]=true
      end
    else
      assert(url:sub(1,1)~='/','root-relative asset/link')
      local path,suffix=url:match('^([^?#]*)(.*)$'); path=c.decode(path)
      local parts={}
      if path~='' then
        assert(path:sub(1,1)~='/','encoded root-relative path')
        for part in (page:match('^(.*)/') or ''):gmatch('[^/]+') do parts[#parts+1]=part end
        for part in path:gmatch('[^/]+') do
          if part=='..' then assert(#parts>0,'escaping output URL'); table.remove(parts)
          elseif part~='.' then parts[#parts+1]=part end
        end
        path=table.concat(parts,'/')
      else path=page end
      assert(outputs[path]~=nil,'missing local target: '..page..' '..url)
      c.decode(suffix)
      local fragment=suffix:match('#(.*)$')
      if fragment and fragment~='' then
        fragment=c.decode(fragment)
        assert(ids[path] and ids[path][fragment],'missing rendered fragment: '..page..' '..url)
      end
    end
  end
end
local urls={}; for url in pairs(external) do urls[#urls+1]=url end; table.sort(urls)
print('site graph/bytes/freshness PASS: '..#documents..' exported members')
for _,url in ipairs(urls) do print('external URL (not network tested): '..url) end
