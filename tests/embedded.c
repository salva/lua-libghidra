/* MIT Copyright 2026 Salvador Fandiño. Ordinary C-built host. */
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdio.h>
int main(int argc, char** argv) {
    lua_State* L = luaL_newstate();
    if (!L || argc != 4) return 2;
    luaL_openlibs(L);
    lua_createtable(L, 3, 0);
    for (int i = 1; i < argc; ++i) {
        lua_pushstring(L, argv[i]); lua_rawseti(L, -2, i - 1);
    }
    lua_setglobal(L, "arg");
    int rc = luaL_dofile(L, argv[1]);
    if (rc) fprintf(stderr, "%s\n", lua_tostring(L, -1));
    lua_close(L); return rc ? 1 : 0;
}
