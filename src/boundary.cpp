// MIT Copyright 2026 Salvador Fandiño.
#include "boundary.hpp"
#include <climits>
#include <cstdio>
#include <cstring>
#include <limits>
#include <type_traits>

namespace llg {
static_assert(LUA_VERSION_NUM == 504 && sizeof(lua_Integer) == 8);
static constexpr const char* mt = "libghidra.UInt64";
struct U64 { uint64_t n; };
static_assert(std::is_trivial_v<U64>);
static U64* get(lua_State* L, int i) { return static_cast<U64*>(luaL_testudata(L, i, mt)); }
int error(lua_State* L, const char* op, const char* message) {
    lua_pushnil(L); lua_createtable(L, 0, 4);
    lua_pushliteral(L, "INVALID_ARGUMENT"); lua_setfield(L, -2, "code");
    lua_pushstring(L, message); lua_setfield(L, -2, "message");
    lua_pushstring(L, op); lua_setfield(L, -2, "operation");
    lua_pushliteral(L, "binding"); lua_setfield(L, -2, "backend");
    return 2;
}
bool read_u64(lua_State* L, int i, uint64_t* out) {
    if (U64* p = get(L, i)) { *out = p->n; return true; }
    if (lua_isinteger(L, i)) {
        lua_Integer n = lua_tointeger(L, i); if (n < 0) return false;
        *out = static_cast<uint64_t>(n); return true;
    }
    if (lua_type(L, i) != LUA_TSTRING) return false;
    size_t len; const char* s = lua_tolstring(L, i, &len);
    size_t j = 0; unsigned base = 10; uint64_t n = 0;
    if (len >= 2 && s[0] == '0' && s[1] == 'x') { j = 2; base = 16; }
    if (j == len) return false;
    for (; j < len; ++j) {
        unsigned c = static_cast<unsigned char>(s[j]); unsigned d;
        if (c >= '0' && c <= '9') d = c - '0';
        else if (base == 16 && c >= 'a' && c <= 'f') d = c - 'a' + 10;
        else if (base == 16 && c >= 'A' && c <= 'F') d = c - 'A' + 10;
        else return false;
        if (d >= base || n > (UINT64_MAX - d) / base) return false;
        n = n * base + d;
    }
    *out = n; return true;
}
void push_u64(lua_State* L, uint64_t n) {
    U64* p = static_cast<U64*>(lua_newuserdatauv(L, sizeof(U64), 0)); p->n = n;
    luaL_setmetatable(L, mt);
}
static int make(lua_State* L) {
    uint64_t n;
    if (!read_u64(L, 1, &n)) return error(L, "u64", "expected exact unsigned 64-bit value");
    push_u64(L, n); return 1;
}
static int hex(lua_State* L) {
    U64* p = get(L, 1); char b[19];
    if (!p) return error(L, "hex", "expected UInt64");
    std::snprintf(b, sizeof b, "0x%016llx", static_cast<unsigned long long>(p->n));
    lua_pushstring(L, b); return 1;
}
static int decimal(lua_State* L) {
    U64* p = get(L, 1); char b[21];
    if (!p) return error(L, "decimal", "expected UInt64");
    std::snprintf(b, sizeof b, "%llu", static_cast<unsigned long long>(p->n));
    lua_pushstring(L, b); return 1;
}
static int integer(lua_State* L) {
    U64* p = get(L, 1);
    if (!p || p->n > static_cast<uint64_t>(LUA_MAXINTEGER)) return error(L, "to_integer", "not representable as Lua integer");
    lua_pushinteger(L, static_cast<lua_Integer>(p->n)); return 1;
}
static int adjust(lua_State* L, bool sub) {
    U64* p = get(L, 1); uint64_t n;
    if (!p || !lua_isinteger(L, 2) || lua_tointeger(L, 2) < 0)
        return error(L, sub ? "sub" : "add", "expected UInt64 and nonnegative integer");
    n = static_cast<uint64_t>(lua_tointeger(L, 2));
    if (sub ? p->n < n : p->n > UINT64_MAX - n)
        return error(L, sub ? "sub" : "add", "unsigned arithmetic overflow");
    push_u64(L, sub ? p->n - n : p->n + n); return 1;
}
static int add(lua_State* L) { return adjust(L, false); }
static int sub(lua_State* L) { return adjust(L, true); }
static int compare(lua_State* L, int mode) {
    U64 *a = get(L, 1), *b = get(L, 2);
    if (!a || !b) {
        if (!mode) { lua_pushboolean(L, false); return 1; }
        error(L, mode == 1 ? "__lt" : "__le", "ordered operands must both be UInt64");
        return lua_error(L);
    }
    lua_pushboolean(L, mode == 0 ? a->n == b->n : mode == 1 ? a->n < b->n : a->n <= b->n); return 1;
}
static int eq(lua_State* L) { return compare(L, 0); }
static int lt(lua_State* L) { return compare(L, 1); }
static int le(lua_State* L) { return compare(L, 2); }
static int immutable(lua_State* L) {
    error(L, "__newindex", "UInt64 is immutable"); return lua_error(L);
}
void text(lua_State* L, const std::string& s) { lua_pushlstring(L, s.data(), s.size()); }
void value(lua_State* L, const std::string& s) { text(L, s); }
void value(lua_State* L, uint64_t n) { push_u64(L, n); }
void value(lua_State* L, int64_t n) { lua_pushinteger(L, n); }
void value(lua_State* L, uint32_t n) { lua_pushinteger(L, n); }
void value(lua_State* L, int n) { lua_pushinteger(L, n); }
void value(lua_State* L, bool b) { lua_pushboolean(L, b); }
bool read_integer(lua_State* L, int i, lua_Integer min, lua_Integer max, lua_Integer* out) {
    if (!lua_isinteger(L, i)) return false;
    lua_Integer n = lua_tointeger(L, i);
    if (n < min || n > max) return false;
    *out = n; return true;
}
bool read_boolean(lua_State* L, int i, bool* out) {
    if (lua_type(L, i) != LUA_TBOOLEAN) return false;
    *out = lua_toboolean(L, i); return true;
}
bool read_text(lua_State* L, int i, const char** out, size_t* len) {
    if (lua_type(L, i) != LUA_TSTRING) return false;
    *out = lua_tolstring(L, i, len); return true;
}
bool known_keys(lua_State* L, int i, const char* const* allowed) {
    if (!lua_istable(L, i)) return false;
    i = lua_absindex(L, i); lua_pushnil(L);
    while (lua_next(L, i)) {
        size_t len; const char* k; bool found = false;
        if (read_text(L, -2, &k, &len)) {
            for (size_t j = 0; allowed[j]; ++j)
                if (strlen(allowed[j]) == len && !memcmp(k, allowed[j], len)) { found = true; break; }
        }
        lua_pop(L, 1);
        if (!found) { lua_pop(L, 1); return false; }
    }
    return true;
}
bool read_size(lua_State* L, int i, uint32_t* n) {
    if (!lua_isinteger(L, i)) return false;
    lua_Integer v = lua_tointeger(L, i);
    if (v < 0 || v > INT32_MAX) return false;
    *n = static_cast<uint32_t>(v); return true;
}
// Raw access rejects unknown keys without invoking __pairs/__index or coercing
// numeric keys. No dispatch or size-proportional allocation occurs here.
bool read_page(lua_State* L, int i, Page* p, bool iterator) {
    *p = Page{};
    if (lua_isnoneornil(L, i)) return true;
    if (!lua_istable(L, i)) return false;
    i = lua_absindex(L, i); lua_pushnil(L);
    while (lua_next(L, i)) {
        if (lua_type(L, -2) != LUA_TSTRING) { lua_pop(L, 2); return false; }
        size_t len; const char* k = lua_tolstring(L, -2, &len);
        bool ok = false; uint64_t n;
        if (len == 11 && !memcmp(k, "range_start", len)) {
            ok = read_u64(L, -1, &n); if (ok) p->start = n;
        } else if (len == 9 && !memcmp(k, "range_end", len)) {
            ok = read_u64(L, -1, &n); if (ok) p->end = n;
        } else if ((iterator && len == 9 && !memcmp(k, "page_size", len)) ||
                   (!iterator && len == 5 && !memcmp(k, "limit", len))) {
            ok = lua_isinteger(L, -1) && lua_tointeger(L, -1) > 0 && lua_tointeger(L, -1) <= INT_MAX;
            if (ok) p->limit = static_cast<int>(lua_tointeger(L, -1));
        } else if (len == 6 && !memcmp(k, "offset", len)) {
            ok = lua_isinteger(L, -1) && lua_tointeger(L, -1) >= 0 && lua_tointeger(L, -1) <= INT_MAX;
            if (ok) p->offset = static_cast<int>(lua_tointeger(L, -1));
        }
        lua_pop(L, 1);
        if (!ok) { lua_pop(L, 1); return false; }
    }
    if (p->end == 0) p->end = UINT64_MAX;
    return p->offset <= INT_MAX - p->limit && p->start <= p->end;
}
static int size_check(lua_State* L) {
    uint32_t n;
    if (!read_size(L, 1, &n)) return error(L, "read_bytes", "size must be an integer in 0..INT32_MAX");
    lua_pushinteger(L, n); return 1;
}
static int page_check(lua_State* L) {
    Page p;
    if (!read_page(L, 1, &p, lua_toboolean(L, 2))) return error(L, "page", "invalid page request");
    lua_createtable(L, 0, 4);
    field(L, "range_start", p.start); field(L, "range_end", p.end);
    field(L, "limit", p.limit); field(L, "offset", p.offset); return 1;
}
static void function(lua_State* L, const char* key, lua_CFunction f) {
    lua_pushcfunction(L, f); lua_setfield(L, -2, key);
}
#ifdef LLG_OWNER
void owner_module(lua_State*);
#endif
int module(lua_State* L) {
    luaL_newmetatable(L, mt);
    function(L, "__tostring", hex); function(L, "__eq", eq);
    function(L, "__lt", lt); function(L, "__le", le);
    function(L, "__newindex", immutable);
    lua_pushliteral(L, "UInt64"); lua_setfield(L, -2, "__metatable");
    lua_newtable(L);
    function(L, "hex", hex); function(L, "decimal", decimal);
    function(L, "to_integer", integer); function(L, "add", add); function(L, "sub", sub);
    lua_setfield(L, -2, "__index"); lua_pop(L, 1);
    lua_createtable(L, 0, 3);
    function(L, "u64", make); function(L, "_validate_read_size", size_check);
    function(L, "_validate_page", page_check);
#ifdef LLG_OWNER
    owner_module(L);
#endif
    return 1;
}
}
extern "C" int luaopen_libghidra__native(lua_State* L) { return llg::module(L); }
