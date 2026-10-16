-- MIT Copyright 2026 Salvador Fandiño. Native tooling subprocess primitives.
local M={}
function M.quote(s) assert(not s:find('\0',1,true),'NUL argument'); return "'"..s:gsub("'","'\\''").."'" end
function M.command(a) local t={}; for i,v in ipairs(a) do t[i]=M.quote(v) end; return table.concat(t,' ') end
function M.run(a) local ok,_,code=os.execute(M.command(a)); assert(ok,'command failed '..tostring(code)..': '..M.command(a)) end
function M.capture(a)
 local p=assert(io.popen(M.command(a),'r')); local s=p:read('a'); local ok,_,code=p:close(); assert(ok,'command failed '..tostring(code)..': '..M.command(a)); return s
end
function M.read(p) local f=assert(io.open(p,'rb')); local s=f:read('a'); f:close(); return s end
function M.write(p,s) local f=assert(io.open(p,'wb')); assert(f:write(s)); assert(f:close()) end
function M.exists(p) return os.execute('test -e '..M.quote(p)..' -o -L '..M.quote(p))==true end
function M.hash(p) return assert(M.capture{'sha256sum','--',p}:match('^(%x+)')) end
function M.safe(name)
 assert(name~='' and name:sub(1,1)~='/' and not name:find('[%c\\]'),'unsafe archive member')
 for part in name:gmatch('[^/]+') do assert(part~='..' and part~='.' ,'unsafe archive component') end
 return name
end
return M
