// MIT Copyright 2026 Salvador Fandiño.
// Native fixture seeding only, never exported in the production module.
#include <lua.hpp>
#include <libghidra/local.hpp>
#include <cassert>
#include <cstdio>
#include <stdexcept>
#include <cstdlib>
#include <filesystem>
#include <string>
static bool seed_enabled=true;
static int set_seed(lua_State* L) { seed_enabled=lua_toboolean(L,1); return 0; }
extern "C" int luaopen_libghidra__native(lua_State*);
namespace llg {
template<class T> T fixture_result(libghidra::client::StatusOr<T> r) {
 if(!r.status.ok() || !r.value) throw std::runtime_error("native fixture seeding failed: "+r.status.code);
 return std::move(*r.value);
}
void seed_core_fixture(libghidra::client::IClient* c) {
 if(!seed_enabled) return;
 using namespace libghidra::client;
 assert(fixture_result(c->GetDecompilation(0x401106,30000)).decompilation->completed);
 assert(fixture_result(c->CreateType("M3Struct","struct",16)).updated);
 assert(fixture_result(c->AddTypeMember("M3Struct","field","int",4)).updated);
 auto unsupported_union=c->CreateType("M3Union","union",8);
 assert(!unsupported_union.status.ok() && unsupported_union.status.code=="NOT_SUPPORTED");
 assert(fixture_result(c->CreateTypeAlias("M3Alias","int")).updated);
 assert(fixture_result(c->CreateTypeEnum("M3Enum",4,true)).updated);
 assert(fixture_result(c->AddTypeEnumMember("M3Enum","ONE",1)).updated);
 assert(fixture_result(c->SetComment(0x401106,CommentKind::kEol,"native fixture comment")).updated);
 assert(fixture_result(c->SetFunctionSignature(0x401106,"int native_smoke(int x)")).updated);
}
}
int main(int argc,char** argv) {
 if(argc!=3) return 2;
 lua_State* L=luaL_newstate(); assert(L); luaL_openlibs(L);
 luaL_requiref(L,"libghidra._native",luaopen_libghidra__native,0);lua_pop(L,1);
 lua_pushcfunction(L,set_seed);lua_setglobal(L,"set_fixture_seed");
 const char* work=std::getenv("SAIVAGE_CARD_WORK_ROOT");
 std::string dir=work?std::string(work)+"/m3-seeded-persistence":"m3-seeded-persistence";
 std::filesystem::create_directories(dir);
 lua_pushstring(L,dir.c_str());lua_setglobal(L,"fixture_work");
 lua_newtable(L);lua_pushstring(L,argv[2]);lua_rawseti(L,-2,1);lua_setglobal(L,"arg");
 int rc=luaL_dofile(L,argv[1]);
 if(rc) { if(lua_istable(L,-1)) lua_getfield(L,-1,"message"); std::fprintf(stderr,"seeded Lua error: %s\n",lua_tostring(L,-1)); }
 lua_close(L);return rc?1:0;
}
