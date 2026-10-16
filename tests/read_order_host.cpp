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
 // Refuse wrapper Handle allocation only; never enter upstream construction.
 lua_pushcfunction(L,factory); lua_pushvalue(L,1);
 const size_t wrapper_blocks=live_blocks, wrapper_bytes=live_bytes;
 attempts=denied=0; deny_after=1; watching=deny=true;
 int factory_result=lua_pcall(L,1,2,0); watching=deny=false;
 assert(denied==1 && factory_result==LUA_OK && lua_isnil(L,-2));
 lua_getfield(L,-1,"code");
 assert(std::string_view(lua_tostring(L,-1))=="NATIVE_EXCEPTION"); lua_pop(L,3);
 lua_gc(L,LUA_GCCOLLECT);
 assert(live_blocks==wrapper_blocks && live_bytes==wrapper_bytes);
 std::puts("Wrapper Handle allocation refusal: exception conversion and balance PASS");
 // Sweep Lua setup/publication/error exits of the real factory. An owner may
 // already have been published when pcall's result adjustment allocates.
 unsigned factory_oom=0,factory_tail=0;
 for(size_t point=1;point<=512;++point) {
  lua_pushcfunction(L,factory); lua_pushvalue(L,1);
  allocator.calls=allocator.refused=0; allocator.fail=point;
  int result=lua_pcall(L,1,2,0);
  allocator.fail=SIZE_MAX;
  if(allocator.refused) {
   ++factory_oom; assert(result==LUA_ERRMEM); lua_pop(L,1);
  } else {
   ++factory_tail; assert(result==LUA_OK && lua_isuserdata(L,-2));
   lua_pop(L,2); // Deliberately GC-only release of successful publication.
  }
  lua_gc(L,LUA_GCCOLLECT);
  lua_pushcfunction(L,factory); lua_pushvalue(L,1);
  assert(lua_pcall(L,1,2,0)==LUA_OK && lua_isuserdata(L,-2));
  lua_getfield(L,-2,"close"); lua_pushvalue(L,-3);
  assert(lua_pcall(L,1,1,0)==LUA_OK && lua_toboolean(L,-1)); lua_pop(L,3);
  lua_gc(L,LUA_GCCOLLECT);
  if(factory_tail) break;
 }
 assert(factory_oom>1 && factory_tail==1);
 std::printf("Factory Lua OOM: %u reached, success tail, GC-only publication release and fresh-owner recovery PASS\n",factory_oom);
 // Combine real native factory refusal with Lua failure converting its error.
 unsigned dual_reached=0,dual_tail=0;
 for(size_t point=1;point<=512;++point) {
  lua_pushcfunction(L,factory); lua_pushvalue(L,1);
  allocator.calls=allocator.refused=0; allocator.fail=point;
  attempts=denied=0; deny_after=1; watching=deny=true;
  int result=lua_pcall(L,1,2,0);
  watching=deny=false; allocator.fail=SIZE_MAX;
  if(allocator.refused) {
   assert(result==LUA_ERRMEM); lua_pop(L,1);
   if(denied) ++dual_reached; // Exclude Lua setup failures before native entry.
  } else {
   ++dual_tail;
   assert(denied>0 && result==LUA_OK && lua_isnil(L,-2) && lua_istable(L,-1));
   lua_getfield(L,-1,"code");
   assert(std::string_view(lua_tostring(L,-1))=="NATIVE_EXCEPTION"); lua_pop(L,1);
   lua_getfield(L,-1,"operation");
   assert(std::string_view(lua_tostring(L,-1))=="local_client"); lua_pop(L,1);
   lua_getfield(L,-1,"backend");
   assert(std::string_view(lua_tostring(L,-1))=="binding"); lua_pop(L,3);
  }
  lua_gc(L,LUA_GCCOLLECT);
  lua_pushcfunction(L,factory); lua_pushvalue(L,1);
  assert(lua_pcall(L,1,2,0)==LUA_OK && lua_isuserdata(L,-2));
  lua_getfield(L,-2,"close"); lua_pushvalue(L,-3);
  assert(lua_pcall(L,1,1,0)==LUA_OK && lua_toboolean(L,-1)); lua_pop(L,3);
  lua_gc(L,LUA_GCCOLLECT);
  if(dual_tail) break;
 }
 assert(dual_reached>1 && dual_tail==1);
 std::printf("Factory dual fault: %u actual native+Lua refusals, structured tail and fresh-owner recovery PASS\n",dual_reached);
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
 // Upstream-internal C++ allocation sweeps are excluded by operator scope.
 // Deny Lua conversion allocations after a successful allocating native call.
 // The Packet's vector/strings must die even when conversion longjmps.
 {
 unsigned lua_reached=0,lua_tail=0;
 lua_gc(L,LUA_GCSTOP);
 for(size_t point=1;point<=512;++point) {
  const size_t blocks=live_blocks,bytes=live_bytes;
  lua_pushcfunction(L,capabilities); lua_pushvalue(L,owner);
  allocator.calls=allocator.refused=0; allocator.fail=point;
  attempts=denied=0; deny_after=1;
  watching=deny=false;
  int result=lua_pcall(L,1,2,0);
  watching=deny=false;
  allocator.fail=SIZE_MAX;
  if(allocator.refused) {
   ++lua_reached; assert(result==LUA_ERRMEM); lua_pop(L,1);
  } else {
   ++lua_tail; assert(result==LUA_OK);
   assert(lua_istable(L,-2) && lua_rawlen(L,-2)>0);
   lua_pop(L,2);
  }
  assert(live_blocks==blocks && live_bytes==bytes);
  lua_pushcfunction(L,capabilities); lua_pushvalue(L,owner);
  assert(lua_pcall(L,1,2,0)==LUA_OK && lua_istable(L,-2)); lua_pop(L,2);
  assert(live_blocks==blocks && live_bytes==bytes);
  if(lua_tail) break;
 }
 assert(lua_reached>1 && lua_tail==1);
 std::printf("GetCapabilities Lua conversion OOM: %u reached, success tail, native block/byte balance PASS\n",lua_reached);
 lua_gc(L,LUA_GCRESTART);
 }
 lua_close(L); assert(allocator.bytes==0);
}
