-- MIT Copyright 2026 Salvador Fandiño. Bounded native C++ source extraction.
-- Not a general C++ parser. Unsupported pinned grammar fails closed.
local M={}
function M.norm(s) return (s:gsub('%s+',' '):match('^%s*(.-)%s*$')) end
local function blank(s) return (s:gsub('[^\n]',' ')) end
function M.mask(s,literals)
 local out={}; local i=1
 while i<=#s do
  local start=i; local two=s:sub(i,i+1); local c=s:sub(i,i)
  if two=='//' then i=(s:find('\n',i+2,true) or #s+1)
  elseif two=='/*' then i=assert(s:find('*/',i+2,true),'unterminated comment')+2
  elseif two=='R"' then
   local opening=assert(s:find('(',i+2,true),'unterminated raw literal')
   local delimiter=s:sub(i+2,opening-1)
   assert(#delimiter<=16 and not delimiter:find('[%s\\()]'),'invalid raw delimiter')
   local ending=')'..delimiter..'"'; i=assert(s:find(ending,opening+1,true),'unterminated raw literal')+#ending
  elseif c=='"' or c=="'" then
   local quote=c; i=i+1; local closed=false
   while i<=#s do
    c=s:sub(i,i); i=i+1
    if c=='\\' then i=i+1 elseif c==quote then closed=true; break end
   end
   assert(closed,'unterminated literal')
  else i=i+1 end
  local fragment=s:sub(start,i-1)
  local comment=two=='//' or two=='/*'
  out[#out+1]=(comment or (literals and (two=='R"' or s:sub(start,start)=='"' or s:sub(start,start)=="'"))) and blank(fragment) or fragment
 end
 return table.concat(out)
end
function M.closing(code,opening,left,right)
 assert(code:sub(opening,opening)==left,'wrong opening delimiter')
 local depth=1
 for i=opening+1,#code do
  local c=code:sub(i,i); if c==left then depth=depth+1 elseif c==right then depth=depth-1 end
  if depth==0 then return i end
 end
 error('unbalanced definition')
end
function M.body(source,signature)
 local code=M.mask(source,true); local candidates={}; local cursor=1
 while true do
  local start,finish=source:find(signature,cursor,true); if not start then break end; cursor=finish+1
  if code:sub(start,start):match('%S') then
   local opening=code:find('{',finish+1,true)
   if opening and not code:sub(finish+1,opening-1):find('[;}]') then candidates[#candidates+1]={start,opening} end
  end
 end
 assert(#candidates==1,'expected one definition: '..signature..' count='..#candidates)
 local start,opening=table.unpack(candidates[1]); local ending=M.closing(code,opening,'{','}')
 return start,source:sub(opening,ending),opening,ending
end
function M.split(s)
 local out={}; local start=1; local depth=0
 for i=1,#s do
  local c=s:sub(i,i)
  if c:find('[<(%[]') then depth=depth+1 elseif c:find('[>)%]]') then depth=depth-1 end
  assert(depth>=0,'unbalanced argument type')
  if c==',' and depth==0 then out[#out+1]=M.norm(s:sub(start,i-1)); start=i+1 end
 end
 assert(depth==0,'unbalanced argument type')
 local tail=M.norm(s:sub(start)); if tail~='' then out[#out+1]=tail end; return out
end
function M.lua(t)
 t=M.norm(t:gsub('%f[%w]const%f[%W]',''):gsub('&',''))
 if t:sub(1,14)=='std::optional<' then return 'optional '..M.lua(t:sub(15,-2))..' (absence=nil)' end
 if t=='std::vector<std::uint8_t>' then return 'binary Lua string (length preserving)' end
 if t:sub(1,12)=='std::vector<' then return 'dense 1-based array of '..M.lua(t:sub(13,-2)) end
 if t=='std::uint64_t' then return 'exact UInt64' end
 if t=='int' or t=='std::uint32_t' or t=='std::int64_t' or t=='std::uint8_t' then return 'checked Lua integer ('..t..')' end
 if t=='double' then return 'Lua number (native double; lua_Number precision/runtime qualification required)' end
 if t=='bool' then return 'boolean (preserve false)' end
 if t=='std::string' then return 'Lua string (no transcoding)' end
 return t..' table/enum; resolve in types/enums'
end
local function cite(path,raw,i) local _,n=raw:sub(1,i-1):gsub('\n',''); return {path=path,line=n+1} end
function M.header(path,raw)
 local s=M.mask(raw,false); local types,enums,declarations={},{},{}
 for start,name,opening in s:gmatch('()enum%s+class%s+([%w_]+)%s*(){') do
  local ending=M.closing(M.mask(raw,true),opening,'{','}')
  assert(not enums[name],'duplicate enum')
  enums[name]={source=cite(path,raw,start),values=M.norm(s:sub(opening+1,ending-1))}
 end
 local filename=path:match('[^/]+$')
 if filename~='http.hpp' and filename~='headless.hpp' and filename~='status.hpp' then
  for start,name,opening in s:gmatch('()struct%s+([%w_]+)%s*(){') do
   local ending=M.closing(M.mask(raw,true),opening,'{','}')
   assert(s:sub(ending+1):match('^%s*;'),'unsupported model ending')
   assert(not types[name],'duplicate type '..name)
   local fields={}; local text=s:sub(opening+1,ending-1); local pos=1
   for finish in text:gmatch('();') do
    local f=M.norm(text:sub(pos,finish-1)); pos=finish+1
    if f~='' then
     local declaration,default=f:match('^(.-)%s*=%s*(.*)$'); declaration=declaration or f
     local native,field=declaration:match('^(.-)%s+([%w_]+)$')
     assert(native and native:match('^[%w_:<>, &]+$'),'unparsed field '..name..': '..f)
     native=M.norm(native)
     if not default then
      if native:match('^std::string') or native:match('^std::vector<') then default='empty'
      elseif native:match('^std::optional<') then default='absent' else default='no explicit initializer; inspect construction' end
     end
     fields[#fields+1]={name=field,native_type=native,lua=M.lua(native),native_default=M.norm(default),optional=native:match('^std::optional<')~=nil}
    end
   end
   assert(M.norm(text:sub(pos))=='','unterminated model field')
   types[name]={source=cite(path,raw,start),fields=fields}
  end
 end
 if filename~='api.hpp' and filename~='http.hpp' and filename~='headless.hpp' then
  for start,response,name,args in s:gmatch('()virtual%s+StatusOr<(.-)>%s+([%w_]+)%((.-)%)%s*=%s*0%s*;') do
   assert(not declarations[name],'duplicate declaration '..name)
   declarations[name]={source=cite(path,raw,start),response_type=M.norm(response),arguments=M.norm(args)}
  end
 end
 return types,enums,declarations
end
function M.implementations(path,raw)
 local code=M.mask(raw,true); local result={}
 for start,response,name,args,opening in code:gmatch('()StatusOr<(.-)>%s+([%w_]+)%((.-)%)%s*override%s*(){') do
  assert(not result[name],'duplicate implementation '..name)
  local ending=M.closing(code,opening,'{','}')
  result[name]={source=cite(path,raw,start),response_type=M.norm(response),arguments=M.norm(args),body=raw:sub(opening+1,ending-1)}
 end
 return result
end
return M
