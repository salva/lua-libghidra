-- MIT Copyright 2026 Salvador Fandiño. Deterministic JSON writer for lock files.
local function quote(s)
 return '"'..s:gsub('[%z\1-\31\\"]',function(c)
  local short={['"']='\\"',['\\']='\\\\',['\n']='\\n',['\r']='\\r',['\t']='\\t'}
  return short[c] or string.format('\\u%04x',c:byte())
 end)..'"'
end
local encode
function encode(v)
 if v==require('tool_json').null then return 'null' end
 local kind=type(v)
 if kind=='string' then return quote(v) end
 if kind=='boolean' then return tostring(v) end
 if kind=='number' then assert(v==v and math.abs(v)~=math.huge,'nonfinite JSON number'); return tostring(v) end
 assert(kind=='table','unsupported JSON value')
 local out={}
 if #v>0 then
  local count=0; for k in pairs(v) do assert(type(k)=='number' and math.type(k)=='integer' and k>=1 and k<=#v,'mixed JSON array'); count=count+1 end
  assert(count==#v,'sparse JSON array')
  for i,x in ipairs(v) do out[i]=encode(x) end
  return '['..table.concat(out,',')..']'
 end
 local keys={}; for k in pairs(v) do assert(type(k)=='string','invalid JSON key'); keys[#keys+1]=k end; table.sort(keys)
 for _,k in ipairs(keys) do out[#out+1]=quote(k)..':'..encode(v[k]) end
 return '{'..table.concat(out,',')..'}'
end
return encode
