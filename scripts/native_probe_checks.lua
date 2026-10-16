-- MIT Copyright 2026 Salvador Fandiño. Native probe qualification primitives.
local U=require('tool_util')
local M={}
function M.absolute(p) return U.capture{'realpath','-m','--',p}:gsub('\n$','') end
function M.ordinary() assert(U.capture{'id','-u'}~='0\n','ordinary user required') end
function M.fresh(p) assert(not U.exists(p),'fresh work directory required'); U.run{'mkdir','-p',p} end
function M.check(label,code,out,err,expected,diagnostic)
 print(label,'exit=',code); io.write(out); io.stderr:write(err)
 assert(code==(expected or 0),'unexpected exit '..label)
 if (expected or 0)==0 then
  for _,s in ipairs{'completed=1 fallback=0','param_1 * 3 + 7'} do assert(out:find(s,1,true),'missing semantic result '..label) end
 end
 if diagnostic then assert(err:find(diagnostic,1,true),'missing diagnostic '..label) end
end
function M.run(work,label,args,home,expected,diagnostic)
 local out,err=work..'/probe.stdout',work..'/probe.stderr'
 local command=U.command(args)
 if home then command='HOME='..U.quote(home)..' '..command end
 local ok,kind,code=os.execute(command..' >'..U.quote(out)..' 2>'..U.quote(err))
 if kind~='exit' then error('probe terminated by signal '..tostring(code)) end
 M.check(label,ok and 0 or code,U.read(out),U.read(err),expected,diagnostic)
end
function M.snapshot(home)
 -- find's nanosecond timestamp and size preserve the predecessor's checks;
 -- content hashes add detection of same-sized rewrites.
 return U.capture{'sh','-c','find '..U.quote(home).." -type f -printf '%P %T@ %s\\n' | LC_ALL=C sort"},
 U.capture{'sh','-c','find '..U.quote(home)..' -type f -exec sha256sum {} + | LC_ALL=C sort'}
end
function M.readonly(home,callback)
 local paths={}; for p in U.capture{'find',home,'-print0'}:gmatch('([^\0]+)\0') do
  paths[#paths+1]={p,U.capture{'stat','-c','%a','--',p}:gsub('\n$','')}
 end
 local ok,e=xpcall(function()
  U.run{'chmod','-R','a-w',home}
  for _,p in ipairs(paths) do assert(not os.execute('test -w '..U.quote(p[1])),'cache still writable') end
  callback()
 end,debug.traceback)
 -- Restore parents before descendants even after a failed assertion/probe.
 for _,p in ipairs(paths) do U.run{'chmod',p[2],'--',p[1]} end
 assert(ok,e)
end
function M.cache(work,home,run)
 M.fresh(home); run('cold')
 local sentinels=U.capture{'find',home,'-name','.complete','-type','f','-print'}
 local count=0; for _ in sentinels:gmatch('\n') do count=count+1 end
 assert(count==1,'expected one extracted cache sentinel')
 local before,hash=M.snapshot(home)
 run('warm'); M.readonly(home,function() run('warm-unwritable') end)
 local after,afterhash=M.snapshot(home)
 assert(before==after and hash==afterhash,'warm cache changed')
end
return M
