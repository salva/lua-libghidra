// MIT Copyright 2026 Salvador Fandiño.
#include "boundary.hpp"
#include <cstdlib>
#include <cstdio>
#include <cassert>
#include <stdexcept>
extern "C" int luaopen_libghidra__native(lua_State*);
struct Allocator { size_t calls = 0, fail = SIZE_MAX, bytes = 0; };
static void* allocate(void* ud, void* ptr, size_t old, size_t n) {
    auto* a = static_cast<Allocator*>(ud);
    if (!ptr) old = 0;
    if (!n) { a->bytes -= old; free(ptr); return nullptr; }
    if (n > old && ++a->calls >= a->fail) return nullptr;
    void* p = realloc(ptr, n);
    if (p) a->bytes = a->bytes - old + n;
    return p;
}
struct Owned {
    static inline int live = 0;
    std::string bytes = std::string("a\0b", 3);
    std::optional<bool> flag = false;
    std::optional<int> zero = 0;
    std::optional<std::optional<bool>> nested = std::optional<bool>(false);
    std::optional<int> missing;
    std::vector<uint64_t> ids = {0, UINT64_MAX};
    Owned() { ++live; }
    ~Owned() { --live; }
};
static int convert(lua_State* L) {
    auto* p = static_cast<Owned*>(lua_touserdata(L, 1));
    lua_createtable(L, 0, 8);
    llg::field(L, "data", p->bytes); llg::field(L, "flag", p->flag);
    llg::field(L, "zero", p->zero); llg::field(L, "nested", p->nested);
    llg::field(L, "missing", p->missing); llg::field(L, "ids", p->ids);
    llg::field(L, "ordinal", int64_t(-1)); llg::field(L, "count", uint32_t(0));
    return 1;
}
// RAII is ONLY outside jumped frames. Check stack before creating owner.
static int detached(lua_State* L) {
    int rc;
    luaL_checkstack(L, 32, "conversion stack");
    { Owned owner; rc = llg::protected_convert(L, convert, &owner); }
    if (rc) return lua_error(L);
    return 1;
}
static int exercise(lua_State* L) {
    luaL_requiref(L, "libghidra._native", luaopen_libghidra__native, 0); lua_pop(L, 1);
    lua_pushcfunction(L, detached); lua_setglobal(L, "detached");
    return luaL_dostring(L,
      "local n=require('libghidra._native'); local v=assert(n.u64('18446744073709551615')); "
      "assert(v:hex()=='0xffffffffffffffff'); assert(v:decimal()=='18446744073709551615'); "
      "local x,e=n.u64('bad'); assert(x==nil and e.backend=='binding'); "
      "assert(n._validate_read_size(2147483647)==2147483647); "
      "local x,e=n._validate_read_size(2147483648); assert(x==nil and e.code=='INVALID_ARGUMENT'); "
      "assert(n._validate_page{range_start=1,range_end=0}); "
      "local r=detached(); collectgarbage(); assert(r.data=='a\\0b' and #r.data==3); "
      "assert(r.flag==false and r.nested==false and r.zero==0 and r.missing==nil); "
      "assert(r.ids[1]:decimal()=='0' and r.ids[2]==v and r.ordinal==-1 and r.count==0)");
}
// Setup failure is also protected; luaL_dostring returns rather than rethrows.
static int sweep_body(lua_State* L) {
    int rc = exercise(L); if (rc) return lua_error(L); return 0;
}
int main() {
    size_t boundaries = 0;
    for (size_t failure = 0; ; ++failure) {
        Allocator a;
        lua_State* L = lua_newstate(allocate, &a); assert(L);
        luaL_openlibs(L); lua_checkstack(L, 64);
        lua_pushinteger(L, INT32_MAX);
        size_t count = a.calls; uint32_t size = 0;
        assert(llg::read_size(L, -1, &size) && size == INT32_MAX);
        assert(a.calls == count); lua_pop(L, 1);
        lua_pushinteger(L, UINT32_MAX); count = a.calls;
        assert(!llg::read_size(L, -1, &size) && a.calls == count);
        lua_pop(L, 1);
        lua_pushcfunction(L, sweep_body);
        lua_pushboolean(L, 0); bool flag = true;
        assert(llg::read_boolean(L, -1, &flag) && !flag);
        lua_Integer integer; assert(!llg::read_integer(L, -1, 0, 1, &integer));
        lua_pop(L, 1); lua_pushinteger(L, 0);
        assert(llg::read_integer(L, -1, 0, 1, &integer) && integer == 0);
        assert(!llg::read_boolean(L, -1, &flag));
        const char* text; size_t length; assert(!llg::read_text(L, -1, &text, &length));
        lua_pop(L, 1); lua_pushlstring(L, "a\0b", 3);
        assert(llg::read_text(L, -1, &text, &length) && length == 3); lua_pop(L, 1);
        const char* keys[] = {"x", nullptr};
        lua_newtable(L); lua_pushinteger(L, 0); lua_setfield(L, -2, "x");
        assert(llg::known_keys(L, -1, keys));
        lua_pushboolean(L, false); lua_setfield(L, -2, "unknown");
        assert(!llg::known_keys(L, -1, keys)); lua_pop(L, 1);
        size_t baseline = a.calls;
        if (failure) a.fail = baseline + failure;
        int rc = lua_pcall(L, 0, 0, 0);
        a.fail = SIZE_MAX;
        if (!failure) { assert(rc == LUA_OK); boundaries = a.calls - baseline; }
        assert(Owned::live == 0);
        lua_settop(L, 0);
        lua_pushcfunction(L, sweep_body);
        assert(lua_pcall(L, 0, 0, 0) == LUA_OK);
        assert(Owned::live == 0);
        lua_close(L); assert(a.bytes == 0);
        if (failure == boundaries) break;
    }
    std::printf("detached conversions + persistent OOM sweep: %zu allocation boundaries PASS\n", boundaries);
}
