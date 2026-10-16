// MIT Copyright 2026 Salvador Fandiño.
// Real SDK, independent C-built Lua states, each confined to one worker thread.
#include <lua.hpp>
#include <cassert>
#include <barrier>
#include <thread>
#include <cstdio>
#include <cstdlib>
#include <atomic>
#include <array>

extern "C" int luaopen_libghidra__native(lua_State*);
static std::atomic<unsigned> active{0};
static std::array<std::atomic<unsigned>,3> entered{}, exited{};
static thread_local int local_phase=-1;
static unsigned previous=3;
static unsigned transitions[3][3]{}; // Protected by observed native exclusivity.
namespace llg {
void native_phase_event(int kind,bool entering) noexcept {
 assert(kind>=0 && kind<3);
 if(entering) {
  assert(local_phase==-1);
  assert(active.fetch_add(1)==0); // No overlapping native critical phases.
  local_phase=kind;
  ++entered[kind];
  if(previous<3) ++transitions[previous][kind];
 } else {
  assert(local_phase==kind);
  ++exited[kind]; previous=kind; local_phase=-1;
  assert(active.fetch_sub(1)==1);
 }
}
}
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
  luaL_requiref(L,"libghidra._native",luaopen_libghidra__native,0); lua_setglobal(L,"low");
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
   // Race the retained winner's actual destructor against fresh construction
   // in the other state. No barrier separates reset from factory attempts.
   if(id==round%2) run(L,"assert(c:close()); c=nil; collectgarbage('collect')");
   else {
    bool got=false;
    for(unsigned attempt=0;attempt<100000 && !got;++attempt) {
     run(L,"candidate,e=low.local_client(); if not candidate then assert(e.code=='CLIENT_IN_USE') end");
     lua_getglobal(L,"candidate"); got=lua_isuserdata(L,-1); lua_pop(L,1);
     if(!got) std::this_thread::yield();
    }
    assert(got);
    run(L,"assert(candidate:get_status().ok); assert(candidate:close()); candidate=nil; collectgarbage('collect')");
   }
   phase.arrive_and_wait();
  }
  lua_close(L);
 };
 std::thread a(worker,0), b(worker,1); a.join(); b.join();
 // Both states are gone: native destruction must have released the slot.
 lua_State* L=luaL_newstate(); assert(L); luaL_openlibs(L);
 lua_getglobal(L,"package"); lua_pushfstring(L,"%s/?.so",argv[2]);
 lua_setfield(L,-2,"cpath"); lua_pop(L,1);
 luaL_requiref(L,"libghidra._native",luaopen_libghidra__native,0); lua_setglobal(L,"n");
 run(L,"assert(n.local_client()):close()");
 lua_close(L);
 assert(active==0);
 for(int k=0;k<3;++k) assert(entered[k]>0 && entered[k]==exited[k]);
 assert(entered[0]==entered[2]); // Each real factory has exactly one reset.
 assert(transitions[2][0]>0); // Destruction exits before later construction.
 std::printf("native phases: construct=%u dispatch=%u destroy=%u; balanced, no overlap, destroy->construct=%u PASS\n",
             entered[0].load(),entered[1].load(),entered[2].load(),transitions[2][0]);
}
