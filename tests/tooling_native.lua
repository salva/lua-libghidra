-- MIT Copyright 2026 Salvador Fandiño. Validator failure-path regressions.
package.path='scripts/?.lua;'..package.path
local U,C=require('tool_util'),require('native_probe_checks')
local work=assert(arg[1]); C.fresh(work)
local function reject(f,needle) local ok,e=pcall(f); assert(not ok and tostring(e):find(needle,1,true),tostring(e)) end
local good='completed=1 fallback=0\nparam_1 * 3 + 7\n'
C.check('authored-success',0,good,'')
reject(function() C.check('bad-exit',4,good,'') end,'unexpected exit')
reject(function() C.check('bad-semantic',0,'completed=1 fallback=0','') end,'missing semantic result')
reject(function() C.check('bad-diagnostic',4,'','wrong',4,'required') end,'missing diagnostic')
C.check('authored-error',4,'','required',4,'required')
local home=work..'/home'; C.fresh(home); U.write(home..'/file','unchanged')
local mode=U.capture{'stat','-c','%a',home..'/file'}
reject(function() C.readonly(home,function() error('injected failure') end) end,'injected failure')
assert(U.capture{'stat','-c','%a',home..'/file'}==mode,'permissions not restored')
U.run{'touch',home..'/file'}
C.run(work,'subprocess-positive',{'printf',good})
reject(function() C.run(work,'subprocess-false-green',{'sh','-c','printf '..U.quote(good)..'; exit 7'}) end,'unexpected exit')
print('Lua native validator semantic/exit/diagnostic and cleanup regressions PASS')
