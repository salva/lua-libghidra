-- MIT Copyright 2026 Salvador Fandiño.
-- Real artifact mutations; never alter the checkout or original render evidence.
local M={}
function M.run(work,pandoc)
  local c=require('content'); local json=require('tool_json'); local encode=require('tool_json_encode')
  local source=c.capture('pwd -P'):gsub('\n$','')
  local function hash(path) return assert(c.capture('sha256sum '..c.quote(path)):match('^(%x+)')) end
  local build='lua5.4 scripts/build-site.lua --pandoc '..c.quote(pandoc)
    ..' --baseurl /lua-libghidra --origin https://salva.github.io --output '
    ..c.quote(work..'/baseline')..' --report '..c.quote(work..'/baseline.json')
  c.command(build)
  local function check(root,report,cwd)
    return 'cd '..c.quote(cwd or source)..' && LLG_SITE_PANDOC='..c.quote(pandoc)
      ..' lua5.4 scripts/check-site.lua --root '..c.quote(root)
      ..' --baseurl /lua-libghidra --report '..c.quote(report)..' --source .'
  end
  c.command(check(work..'/baseline',work..'/baseline.json'))
  local number=0
  local function mutation(name,fn,expected)
    number=number+1
    local dir=work..'/attack-'..number
    c.command('mkdir '..c.quote(dir)..' && cp -a '..c.quote(work..'/baseline')..' '..c.quote(dir..'/site'))
    local report=json.decode(c.read(work..'/baseline.json'))
    local cwd=fn(dir,report) or source
    -- Every output attack recomputes report hashes, so graph/policy/bytes and
    -- regeneration, not accidental digest mismatch, must reject it.
    for path in pairs(report.files) do
      local f=io.open(dir..'/site/'..path,'rb')
      if f then f:close(); report.files[path]=hash(dir..'/site/'..path) end
    end
    c.write(dir..'/report.json',encode(report))
    local ok=os.execute(check(dir..'/site',dir..'/report.json',cwd)..' >'..c.quote(dir..'/stdout')..' 2>'..c.quote(dir..'/stderr'))
    assert(not ok,'attack accepted: '..name)
    local err=c.read(dir..'/stderr')
    assert(err:find(expected,1,true),'wrong rejection '..name..': '..err)
    print('real artifact rejection PASS: '..name..' ('..expected..')')
  end
  local function edit(path,change)
    return function(dir) c.write(dir..'/site/'..path,change(c.read(dir..'/site/'..path))) end
  end
  mutation('rehashed altered narrative',edit('docs/TUTORIAL.html',function(s)
    return s:gsub('</main>','<p>STALE-RENDER-ATTACK: this paragraph is not in the selected source.</p></main>',1)
  end),'source-render mismatch')
  mutation('missing notice',function(d) c.command('rm '..c.quote(d..'/site/docs/notices/engine.txt')) end,'missing output')
  mutation('missing fragment',edit('docs/API.html',function(s) return s:gsub('id="construction%-and%-return%-shapes"','id="missing-target"') end),'missing rendered fragment')
  mutation('duplicate ID',edit('index.html',function(s) return s:gsub('</main>','<p id="main-content">duplicate</p></main>',1) end),'duplicate/empty ID')
  mutation('root asset',edit('index.html',function(s) return s:gsub('href="assets/style.css"','href="/assets/style.css"',1) end),'root-relative')
  mutation('README wrong route',edit('docs/API.html',function(s) return s:gsub('href="../index.html"','href="../README.html"',1) end),'missing local target')
  mutation('altered download',edit('examples/decompile.lua',function(s) return s..'-- altered\n' end),'altered download')
  mutation('altered example display',edit('docs/EXAMPLES.html',function(s) return s:gsub('os.exit%(result%)','os.exit(99)',1) end),'complete example display')
  for _,path in ipairs{'private.txt','history/report.html'} do
    mutation('extra '..path,function(d) c.command('mkdir -p '..c.quote((d..'/site/'..path):match('^(.*)/'))); c.write(d..'/site/'..path,'private') end,'unlisted or nonregular')
  end
  mutation('output symlink',function(d) c.command('rm '..c.quote(d..'/site/LICENSE')..' && ln -s '..c.quote(source..'/LICENSE')..' '..c.quote(d..'/site/LICENSE')) end,'unlisted or nonregular')
  mutation('encoded policy',edit('index.html',function(s) return s:gsub('</main>','<!-- &#83;aivage --></main>',1) end),'forbidden decoded content')
  mutation('mislocated credit',edit('docs/API.html',function(s) return s:gsub('</main>','<p>Saivage was used in creating this project.</p></main>',1) end),'forbidden decoded content')
  mutation('duplicate credit',edit('index.html',function(s) return s:gsub('</main>','<h2>Acknowledgments</h2><p>Saivage was used in creating this project.</p><p>Saivage was used in creating this project.</p></main>',1) end),'duplicate landing credit')
  -- Source snapshots contain only tracked project inputs, never runtime state.
  local function snapshot(d)
    c.command('mkdir '..c.quote(d..'/source'))
    c.command('git ls-files -z --cached --others --exclude-standard | tar --null -T - -cf - | tar -xf - -C '..c.quote(d..'/source'))
    return d..'/source'
  end
  mutation('rehashed stale source/report',function(d,r)
    local src=snapshot(d); c.write(src..'/README.md',c.read(src..'/README.md')..'\nA current source paragraph absent from this stale render.\n')
    r.sources['README.md']=hash(src..'/README.md'); return src
  end,'source-render mismatch')
  mutation('source symlink',function(d)
    local src=snapshot(d); c.command('rm '..c.quote(src..'/README.md')..' && ln -s '..c.quote(source..'/README.md')..' '..c.quote(src..'/README.md')); return src
  end,'command failed')
  mutation('stale report',function(_,r) r.sources['README.md']=string.rep('0',64) end,'stale source')
  print('site actual artifact integrity PASS: '..number..' attacks')
end
return M
