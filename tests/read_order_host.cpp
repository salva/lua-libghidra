// MIT Copyright 2026 Salvador Fandiño.
#include <lua.hpp>
#include <cassert>
#include <cstdlib>
#include <cstdio>
#include <new>
#include <cstdint>
#include <string_view>
#include <cstddef>
extern "C" int luaopen_libghidra__native(lua_State*);
static unsigned phases[2];
static uint32_t observed[2];
static bool watching=false;
static bool deny=false;
static unsigned denied=0;
static unsigned attempts=0, deny_after=1;
static size_t largest=0;
// All ordinary C++ allocations in this executable carry an aligned header.
// Count outstanding blocks/bytes independently of fault-observation windows.
struct alignas(std::max_align_t) Allocation { size_t size; };
static size_t live_blocks=0, live_bytes=0;
static void free_allocation(void* p) noexcept {
 if(!p) return;
 auto* h=static_cast<Allocation*>(p)-1;
 assert(live_blocks && live_bytes>=h->size);
 --live_blocks; live_bytes-=h->size; std::free(h);
}
// Observe C++ request/response allocations. Refuse huge allocations as a safety
// backstop: an accidental accepted-bound read must never allocate gigabytes.
void* operator new(size_t n) {
 if(watching) { if(n>largest) largest=n; if(deny && ++attempts>=deny_after) { ++denied; throw std::bad_alloc(); } if(n>1024*1024) throw std::bad_alloc(); }
 if(n>SIZE_MAX-sizeof(Allocation)) throw std::bad_alloc();
 auto* h=static_cast<Allocation*>(std::malloc(sizeof(Allocation)+(n?n:1)));
 if(!h) throw std::bad_alloc();
 h->size=n; ++live_blocks; live_bytes+=n; return h+1;
}
void* operator new[](size_t n) { return ::operator new(n); }
void operator delete(void* p) noexcept { free_allocation(p); }
void operator delete[](void* p) noexcept { free_allocation(p); }
void operator delete(void* p,size_t) noexcept { free_allocation(p); }
void operator delete[](void* p,size_t) noexcept { free_allocation(p); }
namespace llg {
void observe_read_phase(int phase,uint32_t size) noexcept {
 assert(phase==0 || phase==1);
 if(phase==1) assert(phases[0]==1); // validated before SDK
 ++phases[phase]; observed[phase]=size;
}
}
static int call(lua_State* L) {
 lua_getfield(L,1,"read_bytes"); lua_pushvalue(L,1);
 lua_pushinteger(L,0); lua_pushvalue(L,2); lua_call(L,3,2); return 2;
}
static int capabilities(lua_State* L) {
 lua_getfield(L,1,"get_capabilities"); lua_pushvalue(L,1);
 lua_call(L,1,2); return 2;
}
static int factory(lua_State* L) {
 lua_getfield(L,1,"local_client"); lua_call(L,0,2); return 2;
}
struct LuaAllocator { size_t bytes=0, calls=0, fail=SIZE_MAX, refused=0; };
static void* lua_allocate(void* ud,void* p,size_t old,size_t n) {
 auto* a=static_cast<LuaAllocator*>(ud); if(!p) old=0;
 if(!n) { a->bytes-=old; std::free(p); return nullptr; }
 if(n>old && ++a->calls>=a->fail) { ++a->refused; return nullptr; }
 void* q=std::realloc(p,n);
 if(q) a->bytes=a->bytes-old+n;
 return q;
}
int main() {
 LuaAllocator allocator;
 lua_State* L=lua_newstate(lua_allocate,&allocator); assert(L); luaL_openlibs(L);
 luaL_requiref(L,"libghidra._native",luaopen_libghidra__native,0);
 lua_getfield(L,-1,"local_client");
 // Exercise real native factory partial construction, before any live owner.
 for(unsigned point=1;point<=16;++point) {
  lua_pushcfunction(L,factory); lua_pushvalue(L,1);
  attempts=denied=0; deny_after=point; watching=deny=true;
  int result=lua_pcall(L,1,2,0); watching=deny=false;
  assert(denied>0 && result==LUA_OK && lua_isnil(L,-2) && lua_istable(L,-1));
  lua_getfield(L,-1,"code");
  assert(std::string_view(lua_tostring(L,-1))=="NATIVE_EXCEPTION"); lua_pop(L,1);
  lua_getfield(L,-1,"operation");
  assert(std::string_view(lua_tostring(L,-1))=="local_client"); lua_pop(L,1);
  lua_pop(L,2);
  // Failed factory must not retain the process slot or poison native init.
  lua_pushcfunction(L,factory); lua_pushvalue(L,1);
  assert(lua_pcall(L,1,2,0)==LUA_OK && lua_isuserdata(L,-2));
  lua_getfield(L,-2,"get_status"); lua_pushvalue(L,-3);
  assert(lua_pcall(L,1,2,0)==LUA_OK && lua_istable(L,-2)); lua_pop(L,2);
  lua_getfield(L,-2,"close"); lua_pushvalue(L,-3);
  assert(lua_pcall(L,1,1,0)==LUA_OK && lua_toboolean(L,-1)); lua_pop(L,3);
  lua_gc(L,LUA_GCCOLLECT);
 }
 std::puts("Native factory first 16 allocation faults: structured exception and fresh-owner recovery PASS");
 assert(lua_pcall(L,0,1,0)==LUA_OK && lua_isuserdata(L,-1));
 int owner=lua_gettop(L);
 const lua_Integer sizes[]={0,INT32_MAX,lua_Integer(INT32_MAX)+1,UINT32_MAX};
 for(lua_Integer size:sizes) {
  phases[0]=phases[1]=0; largest=0;
  lua_pushcfunction(L,call); lua_pushvalue(L,owner); lua_pushinteger(L,size);
  watching=true; int rc=lua_pcall(L,2,2,0); watching=false;
  assert(rc==LUA_OK && lua_isnil(L,-2) && lua_istable(L,-1));
  lua_getfield(L,-1,"code"); const char* code=lua_tostring(L,-1);
  bool accepted=size<=INT32_MAX;
  assert(code && std::string_view(code)==(accepted?"NO_PROGRAM":"INVALID_ARGUMENT"));
  lua_pop(L,1);
  lua_getfield(L,-1,"backend");
  assert(std::string_view(lua_tostring(L,-1))==(accepted?"local":"binding")); lua_pop(L,1);
  assert(phases[0]==unsigned(accepted) && phases[1]==unsigned(accepted));
  if(accepted) assert(observed[0]==size && observed[1]==size);
  assert(largest<1024*1024);
  std::printf("ReadBytes %lld: validated=%u dispatched=%u largest C++ allocation=%zu PASS\n",
              (long long)size,phases[0],phases[1],largest);
  lua_pop(L,2);
 }
 // Fail real C++ allocation in the SDK NO_PROGRAM/error-copy phase. Denial
 // stays enabled through catch and protected Lua conversion (Lua uses malloc).
 phases[0]=phases[1]=0; denied=0;
 lua_pushcfunction(L,call); lua_pushvalue(L,owner); lua_pushinteger(L,0);
 watching=true; deny=true;
 int rc=lua_pcall(L,2,2,0);
 watching=false; deny=false;
 assert(denied>0 && rc==LUA_OK && lua_isnil(L,-2) && lua_istable(L,-1));
 lua_getfield(L,-1,"code");
 assert(std::string_view(lua_tostring(L,-1))=="NATIVE_EXCEPTION"); lua_pop(L,1);
 lua_getfield(L,-1,"backend");
 assert(std::string_view(lua_tostring(L,-1))=="binding"); lua_pop(L,1);
 lua_getfield(L,-1,"operation");
 assert(std::string_view(lua_tostring(L,-1))=="read_bytes"); lua_pop(L,1);
 lua_getfield(L,-1,"message");
 assert(lua_isstring(L,-1) && lua_rawlen(L,-1)>0); lua_pop(L,1);
 assert(phases[0]==1 && phases[1]==1); lua_pop(L,2);
 // Native and binding locks must unwind; same live owner must remain usable.
 phases[0]=phases[1]=0;
 lua_pushcfunction(L,call); lua_pushvalue(L,owner); lua_pushinteger(L,0);
 assert(lua_pcall(L,2,2,0)==LUA_OK);
 lua_getfield(L,-1,"code");
 assert(std::string_view(lua_tostring(L,-1))=="NO_PROGRAM"); lua_pop(L,3);
 std::printf("ReadBytes native bad_alloc: %u actual denials, structured exception and same-owner recovery PASS\n",denied);
 // Sweep allocation failures through a real allocating success response.
 // GetCapabilities creates native vector/string storage before Lua conversion.
 unsigned reached=0, unreached=0;
 for(unsigned point=1;point<=256;++point) {
  attempts=denied=0; deny_after=point;
  const size_t before_blocks=live_blocks, before_bytes=live_bytes;
  lua_pushcfunction(L,capabilities); lua_pushvalue(L,owner);
  watching=deny=true; int result=lua_pcall(L,1,2,0); watching=deny=false;
  assert(result==LUA_OK);
  if(denied) {
   ++reached; assert(lua_isnil(L,-2) && lua_istable(L,-1));
   lua_getfield(L,-1,"code");
   assert(std::string_view(lua_tostring(L,-1))=="NATIVE_EXCEPTION"); lua_pop(L,1);
   lua_getfield(L,-1,"operation");
   assert(std::string_view(lua_tostring(L,-1))=="get_capabilities"); lua_pop(L,1);
   lua_getfield(L,-1,"backend");
   assert(std::string_view(lua_tostring(L,-1))=="binding"); lua_pop(L,1);
  } else {
   ++unreached; assert(attempts<point && lua_istable(L,-2) && lua_rawlen(L,-2)>0);
  }
  lua_pop(L,2);
  assert(live_blocks==before_blocks && live_bytes==before_bytes);
  // Retry the complete success path on the same owner after every failure.
  lua_pushcfunction(L,capabilities); lua_pushvalue(L,owner);
  assert(lua_pcall(L,1,2,0)==LUA_OK && lua_istable(L,-2) && lua_rawlen(L,-2)>0);
  lua_pop(L,2);
  assert(live_blocks==before_blocks && live_bytes==before_bytes);
  if(unreached) break;
 }
 assert(reached>1 && unreached==1);
 std::printf("GetCapabilities allocation sweep: %u reached failures, success tail, same-owner retries and block/byte balance PASS\n",reached);
 // Deny Lua conversion allocations after a successful allocating native call.
 // The Packet's vector/strings must die even when conversion longjmps.
 for(int native_fault=0;native_fault<2;++native_fault) {
 unsigned lua_reached=0,lua_tail=0;
 lua_gc(L,LUA_GCSTOP);
 for(size_t point=1;point<=512;++point) {
  const size_t blocks=live_blocks,bytes=live_bytes;
  lua_pushcfunction(L,capabilities); lua_pushvalue(L,owner);
  allocator.calls=allocator.refused=0; allocator.fail=point;
  attempts=denied=0; deny_after=1;
  watching=deny=bool(native_fault);
  int result=lua_pcall(L,1,2,0);
  watching=deny=false;
  allocator.fail=SIZE_MAX;
  if(native_fault) assert(denied>0);
  if(allocator.refused) {
   ++lua_reached; assert(result==LUA_ERRMEM); lua_pop(L,1);
  } else {
   ++lua_tail; assert(result==LUA_OK);
   if(native_fault) {
    assert(lua_isnil(L,-2) && lua_istable(L,-1));
    lua_getfield(L,-1,"code");
    assert(std::string_view(lua_tostring(L,-1))=="NATIVE_EXCEPTION"); lua_pop(L,1);
    lua_getfield(L,-1,"backend");
    assert(std::string_view(lua_tostring(L,-1))=="binding"); lua_pop(L,1);
    lua_getfield(L,-1,"operation");
    assert(std::string_view(lua_tostring(L,-1))=="get_capabilities"); lua_pop(L,1);
   } else assert(lua_istable(L,-2) && lua_rawlen(L,-2)>0);
   lua_pop(L,2);
  }
  assert(live_blocks==blocks && live_bytes==bytes);
  lua_pushcfunction(L,capabilities); lua_pushvalue(L,owner);
  assert(lua_pcall(L,1,2,0)==LUA_OK && lua_istable(L,-2)); lua_pop(L,2);
  assert(live_blocks==blocks && live_bytes==bytes);
  if(lua_tail) break;
 }
 assert(lua_reached>1 && lua_tail==1);
 std::printf("GetCapabilities Lua conversion OOM (native fault=%d): %u reached, success tail, native block/byte balance PASS\n",native_fault,lua_reached);
 lua_gc(L,LUA_GCRESTART);
 }
 lua_close(L); assert(allocator.bytes==0);
}
