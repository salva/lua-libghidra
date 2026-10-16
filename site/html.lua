-- MIT Copyright 2026 Salvador Fandiño.
-- Inspect actual HTML, not the build report's asserted graph.
local M={}
local function entity(s)
  local named={amp='&',lt='<',gt='>',quot='"',apos="'",nbsp=' '}
  return (s:gsub('&(#?[%w]+);',function(v)
    if named[v] then return named[v] end
    local n=v:match('^#x(%x+)$') or v:match('^#X(%x+)$')
    n=n and tonumber(n,16) or tonumber(v:match('^#(%d+)$'))
    assert(n and n>0 and n<=0x10ffff and not (n>=0xd800 and n<=0xdfff), 'unsupported HTML entity: '..v)
    return utf8.char(n)
  end))
end
M.entity=entity
function M.inspect(html,path)
  local ids,urls={},{}
  -- Include text, attributes and comments in decoded policy scanning. Exemptions
  -- are handled by the caller only for an exact single landing paragraph.
  local decoded=entity(html)
  for tag in html:gmatch('<[^>]+>') do
    if not tag:match('^<!') then
      local name=tag:match('^<%s*([%w]+)')
      if name then
        name=name:lower()
        assert(name~='script' and name~='iframe' and name~='object' and name~='embed'
          and name~='base','forbidden HTML element: '..path..' '..name)
        for key,q,value in tag:gmatch('([%w_:%-]+)%s*=%s*([\'"])(.-)%2') do
          key=key:lower(); value=entity(value)
          assert(not key:match('^on'),'event attribute forbidden')
          if key=='id' then
            assert(value~='' and not ids[value],'duplicate/empty ID: '..path..' '..value)
            ids[value]=true
          elseif key=='href' or key=='src' then
            urls[#urls+1]={value=value,asset=key=='src' or (name=='link' and not tag:find('rel="canonical"',1,true)),
              canonical=name=='link' and tag:find('rel="canonical"',1,true)~=nil}
          end
        end
        -- Pandoc emits quoted attributes; reject rather than ignore unquoted URLs.
        for key,value in tag:gmatch('([%w_:%-]+)%s*=%s*([^%s>]+)') do
          assert(value:sub(1,1)=='"' or value:sub(1,1)=="'",'unquoted HTML attribute: '..key)
        end
      end
    end
  end
  return ids,urls,decoded
end
function M.policy(path,decoded)
  local credit='Saivage was used in creating this project.'
  if path=='index.html' then
    local literal='<p>'..credit..'</p>'
    local _,count=decoded:gsub(literal:gsub('([^%w])','%%%1'),'')
    assert(count<=1,'duplicate landing credit')
    if count==1 then decoded=decoded:gsub(literal:gsub('([^%w])','%%%1'),'') end
  end
  local lower=decoded:gsub('%%(%x%x)',function(h) return string.char(tonumber(h,16)) end):lower()
  for _,pattern in ipairs{'saivage','card://','record://','work://','%[%[card:','card%-[a-z]+'} do
    assert(not lower:find(pattern),'forbidden decoded content: '..path..' '..pattern)
  end
end
return M
