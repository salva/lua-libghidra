// MIT Copyright 2026 Salvador Fandiño.
#include <lua.hpp>
#include <cassert>
#include <cstdio>
extern "C" int luaopen_libghidra__native(lua_State*);
static bool natural=false;
static unsigned natural_phase=0, natural_hits=0;
static int mark_finalizer(lua_State* L) {
 if(natural && (natural_phase==1 || natural_phase==3)) ++natural_hits;
 lua_pushinteger(L,natural_phase); return 1;
}
static bool armed=false;
static unsigned edges=0;
namespace llg {
void before_owner_recheck(lua_State* L) {
 if(!armed) { if(natural && natural_phase==1) natural_phase=3; return; }
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
static int natural_call(lua_State* L) {
 // Function/receiver already rooted before starting collector. No explicit
 // collection/step or allocator callback calls Lua; Lua's allocation GC checks
 // alone schedule pending finalizers while the real method executes.
 lua_gc(L,LUA_GCRESTART);
 natural_phase=1;
 lua_call(L,1,2);
 natural_phase=2;
 return 2;
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
 lua_pushcfunction(L,mark_finalizer); lua_setglobal(L,"mark_finalizer");
 // Real allocating conversion edges across every no-argument dispatch plus
 // generation. Sweep GC debt by unreachable userdata/table allocation volume.
 const char* methods[]={"get_status","get_revision","get_capabilities","_generation"};
 natural=true;
 for(const char* method:methods) {
  bool observed=false;
  for(int debt=1;debt<=128 && !observed;debt*=2) {
   natural_phase=0;
   run(L,"finalizer_phase=0; collectgarbage('collect'); collectgarbage('incremental',100,1000,0); "
         "c=assert(n.local_client()); collectgarbage('stop'); hits=0; finalizer_ok=false; completed=0; "
         "do local owner=c; local f=setmetatable({}, {__gc=function() "
         "local phase=mark_finalizer(); hits=hits+1; finalizer_phase=phase; "
         "finalizer_ok,finalizer_error=pcall(function() assert(owner:close()); "
         "local replacement=assert(n.local_client()); assert(replacement:close()); completed=completed+1 end) end}) end");
   for(int i=0;i<debt;++i) { lua_newtable(L); lua_pop(L,1); }
   lua_pushcfunction(L,natural_call);
   lua_getglobal(L,"c"); lua_getfield(L,-1,method); lua_insert(L,-2);
   int rc=lua_pcall(L,2,2,0); natural_phase=2;
   if(rc) std::fprintf(stderr,"natural GC %s: %s\n",method,lua_tostring(L,-1));
   assert(rc==LUA_OK);
   lua_pop(L,2);
   lua_getglobal(L,"finalizer_phase"); observed=lua_tointeger(L,-1)==(method[0]=='_'?1:3); lua_pop(L,1);
   if(observed) run(L,"assert(hits==1 and completed==1); assert(finalizer_ok,finalizer_error)");
   run(L,"c:close(); c=nil; collectgarbage('collect')");
   if(observed) std::printf("allocation-driven real finalizer during %s: close/reconstruct completed PASS\n",method);
  }
  assert(observed);
 }
 assert(natural_hits>=4);
 lua_close(L);
 std::puts("deterministic pre-recheck real GC: close/reconstruct finalizer and CLOSED revalidation PASS");
}
