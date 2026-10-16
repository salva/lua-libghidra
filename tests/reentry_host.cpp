// MIT Copyright 2026 Salvador Fandiño.
#include <lua.hpp>
#include <cassert>
#include <cstdio>
#include <cstring>
#include <initializer_list>
#include <cstdlib>
#include <string>
#include <filesystem>
extern "C" int luaopen_libghidra__native(lua_State*);
static bool natural=false;
static unsigned natural_phase=0, natural_hits=0;
static int mark_finalizer(lua_State* L) {
 if(natural && (natural_phase==1 || natural_phase==3)) ++natural_hits;
 lua_pushinteger(L,natural_phase); return 1;
}
static bool armed=false;
static bool restart_at_page=false;
static unsigned edges=0;
namespace llg {
void before_owner_recheck(lua_State* L) {
 if(restart_at_page) lua_gc(L,LUA_GCRESTART); // no collection/step; allocations schedule GC
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
 if(!restart_at_page) lua_gc(L,LUA_GCRESTART);
 if(prime_debt) assert(lua_checkstack(L,65536)); // storage-only growth, no GC step
 natural_phase=1;
 lua_call(L,lua_gettop(L)-1,2);
 natural_phase=2;
 return 2;
}
int main() {
 lua_State* L=luaL_newstate(); assert(L); luaL_openlibs(L);
 const char* work=std::getenv("SAIVAGE_CARD_WORK_ROOT");
 // CTest outside card runs uses build cwd; card runs keep disposable state scoped.
 if(work) std::filesystem::create_directories(std::string(work)+"/m3-branch");
 std::string save_path=work?std::string(work)+"/m3-branch/save-finalizer.xml":"save-finalizer.xml";
 lua_pushstring(L,save_path.c_str()); lua_setglobal(L,"save_path");
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
 // Loaded nested results: collector runs only from real conversion allocation,
 // after dispatch, while Packet owns a detached native snapshot. Cover both
 // input profiles without repeating the already-qualified unloaded paths.
 const char* loaded_methods[]={"get_function","list_functions","get_instruction","list_instructions","get_decompilation",
 "get_symbol","list_symbols","list_memory_blocks","get_type","list_types","list_type_aliases",
 "list_type_unions","list_type_enums","list_type_enum_members","list_type_members",
 "get_function_signature","list_function_signatures","list_basic_blocks","list_cfg_edges",
 "list_xrefs","get_comments","list_defined_strings","rename_function","rename_symbol","write_bytes","discard_program","save_program"};
 for(int project=0;project<2;++project) {
 for(const char* method:loaded_methods) {
  bool observed=false;
  for(int debt=1;debt<=8192 && !observed;debt*=2) {
   natural_phase=0;
   lua_pushboolean(L,project); lua_setglobal(L,"project_profile");
   run(L,"result=nil; result_error=nil; c=nil; collectgarbage('collect'); "
         "collectgarbage('incremental',100,1000,0); c=assert(n.local_client{state_path=save_path}); "
         "local p={program_path='" LLG_FIXTURE_ROOT "/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}; "
         "if project_profile then p.project_path='" LLG_FIXTURE_ROOT "/tests/fixtures/project/authored.gpr' end; "
         "assert(c:open_program(p)); assert(c:get_decompilation(0x401106).decompilation.completed); "
         "collectgarbage('stop'); hits=0; completed=0; finalizer_phase=0; "
         "do local owner=c; local f=setmetatable({}, {__gc=function() "
         "finalizer_phase=mark_finalizer(); hits=hits+1; "
         "finalizer_ok,finalizer_error=pcall(function() assert(owner:close()); "
         "local replacement=assert(n.local_client()); assert(replacement:close()); completed=completed+1 end) end}) end");
   // Requests are constructed/rooted before restarting GC. No pcall result or
   // Lua chunk compilation allocation is misattributed to native conversion.
   const bool page=method[0]=='l' || !std::strcmp(method,"get_comments");
   const bool text=!std::strcmp(method,"get_type") || !std::strncmp(method,"list_type",9);
   const bool no_range=!std::strcmp(method,"list_memory_blocks");
   const bool mutation=!std::strcmp(method,"rename_function") || !std::strcmp(method,"rename_symbol") || !std::strcmp(method,"write_bytes") || !std::strcmp(method,"discard_program") || !std::strcmp(method,"save_program");
   if(text) run(L,"request='int'; request2={limit=2}");
   else if(no_range) run(L,"request={limit=2}");
   else if(page) run(L,"request={range_start=0x401106,range_end=0x401106,limit=2}");
   else run(L,"request=0x401106");
   for(int i=0;i<debt;++i) { lua_newtable(L); lua_pop(L,1); }
   lua_pushcfunction(L,natural_call); lua_getglobal(L,"c");
   lua_getfield(L,-1,method); lua_insert(L,-2); lua_getglobal(L,"request");
   int args=3;
   if(text && page) { lua_getglobal(L,"request2"); ++args; }
   if(mutation && std::strcmp(method,"discard_program") && std::strcmp(method,"save_program")) {
    lua_pushstring(L,!std::strcmp(method,"write_bytes")?"abc":"loaded_m3_finalizer"); ++args;
   }
   int rc=lua_pcall(L,args,2,0); natural_phase=2;
   assert(rc==LUA_OK);
   lua_pushvalue(L,-2); lua_setglobal(L,"result");
   lua_pushvalue(L,-1); lua_setglobal(L,"result_error"); lua_pop(L,2);
   lua_getglobal(L,"finalizer_phase"); observed=lua_tointeger(L,-1)==3; lua_pop(L,1);
   if(observed) {
    lua_pushinteger(L,mutation?3:2); lua_setglobal(L,"expected_generation");
    run(L,"assert(hits==1 and completed==1); assert(finalizer_ok,finalizer_error); "
          "assert(result_error==nil and type(result)=='table'); "
          "local v,e=c:get_status(); assert(v==nil and e.code=='CLOSED'); "
          "assert(c:_generation():to_integer()==expected_generation); collectgarbage('collect')");
    if(!std::strcmp(method,"get_function") || !std::strcmp(method,"list_functions")) {
     run(L,"local f=result['function'] or result.functions[1]; "
           "assert(f.entry_address:hex()=='0x0000000000401106'); "
           "assert(type(f.name)=='string' and type(f.is_thunk)=='boolean' and math.type(f.parameter_count)=='integer')");
    } else if(!std::strcmp(method,"get_instruction") || !std::strcmp(method,"list_instructions")) {
     run(L,"local i=result.instruction or result.instructions[1]; "
           "assert(i.address:hex()=='0x0000000000401106' and i.length==4); "
           "assert(i.mnemonic:lower()=='endbr64' and type(i.disassembly)=='string')");
    } else if(!std::strcmp(method,"save_program")) {
     run(L,"assert(result.saved==true)");
    } else if(!std::strcmp(method,"get_decompilation")) {
     run(L,"local d=result.decompilation; assert(d.completed and not d.is_fallback); "
           "assert(d.function_entry_address:hex()=='0x0000000000401106'); "
           "assert(d.pseudocode:find('* 3 + 7',1,true)); "
           "assert(type(d.locals)=='table' and type(d.tokens)=='table')");
    }
   }
   run(L,"assert(c:close()); c=nil; result=nil; result_error=nil; collectgarbage('collect'); "
         "local fresh=assert(n.local_client()); assert(fresh:close())");
  }
  assert(observed);
  std::printf("allocation-driven loaded %s %s: detached success after close/reconstruct PASS\n",project?"project":"ELF",method);
 }
 }
 // R1: real Session iterator page publication must not yield a detached page
 // after its shared owner closes in an allocation-triggered finalizer.
 run(L,"package.path='" LLG_FIXTURE_ROOT "/lua/?.lua;" LLG_FIXTURE_ROOT "/lua/?/init.lua'; g=require('libghidra')");
 for(int project=0;project<2;++project) {
 for(const char* family:{"functions","symbols","memory_blocks"}) {
 for(int empty=0;empty<2;++empty) {
  bool observed=false;
  for(int debt=1;debt<=8192 && !observed;debt*=2) {
   natural_phase=0;
   lua_pushboolean(L,project); lua_setglobal(L,"project_profile");
   lua_pushboolean(L,empty); lua_setglobal(L,"empty_page");
   lua_pushstring(L,family); lua_setglobal(L,"iterator_family");
   run(L,"result=nil; result_error=nil; iterator=nil; session=nil; c=nil; collectgarbage('collect'); "
         "collectgarbage('incremental',100,1000,0); "
         "local p={program_path='" LLG_FIXTURE_ROOT "/tests/fixtures/inputs/authored.elf',language_id='x86:LE:64:default',compiler_spec_id='gcc'}; "
         "if project_profile then p.project_path='" LLG_FIXTURE_ROOT "/tests/fixtures/project/authored.gpr' end; "
         "session=assert(g.open{program=p}); c=session:native(); "
         "assert(c:get_decompilation(0x401106).decompilation.completed); assert(c:get_decompilation(0x40111f).decompilation.completed); "
         "local start=empty_page and 0x700000 or 0x401106; "
         "local opts={range_start=start,range_end=start,page_size=2}; "
         "if iterator_family=='memory_blocks' then opts={offset=empty_page and 100 or 0,page_size=2} end; "
         "iterator=session['iter_'..iterator_family](session,opts); "
         "collectgarbage('stop'); hits=0; completed=0; finalizer_phase=0; "
         "do local owner=c; local f=setmetatable({}, {__gc=function() "
         "finalizer_phase=mark_finalizer(); hits=hits+1; "
         "finalizer_ok,finalizer_error=pcall(function() assert(owner:close()); "
         "local r=assert(n.local_client()); assert(r:close()); completed=completed+1 end) end}) end");
   for(int i=0;i<debt;++i) { lua_newtable(L); lua_pop(L,1); }
   lua_pushcfunction(L,natural_call); lua_getglobal(L,"iterator");
   restart_at_page=true;
   int rc=lua_pcall(L,1,2,0); restart_at_page=false; natural_phase=2;
   lua_getglobal(L,"finalizer_phase"); observed=lua_tointeger(L,-1)==3; lua_pop(L,1);
   if(observed) {
    run(L,"assert(hits==1 and completed==1); assert(finalizer_ok,finalizer_error); "
          "local v,e=c:get_status(); assert(v==nil and e.code=='CLOSED')");
    if(rc==LUA_OK) {
     lua_getfield(L,-2,"entry_address");
     std::fprintf(stderr,"R1 RED %s: SAME invocation yielded record after phase-3 owner close/reconstruct (address userdata=%d)\n",project?"project":"ELF",lua_isuserdata(L,-1));
     lua_pop(L,1);
    }
    assert(rc!=LUA_OK && lua_istable(L,-1));
    lua_getfield(L,-1,"code"); assert(!std::strcmp(lua_tostring(L,-1),"ITERATOR_INVALIDATED")); lua_pop(L,1);
   }
   lua_settop(L,0);
   if(observed) run(L,"local ok,e=pcall(iterator); assert(not ok and e.code=='ITERATOR_INVALIDATED')");
   run(L,"c:close(); c=nil; session=nil; iterator=nil; collectgarbage('collect'); local r=assert(n.local_client()); assert(r:close())");
  }
  assert(observed);
  std::printf("R1 %s %s %s iterator same-invocation invalidation PASS\n",project?"project":"ELF",family,empty?"empty-page":"populated-page");
 }
 }
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
 std::remove(save_path.c_str());
 lua_close(L);
 std::puts("deterministic pre-recheck real GC: close/reconstruct finalizer and CLOSED revalidation PASS");
}
