// MIT Copyright 2026 Salvador Fandiño.
#include <lua.hpp>
#include <cassert>
#include <cstdlib>
#include <cstdio>
#include <new>
#include <cstdint>
#include <string_view>
#include <cstddef>
#include <stdexcept>
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
static int boundary_fault=0;
static unsigned adapter_calls=0;
// Dependency uses nothrow new too: pair it with this host's header allocator.
// Otherwise ASan's nothrow allocator and our ordinary delete disagree.
void* operator new(size_t n,const std::nothrow_t&) noexcept { try { return ::operator new(n); } catch(...) { return nullptr; } }
void* operator new[](size_t n,const std::nothrow_t&) noexcept { try { return ::operator new(n); } catch(...) { return nullptr; } }
void operator delete(void* p,const std::nothrow_t&) noexcept { free_allocation(p); }
void operator delete[](void* p,const std::nothrow_t&) noexcept { free_allocation(p); }
namespace llg {
void before_adapter_dispatch(int kind) {
 ++adapter_calls;
 if(kind<7 || !boundary_fault) return;
 if(boundary_fault==1) throw std::bad_alloc();
 if(boundary_fault==2) throw std::runtime_error("adapter boundary test");
 throw 7;
}

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
static int open_request(lua_State* L) {
 lua_getfield(L,1,"open_program"); lua_pushvalue(L,1); lua_pushvalue(L,2);
 lua_call(L,2,2); return 2;
}
static int capabilities(lua_State* L) {
 lua_getfield(L,1,"get_capabilities"); lua_pushvalue(L,1);
 lua_call(L,1,2); return 2;
}
static int factory_options(lua_State* L) {
 lua_getfield(L,1,"local_client"); lua_pushvalue(L,2);
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
 // Three non-SSO option copies followed by Handle are wrapper-owned. Refuse
 // ONLY those four sites: never sweep into CreateLocalClient/dependencies.
 lua_createtable(L,0,3);
 const char* option_keys[]={"ghidra_root","state_path","default_arch"};
 for(const char* key:option_keys) {
  lua_pushliteral(L,"wrapper-owned-copy-longer-than-small-string-optimization-storage");
  lua_setfield(L,-2,key);
 }
 const int options=lua_gettop(L);
 unsigned option_dual=0;
 for(unsigned cpp_point=1;cpp_point<=4;++cpp_point) {
  unsigned reached=0,tail=0;
  // point zero isolates native exception conversion without Lua refusal.
  for(size_t lua_point=0;lua_point<=512;++lua_point) {
   lua_pushcfunction(L,factory_options); lua_pushvalue(L,1); lua_pushvalue(L,options);
   const size_t blocks=live_blocks,bytes=live_bytes;
   allocator.calls=allocator.refused=0;
   allocator.fail=lua_point?lua_point:SIZE_MAX;
   attempts=denied=0; deny_after=cpp_point; watching=deny=true;
   int result=lua_pcall(L,2,2,0);
   watching=deny=false; allocator.fail=SIZE_MAX;
   if(allocator.refused) {
    assert(result==LUA_ERRMEM); lua_pop(L,1);
    if(denied) { ++reached; ++option_dual; }
   } else {
    assert(denied==1 && attempts==cpp_point && result==LUA_OK);
    assert(lua_isnil(L,-2) && lua_istable(L,-1));
    lua_getfield(L,-1,"code");
    assert(std::string_view(lua_tostring(L,-1))=="NATIVE_EXCEPTION"); lua_pop(L,1);
    lua_getfield(L,-1,"operation");
    assert(std::string_view(lua_tostring(L,-1))=="local_client"); lua_pop(L,1);
    lua_getfield(L,-1,"backend");
    assert(std::string_view(lua_tostring(L,-1))=="binding"); lua_pop(L,3);
    if(lua_point) ++tail;
   }
   lua_gc(L,LUA_GCCOLLECT);
   assert(live_blocks==blocks && live_bytes==bytes);
   // Restored ordinary factory proves no wrapper lock/slot was stranded.
   lua_pushcfunction(L,factory); lua_pushvalue(L,1);
   assert(lua_pcall(L,1,2,0)==LUA_OK && lua_isuserdata(L,-2));
   lua_getfield(L,-2,"close"); lua_pushvalue(L,-3);
   assert(lua_pcall(L,1,1,0)==LUA_OK && lua_toboolean(L,-1)); lua_pop(L,3);
   lua_gc(L,LUA_GCCOLLECT);
   if(tail) break;
  }
  assert(reached>1 && tail==1);
 }
 lua_pop(L,1); // rooted options
 std::printf("Wrapper option copies + Handle: four C++ sites, %u actual dual Lua refusals, balance/recovery PASS\n",option_dual);
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
 // All six OpenProgram request copies occur in the wrapper before native
 // dispatch/generation advance. Refuse only these known sites.
 lua_createtable(L,0,6);
 const char* request_keys[]={"program_path","project_path","project_name","language_id","compiler_spec_id","format"};
 for(const char* key:request_keys) {
  lua_pushliteral(L,"wrapper-request-copy-longer-than-small-string-optimization-storage");
  lua_setfield(L,-2,key);
 }
 int request=lua_gettop(L);
 for(unsigned point=1;point<=6;++point) {
  lua_pushcfunction(L,open_request); lua_pushvalue(L,owner); lua_pushvalue(L,request);
  const size_t blocks=live_blocks,bytes=live_bytes;
  attempts=denied=0; deny_after=point; watching=deny=true;
  int result=lua_pcall(L,2,2,0); watching=deny=false;
  assert(denied==1 && attempts==point && result==LUA_OK && lua_isnil(L,-2));
  lua_getfield(L,-1,"code");
  assert(std::string_view(lua_tostring(L,-1))=="NATIVE_EXCEPTION"); lua_pop(L,1);
  lua_getfield(L,-1,"operation");
  assert(std::string_view(lua_tostring(L,-1))=="open_program"); lua_pop(L,1);
  lua_getfield(L,-1,"backend");
  assert(std::string_view(lua_tostring(L,-1))=="binding"); lua_pop(L,3);
  lua_gc(L,LUA_GCCOLLECT);
  assert(live_blocks==blocks && live_bytes==bytes);
  lua_getfield(L,owner,"get_revision"); lua_pushvalue(L,owner);
  assert(lua_pcall(L,1,2,0)==LUA_OK && lua_istable(L,-2)); lua_pop(L,2);
 }
 lua_pop(L,1);
 std::puts("Wrapper OpenProgram six request-copy refusals: structured errors, balance and same-owner retry PASS");
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
 // M2 scalar requests and M3 text/byte requests share the protected boundary.
 // Warm dependencies normally, then sweep ONLY Lua result/error allocations.
 lua_pushvalue(L,owner); lua_setglobal(L,"c");
 assert(luaL_dostring(L,
  "assert(c:open_program{program_path='" LLG_FIXTURE_ROOT "/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}); "
  "assert(c:get_decompilation(0x401106).decompilation.completed)")==LUA_OK);
 const char* paths[]={
  "return c:get_function(0x401106)", "return c:list_functions{limit=2}",
  "return c:get_instruction(0x401106)", "return c:list_instructions{range_start=0x401106,limit=2}",
  "return c:get_decompilation(0x401106)",
  "return c:discard_program()", "return c:rename_function(0x401106,'m3_boundary')",
  "return c:list_basic_blocks{limit=2}", "return c:list_cfg_edges{limit=2}",
  "return c:get_symbol(0x401106)", "return c:list_symbols{limit=2}",
  "return c:rename_symbol(0x401106,'m3_boundary')", "return c:list_xrefs{limit=2}",
  "return c:list_memory_blocks{limit=2}", "return c:write_bytes(0x404010,'a\\0b')",
  "return c:get_type('int')", "return c:list_types('',{limit=2})",
  "return c:list_type_aliases('',{limit=2})", "return c:list_type_unions('',{limit=2})",
  "return c:list_type_enums('',{limit=2})", "return c:list_type_enum_members('missing',{limit=2})",
  "return c:list_type_members('missing',{limit=2})", "return c:get_function_signature(0x401106)",
  "return c:list_function_signatures{limit=2}", "return c:get_comments{limit=2}",
  "return c:list_defined_strings{limit=2}",
  "return c:list_decompilations{range_start=0x401106,range_end=0x401106,limit=1}",
  "return c:list_leaf_functions{limit=2}",
  "return c:create_type('M4Boundary','struct',0)",
  "return c:create_type_enum('M4BoundaryEnum',0,false)",
  "return c:set_comment(0x401106,'eol','boundary')",
  "return c:list_data_items{limit=2}",
  "return c:add_perf_benchmark{bench_id='boundary',warm_ms_p50=1.5}",
  "return c:list_perf_benchmarks()",
  "return c:patch_bytes_batch{{address=0x404010,data='a\\0b'}}"};
 for(const char* source:paths) {
  unsigned refused=0; bool tail=false;
  for(size_t point=1;point<=512;++point) {
   assert(luaL_loadstring(L,source)==LUA_OK);
   allocator.calls=allocator.refused=0; allocator.fail=point;
   int rc=lua_pcall(L,0,2,0); allocator.fail=SIZE_MAX;
   if(allocator.refused) { assert(rc==LUA_ERRMEM); ++refused; lua_pop(L,1); }
   else { assert(rc==LUA_OK && (lua_istable(L,-2) || (lua_isnil(L,-2) && lua_istable(L,-1)))); lua_pop(L,2); tail=true; }
   assert(luaL_dostring(L,source)==LUA_OK); lua_settop(L,owner);
   if(tail) break;
  }
  assert(tail && refused>0);
  // bad_alloc, standard and unknown exceptions are injected at the no-Lua SDK
  // boundary, never by sweeping allocations inside the dependency.
  for(int fault=1;fault<=3;++fault) {
   boundary_fault=fault;
   assert(luaL_dostring(L,source)==LUA_OK && lua_isnil(L,-2));
   lua_getfield(L,-1,"code"); assert(std::string_view(lua_tostring(L,-1))=="NATIVE_EXCEPTION"); lua_pop(L,1);
   lua_getfield(L,-1,"backend"); assert(std::string_view(lua_tostring(L,-1))=="binding"); lua_pop(L,3);
   boundary_fault=0;
   assert(luaL_dostring(L,source)==LUA_OK); lua_settop(L,owner);
  }
  std::printf("M2/M3 adapter Lua result refusal (%u points), three boundary exceptions and retry PASS: %s\n",refused,source);
 }
 // Refuse only the first, non-SSO wrapper copy. No dependency dispatch/OOM.
 // All strings/chunks are rooted before enabling operator-new refusal.
 const char* copy_paths[]={
  "return c:rename_function(0x401106,payload)",
  "return c:rename_symbol(0x401106,payload)",
  "return c:write_bytes(0x404010,payload)", "return c:get_type(payload)",
  "return c:list_types(payload,{limit=1})", "return c:list_type_aliases(payload,{limit=1})",
  "return c:list_type_unions(payload,{limit=1})", "return c:list_type_enums(payload,{limit=1})",
  "return c:list_type_enum_members(payload,{limit=1})", "return c:list_type_members(payload,{limit=1})",
  "return c:create_type(payload,'struct',0)",
  "return c:add_perf_benchmark{bench_id=payload}",
  "return c:patch_bytes_batch{{address=0x404010,data=payload}}"};
 assert(luaL_dostring(L,"payload=string.rep('wrapper_owned_',16)")==LUA_OK);
 for(const char* source:copy_paths) {
  unsigned hits=0; bool tail=false;
  for(size_t point=0;point<=128;++point) {
   assert(luaL_loadstring(L,source)==LUA_OK);
   const size_t blocks=live_blocks, bytes=live_bytes;
   allocator.calls=allocator.refused=0; allocator.fail=point?point:SIZE_MAX;
   attempts=denied=adapter_calls=0; deny_after=1; watching=deny=true;
   int rc=lua_pcall(L,0,2,0); watching=deny=false; allocator.fail=SIZE_MAX;
   assert(adapter_calls==0);
   if(denied==0) { assert(rc==LUA_ERRMEM && allocator.refused>0 && attempts==0); }
   else assert(denied==1 && attempts==1);
   assert(live_blocks==blocks && live_bytes==bytes);
   if(allocator.refused) { assert(rc==LUA_ERRMEM); ++hits; lua_pop(L,1); }
   else {
    assert(rc==LUA_OK && lua_isnil(L,-2));
    lua_getfield(L,-1,"code"); assert(std::string_view(lua_tostring(L,-1))=="NATIVE_EXCEPTION"); lua_pop(L,3);
    if(point) tail=true;
   }
   lua_settop(L,owner);
   // Same owner remains usable, without dispatching arbitrary long mutation data.
   phases[0]=phases[1]=0;
   assert(luaL_dostring(L,"assert(c:get_status().ok); assert(c:read_bytes(0x401106,4).data=='\\xf3\\x0f\\x1e\\xfa')")==LUA_OK);
   if(tail) break;
  }
  assert(tail && hits>0);
  std::printf("M3 wrapper request-copy refusal + %u Lua error-publication denials, no SDK dispatch/balance PASS: %s\n",hits,source);
 }
 lua_close(L); assert(allocator.bytes==0);
}
