-- MIT Copyright 2026 Salvador Fandiño.
-- Focused example control-flow checks; fake outcomes are not runtime acceptance.
local root = assert(arg[1], 'source root required')
local example = root .. '/examples/decompile.lua'
local cases = {
  {label='complete', dec={completed=true,is_fallback=false,pseudocode='ok'}, exit=0},
  {label='incomplete', dec={completed=false,is_fallback=false}, exit=1},
  {label='fallback', dec={completed=true,is_fallback=true}, exit=1},
  {label='error message', dec={completed=true,is_fallback=false,error_message='failure'}, exit=1},
  {label='native failure', exit=1},
  {label='raised conversion error', raises=true, exit=1},
  {label='open failure', open_fail=true, exit=1},
  {label='bad address', bad_address=true, exit=2},
  {label='optional absent', code='NOT_FOUND', result='unavailable', exit=1},
  {label='incomplete fallback precedence', dec={completed=false,is_fallback=true,error_message='failure'}, result='incomplete', exit=1},
  {label='extra argument', extra=true, exit=2},
  {label='empty optional root', empty_root=true, exit=2},
  {label='missing argument', missing=true, exit=2},
}
for _, case in ipairs(cases) do
  local closed, opened, exit, output = 0, 0, nil, {}
  local session = setmetatable({}, {__close=function() closed=closed+1 end})
  function session:get_decompilation()
    if case.raises then error('conversion refusal') end
    if case.dec then return case.dec end
    return nil,{code=case.code or 'DECOMPILE_FAILED',backend='local',operation='get_decompilation',message='failure'}
  end
  local api = {}
  function api.u64()
    if case.bad_address then return nil,{code='INVALID_ARGUMENT',backend='binding',operation='u64',message='bad address'} end
    return {hex=function() return '0x0000000000401106' end}
  end
  function api.open()
    opened=opened+1
    if case.open_fail then return nil,{code='OPEN_FAILED',backend='local',operation='open',message='failure'} end
    return session
  end
  local sink={write=function(_,...) for _,v in ipairs{...} do output[#output+1]=tostring(v) end end}
  local args=case.missing and {} or {'input','0x401106','x86:LE:64:default','gcc'}
  if case.extra then args[5]='root';args[6]='extra' end
  if case.empty_root then args[5]='' end
  local invalid=case.bad_address or case.missing or case.extra or case.empty_root
  local env=setmetatable({arg=args,
    require=function(name) assert(name=='libghidra');return api end,
    io={stdout=sink,stderr=sink}, os={exit=function(status)
      assert(closed==(opened==1 and not case.open_fail and 1 or 0),'owner still live at exit')
      assert(exit==nil);exit=status; error("exit sentinel",0)
    end}}, {__index=_G})
  local ok, err=pcall(assert(loadfile(example,'t',env)))
  assert(not ok and err=='exit sentinel',tostring(err))
  assert(exit==case.exit,case.label)
  assert(opened==(invalid and 0 or 1),case.label)
  local text=table.concat(output)
  if invalid then assert(text:find('code=INVALID_ARGUMENT',1,true))
  elseif not case.raises then
    local result=case.result or ({complete='complete',incomplete='incomplete',fallback='fallback'})[case.label] or 'error'
    local prefix='address=0x0000000000401106\nresult='..result..'\n'
    assert(text:sub(1,#prefix)==prefix,case.label..': missing task output prefix')
    if case.dec then
      assert(text:find('completed='..tostring(case.dec.completed)..'\nis_fallback='..tostring(case.dec.is_fallback),1,true))
      if case.dec.error_message then assert(text:find('error_message='..case.dec.error_message,1,true)) end
    else
      assert(text:find('operation=',1,true) and text:find('backend=local',1,true) and text:find('message=failure',1,true))
    end
  end
  print('PASS example control: '..case.label)
end
