-- MIT Copyright 2026 Salvador Fandiño.
-- Bounded tokenizer for Pandoc's static HTML; reject unsupported markup instead
-- of silently skipping a URL/ID. Comments and quoted '>' are parsed explicitly.
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
local function attributes(body)
  local result,offset={},1
  while offset<=#body do
    local whitespace=body:sub(offset):match('^%s*')
    offset=offset+#whitespace
    if offset>#body then break end
    if body:sub(offset):match('^/%s*$') then break end
    local name=body:sub(offset):match('^([%a_:][%w_:%.%-]*)')
    assert(name,'malformed HTML attribute')
    offset=offset+#name
    name=name:lower()
    assert(result[name]==nil,'duplicate HTML attribute: '..name)
    local gap=body:sub(offset):match('^%s*'); offset=offset+#gap
    local value=true
    if body:sub(offset,offset)=='=' then
      offset=offset+1
      gap=body:sub(offset):match('^%s*'); offset=offset+#gap
      local quote=body:sub(offset,offset)
      assert(quote=='"' or quote=="'",'unquoted HTML attribute: '..name)
      local ending=body:find(quote,offset+1,true)
      assert(ending,'unterminated HTML attribute: '..name)
      value=entity(body:sub(offset+1,ending-1)); offset=ending+1
      assert(offset>#body or body:sub(offset,offset):match('[%s/]'),'missing attribute separator')
    end
    result[name]=value
  end
  return result
end
local forbidden_tags={script=true,iframe=true,object=true,embed=true,base=true,
  style=true,form=true,input=true,button=true,textarea=true,select=true,
  video=true,audio=true,source=true,svg=true,math=true}
function M.inspect(text,path)
  local ids,urls,headings,code={}, {}, {}, {}
  local canonical_count,offset=0,1
  local in_heading,in_code
  while offset<=#text do
    local first=text:find('<',offset,true)
    local chunk=text:sub(offset,first and first-1 or #text)
    if in_heading then in_heading.text=in_heading.text..entity(chunk) end
    if in_code then in_code.text=in_code.text..entity(chunk) end
    if not first then break end
    if text:sub(first,first+3)=='<!--' then
      local ending=assert(text:find('-->',first+4,true),'unterminated HTML comment')
      offset=ending+3
    else
      local quote,ending=nil,nil
      for i=first+1,#text do
        local ch=text:sub(i,i)
        if quote then if ch==quote then quote=nil end
        elseif ch=='"' or ch=="'" then quote=ch
        elseif ch=='>' then ending=i; break end
      end
      assert(ending,'unterminated HTML tag: '..path)
      local tag=text:sub(first+1,ending-1)
      if tag:match('^!') then
        assert(tag:lower()=='!doctype html','unsupported HTML declaration')
      else
        local slash,name,body=tag:match('^(/?)([%a][%w%-]*)(.*)$')
        assert(name,'unsupported HTML markup: '..path)
        name=name:lower()
        assert(not forbidden_tags[name],'forbidden HTML element: '..path..' '..name)
        if slash=='/' then
          assert(body:match('^%s*$'),'attributes on closing tag')
          if name:match('^h[1-6]$') then
            assert(in_heading and in_heading.tag==name,'mismatched heading')
            headings[#headings+1]=in_heading; in_heading=nil
          elseif name=='code' and in_code then code[#code+1]=in_code; in_code=nil end
        else
          local attrs=attributes(body)
          for key in pairs(attrs) do
            assert(not key:match('^on') and key~='style' and key~='srcdoc'
              and key~='srcset' and key~='ping' and key~='action' and key~='formaction'
              and key~='background' and key~='poster' and key~='xlink:href',
              'unsupported active/asset attribute: '..key)
          end
          if attrs.id then
            assert(type(attrs.id)=='string' and attrs.id~='' and not ids[attrs.id],
              'duplicate/empty ID: '..path..' '..tostring(attrs.id))
            ids[attrs.id]=true
          end
          local canonical=name=='link' and attrs.rel=='canonical'
          if canonical then
            canonical_count=canonical_count+1
            assert(type(attrs.href)=='string','canonical href required')
          end
          for _,key in ipairs{'href','src'} do
            if attrs[key] then
              assert(type(attrs[key])=='string','URL attribute needs value')
              urls[#urls+1]={value=attrs[key],asset=key=='src' or (name=='link' and not canonical),
                canonical=canonical}
            end
          end
          if name:match('^h[1-6]$') then
            assert(not in_heading,'nested heading'); in_heading={id=attrs.id,tag=name,text=''}
          elseif name=='code' then
            assert(not in_code,'nested code'); in_code={text='',class=attrs.class}
          end
          if name=='meta' then assert(not attrs['http-equiv'],'HTTP refresh/meta directive forbidden') end
        end
      end
      offset=ending+1
    end
  end
  assert(not in_heading and not in_code,'unterminated heading/code')
  return ids,urls,entity(text),{headings=headings,code=code,canonical_count=canonical_count}
end
function M.policy(path,decoded)
  local credit='Saivage was used in creating this project.'
  if path=='index.html' then
    -- Only a single literal paragraph in an actual acknowledgment section may
    -- be exempt. A comment/attribute/code string must never grant the exception.
    local literal='<p>'..credit..'</p>'
    local _,count=decoded:gsub(literal:gsub('([^%w])','%%%1'),'')
    assert(count<=1,'duplicate landing credit')
    if count==1 then
      local position=assert(decoded:find(literal,1,true))
      local prefix=decoded:sub(1,position-1)
      local last=prefix:match('.*<h[1-6][^>]*>(.-)</h[1-6]>')
      assert(last and (last=='Acknowledgment' or last=='Acknowledgments'
        or last=='Acknowledgement' or last=='Acknowledgements'),'invalid landing credit section')
      -- Strip comments before locating the literal, preserving any forbidden text
      -- in them for the all-byte scan below.
      local visible=decoded:gsub('<!%-%-.-%-%->',''):gsub('<pre[%s>].-</pre>','')
      assert(visible:find(literal,1,true),'hidden landing credit')
      decoded=decoded:sub(1,position-1)..decoded:sub(position+#literal)
    end
  end
  local lower=decoded:gsub('%%(%x%x)',function(h) return string.char(tonumber(h,16)) end):lower()
  for _,pattern in ipairs{'saivage','card://','record://','work://','%[%[card:','card%-[a-z]+'} do
    assert(not lower:find(pattern),'forbidden decoded content: '..path..' '..pattern)
  end
end
return M
