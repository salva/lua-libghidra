-- MIT Copyright 2026 Salvador Fandiño.
-- Uses the real exact-value primitive, but observes calls without native dispatch.
local root=assert(arg[1],'source root required')
local u64=require('libghidra').u64
local function u(s) return assert(u64(s)) end
local base={'input','0x401106','x86:LE:64:default','gcc','0x401000','0x401134','4','0x401109','1'}
local cases={
 {name='complete',exit=0,result='complete'},
 {name='short instruction page',count='2',exit=0,result='complete'},
 {name='empty page',empty=true,exit=1,result='unavailable'},
 {name='malformed page',malformed=true,exit=1,result='error'},
 {name='optional function absent',absent=true,exit=1,result='unavailable'},
 {name='native read failure',failure=true,exit=1,result='error'},
 {name='short bytes',short=true,exit=1,result='error'},
 {name='out of bounds page',outside=true,exit=1,result='error'},
 {name='instruction crosses bound',long=true,exit=1,result='error'},
 {name='zero instruction length',zero_length=true,exit=1,result='error'},
 {name='incomplete',dec={completed=false,is_fallback=false},exit=1,result='incomplete'},
 {name='fallback',dec={completed=true,is_fallback=true},exit=1,result='fallback'},
 {name='engine message',dec={completed=true,is_fallback=false,error_message='engine text'},exit=1,result='error'},
 {name='raised conversion',raises=true,exit=1},
 {name='open failure',open_fail=true,exit=1,result='error'},
}
for _,c in ipairs{
 {'invalid address',2,'1.0'}, {'invalid mapped start',5,'-1'}, {'invalid mapped end',6,'0xZZ'},
 {'zero bytes',7,'0'}, {'too many bytes',7,'65'}, {'float count',7,'1.0'},
 {'zero instructions',9,'0'}, {'too many instructions',9,'9'},
 {'reversed bounds',5,'0x401135'}, {'outside bounds',6,'0x401105'},
 {'bytes cross bound',6,'0x401108'}, {'independent instruction bound',8,'0x401135'},
 {'instruction end below start',8,'0x401105'}, {'zero sentinel',8,'0'},
 {'empty optional root',10,''}, {'missing argument',9,false}, {'extra argument',11,'extra'},
} do cases[#cases+1]={name=c[1],index=c[2],value=c[3],invalid=true,exit=2} end
cases[#cases+1]={name='checked overflow',overflow=true,invalid=true,exit=2}
for _,case in ipairs(cases) do
 local args={table.unpack(base)}
 if case.index then args[case.index]=case.value or nil end
 if case.index==11 then args[10]='root' end
 if case.count then args[9]=case.count end
 if case.overflow then args[2]='18446744073709551615';args[6]=args[2];args[8]=args[2] end
 local calls,closed,opened,status,out,err={},0,0,nil,{},{}
 local function record(name) calls[#calls+1]=name end
 local session=setmetatable({}, {__close=function() closed=closed+1 end})
 function session:get_decompilation(address)
  record('decompile');assert(address==u(base[2]))
  if case.raises then error('conversion refusal') end
  return case.dec or {completed=true,is_fallback=false}
 end
 function session:get_function(address)
  record('function');assert(address==u(base[2]))
  if case.absent then return nil,{code='NOT_FOUND',operation='get_function',backend='local',message='absent'} end
  return {name='native\nsmoke',entry_address=address,start_address=address,end_address=u('0x40111f')}
 end
 function session:read_bytes(address,n)
  record('bytes');assert(address==u(base[2]) and n==4)
  if case.failure then return nil,{code='READ_FAILED',operation='read_bytes',backend='local',message='read refusal'} end
  return case.short and '\xf3' or '\xf3\x0f\x1e\xfa'
 end
 function session:list_instructions(page)
  record('instructions')
  assert(page.range_start==u(base[2]) and page.range_end==u(base[8]) and page.offset==0 and page.limit==tonumber(args[9]))
  if case.malformed then return {} end
  return {instructions=case.empty and {} or {{address=u(case.outside and '0x40110a' or base[2]),length=case.long and 5 or case.zero_length and 0 or 4}}}
 end
 local api={u64=u64,open=function(options)
  opened=opened+1
  assert(options.program.language_id==base[3] and options.program.compiler_spec_id==base[4])
  if case.open_fail then return nil,{code='OPEN_FAILED',operation='open',backend='local',message='open refusal'} end
  return session
 end}
 local function sink(t) return {write=function(_,...) for _,s in ipairs{...} do t[#t+1]=tostring(s) end end} end
 local env=setmetatable({arg=args,require=function(n) assert(n=='libghidra');return api end,
 io={stdout=sink(out),stderr=sink(err)},os={exit=function(n)
  assert(closed==(opened==1 and not case.open_fail and 1 or 0),'owner live at exit')
  status=n;error('exit sentinel',0)
 end}},{__index=_G})
 local ok,e=pcall(assert(loadfile(root..'/examples/inspect_function.lua','t',env)))
 assert(not ok and e=='exit sentinel',tostring(e))
 assert(status==case.exit,case.name..': exit '..tostring(status))
 assert(opened==(case.invalid and 0 or 1),case.name..': predispatch')
 if case.invalid or case.open_fail then assert(#calls==0,case.name) end
 if case.result then
  local text=table.concat(out)
  local prefix='address=0x0000000000401106\nresult='..case.result..'\n'
  assert(text:sub(1,#prefix)==prefix,case.name..': result')
  if case.exit==0 then
   assert(table.concat(calls,',')=='decompile,function,bytes,instructions')
   assert(text:find('bytes_hex=f30f1efa\n',1,true))
   assert(text:find('instruction_address=0x0000000000401106\n',1,true))
   assert(text:find('function_name="native\\\nsmoke"',1,true),'quoted metadata')
  end
 end
 if case.failure then assert(table.concat(err):find('code=READ_FAILED operation=read_bytes backend=local message=read refusal',1,true)) end
 if case.dec and case.dec.error_message then assert(table.concat(err):find('engine text',1,true)) end
 print('PASS inspection control: '..case.name)
end
