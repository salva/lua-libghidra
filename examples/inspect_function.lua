-- MIT Copyright 2026 Salvador Fandiño.
-- Bounds must cover complete mapped instructions. This does not detect mappings.
local ghidra = require('libghidra')
local function diagnostic(err)
  if type(err) ~= 'table' then io.stderr:write(tostring(err), '\n'); return end
  io.stderr:write(('code=%s operation=%s backend=%s message=%s\n'):format(
    tostring(err.code), tostring(err.operation), tostring(err.backend), tostring(err.message)))
end
local function invalid(message)
  diagnostic{code='INVALID_ARGUMENT',operation='arguments',backend='example',message=message}
  return 2
end
local function run(args)
  if #args ~= 9 and #args ~= 10 then
    return invalid('usage: inspect_function.lua BINARY ADDRESS LANGUAGE_ID COMPILER_SPEC_ID MAPPED_START MAPPED_END BYTE_COUNT INSTRUCTION_END INSTRUCTION_COUNT [GHIDRA_ROOT]')
  end
  for i=1,#args do if args[i]=='' then return invalid('argument is empty') end end
  local values={}
  for _,i in ipairs{2,5,6,8} do
    local value,err=ghidra.u64(args[i])
    if not value then diagnostic(err); return 2 end
    values[i]=value
  end
  local function count(text,maximum)
    if not text:match('^%d+$') then return nil end
    local n=tonumber(text)
    if not n or n<1 or n>maximum or n%1~=0 then return nil end
    return math.tointeger(n)
  end
  local byte_count,instruction_count=count(args[7],64),count(args[9],8)
  if not byte_count or not instruction_count then return invalid('BYTE_COUNT must be 1..64 and INSTRUCTION_COUNT 1..8') end
  local address,first,last,instruction_end=values[2],values[5],values[6],values[8]
  if first>address or address>last then return invalid('ADDRESS outside ordered mapped bounds') end
  local byte_end,err=address:add(byte_count-1)
  if not byte_end then diagnostic(err); return 2 end
  if byte_end>last then return invalid('byte read outside mapped bounds') end
  if instruction_end:hex()=='0x0000000000000000' or instruction_end<address or instruction_end>last then
    return invalid('instruction end must be nonzero and within ADDRESS..MAPPED_END')
  end
  local function report(result) io.stdout:write('address=',address:hex(),'\nresult=',result,'\n') end
  local opened,open_err=ghidra.open{
    client={ghidra_root=args[10] or ''},
    program={program_path=args[1],language_id=args[3],compiler_spec_id=args[4]},
  }
  if not opened then report('error'); diagnostic(open_err); return 1 end
  local session <close> = opened
  -- Decompilation discovers the function lazily; no speculative lookup/scan.
  local dec,dec_err=session:get_decompilation(address)
  local fn,fn_err=session:get_function(address)
  local bytes,bytes_err=session:read_bytes(address,byte_count)
  local page,page_err=session:list_instructions{
    range_start=address,range_end=instruction_end,offset=0,limit=instruction_count,
  }
  local result='complete'
  local function absent(value,err)
    if value then return end
    if type(err)=='table' and err.code=='NOT_FOUND' then
      if result~='error' then result='unavailable' end
    else result='error' end
    diagnostic(err)
  end
  absent(dec,dec_err); absent(fn,fn_err); absent(bytes,bytes_err); absent(page,page_err)
  if dec then
    if dec.error_message and dec.error_message~='' then
      io.stderr:write('error_message=',dec.error_message,'\n'); result='error'
    elseif result=='complete' then
      if dec.completed==false then result='incomplete'
      elseif dec.is_fallback==true then result='fallback'
      elseif dec.completed~=true or dec.is_fallback~=false then result='error' end
    end
  end
  if bytes and #bytes~=byte_count then result='error'; diagnostic('returned byte length differs from request') end
  local instructions=page and page.instructions
  if instructions then
    if #instructions==0 and result~='error' then result='unavailable' end
    local previous
    for _,instruction in ipairs(instructions) do
      local finish=instruction.address:add(instruction.length>0 and instruction.length-1 or 0)
      if instruction.length<1 or not finish or finish>instruction_end or instruction.address<address or instruction.address>instruction_end or
          (previous and instruction.address<=previous) then
        result='error'; diagnostic('returned instruction addresses outside ordered request')
      end
      previous=instruction.address
    end
    if #instructions>instruction_count then result='error'; diagnostic('returned instruction page exceeds request') end
  end
  report(result)
  if dec then io.stdout:write(('completed=%s\nis_fallback=%s\n'):format(tostring(dec.completed),tostring(dec.is_fallback))) end
  if fn then
    io.stdout:write('function_name=',('%q'):format(fn.name),'\n')
    for _,field in ipairs{'entry_address','start_address','end_address'} do
      io.stdout:write('function_',field,'=',fn[field]:hex(),'\n')
    end
  end
  if bytes then io.stdout:write('bytes_hex=',(bytes:gsub('.',function(c) return ('%02x'):format(c:byte()) end)),'\n') end
  for _,instruction in ipairs(instructions or {}) do
    io.stdout:write('instruction_address=',instruction.address:hex(),'\n')
  end
  return result=='complete' and 0 or 1
end
local ok,result=pcall(run,arg)
if not ok then diagnostic(result); os.exit(1) end
os.exit(result)
