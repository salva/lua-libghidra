-- MIT Copyright 2026 Salvador Fandiño.
-- Focused synthetic grammar tests, not a second package inventory.
local root, work=assert(arg[1]),assert(arg[2])
local policy=dofile(root..'/scripts/package-documents.lua')
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
