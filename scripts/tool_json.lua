-- MIT Copyright 2026 Salvador Fandiño. Strict JSON reader for project tooling.
local M={null={}}
function M.decode(s)
 local i=1
 local function ws() local _,e=s:find('^[ \t\r\n]*',i); i=(e or i-1)+1 end
 local value
 local function str()
  assert(s:sub(i,i)=='"','expected JSON string'); i=i+1; local out={}
  while i<=#s do
   local c=s:sub(i,i); i=i+1
   if c=='"' then return table.concat(out) end
   assert(c:byte()>=32,'control character in JSON string')
   if c=='\\' then
    c=s:sub(i,i); i=i+1
    local escapes={['"']='"',['\\']='\\',['/']='/',b='\b',f='\f',n='\n',r='\r',t='\t'}
    if c=='u' then
     local hex=s:sub(i,i+3); assert(hex:match('^%x%x%x%x$'),'invalid unicode escape'); i=i+4
     local n=tonumber(hex,16)
     if n>=0xd800 and n<=0xdbff then
      assert(s:sub(i,i+1)=='\\u','missing low surrogate'); i=i+2
      hex=s:sub(i,i+3); assert(hex:match('^%x%x%x%x$'),'invalid low surrogate'); i=i+4
      local low=tonumber(hex,16); assert(low>=0xdc00 and low<=0xdfff,'invalid low surrogate')
      n=0x10000+(n-0xd800)*1024+low-0xdc00
     else assert(n<0xdc00 or n>0xdfff,'unpaired low surrogate') end
     c=utf8.char(n)
    else c=assert(escapes[c],'invalid JSON escape') end
   end
   out[#out+1]=c
  end
  error('unterminated JSON string')
 end
 function value()
  ws(); local c=s:sub(i,i)
  if c=='"' then return str() end
  if c=='{' or c=='[' then
   local object=c=='{'; i=i+1; ws(); local t={}; local seen={}; local close=object and '}' or ']'
   if s:sub(i,i)==close then i=i+1; return t end
   while true do
    local k
    if object then k=str(); assert(not seen[k],'duplicate JSON key'); seen[k]=true; ws(); assert(s:sub(i,i)==':','expected colon'); i=i+1 end
    local v=value(); if object then t[k]=v else t[#t+1]=v end
    ws(); c=s:sub(i,i); i=i+1
    if c==close then return t end
    assert(c==',','expected comma'); ws()
   end
  end
  for literal,v in pairs{['true']=true,['false']=false,['null']=M.null} do
   if s:sub(i,i+#literal-1)==literal then i=i+#literal; return v end
  end
  local token=s:sub(i):match('^%-?%d+%.?%d*[eE]?[+%-]?%d*')
  assert(token and token~='','invalid JSON value')
  local integer,rest=token:match('^(%-?%d+)(.*)$')
  assert(integer and not integer:match('^%-?0%d'),'invalid JSON number')
  if rest:sub(1,1)=='.' then rest=assert(rest:match('^%.%d+(.*)$'),'invalid JSON fraction') end
  assert(rest=='' or rest:match('^[eE][+%-]?%d+$'),'invalid JSON exponent')
  local n=assert(tonumber(token),'invalid JSON number'); assert(n~=math.huge and n~=-math.huge,'JSON number overflow'); i=i+#token; return n
 end
 local v=value(); ws(); assert(i>#s,'trailing JSON data'); return v
end
return M
