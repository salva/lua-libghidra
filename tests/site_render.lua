-- MIT Copyright 2026 Salvador Fandiño.
-- Actual render regression for generated angle-bracket types, URI-looking C++
-- namespaces, exact examples and unchanged rejection of unsupported raw markup.
package.path='site/?.lua;scripts/?.lua;'..package.path
local c=require('content'); local json=require('tool_json'); local encode=require('tool_json_encode')
local o=require('cli').options(arg,{'--work','--pandoc'})
local work=c.safe_path(o['--work'],'fresh'); c.command('mkdir '..c.quote(work))
assert(os.getenv('LLG_SITE_PANDOC'),'set LLG_SITE_PANDOC to the verified converter for offline checking')
local source=c.capture('pwd -P'):gsub('\n$','')
local function build(base,name)
  c.command('lua5.4 scripts/build-site.lua --pandoc '..c.quote(o['--pandoc'])
    ..' --baseurl '..c.quote(base)..' --origin https://salva.github.io --output '
    ..c.quote(work..'/'..name)..' --report '..c.quote(work..'/'..name..'.json'))
  c.command('lua5.4 scripts/check-site.lua --root '..c.quote(work..'/'..name)
    ..' --baseurl '..c.quote(base)..' --report '..c.quote(work..'/'..name..'.json')..' --source .')
end
build('/lua-libghidra','project')
local report=json.decode(c.read(work..'/project.json'))
local policy=dofile('scripts/package-documents.lua')
local routes=c.routes(report.documents,report.examples)
local fields=c.read(work..'/project/api/FIELDS.html')
assert(fields:find('std::optional&lt;FunctionRecord&gt;',1,true))
assert(fields:find('std::optional&lt;bool&gt;',1,true))
assert(fields:find('&lt;std::string&gt;',1,true))
assert(not fields:find('<FunctionRecord>',1,true) and not fields:find('href="std::',1,true))
local config={source='api/FIELDS.md',routes=routes,examples=report.examples,
  origin='https://salva.github.io',baseurl='/lua-libghidra'}
local fixture=work..'/filter-source'
c.command('mkdir -p '..c.quote(fixture..'/api')..' '..c.quote(fixture..'/docs'))
c.command('cp -a site scripts examples '..c.quote(fixture))
c.write(fixture..'/api/coverage.json',c.read('api/coverage.json'))
local function filter(text,page,name,fail,source_text)
  config.source=page
  c.write(fixture..'/'..page,source_text or text)
  c.write(work..'/config.json',encode(config)); c.write(work..'/input.md',text)
  local command='LLG_SITE_SOURCE='..c.quote(fixture)..' LLG_SITE_CONFIG='..c.quote(work..'/config.json')
    ..' '..c.quote(o['--pandoc'])..' -f gfm -t html5 --standalone --no-highlight'
    ..' --template=site/template.html --lua-filter=site/links.lua '..c.quote(work..'/input.md')
    ..' -o '..c.quote(work..'/'..name..'.html')..' >'..c.quote(work..'/'..name..'.stdout')
    ..' 2>'..c.quote(work..'/'..name..'.stderr')
  local ok=os.execute(command)
  if fail then assert(not ok,'unsupported markup accepted: '..name)
    assert(c.read(work..'/'..name..'.stderr'):find((name:match('^count') and 'heading-count' or 'unsupported raw'),1,true),'wrong rejection: '..name)
  else assert(ok,'fixture failed: '..name) end
end
filter('# `UInt64` *values*\n\nstd::optional<FunctionRecord> <std::string> std::optional<bool>\n',
  'api/FIELDS.md','types',false)
local types=c.read(work..'/types.html')
assert(types:find('id="uint64-values"',1,true))
assert(types:find('&lt;FunctionRecord&gt;',1,true) and types:find('&lt;std::string&gt;',1,true))
filter('# Repeat\n\n# Repeat\n\nSetext title\n------------\n\n[ref][r] ![asset](../docs/notices/engine.txt) [query](../README.md?x=1#lua-libghidra) [encoded](../api/%46IELDS.md#functionrecord)\n\n[r]: ../docs/API.md#method-index\n', 'api/FIELDS.md','semantics',false)
local semantics=c.read(work..'/semantics.html')
for _,literal in ipairs{'id="repeat"','id="repeat-1"','id="setext-title"','href="../docs/API.html#method-index"','src="../docs/notices/engine.txt"','href="../index.html?x=1#lua-libghidra"','href="FIELDS.html#functionrecord"'} do
  assert(semantics:find(literal,1,true),'missing rendered semantics: '..literal)
end
for i,text in ipairs{'x <UnknownRecord>','x <FunctionRecord title="bad">','x </FunctionRecord>',
  '<script>bad</script>','<div>bad</div>'} do filter(text,'api/FIELDS.md','raw-reject-'..i,true) end
filter('x <FunctionRecord>','README.md','wrong-page',true)
local inline='# [Installation](../docs/INSTALL.md)\n\n## Fish &amp; chips\n\n## [Ref][r]\n\n## *Emphasis* and `code`\n\nSetext &amp; text\n-----------------\n\n```md\n# hidden\n```\n\n[r]: ../docs/API.md\n'
filter(inline,'api/FIELDS.md','inline-raw',false)
local rendered=c.read(work..'/inline-raw.html')
local allocate=policy.heading_ids()
for _,raw in ipairs(policy.heading_texts(inline)) do
  assert(rendered:find('id="'..allocate(raw)..'"',1,true),'raw ID missing: '..raw)
end
assert(not rendered:find('id="hidden"',1,true))
filter('# examples/decompile.lua\n','docs/EXAMPLES.md','example-state',false)
assert(c.read(work..'/example-state.html'):find('id="examplesdecompilelua-1"',1,true),
  'appended examples lost source allocator state')
filter('# Extra\n','api/FIELDS.md','count-extra',true,'plain text\n')
filter('plain text\n','api/FIELDS.md','count-missing',true,'# Missing\n')
build('','root')
build('/lua-libghidra','again')
c.command('diff -r '..c.quote(work..'/project')..' '..c.quote(work..'/again'))
print('site actual render/types/raw-rejection/exact-example/project+empty-base/determinism PASS')
