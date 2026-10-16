-- MIT Copyright 2026 Salvador Fandiño.
package.path='site/?.lua;scripts/?.lua;'..package.path
local c=require('content')
local cli=require('cli')
local json=require('tool_json')
local encode=require('tool_json_encode')
local policy=dofile('scripts/package-documents.lua')
local o=cli.options(arg,{'--pandoc','--baseurl','--origin','--output','--report'})
local source=c.capture('pwd -P'):gsub('\n$','')
local output=c.absolute(o['--output']); local report=c.absolute(o['--report'])
c.baseurl(o['--baseurl']); c.origin(o['--origin'])
c.disjoint(output,report)
-- Output beneath the checkout is allowed only in ignored caller-owned work;
-- never permit overlap with any actual source input or tooling directory.
for _,path in ipairs{'site','scripts','tests','cmake','docs','api','examples'} do
  c.disjoint(output,source..'/'..path); c.disjoint(report,source..'/'..path)
end
c.safe_path(output,'fresh'); c.safe_path(report,'fresh')
local pandoc=c.safe_path(o['--pandoc'],'file')
local lock=json.decode(c.read('site/toolchain.lock.json'))
local version=c.capture(c.quote(pandoc)..' --version')
assert(version:match('^pandoc ([^\n]+)')==lock.version,'converter version differs from lock')
local work=report..'.work'
c.safe_path(work,'fresh'); c.command('mkdir '..c.quote(work))
c.command('cmake -DLLG_DOCUMENT_EXPORT_DIR='..c.quote(work..'/export')..' -P site/export-documents.cmake')
local documents=policy.manifest(work..'/export/package-documents.txt')
local examples=policy.manifest(work..'/export/package-examples.txt')
local routes=c.routes(documents,examples)
for _,path in ipairs(documents) do
  c.safe_path(source..'/'..path,'file'); c.disjoint(output,source..'/'..path)
  c.disjoint(report,source..'/'..path)
end
c.command('lua5.4 scripts/render-fields.lua --check')
c.command('lua5.4 tests/installed_documents.lua source '..c.quote(source)..' '..c.quote(work..'/export/package-documents.txt'))
-- An unavailable shared primitive is a clear integration failure before output
-- creation; do not silently fall back to independently generated IDs.
assert(type(policy.heading_ids)=='function',
  'shared-heading-api: package owner must export heading_ids allocator before site rendering')
c.command('mkdir '..c.quote(output))
local function parent(path)
  c.command('mkdir -p '..c.quote(path:match('^(.*)/')))
end
local files={}
local function digest(path)
  return assert(c.capture('sha256sum '..c.quote(path)):match('^(%x+)'))
end
local source_hashes={}
for _,path in ipairs(documents) do
  local route=routes[path]; local target=output..'/'..route.output
  parent(target)
  source_hashes[path]=digest(source..'/'..path)
  if route.kind=='markdown' then
    c.write(work..'/page.json',encode({source=path,routes=routes,examples=examples,
      origin=o['--origin'],baseurl=o['--baseurl']}))
    c.command('LLG_SITE_SOURCE='..c.quote(source)..' LLG_SITE_CONFIG='..c.quote(work..'/page.json')..' '
      ..c.quote(pandoc)..' --from=gfm --to=html5 --standalone --wrap=none --no-highlight'
      ..' --toc --toc-depth=3 --template=site/template.html --lua-filter=site/links.lua'
      ..' --output='..c.quote(target)..' '..c.quote(source..'/'..path))
  else c.write(target,c.read(source..'/'..path)) end
  files[route.output]=digest(target)
end
parent(output..'/assets/style.css')
c.write(output..'/assets/style.css',c.read('site/style.css'))
c.write(output..'/.nojekyll','')
files['assets/style.css']=digest(output..'/assets/style.css'); files['.nojekyll']=digest(output..'/.nojekyll')
local tools={}
for _,path in ipairs(c.tool_inputs) do
  tools[path]=digest(source..'/'..path)
end
c.write(report,encode({schema=1,baseurl=o['--baseurl'],origin=o['--origin'],
  documents=documents,examples=examples,files=files,sources=source_hashes,tools=tools})..'\n')
print('site build PASS: '..#documents..' exported members')
