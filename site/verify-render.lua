-- MIT Copyright 2026 Salvador Fandiño.
-- A report is an index, not an attestation. Independently regenerate HTML from
-- current selected inputs with an operator-selected locked converter.
local M={}
function M.check(source,root,report,work)
  local c=require('content'); local json=require('tool_json')
  local encode=require('tool_json_encode')
  local pandoc=os.getenv('LLG_SITE_PANDOC')
  if not pandoc then pandoc=c.capture('command -v pandoc'):gsub('\n$','') end
  c.safe_path(pandoc,'file')
  local lock=json.decode(c.read(source..'/site/toolchain.lock.json'))
  assert(c.capture(c.quote(pandoc)..' --version'):match('^pandoc ([^\n]+)')==lock.version,
    'verification converter differs from lock')
  local routes=c.routes(report.documents,report.examples)
  for _,path in ipairs(report.documents) do
    local route=routes[path]
    if route.kind=='markdown' then
      c.write(work..'/verify.json',encode({source=path,routes=routes,examples=report.examples,
        baseurl=report.baseurl,origin=report.origin}))
      c.command('LLG_SITE_SOURCE='..c.quote(source)..' LLG_SITE_CONFIG='..c.quote(work..'/verify.json')..' '
        ..c.quote(pandoc)..' --from=gfm --to=html5 --standalone --wrap=none --no-highlight'
        ..' --toc --toc-depth=3 --template=site/template.html --lua-filter=site/links.lua'
        ..' --output='..c.quote(work..'/expected.html')..' '..c.quote(source..'/'..path))
      assert(c.read(work..'/expected.html')==c.read(root..'/'..route.output),
        'source-render mismatch: '..route.output)
    end
  end
end
return M
