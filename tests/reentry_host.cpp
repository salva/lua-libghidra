// MIT Copyright 2026 Salvador Fandiño.
#include <lua.hpp>
#include <cassert>
#include <cstdio>
#include <cstring>
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
static bool prime_debt=false;
static int natural_call(lua_State* L) {
 // Function/receiver already rooted before starting collector. No explicit
 // collection/step or allocator callback calls Lua; Lua's allocation GC checks
 // alone schedule pending finalizers while the real method executes.
 lua_gc(L,LUA_GCRESTART);
 if(prime_debt) assert(lua_checkstack(L,65536)); // storage-only growth, no GC step
 natural_phase=1;
 lua_call(L,lua_gettop(L)-1,2);
 natural_phase=2;
 return 2;
}
int main() {
 lua_State* L=luaL_newstate(); assert(L); luaL_openlibs(L);
 luaL_requiref(L,"libghidra._native",luaopen_libghidra__native,1); lua_setglobal(L,"n");
 const char* recheck_calls[]={
 "local v,e=c:read_bytes(0,0)", "local v,e=c:open_program{program_path='absent'}",
 "local v,e=c:get_function(0)", "local v,e=c:list_functions{limit=2}",
 "local v,e=c:get_instruction(0)", "local v,e=c:list_instructions{limit=2}",
 "local v,e=c:get_decompilation(0)"};
 const char* recheck_names[]={"read_bytes","open_program","get_function","list_functions","get_instruction","list_instructions","get_decompilation"};
 for(int mode=0;mode<7;++mode) {
  run(L,"c=assert(n.local_client()); collectgarbage('stop'); hits=0; completed=0; finalizer_ok=false; finalizer_error=nil; "
        "do local owner=c; local f=setmetatable({}, {__gc=function() "
        "hits=hits+1; finalizer_ok,finalizer_error=pcall(function() "
        "assert(owner:close()); local replacement=assert(n.local_client()); "
        "assert(replacement:close()); completed=completed+1 end) end}) end");
  armed=true;
  char source[512];
  std::snprintf(source,sizeof(source),"%s; assert(v==nil and e.code=='CLOSED' and e.backend=='binding' and e.operation=='%s')",recheck_calls[mode],recheck_names[mode]);
  run(L,source);
  assert(!armed && edges==unsigned(mode+1));
  run(L,"assert(hits==1); assert(finalizer_ok,finalizer_error); assert(finalizer_error==nil and completed==1); "
        "assert(c:close()); c=nil; collectgarbage('restart'); collectgarbage('collect'); "
        "local fresh=assert(n.local_client()); assert(fresh:close())");
 }
 lua_pushcfunction(L,mark_finalizer); lua_setglobal(L,"mark_finalizer");
 // Real allocating conversion edges across every no-argument dispatch plus
 // generation. Sweep GC debt by unreachable userdata/table allocation volume.
 const char* methods[]={"get_status","get_revision","get_capabilities","_generation","get_function","list_functions","get_instruction","list_instructions","get_decompilation"};
 natural=true;
 for(const char* method:methods) {
  bool observed=false;
  for(int debt=1;debt<=8192 && !observed;debt*=2) {
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
   const bool adapter=!std::strcmp(method,"get_function") || !std::strcmp(method,"get_instruction") || !std::strcmp(method,"get_decompilation") || !std::strcmp(method,"list_functions") || !std::strcmp(method,"list_instructions");
   if(adapter && method[0]=='g') lua_pushinteger(L,0);
   int rc=lua_pcall(L,adapter && method[0]=='g'?3:2,2,0); natural_phase=2;
   if(rc) std::fprintf(stderr,"natural GC %s: %s\n",method,lua_tostring(L,-1));
   assert(rc==LUA_OK);
   // Keep actual detached result rooted while checking finalizer completion.
   lua_pushvalue(L,-2); lua_setglobal(L,"result");
   lua_pushvalue(L,-1); lua_setglobal(L,"result_error");
   lua_pop(L,2);
   lua_getglobal(L,"finalizer_phase"); observed=lua_tointeger(L,-1)==(method[0]=='_'?1:3); lua_pop(L,1);
   if(observed) {
    run(L,"assert(hits==1 and completed==1); assert(finalizer_ok,finalizer_error)");
    if(adapter) run(L,"assert(result==nil and result_error.code=='NO_PROGRAM' and result_error.backend=='local')");
    else run(L,"assert(result_error==nil)");
    if(adapter) {}
    else if(method[0]=='_') run(L,"assert(result:decimal()=='0')");
    else if(!std::strcmp(method,"get_status")) run(L,"assert(result.ok==true and result.host_mode=='local'); assert(type(result.service_name)=='string')");
    else if(!std::strcmp(method,"get_revision")) run(L,"assert(result.modification_number:decimal()=='0')");
    else run(L,"assert(type(result)=='table' and #result>0); for _,v in ipairs(result) do assert(type(v.id)=='string' and type(v.status)=='string') end");
    run(L,"local v,e=c:get_status(); assert(v==nil and e.code=='CLOSED'); "
          "assert(c:_generation():decimal()=='1'); local fresh=assert(n.local_client()); assert(fresh:close()); "
          "collectgarbage('collect'); assert(result~=nil or result_error~=nil)");
   }
   run(L,"c:close(); c=nil; collectgarbage('collect')");
   if(observed) std::printf("allocation-driven real finalizer during %s: close/reconstruct completed PASS\n",method);
  }
  assert(observed);
 }
 // Invalid option paths allocate structured errors before receiver lookup.
 // Require natural finalization in that window and preserve INVALID_ARGUMENT.
 const char* parsing[]={
  "return {program_path=false}",
  "return {policy=false}",
  "return {policy=false}"};
 const char* parse_methods[]={"open_program","close_program","shutdown"};
 const char* valid_parsing[]={
  "return {program_path='absent',project_name='rooted',language_id='x86:LE:64:default'}",
  "return {policy='discard'}", "return {policy='discard'}"};
 int parse_index=0;
 for(int parse_mode=0;parse_mode<2;++parse_mode) {
 parse_index=0;
 for(int request=0;request<3;++request) {
  const char* source=parse_mode?valid_parsing[request]:parsing[request];
  bool observed=false;
  for(int debt=1;debt<=8192 && !observed;debt*=2) {
   natural_phase=0;
   run(L,"collectgarbage('collect'); collectgarbage('incremental',0,10000,0); c=assert(n.local_client()); collectgarbage('stop'); "
         "hits=0; completed=0; finalizer_phase=0; do local owner=c; "
         "local f=setmetatable({}, {__gc=function() finalizer_phase=mark_finalizer(); hits=hits+1; "
         "finalizer_ok,finalizer_error=pcall(function() assert(owner:close()); "
         "local r=assert(n.local_client()); assert(r:close()); completed=completed+1 end) end}) end");
   // Compile before restarting collector; closure and parsed request strings
   // are rooted. Collection must be observed before observer advances phase.
   assert(luaL_loadstring(L,source)==LUA_OK); assert(lua_pcall(L,0,1,0)==LUA_OK);
   for(int i=0;i<debt;++i) { lua_newtable(L); lua_pop(L,1); }
   lua_pushcfunction(L,natural_call); lua_insert(L,-2);
   lua_getglobal(L,"c"); lua_getfield(L,-1,parse_methods[parse_index]);
   lua_insert(L,-2); // table, method, receiver -> method, receiver, table
   lua_rotate(L,-3,-1);
   // Fresh thread gives deterministic storage-growth debt without advancing
   // collector or calling Lua finalizers before the actual request.

   lua_State* T=lua_newthread(L); lua_pop(L,1); // root via registry until done
   lua_pushthread(T); int thread_ref=luaL_ref(T,LUA_REGISTRYINDEX);
   lua_xmove(L,T,4); prime_debt=true;
   assert(lua_pcall(T,3,2,0)==LUA_OK); prime_debt=false; natural_phase=2;
   lua_xmove(T,L,2); luaL_unref(L,LUA_REGISTRYINDEX,thread_ref);
   assert(lua_isnil(L,-2));
   lua_pushstring(L,parse_methods[parse_index]); lua_setglobal(L,"expected_operation");
   lua_pushvalue(L,-1); lua_setglobal(L,"parse_error"); lua_pop(L,2);
   lua_getglobal(L,"finalizer_phase"); observed=lua_tointeger(L,-1)==1; lua_pop(L,1);
   if(observed) {
    lua_pushstring(L,parse_mode?"CLOSED":"INVALID_ARGUMENT"); lua_setglobal(L,"expected_code");
    run(L,"assert(hits==1 and completed==1); assert(finalizer_ok,finalizer_error); "
       "assert(parse_error.code==expected_code and parse_error.backend=='binding'); "
       "assert(parse_error.operation==expected_operation and type(parse_error.message)=='string' and #parse_error.message>0); "
       "assert(c:_generation():decimal()=='1')");
   }
   run(L,"c:close(); c=nil; collectgarbage('collect')");
  }
  assert(observed); ++parse_index;
 }
 }
 std::puts("allocation-driven valid parsing and invalid requests: CLOSED/INVALID_ARGUMENT preservation PASS");
 // Factory userdata allocation is before native ownership publication. A
 // pending finalizer may construct/close another owner there; the outer owner
 // must publish normally afterwards without inheriting the competitor's slot.
 bool factory_observed=false;
 for(int debt=1;debt<=8192 && !factory_observed;debt*=2) {
  natural_phase=0;
  run(L,"result=nil; result_error=nil; finalizer_phase=0; collectgarbage('collect'); "
        "collectgarbage('incremental',100,1000,0); collectgarbage('stop'); hits=0; completed=0; "
        "do local f=setmetatable({}, {__gc=function() "
        "finalizer_phase=mark_finalizer(); hits=hits+1; finalizer_ok,finalizer_error=pcall(function() "
        "local competitor=assert(n.local_client()); assert(competitor:close()); completed=completed+1 end) end}) end");
  for(int i=0;i<debt;++i) { lua_newtable(L); lua_pop(L,1); }
  lua_pushcfunction(L,natural_call); lua_getglobal(L,"n");
  lua_getfield(L,-1,"local_client"); lua_remove(L,-2); lua_pushnil(L);
  assert(lua_pcall(L,2,2,0)==LUA_OK); natural_phase=2;
  lua_pushvalue(L,-2); lua_setglobal(L,"published"); lua_pop(L,2);
  lua_getglobal(L,"finalizer_phase"); factory_observed=lua_tointeger(L,-1)==1; lua_pop(L,1);
  if(factory_observed) run(L,"assert(hits==1 and completed==1); assert(finalizer_ok,finalizer_error); "
        "assert(published:get_status().ok); local v,e=n.local_client(); assert(v==nil and e.code=='CLIENT_IN_USE'); "
        "assert(published:close()); assert(published:close()); published=nil; collectgarbage('collect'); "
        "local fresh=assert(n.local_client()); assert(fresh:close())");
  else run(L,"if published then published:close() end; published=nil; collectgarbage('collect')");
 }
 assert(factory_observed && natural_hits>=5);
 std::puts("allocation-driven factory prepublication finalizer: competing owner close, publication/exclusion/reuse PASS");
 lua_close(L);
 std::puts("deterministic pre-recheck real GC: close/reconstruct finalizer and CLOSED revalidation PASS");
}
