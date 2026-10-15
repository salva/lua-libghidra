-- MIT Copyright 2026 Salvador Fandiño.
local low = require('libghidra.lowlevel')
local Session = {}
Session.__index = Session
function Session:native() return self._owner end
function Session:close() return self._owner:close() end
Session.__close = Session.close
for _, name in ipairs{'get_status','get_capabilities','get_revision','open_program',
                       'close_program','shutdown'} do
  Session[name] = function(self, ...) return self._owner[name](self._owner, ...) end
end
function Session:read_bytes(...)
  local response, err = self._owner:read_bytes(...)
  if not response then return nil, err end
  return response.data, nil, response
end
local function invalid(message)
  return nil, {code='INVALID_ARGUMENT', operation='open', backend='binding', message=message}
end
local function publish(owner, program)
  local response, err = owner:open_program(program)
  if not response then return nil, err end
  return setmetatable({_owner=owner}, Session), nil, response
end
-- Keep validation separate from construction, and use pcall for publication.
local function open(options)
  -- Validate with the same rules without constructing any resource.
  if type(options) ~= 'table' then return invalid('options table required') end
  for k in next, options do
    if k ~= 'client' and k ~= 'program' then return invalid('unknown open option') end
  end
  local program = rawget(options,'program')
  if type(program) ~= 'table' then return invalid('program table required') end
  local allowed = {program_path=true,project_path=true,language_id=true,compiler_spec_id=true,format=true,base_address=true}
  for k in next, program do if not allowed[k] then return invalid('unknown program option') end end
  local owner, err = low.local_client(rawget(options,'client'))
  if not owner then return nil, err end
  local ok, session, failure, response = pcall(publish, owner, program)
  if not ok then owner:close(); error(session,0) end
  if not session then owner:close(); return nil, failure end
  return session, nil, response
end
return {u64=low.u64, check=low.check, open=open}
