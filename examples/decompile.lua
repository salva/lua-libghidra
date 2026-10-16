-- MIT Copyright 2026 Salvador Fandiño.
-- ADDRESS is a caller-verified mapped virtual function entry, not a file offset.
local ghidra = require('libghidra')
local function diagnostic(err)
  if type(err) ~= 'table' then io.stderr:write(tostring(err), '\n'); return end
  io.stderr:write(('code=%s operation=%s backend=%s message=%s\n'):format(
    tostring(err.code), tostring(err.operation), tostring(err.backend), tostring(err.message)))
end
local function run(args)
  if #args < 4 or #args > 5 then
    diagnostic{code='INVALID_ARGUMENT', operation='arguments', backend='example',
      message='usage: decompile.lua BINARY ADDRESS LANGUAGE_ID COMPILER_SPEC_ID [GHIDRA_ROOT]'}
    return 2
  end
  for i = 1, #args do
    if args[i] == '' then
      diagnostic{code='INVALID_ARGUMENT', operation='arguments', backend='example', message='argument is empty'}
      return 2
    end
  end
  local address, err = ghidra.u64(args[2])
  if not address then diagnostic(err); return 2 end
  local function report(result)
    io.stdout:write('address=', address:hex(), '\nresult=', result, '\n')
  end
  local opened, open_err = ghidra.open{
    client={ghidra_root=args[5] or ''},
    program={program_path=args[1], language_id=args[3], compiler_spec_id=args[4]},
  }
  if not opened then report('error'); diagnostic(open_err); return 1 end
  local session <close> = opened
  local dec, failure = session:get_decompilation(address)
  if not dec then
    report(type(failure)=='table' and failure.code=='NOT_FOUND' and 'unavailable' or 'error')
    diagnostic(failure)
    return 1
  end
  local result
  if dec.completed == false then result='incomplete'
  elseif dec.is_fallback == true then result='fallback'
  elseif dec.completed == true and dec.is_fallback == false and
      (not dec.error_message or dec.error_message == '') then result='complete'
  else result='error' end
  report(result)
  io.stdout:write(('completed=%s\nis_fallback=%s\n'):format(tostring(dec.completed), tostring(dec.is_fallback)))
  if dec.error_message and dec.error_message ~= '' then
    io.stderr:write('error_message=', dec.error_message, '\n')
  end
  if dec.pseudocode then io.stdout:write(dec.pseudocode, '\n') end
  return result=='complete' and 0 or 1
end
-- Return through the close scope before os.exit, including on Lua exceptions.
local ok, result = pcall(run, arg)
if not ok then diagnostic(result); os.exit(1) end
os.exit(result)
