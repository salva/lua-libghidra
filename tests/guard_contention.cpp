// MIT Copyright 2026 Salvador Fandiño.
#include <lua.hpp>
#include "process_guard.hpp"
#include <cassert>
#include <barrier>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <future>
#include <thread>
static void run(lua_State* L,const char* s) {
 if(luaL_dostring(L,s)!=LUA_OK) {
  std::fprintf(stderr,"guard contention: %s\n",lua_tostring(L,-1)); std::abort();
 }
}
int main(int argc,char** argv) {
 assert(argc==2);
 for(int kind=0;kind<3;++kind) {
  std::barrier ready(2), start(2);
  std::promise<void> done;
  auto completion=done.get_future();
  std::thread worker([&] {
   lua_State* L=luaL_newstate(); assert(L); luaL_openlibs(L);
   lua_getglobal(L,"package"); lua_pushfstring(L,"%s/?.so",argv[1]);
   lua_setfield(L,-2,"cpath"); lua_pop(L,1);
   run(L,"n=require'libghidra._native'");
   if(kind) run(L,"c=assert(n.local_client())");
   ready.arrive_and_wait(); start.arrive_and_wait();
   if(kind==0) run(L,"c=assert(n.local_client())");
   else if(kind==1) run(L,"assert(c:get_status().ok)");
   else run(L,"assert(c:close())");
   done.set_value();
   run(L,"assert(c:close()); c=nil; collectgarbage('collect')");
   lua_close(L);
  });
  ready.arrive_and_wait();
  std::unique_lock<std::mutex> held(llg::process_guard().engine);
  start.arrive_and_wait();
  // Completion may not cross the externally held SAME shared guard.
  assert(completion.wait_for(std::chrono::milliseconds(50))==std::future_status::timeout);
  held.unlock();
  assert(completion.wait_for(std::chrono::seconds(10))==std::future_status::ready);
  worker.join();
  assert(!llg::process_guard().occupied);
 }
 std::puts("shared process guard: factory/status/destruction block while held and recover after release PASS");
}
