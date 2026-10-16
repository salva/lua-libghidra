# MIT Copyright 2026 Salvador Fandiño.
find_package(PkgConfig REQUIRED)
pkg_check_modules(LUA REQUIRED lua5.4)
function(llg_header_directory output)
  foreach(directory IN LISTS ARGN)
    if(EXISTS "${directory}/lua.h" AND EXISTS "${directory}/lauxlib.h" AND EXISTS "${directory}/luaconf.h")
      set(${output} "${directory}" PARENT_SCOPE)
      return()
    endif()
  endforeach()
  message(FATAL_ERROR "Missing complete Lua headers (lua.h, lauxlib.h, luaconf.h); searched: ${ARGN}")
endfunction()
function(llg_check_headers directory check)
  include(CheckCXXSourceCompiles)
  set(CMAKE_REQUIRED_INCLUDES "${directory}")
  # Recheck even when files at the same selected path change.
  unset(${check} CACHE)
  check_cxx_source_compiles("#include <lua.h>
#include <type_traits>
static_assert(LUA_VERSION_NUM == 504);
static_assert(sizeof(lua_Integer) == 8 && std::is_signed_v<lua_Integer>);
static_assert(sizeof(lua_Number) == 8 && std::is_same_v<lua_Number, double>);
int main() { return 0; }" ${check})
  if(NOT ${check})
    message(FATAL_ERROR "Requires ordinary Lua 5.4 signed-int64/double headers: ${directory}")
  endif()
endfunction()
set(LLG_LUA_INCLUDE_DIR "" CACHE PATH "Selected Lua directory containing all three headers")
if(LLG_LUA_INCLUDE_DIR STREQUAL "")
  llg_header_directory(selected_include ${LUA_INCLUDE_DIRS})
  set(LLG_LUA_INCLUDE_DIR "${selected_include}" CACHE PATH "Selected Lua headers" FORCE)
else()
  llg_header_directory(selected_include "${LLG_LUA_INCLUDE_DIR}")
endif()
find_program(LUA_EXECUTABLE NAMES lua5.4 REQUIRED)
if(NOT IS_ABSOLUTE "${LUA_EXECUTABLE}" OR NOT EXISTS "${LUA_EXECUTABLE}")
  message(FATAL_ERROR "Selected Lua executable must exist and be absolute: ${LUA_EXECUTABLE}")
endif()
llg_check_headers("${LLG_LUA_INCLUDE_DIR}" NATIVE_LUA_ABI_OK)
message(STATUS "Selected Lua 504 signed-int64/double: host=${LUA_EXECUTABLE}; headers=${LLG_LUA_INCLUDE_DIR}")
try_compile(probe_ok "${CMAKE_BINARY_DIR}/lua-abi-build"
  "${PROJECT_SOURCE_DIR}/cmake/lua-abi-probe" llg_abi_probe llg_abi_probe
  CMAKE_FLAGS "-DLLG_LUA_INCLUDE_DIR:PATH=${LLG_LUA_INCLUDE_DIR}"
    "-DLLG_PROBE_OUTPUT:PATH=${CMAKE_BINARY_DIR}"
  OUTPUT_VARIABLE probe_build)
if(NOT probe_ok)
  message(FATAL_ERROR "Lua ABI probe build failed: ${probe_build}")
endif()
execute_process(COMMAND "${LUA_EXECUTABLE}" "${PROJECT_SOURCE_DIR}/scripts/check-lua-abi.lua"
  "${CMAKE_BINARY_DIR}/lua-abi-probe.so"
  RESULT_VARIABLE probe_status OUTPUT_VARIABLE probe_output ERROR_VARIABLE probe_error)
if(NOT probe_status EQUAL 0)
  message(FATAL_ERROR "Selected Lua ABI probe failed: host=${LUA_EXECUTABLE}; headers=${LLG_LUA_INCLUDE_DIR}\n${probe_output}${probe_error}")
endif()
message(STATUS "Lua ABI probe: ${CMAKE_BINARY_DIR}/lua-abi-probe.so; ${probe_output}")
