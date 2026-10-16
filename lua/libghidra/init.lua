-- MIT Copyright 2026 Salvador Fandiño.
local low = require('libghidra.lowlevel')
local Session = {}
Session.__index = Session
function Session:native() return self._owner end
function Session:close() return self._owner:close() end
Session.__close = Session.close
for _, name in ipairs{'get_status','get_capabilities','get_revision'} do
  Session[name] = function(self, ...) return self._owner[name](self._owner, ...) end
end
local function invalid(operation, message)
  return nil, {code='INVALID_ARGUMENT',operation=operation,backend='binding',message=message}
end
local program_keys={program_path=true,project_path=true,language_id=true,
  compiler_spec_id=true,format=true,base_address=true}
-- Policy only: native parsing remains authoritative for values and defaults.
local function validate_program(program, operation)
  if type(program)~='table' then return invalid(operation,'program table required') end
  for key in next, program do
    if not program_keys[key] then return invalid(operation,'unknown program option') end
  end
  return true
end
function Session:open_program(program)
  local valid, err=validate_program(program,'open_program')
  if not valid then return nil, err end
  return self._owner:open_program(program)
end
-- Stricter save policy for exactly these two facade lifecycle methods.
-- _has_state_path defers closed owners to native CLOSED precedence.
local function close_with_policy(self, options, operation)
  if type(options)=='table' and rawget(options,'policy')=='save' and
     not self._owner:_has_state_path() then
    for key in next, options do
      if key~='policy' then return invalid(operation,'unknown close option') end
    end
    return nil, {code='NO_STATE_PATH',message='save requires state_path',operation=operation,backend='binding'}
  end
  return self._owner[operation](self._owner,options)
end
function Session:close_program(options) return close_with_policy(self,options,'close_program') end
function Session:shutdown(options) return close_with_policy(self,options,'shutdown') end
function Session:read_bytes(...)
  local response, err = self._owner:read_bytes(...)
  if not response then return nil, err end
  return response.data, nil, response
end
-- All reads use the owning native dispatch and detached converter.
for _, name in ipairs{'list_functions','list_instructions','save_program','rename_function','rename_symbol',
  'write_bytes','list_basic_blocks','list_cfg_edges','list_symbols','list_xrefs',
  'list_memory_blocks','list_types','list_type_aliases','list_type_unions','list_type_enums',
  'list_type_enum_members','list_type_members','list_function_signatures','get_comments'} do
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
function Session:get_symbol(address) return unwrap(self,'get_symbol','symbol',address) end
function Session:get_type(path) return unwrap(self,'get_type','type',path) end
function Session:get_function_signature(address) return unwrap(self,'get_function_signature','signature',address) end
function Session:get_instruction(address) return unwrap(self,'get_instruction','instruction',address) end
function Session:get_decompilation(address, options)
  if options ~= nil and (type(options) ~= 'table' or next(options) ~= nil) then
    return nil, {code='INVALID_ARGUMENT',message='facade decompilation options must be empty',operation='get_decompilation',backend='binding'}
  end
  return unwrap(self,'get_decompilation','decompilation',address)
end
local iterate=require('libghidra.iterator')
local function textkey(s) return #s..':'..s end
-- Blocks/CFG/xrefs are pages-only: no qualified native structural/phase comparator.
local families={
  functions={field='functions', id=function(r) return r.entry_address:hex() end,
    order=function(r) return {r.entry_address:hex()} end},
  symbols={field='symbols', id=function(r) return r.address:hex()..textkey(r.name)..textkey(r.namespace_name) end,
    order=function(r) return {r.symbol_id:hex()} end},
  memory_blocks={field='blocks', counts=true, id=function(r) return r.start_address:hex()..textkey(r.name) end,
    order=function(r) return {r.start_address:hex(),r.name} end},

}
for family,descriptor in pairs(families) do
  Session['iter_'..family]=function(self,first,second)
    local query,options
    if descriptor.text then query,options=first,second
    else options=first end
    if descriptor.text and type(query)~='string' then
      error({code='INVALID_ARGUMENT',operation='iter_'..family,backend='binding',message='query string required'},0)
    end
    local owner=self._owner
    return iterate(owner,'iter_'..family,function(page)
      local response,failure
      if descriptor.counts then
        local counts={limit=page.limit,offset=page.offset}
        if descriptor.text then response,failure=owner['list_'..family](owner,query,counts)
        else response,failure=owner['list_'..family](owner,counts) end
      else response,failure=owner['list_'..family](owner,page) end
      if not response then return nil,failure end
      return response[descriptor.field]
    end,descriptor.id,descriptor.order,options,descriptor.counts)
  end
end
local function publish(owner, program)
  local response, err = owner:open_program(program)
  if not response then return nil, err end
  return setmetatable({_owner=owner}, Session), nil, response
end
-- Keep validation separate from construction, and use pcall for publication.
local function open(options)
  -- Validate with the same rules without constructing any resource.
  if type(options) ~= 'table' then return invalid('open','options table required') end
  for k in next, options do
    if k ~= 'client' and k ~= 'program' then return invalid('open','unknown open option') end
  end
  local program = rawget(options,'program')
  local valid, failure=validate_program(program,'open')
  if not valid then return nil, failure end
  local owner, err = low.local_client(rawget(options,'client'))
  if not owner then return nil, err end
  local ok, session, failure, response = pcall(publish, owner, program)
  if not ok then owner:close(); error(session,0) end
  if not session then owner:close(); return nil, failure end
  return session, nil, response
end
return {u64=low.u64, check=low.check, open=open}
