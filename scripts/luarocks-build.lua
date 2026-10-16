-- MIT Copyright 2026 Salvador Fandiño.
-- Local-only package driver. No downloads and no alternate Lua VM.
local function quote(s) return "'" .. s:gsub("'", "'\\''") .. "'" end
local function run(args)
  for i,v in ipairs(args) do args[i]=quote(v) end
  local ok,_,code=os.execute(table.concat(args,' '))
  assert(ok, 'command failed (exit '..tostring(code)..'): '..table.concat(args,' '))
end
local phase=assert(arg[1], 'build or install phase required')
assert(phase=='build' or phase=='install', 'unknown phase')
local build=assert(os.getenv('LLG_BUILD_DIR'), 'set LLG_BUILD_DIR to a fresh absolute build directory')
assert(build:sub(1,1)=='/', 'LLG_BUILD_DIR must be absolute')
if phase=='install' then
  local prefix,libdir,luadir=assert(arg[2]),assert(arg[3]),assert(arg[4])
  run{'cmake','--install',build,'--prefix',prefix}
else
  local prefix,libdir,luadir=assert(arg[2]),assert(arg[3]),assert(arg[4])
  local host,include=assert(arg[5],'selected Lua executable required'),assert(arg[6],'selected Lua headers required')
  for _,path in ipairs{host,include} do
    assert(path:sub(1,1)=='/' and not path:find('$',1,true),'selected Lua paths must be expanded absolute paths')
  end
  print('Selected Lua driver: host='..host..'; headers='..include)
  local sdk=os.getenv('LLG_SDK_PREFIX')
  local inputs=os.getenv('LLG_INPUT_ROOT')
  assert((sdk and sdk~='') ~= (inputs and inputs~=''),
    'set exactly one of LLG_SDK_PREFIX or LLG_INPUT_ROOT (prepared authorized inputs)')
  local args={'cmake','-S','.','-B',build,'-G','Ninja','-DBUILD_TESTING=OFF',
    '-DLUA_EXECUTABLE='..host,'-DLLG_LUA_INCLUDE_DIR='..include,
    '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON','-DCMAKE_BUILD_TYPE=Release','-DCMAKE_INSTALL_PREFIX='..prefix,
    '-DLUA_MODULE_DIR='..libdir,'-DLUA_SOURCE_DIR='..luadir,
    '-DFETCHCONTENT_FULLY_DISCONNECTED=ON'}
  if sdk and sdk~='' then
    args[#args+1]='-DLIBGHIDRA_USE_SDK=ON'
    args[#args+1]='-DCMAKE_PREFIX_PATH='..sdk
  else
    args[#args+1]='-DLIBGHIDRA_USE_SDK=OFF'
    args[#args+1]='-DNATIVE_INPUT_ROOT='..inputs
  end
  run(args)
  run{'cmake','--build',build,'--parallel',os.getenv('BUILD_JOBS') or '4'}
end
