// MIT Copyright 2026 Salvador Fandiño.
// Real SDK, independent C-built Lua states, each confined to one worker thread.
#include <lua.hpp>
#include <cassert>
#include <barrier>
#include <thread>
#include <cstdio>
#include <cstdlib>

static void run(lua_State* L, const char* script) {
 if(luaL_dostring(L,script)!=LUA_OK) {
  std::fprintf(stderr,"concurrent state: %s\n",lua_tostring(L,-1));
  std::abort();
 }
}
int main(int argc,char** argv) {
 assert(argc==3);
 std::barrier phase(2);
 bool acquired[2]={false,false};
 auto worker=[&](int id) {
  lua_State* L=luaL_newstate(); assert(L); luaL_openlibs(L);
  lua_getglobal(L,"package");
  lua_pushfstring(L,"%s/lua/?.lua;%s/lua/?/init.lua",argv[1],argv[1]);
  lua_setfield(L,-2,"path");
  lua_pushfstring(L,"%s/?.so",argv[2]); lua_setfield(L,-2,"cpath");
  lua_pop(L,1);
  run(L,"low=require'libghidra.lowlevel'");
  for(int round=0;round<40;++round) {
   phase.arrive_and_wait();
   // No thread may release its owner before BOTH attempts complete.
   run(L,"c,e=low.local_client(); if c then assert(e==nil) else "
         "assert(e.code=='CLIENT_IN_USE' and e.backend=='binding') end");
   lua_getglobal(L,"c"); acquired[id]=!lua_isnil(L,-1); lua_pop(L,1);
   phase.arrive_and_wait();
   assert(acquired[0]!=acquired[1]);
   // Race native status/conversion against the other state's rejected factory.
   if(acquired[id]) run(L,"for i=1,10 do assert(c:get_status().ok); "
                          "assert(#c:get_capabilities()>0) end");
   else run(L,"for i=1,10 do local x,e=low.local_client(); "
              "assert(x==nil and e.code=='CLIENT_IN_USE') end");
   phase.arrive_and_wait();
   // Alternate explicit release and GC-only native destruction.
   if(round%2==0) run(L,"if c then assert(c:close()); "
                        "local x,e=c:get_status(); assert(not x and e.code=='CLOSED') end");
   run(L,"c=nil; e=nil; collectgarbage('collect')");
   phase.arrive_and_wait();
   // Force both states to own on alternating rounds; scheduler bias in the
   // contested factory must not turn cross-state reuse into same-state reuse.
   if(id==round%2) run(L,"c=assert(low.local_client()); assert(c:get_status().ok)");
   phase.arrive_and_wait();
   if(id!=round%2) run(L,"local x,e=low.local_client(); assert(not x and e.code=='CLIENT_IN_USE')");
   phase.arrive_and_wait();
   run(L,"if c then c:close() end; c=nil; collectgarbage('collect')");
   phase.arrive_and_wait();
  }
  lua_close(L);
 };
 std::thread a(worker,0), b(worker,1); a.join(); b.join();
 // Both states are gone: native destruction must have released the slot.
 lua_State* L=luaL_newstate(); assert(L); luaL_openlibs(L);
 lua_getglobal(L,"package"); lua_pushfstring(L,"%s/?.so",argv[2]);
 lua_setfield(L,-2,"cpath"); lua_pop(L,1);
 run(L,"local n=require'libghidra._native'; assert(n.local_client()):close()");
 lua_close(L);
 std::puts("concurrent independent states: 40 contested factories, status/conversion vs rejection, explicit/GC release and post-teardown reuse PASS");
}
