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
-- All reads use the owning native dispatch and detached converter.
for _, name in ipairs{'list_functions','list_instructions'} do
  Session[name] = function(self, ...) return self._owner[name](self._owner, ...) end
end
local function unwrap(self, name, key, ...)
  local response, err = self._owner[name](self._owner, ...)
  if not response then return nil, err end
  if response[key] == nil then
    return nil, {code='NOT_FOUND',message='optional result absent',operation=name,backend='binding'}, response
  end
  return response[key], nil, response
end
function Session:get_function(address) return unwrap(self,'get_function','function',address) end
function Session:get_instruction(address) return unwrap(self,'get_instruction','instruction',address) end
function Session:get_decompilation(address, options)
  if options ~= nil and (type(options) ~= 'table' or next(options) ~= nil) then
    return nil, {code='INVALID_ARGUMENT',message='facade decompilation options must be empty',operation='get_decompilation',backend='binding'}
  end
  return unwrap(self,'get_decompilation','decompilation',address)
end
function Session:iter_functions(options)
  local function raise(code, message)
    error({code=code,message=message,operation='iter_functions',backend='binding'},0)
  end
  local page, err = require('libghidra._native')._validate_page(options,true)
  if not page then error(err,0) end
  local owner, generation = self._owner, self._owner:_generation()
  local records, index, last, done = {}, 1, nil, false
  return function()
    if owner:_generation() ~= generation then raise('ITERATOR_INVALIDATED','owner generation changed') end
    if done then return nil end
    if index > #records then
      local response, failure = owner:list_functions(page)
      if not response then error(failure,0) end
      records, index = response.functions, 1
      if #records > page.limit then raise('PAGINATION_STALLED','oversized page') end
      for _, record in ipairs(records) do
        local key = record.entry_address
        if last and key <= last then raise('PAGINATION_STALLED','non-advancing function order') end
        last = key
      end
      if #records == 0 then done=true; return nil end
      if page.offset > 2147483647 - page.limit - #records then
        raise('PAGINATION_STALLED','pagination offset exhausted')
      end
      page.offset = page.offset + #records
    end
    local record=records[index]; index=index+1; return record
  end
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
