// MIT Copyright 2026 Salvador Fandiño.
#include <lua.hpp>
#include <cassert>
#include <cstdio>
extern "C" int luaopen_libghidra__native(lua_State*);
static bool armed=false;
static unsigned edges=0;
namespace llg {
void before_owner_recheck(lua_State* L) {
 if(!armed) return;
 armed=false; ++edges;
 // Actual Lua finalization at the last Lua-running edge before validity check.
 lua_gc(L,LUA_GCCOLLECT);
}
}
static void run(lua_State* L,const char* s) {
 int rc=luaL_dostring(L,s);
 if(rc) std::fprintf(stderr,"%s\n",lua_tostring(L,-1));
 assert(rc==LUA_OK);
}
int main() {
 lua_State* L=luaL_newstate(); assert(L); luaL_openlibs(L);
 luaL_requiref(L,"libghidra._native",luaopen_libghidra__native,1); lua_setglobal(L,"n");
 for(int mode=0;mode<2;++mode) {
  run(L,"c=assert(n.local_client()); collectgarbage('stop'); hits=0; completed=0; finalizer_ok=false; finalizer_error=nil; "
        "do local owner=c; local f=setmetatable({}, {__gc=function() "
        "hits=hits+1; finalizer_ok,finalizer_error=pcall(function() "
        "assert(owner:close()); local replacement=assert(n.local_client()); "
        "assert(replacement:close()); completed=completed+1 end) end}) end");
  armed=true;
  if(mode==0) run(L,"local v,e=c:read_bytes(0,0); assert(v==nil and e.code=='CLOSED' and e.backend=='binding' and e.operation=='read_bytes')");
  else run(L,"local v,e=c:open_program{program_path='absent'}; assert(v==nil and e.code=='CLOSED' and e.backend=='binding' and e.operation=='open_program')");
  assert(!armed && edges==unsigned(mode+1));
  run(L,"assert(hits==1); assert(finalizer_ok,finalizer_error); assert(finalizer_error==nil and completed==1); "
        "assert(c:close()); c=nil; collectgarbage('restart'); collectgarbage('collect'); "
        "local fresh=assert(n.local_client()); assert(fresh:close())");
 }
 lua_close(L);
 std::puts("deterministic pre-recheck real GC: close/reconstruct finalizer and CLOSED revalidation PASS");
}
