// MIT Copyright 2026 Salvador Fandiño.
#pragma once
#include <lua.hpp>
#include <cstdint>
#include <optional>
#include <string>
#include <vector>

namespace llg {
// These functions may allocate/raise in Lua: call only in trivial frames under
// a protected boundary. Native owners must remain in the caller of lua_pcall.
void push_u64(lua_State*, uint64_t);
bool read_u64(lua_State*, int, uint64_t*);
int error(lua_State*, const char* operation, const char* message);
void text(lua_State*, const std::string&);
void value(lua_State*, uint64_t);
void value(lua_State*, int64_t);
void value(lua_State*, uint32_t);
void value(lua_State*, int);
void value(lua_State*, bool);
void value(lua_State*, const std::string&);
template<class T> void value(lua_State* L, const std::optional<T>& v) {
    if (v.has_value()) value(L, *v); else lua_pushnil(L);
}
template<class T> void value(lua_State* L, const std::vector<T>& v) {
    lua_createtable(L, static_cast<int>(v.size()), 0);
    for (size_t i = 0; i < v.size(); ++i) { value(L, v[i]); lua_rawseti(L, -2, i + 1); }
}
template<class T> void field(lua_State* L, const char* key, const T& v) {
    value(L, v); lua_setfield(L, -2, key);
}
// The caller must reserve stack capacity before constructing any RAII owner.
// Zero-upvalue lua_pushcfunction and lightuserdata do not allocate (Lua 5.4).
// Conversion thunk takes a borrowed owner pointer in argument 1. No ownership
// is transferred, including on OOM; pop/rethrow only after owner destruction.
inline int protected_convert(lua_State* L, lua_CFunction thunk, void* owner) {
    lua_pushcfunction(L, thunk); lua_pushlightuserdata(L, owner);
    return lua_pcall(L, 1, 1, 0);
}
struct Page { uint64_t start = 0, end = UINT64_MAX; int limit = 100, offset = 0; };
bool read_size(lua_State*, int, uint32_t*);
bool read_page(lua_State*, int, Page*, bool iterator = false);
}
