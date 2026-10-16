/* MIT Copyright 2026 Salvador Fandiño. */
#include <lua.h>
#include <lauxlib.h>
int luaopen_llg_abi_probe(lua_State *L) {
  luaL_checkversion(L);
  lua_pushboolean(L, 1);
  return 1;
}
