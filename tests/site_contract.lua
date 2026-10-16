-- MIT Copyright 2026 Salvador Fandiño.
package.path='site/?.lua;scripts/?.lua;'..package.path
local c=require('content'); local cli=require('cli'); local html=require('html')
local policy=dofile('scripts/package-documents.lua')
local o=cli.options(arg,{'--work','--pandoc'})
local work=c.safe_path(o['--work'],'fresh')
c.command('mkdir '..c.quote(work))
c.safe_path(o['--pandoc'],'file')
local count=0
local function expect_failure(label,fn,pattern)
  local ok,why=pcall(fn)
  assert(not ok and (not pattern or tostring(why):find(pattern,1,true)),
    label..' did not reject as expected: '..tostring(why))
  count=count+1
end
c.command('cmake -DLLG_DOCUMENT_EXPORT_DIR='..c.quote(work..'/export')..' -P site/export-documents.cmake')
local documents=policy.manifest(work..'/export/package-documents.txt')
local examples=policy.manifest(work..'/export/package-examples.txt')
assert(#documents==27 and #examples==2)
local routes,outputs=c.routes(documents,examples)
assert(routes['README.md'].output=='index.html')
local n=0; for _ in pairs(outputs) do n=n+1 end; assert(n==29)
for _,path in ipairs(documents) do
  assert(routes[path])
  if path~='README.md' then assert(routes[path].output==path:gsub('%.md$','.html')) end
end
assert(c.link('docs/API.md','../README.md',routes)=='../index.html')
assert(c.link('docs/API.md','../README.md?view=local#native-local',routes)=='../index.html?view=local#native-local')
assert(c.link('docs/API.md','../api/%46IELDS.md#functionrecord',routes)=='../api/FIELDS.html#functionrecord')
assert(c.link('docs/API.md','#local-client',routes)=='API.html#local-client')
assert(c.link('README.md','docs/TUTORIAL.md',routes)=='docs/TUTORIAL.html')
expect_failure('unknown export',function() c.routes({'README.md','private.txt'},examples) end,'unknown exported class')
expect_failure('escaping source link',function() c.link('README.md','../outside',routes) end,'escaping URL')
expect_failure('root asset',function() c.link('README.md','/assets/style.css',routes) end,'root-relative')
expect_failure('encoded root',function() c.link('README.md','%2fassets/style.css',routes) end,'root-relative')
expect_failure('encoded traversal',function() c.link('README.md','%2e%2e/private',routes) end,'escaping URL')
expect_failure('malformed percent',function() c.link('README.md','README.md#bad%2',routes) end,'malformed percent')
expect_failure('unsafe scheme',function() c.link('README.md','javascript:alert(1)',routes) end,'unsupported URL scheme')
expect_failure('duplicate export',function() c.routes({'README.md','README.md'},examples) end,'duplicate exported')
local ids,links,decoded=html.inspect('<h1 id="one">One</h1><a href="API.html?a=1&amp;b=2#two">link</a>','fixture.html')
assert(ids.one and links[1].value=='API.html?a=1&b=2#two' and decoded:find('a=1&b=2',1,true))
expect_failure('duplicate ID',function() html.inspect('<h1 id="one"></h1><h2 id="one"></h2>','fixture.html') end,'duplicate/empty ID')
expect_failure('script',function() html.inspect('<script>evil</script>','fixture.html') end,'forbidden HTML element')
expect_failure('event handler',function() html.inspect('<p onclick="evil">text</p>','fixture.html') end,'event attribute')
expect_failure('unquoted URL',function() html.inspect('<a href=outside>link</a>','fixture.html') end,'unquoted HTML attribute')
for _,encoded in ipairs{'&#83;aivage','&#x53;aivage','<!-- record://private -->','<a title="work://private">x</a>'} do
  expect_failure('decoded policy '..encoded,function()
    local _,_,text=html.inspect(encoded,'fixture.html'); html.policy('fixture.html',text)
  end,'forbidden decoded content')
end
local credit='<p>Saivage was used in creating this project.</p>'
html.policy('index.html',credit)
expect_failure('duplicate credit',function() html.policy('index.html',credit..credit) end,'duplicate landing credit')
expect_failure('mislocated credit',function() html.policy('docs/API.html',credit) end,'forbidden decoded content')
expect_failure('source/output overlap',function() c.disjoint('/source/docs','/source/docs/new') end,'overlapping paths')
c.write(work..'/regular','bytes')
c.command('ln -s regular '..c.quote(work..'/symlink'))
expect_failure('symlink file',function() c.safe_path(work..'/symlink','file') end,'command failed')
c.command('mkdir '..c.quote(work..'/directory')..' && ln -s directory '..c.quote(work..'/linked-directory'))
expect_failure('symlink ancestor',function() c.safe_path(work..'/linked-directory/new','fresh') end,'command failed')
print('site foundation PASS: export/routes/URLs/HTML/policy/path probes; '..count..' rejection cases')
if type(policy.heading_ids)~='function' then
  io.stderr:write('SITE INTEGRATION NOT QUALIFIED: shared heading_ids API unavailable; rendering/mutation/browser checks remain required\n')
  os.exit(1)
end
-- Integration probes are intentionally required separately until implemented;
-- a future shared helper must not turn these foundation checks into a full pass.
error('SITE INTEGRATION NOT QUALIFIED: complete rendered artifact probes are not implemented',0)
