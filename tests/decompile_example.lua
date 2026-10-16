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
  {label='missing argument', missing=true, exit=2},
}
for _, case in ipairs(cases) do
  local closed, opened, exit, output = 0, 0, nil, {}
  local session = setmetatable({}, {__close=function() closed=closed+1 end})
  function session:get_decompilation()
    if case.raises then error('conversion refusal') end
    if case.dec then return case.dec end
    return nil,{code='DECOMPILE_FAILED',backend='local',operation='get_decompilation',message='failure'}
  end
  local api = {}
  function api.u64()
    if case.bad_address then return nil,{code='INVALID_ARGUMENT',backend='binding',operation='u64',message='bad address'} end
    return 'exact address'
  end
  function api.open()
    opened=opened+1
    if case.open_fail then return nil,{code='OPEN_FAILED',backend='local',operation='open',message='failure'} end
    return session
  end
  local sink={write=function(_,...) for _,v in ipairs{...} do output[#output+1]=tostring(v) end end}
  local env=setmetatable({arg=case.missing and {} or {'input','0x401106','x86:LE:64:default','gcc'},
    require=function(name) assert(name=='libghidra');return api end,
    io={stdout=sink,stderr=sink}, os={exit=function(status)
      assert(closed==(opened==1 and not case.open_fail and 1 or 0),'owner still live at exit')
      assert(exit==nil);exit=status; error("exit sentinel",0)
    end}}, {__index=_G})
  local ok, err=pcall(assert(loadfile(example,'t',env)))
  assert(not ok and err=='exit sentinel',tostring(err))
  assert(exit==case.exit,case.label)
  assert(opened==((case.bad_address or case.missing) and 0 or 1),case.label)
  if case.bad_address or case.missing then assert(table.concat(output):find('code=INVALID_ARGUMENT',1,true)) end
  print('PASS example control: '..case.label)
end
