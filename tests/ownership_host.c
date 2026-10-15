/* MIT Copyright 2026 Salvador Fandiño. Ordinary C-built Lua; real module only. */
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
struct allocator { size_t calls, fail, bytes; };
static void* allocate(void* ud, void* ptr, size_t old, size_t n) {
 struct allocator* a=ud; if(!ptr) old=0;
 if(!n) { a->bytes-=old; free(ptr); return NULL; }
 if(n>old && ++a->calls>=a->fail) return NULL;
 void* p=realloc(ptr,n); if(p) a->bytes=a->bytes-old+n; return p;
}
static int run(lua_State* L,const char* text) {
 int rc=luaL_loadstring(L,text); if(!rc) rc=lua_pcall(L,0,0,0);
 if(rc) { if(lua_type(L,-1)==LUA_TSTRING) fprintf(stderr,"%s\n",lua_tostring(L,-1)); lua_pop(L,1); } return rc;
}
static lua_State* state(struct allocator* a,const char* root,const char* build,int preload) {
 lua_State* L=lua_newstate(allocate,a); assert(L); luaL_openlibs(L);
 lua_getglobal(L,"package");
 lua_pushfstring(L,"%s/lua/?.lua;%s/lua/?/init.lua",root,root); lua_setfield(L,-2,"path");
 lua_pushfstring(L,"%s/?.so",build); lua_setfield(L,-2,"cpath"); lua_pop(L,1);
 lua_pushfstring(L,"%s/tests/fixtures/project/authored.gpr",root); lua_setglobal(L,"project");
 lua_pushfstring(L,"%s/tests/fixtures/inputs/authored.elf",root); lua_setglobal(L,"binary");
 if(preload) assert(!run(L,"low=require'libghidra.lowlevel'; high=require'libghidra'")); return L;
}
static void finish(lua_State* L,struct allocator* a) { a->fail=SIZE_MAX; lua_close(L); assert(!a->bytes); }
int main(int argc,char** argv) {
 assert(argc==3);
 /* Independent states share the same native module guard; close B before A,
    then reverse teardown. GC alone releases ownership. */
 for(int reverse=0;reverse<2;++reverse) {
  struct allocator a={0,SIZE_MAX,0},b={0,SIZE_MAX,0};
  lua_State* A=state(&a,argv[1],argv[2],1); lua_State* B=state(&b,argv[1],argv[2],1);
  assert(!run(A,"c=assert(low.local_client()); assert(c:get_status().ok)"));
  assert(!run(B,"local c,e=low.local_client(); assert(not c and e.code=='CLIENT_IN_USE')"));
  assert(!run(A,"c:close()"));
  assert(!run(B,"c=assert(low.local_client()); assert(c:get_status().ok)"));
  if(reverse) { finish(A,&a); finish(B,&b); } else { finish(B,&b); finish(A,&a); }
  struct allocator d={0,SIZE_MAX,0}; lua_State* D=state(&d,argv[1],argv[2],1);
  assert(!run(D,"assert(low.local_client()):close()")); finish(D,&d);
 }
 /* Persistent allocator denial, across all allocations in construction, native
    dispatch result conversion and error conversion. Restoring allocations must
    allow recovery in the SAME state, then a NEW client in a new state. */
 const char* scripts[]={"local c=assert(low.local_client()); local s=c:get_status(); assert(s.ok); "
   "assert(c:get_capabilities()); local r,e=c:open_program{program_path='/no/such/file'}; "
   "assert(not r and e.backend=='local'); c:close()",
   "local s,e,r=high.open{program={project_path=project,program_path=binary}}; "
   "assert(s,e and e.message); assert(r.program_name); assert(s:native():get_status().ok); s:close()"};
 for(size_t scenario=0;scenario<2;++scenario) {
 const char* script=scripts[scenario];
 size_t count=0;
 for(size_t point=0; point<=count+1; ++point) {
  struct allocator a={0,SIZE_MAX,0}; lua_State* L=state(&a,argv[1],argv[2],1);
  assert(luaL_loadstring(L,script)==LUA_OK);
  size_t before=a.calls; if(point) a.fail=before+point;
  int rc=lua_pcall(L,0,0,0); if(!point) { assert(!rc); count=a.calls-before; }
  a.fail=SIZE_MAX; if(rc) lua_pop(L,1);
  lua_gc(L,LUA_GCCOLLECT);
  assert(!run(L,"assert(low.local_client()):close()")); finish(L,&a);
 }
 printf("ownership allocator scenario %zu: %zu failure points + baseline PASS\n",scenario,count+1);
 }
 /* Combined sweep starts BEFORE require, unlike the preloaded cases above.
    Compile before denial so parser failures cannot masquerade as coverage. */
 const char* combined=
  "local low=require'libghidra.lowlevel'; local high=require'libghidra'; "
  "local c=assert(low.local_client()); assert(c:get_status().ok); "
  "assert(#c:get_capabilities()>0); "
  "local r,e=c:open_program{program_path='/no/such/file'}; "
  "assert(not r and e.backend=='local' and type(e.message)=='string'); c:close(); "
  "local s,e,r=high.open{program={project_path=project,program_path=binary}}; "
  "assert(s,e and e.message); assert(r.program_name); "
  "assert(s:native():get_status().ok); s:close()";
 size_t combined_count=0, denied=0;
 for(size_t point=0; point<=combined_count+1; ++point) {
  struct allocator a={0,SIZE_MAX,0};
  lua_State* L=state(&a,argv[1],argv[2],0);
  assert(luaL_loadstring(L,combined)==LUA_OK);
  size_t before=a.calls;
  if(point) a.fail=before+point;
  int rc=lua_pcall(L,0,0,0);
  if(!point) { assert(rc==LUA_OK); combined_count=a.calls-before; }
  else if(point<=combined_count) { assert(rc!=LUA_OK); ++denied; }
  else assert(rc==LUA_OK); /* first point beyond baseline allocations */
  a.fail=SIZE_MAX;
  if(rc) lua_pop(L,1);
  lua_gc(L,LUA_GCCOLLECT);
  /* Retry the ENTIRE script in the same state: partial module/metatable
     initialization must recover and interrupted owners must release the slot. */
  assert(!run(L,combined));
  finish(L,&a);
 }
 assert(denied==combined_count && combined_count>0);
 printf("combined require/owner/conversion: %zu denied points + baseline + beyond-range PASS\n",denied);
 /* Deliberate manual finalization and double-finalization resistance. */
 struct allocator a={0,SIZE_MAX,0}; lua_State* L=state(&a,argv[1],argv[2],1);
 assert(!run(L,"c=assert(low.local_client()); "
  "local gc=debug.getmetatable(c).__gc; gc(c); gc(c); assert(c:close()); "
  "local r,e=c:get_status(); assert(not r and e.code=='CLOSED'); "
  "assert(low.local_client()):close()"));
 finish(L,&a);
 puts("ownership independent-state/process guard and manual finalization PASS"); return 0;
}
