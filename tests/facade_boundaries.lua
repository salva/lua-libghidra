-- MIT Copyright 2026 Salvador Fandiño.
-- Real installed ELF/project boundary regression. PREFIX ROOT WORK are required.
local prefix,root,work=assert(arg[1]),assert(arg[2]),assert(arg[3])
package.path=prefix..'/share/lua/5.4/?.lua;'..prefix..'/share/lua/5.4/?/init.lua'
package.cpath=prefix..'/lib/lua/5.4/?.so'
local gh,low=require'libghidra',require'libghidra.lowlevel'
local function check(v,e) assert(v,e and e.message); return v end
local function rejects(op,code,v,e)
 assert(v==nil and type(e)=='table' and e.code==code and e.operation==op and e.backend=='binding',
  op..': expected binding '..code..', got '..tostring(e and e.code))
end
local function copy(p) local t={} for k,v in next,p do t[k]=v end return t end
local function stale(iterator)
 for i=1,2 do local ok,e=pcall(iterator); assert(not ok and e.code=='ITERATOR_INVALIDATED') end
end
local function buffered(s)
 check(s:get_decompilation(0x401106)); check(s:get_decompilation(0x40111f)); check(s:get_decompilation(0x40113c))
 local i=s:iter_functions{page_size=100}; assert(i()); return i
end
local function unchanged(s,generation)
 assert(s:native():_generation()==generation)
 assert(check(s:read_bytes(0x401106,4))=='\xf3\x0f\x1e\xfa')
 assert(s:get_status().ok)
end
local touched=false
local hostile=setmetatable({},{__tostring=function() touched=true; error('must not stringify') end})
local userdata=io.tmpfile(); assert(userdata)
for _,project in ipairs{false,true} do
 local route=project and 'project' or 'ELF'
 local p={program_path=root..'/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}
 if project then p.project_path=root..'/tests/fixtures/project/authored.gpr' end
 for _,path in ipairs{p.program_path,p.project_path} do local f=assert(io.open(path,'rb')); f:close() end
 local s,e,opened=gh.open{program=p}; check(s,e)
 local owner=s:native(); local historical=opened.program_name
 local invalid={false,42,'program'}
 for _,pair in ipairs{{'read_only',true},{'read_only',false},{'project_name',''},
                      {'project_name','ignored'},{'unexpected',true},{7,true},{hostile,true},{userdata,true}} do
  local q=copy(p);q[pair[1]]=pair[2];invalid[#invalid+1]=q
 end
 for _,q in ipairs(invalid) do
  local iter=buffered(s); local gen=owner:_generation()
  rejects('open','INVALID_ARGUMENT',gh.open{program=q})
  rejects('open_program','INVALID_ARGUMENT',s:open_program(q))
  unchanged(s,gen); assert(iter()); assert(s:native()==owner)
 end
 -- Value grammar is parsed by native only after construction; factory's
 -- resource-free precheck intentionally covers keys, not value parsing.
 for _,q in ipairs{{},{program_path=false},{program_path='bad\0path'}} do
  local gen=owner:_generation()
  rejects('open_program','INVALID_ARGUMENT',s:open_program(q));unchanged(s,gen)
 end
 assert(not touched)
 local raw=setmetatable(copy(p),{__pairs=function() error('__pairs') end,__index=function() error('__index') end})
 check(s:open_program(raw))
 local inherited=setmetatable({},{__index=p,__pairs=function() return next,p,nil end})
 rejects('open_program','INVALID_ARGUMENT',s:open_program(inherited))
 -- Raw values remain native-validated, never supplied by __index.
 local old=buffered(s)
 local exhausted=s:iter_functions{range_start=0x401106,range_end=0x401106}; assert(exhausted()); assert(exhausted()==nil)
 local gen=owner:_generation()
 local response=check(s:open_program(p))
 assert(type(response.program_name)=='string' and type(response.has_entry_point)=='boolean' and response.image_base:hex())
 assert(owner==s:native() and owner:_generation()==gen:add(1) and opened.program_name==historical)
 stale(old);stale(exhausted)
 -- Dispatched open failure invalidates but never releases the owner.
 old=buffered(s);gen=owner:_generation()
 local missing=copy(p);missing.program_path=work..'/missing.elf';missing.project_path=work..'/missing.gpr'
 local v,err=s:open_program(missing);assert(not v and err.backend=='local')
 assert(owner:_generation()==gen:add(1) and owner==s:native() and s:get_status().ok);stale(old)
 check(s:open_program(p))
 -- Native-only ignored fields remain accepted deliberately.
 local native=copy(p);native.read_only=true;native.project_name='ignored';check(owner:open_program(native))
 for _,op in ipairs{'close_program','shutdown'} do
  old=buffered(s);gen=owner:_generation()
  rejects(op,'NO_STATE_PATH',s[op](s,{policy='save'}))
  unchanged(s,gen);assert(old())
  rejects(op,'INVALID_ARGUMENT',s[op](s,{policy='save',unexpected=true}))
  rejects(op,'INVALID_ARGUMENT',s[op](s,{policy='save',[hostile]=true}))
  rejects(op,'INVALID_ARGUMENT',s[op](s,setmetatable({},{__index={policy='save'}})))
  unchanged(s,gen)
 end
 old=buffered(s);gen=owner:_generation()
 response=check(s:shutdown{policy='discard'})
 assert(response.accepted==true and response.closed==nil and owner:_generation()==gen:add(1));stale(old)
 local v,err=s:read_bytes(0x401106,4);assert(not v and err.code=='NO_PROGRAM' and err.backend=='local')
 assert(s:get_status().ok);local v,err=low.local_client();assert(not v and err.code=='CLIENT_IN_USE')
 check(s:open_program(p));stale(old);assert(opened.program_name==historical)
 response=check(owner:shutdown{policy='save'});assert(response.accepted==true) -- pinned empty-path caveat, not persistence
 local v,err=s:read_bytes(0x401106,4);assert(not v and err.code=='NO_PROGRAM')
 check(s:close());check(s:close())
 rejects('shutdown','CLOSED',s:shutdown{policy='save'})
 rejects('close_program','CLOSED',s:close_program{policy='save'})
 rejects('open_program','CLOSED',s:open_program(p))
 rejects('open_program','INVALID_ARGUMENT',s:open_program{read_only=false})
 rejects('shutdown','INVALID_ARGUMENT',s:shutdown{policy='save',unexpected=true})
 check(low.local_client()):close()
 -- Writable save: verify actual accepted envelope/logical closure, not restoration.
 local f=assert(io.open(work..'/'..route..'-writable-check','w'));f:close()
 s=check(gh.open{client={state_path=work..'/'..route..'-state.xml'},program=p})
 response=check(s:shutdown{policy='save'});assert(response.accepted==true and response.closed==nil)
 local v,err=s:read_bytes(0x401106,4);assert(not v and err.code=='NO_PROGRAM');check(s:close())
 -- Deterministic failure independent of permissions, same setup as ownership_close_failure.
 s=check(gh.open{client={state_path='/dev/null/lua-libghidra-state.xml'},program=p})
 for _,op in ipairs{'shutdown','close_program'} do
  old=buffered(s);gen=s:native():_generation()
  local v,err=s[op](s,{policy='save'})
  assert(not v and err.code=='SAVE_FAILED' and err.backend=='local' and err.operation==op)
  assert(err.message=='Unable to open file for writing: /dev/null/lua-libghidra-state.xml')
  assert(s:native():_generation()==gen:add(1));stale(old)
  assert(s:read_bytes(0x401106,4)=='\xf3\x0f\x1e\xfa')
 end
 check(s:close())
 print('facade '..route..': raw policy, envelopes, same owner, generations, save/close failure and CLOSED PASS')
end
assert(not touched);userdata:close()
-- Forwarding-only supplement: real fixtures do not yield every false/empty flag.
-- This does not substitute for either real route above.
local responses={open_program={program_name='',has_entry_point=false,image_base=0},
  shutdown={accepted=false},close_program={closed=false}}
local fake={}
function fake:_has_state_path() return true end
function fake:close() return true end
for op,response in pairs(responses) do fake[op]=function() return response end end
local facade=assert(loadfile(root..'/lua/libghidra/init.lua','t',setmetatable({require=function(name)
 if name=='libghidra.lowlevel' then return {local_client=function() return fake end} end
 return require(name)
end},{__index=_G})))()
local session,err,response=facade.open{program={program_path='fixture'}}
assert(session and err==nil and response==responses.open_program)
assert(session:open_program{program_path='fixture'}==responses.open_program)
assert(session:shutdown{policy='discard'}==responses.shutdown and responses.shutdown.accepted==false)
assert(session:close_program{policy='discard'}==responses.close_program and responses.close_program.closed==false)
assert(response.program_name=='' and response.has_entry_point==false and response.image_base==0)
-- Arbitrary userdata keys must not invoke even a mutating __tostring.
local key=assert(io.tmpfile());local original=debug.getmetatable(key)
debug.setmetatable(key,{__tostring=function() error('userdata __tostring invoked') end})
rejects('open','INVALID_ARGUMENT',facade.open{program={[key]=true}})
rejects('open_program','INVALID_ARGUMENT',session:open_program{[key]=true})
debug.setmetatable(key,original);key:close()
print('forwarding-only false/zero/empty response identity and userdata key supplement PASS')
