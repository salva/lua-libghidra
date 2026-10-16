-- MIT Copyright 2026 Salvador Fandiño.
-- Focused synthetic grammar tests, not a second package inventory.
local root, work=assert(arg[1]),assert(arg[2])
local policy=dofile(root..'/scripts/package-documents.lua')
-- Public package/site interface: keep the existing slug/count semantics, not
-- Pandoc defaults or global uniqueness repair of colliding suffixed bases.
assert(type(policy.heading_ids)=='function','shared-heading-api: heading_ids missing')
local ids,other=policy.heading_ids(),policy.heading_ids()
assert(type(ids)=='function' and type(other)=='function')
for _,case in ipairs{
 {'Page `value`','page-value'}, {'Repeat','repeat'}, {'Repeat','repeat-1'},
 {'Repeat','repeat-2'}, {'A & B!','a--b'}, {'A_B-C','a_b-c'},
 {' spaced  text ','-spaced--text-'}, {'tab\there','tab-here'},
 {'',''}, {'!!!','-1'}, {'','-2'},
 {'Collision','collision'}, {'Collision-1','collision-1'},
 {'Collision','collision-1'}, {'Collision-1','collision-1-1'},
} do assert(ids(case[1])==case[2],'heading ID parity: '..case[1]) end
assert(other('Repeat')=='repeat' and other('Repeat')=='repeat-1','allocator independence')
assert(ids('Repeat')=='repeat-3','interleaved allocator independence')
assert(policy.heading_ids()('Repeat')=='repeat','fresh document state')
print('Shared heading API/parity/duplicates/collision semantics/independence PASS')
-- Raw source spelling is significant: stringify loses link destinations and
-- entities even when the shared allocator itself is correct.
assert(type(policy.heading_texts)=='function','shared-heading-text-api: heading_texts missing')
local raw_fixture=table.concat({
 '# [Installation](docs/INSTALL.md) ###', '', 'Fish &amp; chips', '----------------', '',
 '## [Reference][ref]', '## Escape \\*literal\\*', '## *Emphasis* and **strong**',
 '## `code`', '## Repeat', '## Repeat-1', '## Repeat',
 '## Has#hash', '## Closing ###', '', 'Setext `raw` ##', '===', '',
 '```md', '# fenced', '```', '~~~', '# tilde fenced', '~~~',
 '    # indented', '\t# tab indented', '   ## Three spaces', '',
 'Prior line', '', '---', '', 'Interrupted', '    code', '---', '',
 'Previous', '---', '===', '', '## !!!', '## !!!', '',
 '[ref]: page.md',
},'\n')
local expected_raw={
 '[Installation](docs/INSTALL.md)', 'Fish &amp; chips', '[Reference][ref]',
 'Escape \\*literal\\*', '*Emphasis* and **strong**', '`code`',
 'Repeat','Repeat-1','Repeat','Has#hash','Closing','Setext `raw`','Three spaces',
 'Previous','---','!!!','!!!',
}
local function same_array(actual,expected,label)
 assert(#actual==#expected,label..': count '..#actual..' ~= '..#expected)
 for i,value in ipairs(expected) do assert(actual[i]==value,label..': item '..i..' '..tostring(actual[i])) end
end
local extracted=policy.heading_texts(raw_fixture)
same_array(extracted,expected_raw,'raw extraction order/parity')
local fresh=policy.heading_texts(raw_fixture)
assert(fresh~=extracted,'heading arrays must be fresh')
extracted[1]='mutated'; extracted[#extracted+1]='extra'
same_array(fresh,expected_raw,'unaliased raw extraction')
same_array(policy.heading_texts(raw_fixture),expected_raw,'repeat extraction')
same_array(policy.heading_texts(''),{},'empty extraction')
local raw_ids=policy.heading_ids()
assert(raw_ids(expected_raw[1])=='installationdocsinstallmd')
assert(raw_ids(expected_raw[2])=='fish-amp-chips')
assert(policy.heading_ids()('Installation')=='installation')
assert(policy.heading_ids()('Fish & chips')=='fish--chips')
print('Raw heading spelling/order/multiplicity/freshness/parsing boundaries PASS')
policy.absolute(work)
local function q(s) return "'"..s:gsub("'","'\\''").."'" end
assert(os.execute('test ! -e '..q(work)..' && mkdir -p '..q(work)))
local function write(path,text)
 local f=assert(io.open(work..'/'..path,'wb')); f:write(text); f:close()
end
write('manifest','README.md\npage.md\npicture.png\nnotice.txt\n')
write('picture.png','image fixture')
write('notice.txt','Exact raw notice\n')
write('page.md','# Page `value`\n\n## Repeat\n\n## Repeat\n')
local good='# Read me\n\n[inline](page.md#page-value)\n![image](picture.png)\n'..
 '[reference][p]\n[collapsed][]\n[shortcut]\n\n[p]: page.md#repeat-1 "title"\n'..
 '[collapsed]: page.md\n[shortcut]: #read-me\n'..
 '\n```lua\n[ignored](missing.md)\n```\n'
local function check(text,category,target)
 write('README.md',text)
 local ok,err=pcall(policy.check,'source',work,work,work..'/manifest')
 if category then
  assert(not ok and err:find(category..':',1,true) and err:find(target,1,true),tostring(err))
 else assert(ok,err) end
end
check(good)
-- Anchors must consume the exported allocator, with one state per document.
-- Cover ATX closing marks, setext, duplicate suffixes and fenced exclusions.
write('page.md','# Page `value` ###\n\nRepeat\n------\n\n## Repeat\n\n## Repeat\n\n```md\n## Repeat\n```\n')
local factory=policy.heading_ids
local allocations,calls=0,0
policy.heading_ids=function()
 allocations=allocations+1
 local allocate=factory()
 return function(heading) calls=calls+1;return allocate(heading) end
end
check(good..'\n[third](page.md#repeat-2)')
assert(allocations==2 and calls==5,'anchors must share exported allocator per document')
policy.heading_ids=factory
check(good..'\n[fenced is not a heading](page.md#repeat-3)','missing-fragment','repeat-3')
-- Real graph consumption must use the exported raw list, not stringify or a
-- second scanner. Observe calls and add a sentinel only through that interface.
local graph_fixture=raw_fixture:gsub('docs/INSTALL%.md','page.md')
local combined=graph_fixture..'\n# Page `value`\n'
write('page.md',combined)
local texts=policy.heading_texts
local text_calls=0
local links=good..'\n[exported](page.md#exported-extraction-sentinel)'
local graph_ids=policy.heading_ids()
for _,heading in ipairs(texts(graph_fixture)) do
 local fragment=graph_ids(heading)
 if fragment~='' then links=links..'\n[raw heading](page.md#'..fragment..')' end
end
-- good's existing page-value/repeat-1 links also resolve in the combined fixture.
policy.heading_texts=function(text)
 text_calls=text_calls+1
 local headings=texts(text)
 if text==combined then headings[#headings+1]='Exported extraction sentinel' end
 return headings
end
check(links)
assert(text_calls==2,'anchors must extract once per selected Markdown document')
policy.heading_texts=texts
check(links,'missing-fragment','exported-extraction-sentinel')
check(good..'\n[not rendered text](page.md#fish--chips)','missing-fragment','fish--chips')
write('page.md','# Page `value`\n\n## Repeat\n\n## Repeat\n')
check(good..'\n[bad](absent.md)','missing-link-target','absent.md')
check(good..'\n![bad](absent.png)','missing-link-target','absent.png')
check(good..'\n[bad][no-definition]','missing-link-target','no-definition')
check(good..'\n[bad](page.md#no-heading)','missing-fragment','no-heading')
check(good..'\n<a href="page.md">bad</a>','unsupported-markup','README.md')
check(good..'\n<img src="picture.png">','unsupported-markup','README.md')
check(good..'\n[bad](../../escape)','missing-link-target','escape')
local credit='Saivage was used in creating this project.'
local acknowledgment='\n## Acknowledgments\n\n'
check(good..acknowledgment..credit..'\n')
check(good..'\nAcknowledgements\n================\n\n'..credit..'\n')
for _,text in ipairs{
 good..'\n'..credit,
 good..'\n## Installation\n\n'..credit,
 good..acknowledgment..'prefix '..credit..' suffix',
 good..acknowledgment..' '..credit,
 good..acknowledgment..'> '..credit,
 good..acknowledgment..'```\n'..credit..'\n```',
 good..'```\n## Acknowledgments\n'..credit..'\n```',
 good..'<!--\n## Acknowledgments\n'..credit..'\n-->',
 good..acknowledgment..'### Installation\n'..credit,
} do check(text,'invalid-credit','README.md') end
check(good..acknowledgment..'Saivage was used in creating this\nproject.', 'forbidden-content','README.md')
check(good..acknowledgment..credit..'\nSAIVAGE', 'forbidden-content','README.md')
write('notice.txt',credit..'\n')
check(good,'invalid-credit','notice.txt')
write('notice.txt','Exact raw notice\n')
for _,name in ipairs{'saivage-note.txt','SAIVAGE-note.txt','card-probe.txt','docs/saivage/note.txt'} do
 write('filename-manifest',name..'\n')
 local ok,err=pcall(policy.manifest,work..'/filename-manifest')
 assert(not ok and err:find('forbidden-filename:',1,true) and err:find(name,1,true),err)
end
write('filename-manifest','build-guide.txt\nsource-generator.txt\nlicense.txt\n')
assert(#policy.manifest(work..'/filename-manifest')==3)

check(good..'\n```\nSAIVAGE\n```','forbidden-content','README.md')
check(good..'\n<!-- record:///hidden -->','forbidden-content','README.md')
check(good..'\nSaivage was used in creating this project.\nSaivage was used in creating this project.', 'invalid-credit','README.md')
write('notice.txt','Exact raw notice\nwork:///hidden')
check(good,'forbidden-content','notice.txt')
write('notice.txt','Exact raw notice\n')
check(good)
for _,bad in ipairs{'','README.md','README.md\nREADME.md\n','../escape\n','/absolute\n','docs/./a\n','docs//a\n','blank\n\n'} do
 write('invalid-manifest',bad)
 local ok,err=pcall(policy.manifest,work..'/invalid-manifest')
 assert(not ok and err:find('invalid-manifest:',1,true),err)
end
print('package document grammar/content/manifest boundaries PASS')
-- A product asset must keep required policy checks active even when a page is
-- omitted/renamed in the manifest. Generic synthetic documents remain allowed.
write('native-inputs.lock.json','{}\n')
write('product-manifest','README.md\nnative-inputs.lock.json\n')
write('README.md','# Product\n')
local ok,err=pcall(policy.check,'source',work,work,work..'/product-manifest')
assert(not ok and tostring(err):find('missing-policy:',1,true),tostring(err))
print('Product-policy missing-member/rename bypass rejected PASS')
