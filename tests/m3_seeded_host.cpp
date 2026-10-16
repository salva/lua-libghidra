// MIT Copyright 2026 Salvador Fandiño.
// Native fixture seeding only, never exported in the production module.
#include <lua.hpp>
#include <libghidra/local.hpp>
#include <cassert>
#include <cstdio>
#include <stdexcept>
extern "C" int luaopen_libghidra__native(lua_State*);
namespace llg {
template<class T> T fixture_result(libghidra::client::StatusOr<T> r) {
 if(!r.status.ok() || !r.value) throw std::runtime_error("native fixture seeding failed: "+r.status.code);
 return std::move(*r.value);
}
void seed_core_fixture(libghidra::client::IClient* c) {
 using namespace libghidra::client;
 assert(fixture_result(c->GetDecompilation(0x401106,30000)).decompilation->completed);
 assert(fixture_result(c->CreateType("M3Struct","struct",16)).updated);
 assert(fixture_result(c->AddTypeMember("M3Struct","field","int",4)).updated);
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
 lua_newtable(L);lua_pushstring(L,argv[2]);lua_rawseti(L,-2,1);lua_setglobal(L,"arg");
 int rc=luaL_dofile(L,argv[1]);
 if(rc) std::fprintf(stderr,"seeded Lua error: %s\n",lua_tostring(L,-1));
 lua_close(L);return rc?1:0;
}
