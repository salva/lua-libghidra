// MIT Copyright 2026 Salvador Fandiño.
#include "boundary.hpp"
#include "core_convert.hpp"
#include <cstdlib>
#include <cstdio>
#include <cassert>
#include <stdexcept>
extern "C" int luaopen_libghidra__native(lua_State*);
struct Allocator { size_t calls = 0, fail = SIZE_MAX, bytes = 0, refused = 0; };
static void* allocate(void* ud, void* ptr, size_t old, size_t n) {
    auto* a = static_cast<Allocator*>(ud);
    if (!ptr) old = 0;
    if (!n) { a->bytes -= old; free(ptr); return nullptr; }
    if (n > old && ++a->calls >= a->fail) { ++a->refused; return nullptr; }
    void* p = realloc(ptr, n);
    if (p) a->bytes = a->bytes - old + n;
    return p;
}
struct Owned {
    static inline int live = 0, constructed = 0, destroyed = 0;
    std::string bytes = std::string("a\0b", 3);
    std::optional<bool> flag = false;
    std::optional<int> zero = 0;
    std::optional<std::optional<bool>> nested = std::optional<bool>(false);
    std::optional<int> missing;
    std::vector<uint64_t> ids = {0, UINT64_MAX};
    Owned() { ++live; ++constructed; }
    ~Owned() { assert(live>0); --live; ++destroyed; }
};
static int convert(lua_State* L) {
    auto* p = static_cast<Owned*>(lua_touserdata(L, 1));
    lua_createtable(L, 0, 8);
    llg::field(L, "data", p->bytes); llg::field(L, "flag", p->flag);
    llg::field(L, "zero", p->zero); llg::field(L, "nested", p->nested);
    llg::field(L, "missing", p->missing); llg::field(L, "ids", p->ids);
    llg::field(L, "ordinal", int64_t(-1)); llg::field(L, "count", uint32_t(0));
    return 1;
}
// RAII is ONLY outside jumped frames. Check stack before creating owner.
static int detached(lua_State* L) {
    int rc;
    luaL_checkstack(L, 32, "conversion stack");
    { Owned owner; rc = llg::protected_convert(L, convert, &owner); }
    if (rc) return lua_error(L);
    return 1;
}
// Full new nested converters, including synthetic fields ordinary fixtures omit.
// The owner lives below the protected conversion, never in a jumped frame.
struct SliceOwned {
 static inline int live=0;
 libghidra::client::DecompilationRecord dec;
 libghidra::client::FunctionRecord fn;
 libghidra::client::InstructionRecord ins;
 SliceOwned() {
  ++live;
 fn.entry_address=UINT64_MAX; fn.is_thunk=false; fn.parameter_count=0;
  dec.function_entry_address=UINT64_MAX; dec.completed=false; dec.is_fallback=true;
  dec.pseudocode=std::string("a\0b",3); dec.error_message="diagnostic";
  libghidra::client::DecompileLocalRecord local;
  local.ordinal=0; local.kind=libghidra::client::DecompileLocalKind::kParam;
  dec.locals.push_back(local);
  libghidra::client::DecompileTokenRecord token;
  token.kind=static_cast<libghidra::client::DecompileTokenKind>(99);
  token.line_number=-1; token.column_offset=0; dec.tokens.push_back(token);
 }
 ~SliceOwned() { --live; }
};
static int slice_convert(lua_State* L) {
 const auto* p=static_cast<SliceOwned*>(lua_touserdata(L,1));
 lua_createtable(L,0,3);
 llg::slice::value(L,p->dec); lua_setfield(L,-2,"dec");
 llg::slice::value(L,p->fn); lua_setfield(L,-2,"fn");
 llg::slice::value(L,p->ins); lua_setfield(L,-2,"ins");
 return 1;
}
static int slice_detached(lua_State* L) {
 int rc; luaL_checkstack(L,32,"slice stack");
 { SliceOwned p; rc=llg::protected_convert(L,slice_convert,&p); }
 if(rc) return lua_error(L);
 return 1;
}
// Full core detached converters are qualified independently of producer availability.
struct CoreOwned {
 static inline int live=0;
 libghidra::client::BasicBlockRecord r0;
 libghidra::client::CFGEdgeRecord r1;
 libghidra::client::SymbolRecord r2;
 libghidra::client::XrefRecord r3;
 libghidra::client::MemoryBlockRecord r4;
 libghidra::client::TypeRecord r5;
 libghidra::client::TypeAliasRecord r6;
 libghidra::client::TypeUnionRecord r7;
 libghidra::client::TypeEnumRecord r8;
 libghidra::client::TypeEnumMemberRecord r9;
 libghidra::client::TypeMemberRecord r10;
 libghidra::client::ParameterRecord r11;
 libghidra::client::FunctionSignatureRecord r12;
 libghidra::client::CommentRecord r13;
 libghidra::client::DefinedStringRecord r14;
 libghidra::client::CommentRecord comment_kinds[6];
 CoreOwned() {
  ++live;
  for(int i=0;i<6;++i) comment_kinds[i].kind=static_cast<libghidra::client::CommentKind>(i);
  r0.function_entry=UINT64_MAX;
  r0.start_address=UINT64_MAX;
  r0.end_address=UINT64_MAX;
  r0.in_degree=UINT32_MAX;
  r0.out_degree=UINT32_MAX;
  r1.function_entry=UINT64_MAX;
  r1.src_block_start=UINT64_MAX;
  r1.dst_block_start=UINT64_MAX;
  r1.edge_kind=std::string("a\0b",3);
  r2.symbol_id=UINT64_MAX;
  r2.address=UINT64_MAX;
  r2.name=std::string("a\0b",3);
  r2.full_name=std::string("a\0b",3);
  r2.type=std::string("a\0b",3);
  r2.namespace_name=std::string("a\0b",3);
  r2.source=std::string("a\0b",3);
  r2.is_primary=false;
  r2.is_external=false;
  r2.is_dynamic=false;
  r2.is_external_entry_point=false;
  r3.from_address=UINT64_MAX;
  r3.to_address=UINT64_MAX;
  r3.operand_index=-1;
  r3.ref_type=std::string("a\0b",3);
  r3.is_primary=false;
  r3.source=std::string("a\0b",3);
  r3.symbol_id=INT64_MIN;
  r3.is_external=false;
  r3.is_memory=false;
  r3.is_flow=false;
  r3.from_function_address=UINT64_MAX;
  r3.from_function_name=std::string("a\0b",3);
  r3.to_function_address=UINT64_MAX;
  r3.to_function_name=std::string("a\0b",3);
  r4.name=std::string("a\0b",3);
  r4.start_address=UINT64_MAX;
  r4.end_address=UINT64_MAX;
  r4.size=UINT64_MAX;
  r4.is_read=false;
  r4.is_write=false;
  r4.is_execute=false;
  r4.is_volatile=false;
  r4.is_initialized=false;
  r4.source_name=std::string("a\0b",3);
  r4.comment=std::string("a\0b",3);
  r5.type_id=UINT64_MAX;
  r5.name=std::string("a\0b",3);
  r5.path_name=std::string("a\0b",3);
  r5.category_path=std::string("a\0b",3);
  r5.display_name=std::string("a\0b",3);
  r5.kind=std::string("a\0b",3);
  r5.length=-1;
  r5.is_not_yet_defined=false;
  r5.source_archive=std::string("a\0b",3);
  r5.universal_id=std::string("a\0b",3);
  r6.type_id=UINT64_MAX;
  r6.path_name=std::string("a\0b",3);
  r6.name=std::string("a\0b",3);
  r6.target_type=std::string("a\0b",3);
  r6.declaration=std::string("a\0b",3);
  r7.type_id=UINT64_MAX;
  r7.path_name=std::string("a\0b",3);
  r7.name=std::string("a\0b",3);
  r7.size=UINT64_MAX;
  r7.declaration=std::string("a\0b",3);
  r8.type_id=UINT64_MAX;
  r8.path_name=std::string("a\0b",3);
  r8.name=std::string("a\0b",3);
  r8.width=UINT64_MAX;
  r8.is_signed=false;
  r8.declaration=std::string("a\0b",3);
  r9.type_id=UINT64_MAX;
  r9.type_path_name=std::string("a\0b",3);
  r9.type_name=std::string("a\0b",3);
  r9.ordinal=UINT64_MAX;
  r9.name=std::string("a\0b",3);
  r9.value=INT64_MIN;
  r9.comment=std::string("a\0b",3);
  r10.parent_type_id=UINT64_MAX;
  r10.parent_type_path_name=std::string("a\0b",3);
  r10.parent_type_name=std::string("a\0b",3);
  r10.ordinal=UINT64_MAX;
  r10.name=std::string("a\0b",3);
  r10.member_type=std::string("a\0b",3);
  r10.offset=INT64_MIN;
  r10.size=UINT64_MAX;
  r10.comment=std::string("a\0b",3);
  r11.ordinal=-1;
  r11.name=std::string("a\0b",3);
  r11.data_type=std::string("a\0b",3);
  r11.formal_data_type=std::string("a\0b",3);
  r11.is_auto_parameter=false;
  r11.is_forced_indirect=false;
  r12.function_entry_address=UINT64_MAX;
  r12.function_name=std::string("a\0b",3);
  r12.prototype=std::string("a\0b",3);
  r12.return_type=std::string("a\0b",3);
  r12.has_var_args=false;
  r12.calling_convention=std::string("a\0b",3);
  r13.address=UINT64_MAX;
  r13.kind=static_cast<libghidra::client::CommentKind>(99);
  r13.text=std::string("a\0b",3);
  r14.address=UINT64_MAX;
  r14.value=std::string("a\0b",3);
  r14.length=UINT32_MAX;
  r14.data_type=std::string("a\0b",3);
  r14.encoding=std::string("a\0b",3);
  r12.parameters.push_back(r11);
 }
 ~CoreOwned() { --live; }
};
static int core_convert(lua_State* L) {
 const auto* p=static_cast<CoreOwned*>(lua_touserdata(L,1));
 lua_createtable(L,0,15);
 llg::slice::value(L,p->r0); lua_setfield(L,-2,"r0");
 llg::slice::value(L,p->r1); lua_setfield(L,-2,"r1");
 llg::slice::value(L,p->r2); lua_setfield(L,-2,"r2");
 llg::slice::value(L,p->r3); lua_setfield(L,-2,"r3");
 llg::slice::value(L,p->r4); lua_setfield(L,-2,"r4");
 llg::slice::value(L,p->r5); lua_setfield(L,-2,"r5");
 llg::slice::value(L,p->r6); lua_setfield(L,-2,"r6");
 llg::slice::value(L,p->r7); lua_setfield(L,-2,"r7");
 llg::slice::value(L,p->r8); lua_setfield(L,-2,"r8");
 llg::slice::value(L,p->r9); lua_setfield(L,-2,"r9");
 llg::slice::value(L,p->r10); lua_setfield(L,-2,"r10");
 llg::slice::value(L,p->r11); lua_setfield(L,-2,"r11");
 llg::slice::value(L,p->r12); lua_setfield(L,-2,"r12");
 llg::slice::value(L,p->r13); lua_setfield(L,-2,"r13");
 llg::slice::value(L,p->r14); lua_setfield(L,-2,"r14");
 lua_createtable(L,6,0);
 for(int i=0;i<6;++i) {
  llg::slice::value(L,p->comment_kinds[i]); lua_rawseti(L,-2,i+1);
 }
 lua_setfield(L,-2,"comment_kinds");
 return 1;
}
static int core_detached(lua_State* L) {
 int rc; luaL_checkstack(L,32,"core stack");
 { CoreOwned p; rc=llg::protected_convert(L,core_convert,&p); }
 if(rc) return lua_error(L);
 return 1;
}
static int exercise(lua_State* L) {
    luaL_requiref(L, "libghidra._native", luaopen_libghidra__native, 0); lua_pop(L, 1);
    lua_pushcfunction(L, detached); lua_setglobal(L, "detached");
    return luaL_dostring(L,
      "local n=require('libghidra._native'); local v=assert(n.u64('18446744073709551615')); "
      "assert(v:hex()=='0xffffffffffffffff'); assert(v:decimal()=='18446744073709551615'); "
      "local x,e=n.u64('bad'); assert(x==nil and e.backend=='binding'); "
      "assert(n._validate_read_size(2147483647)==2147483647); "
      "local x,e=n._validate_read_size(2147483648); assert(x==nil and e.code=='INVALID_ARGUMENT'); "
      "assert(n._validate_page{range_start=1,range_end=0}); "
      "local r=detached(); collectgarbage(); assert(r.data=='a\\0b' and #r.data==3); "
      "assert(r.flag==false and r.nested==false and r.zero==0 and r.missing==nil); "
      "assert(r.ids[1]:decimal()=='0' and r.ids[2]==v and r.ordinal==-1 and r.count==0)");
}
// Setup failure is also protected; luaL_dostring returns rather than rethrows.
static int sweep_body(lua_State* L) {
    int rc = exercise(L); if (rc) return lua_error(L); return 0;
}
// Each chunk is compiled and rooted BEFORE refusal, so reached points belong
// to the selected runtime path rather than parser/setup allocations.
static void edge_sweeps() {
 const char* cases[]={
  "return n.u64('18446744073709551615')",
  "local x,e=n.u64('18446744073709551616'); assert(x==nil and e.code=='INVALID_ARGUMENT')",
  "return u:hex(),u:decimal()",
  "local x,e=u:to_integer(); assert(x==nil and e.operation=='to_integer')",
  "return z:add(1):sub(1)",
  "local x,e=u:add(1); assert(x==nil and e.operation=='add')",
  "local x,e=z:sub(1); assert(x==nil and e.operation=='sub')",
  "local x,e=u:add(false); assert(x==nil and e.operation=='add')",
  "local ok,e=pcall(function() return u<false end); assert(not ok and e.operation=='__lt')",
  "local ok,e=pcall(function() return u<=false end); assert(not ok and e.operation=='__le')",
  "local ok,e=pcall(function() u.x=1 end); assert(not ok and e.operation=='__newindex')",
  "local x,e=n._validate_page{limit=0}; assert(x==nil and e.operation=='page')",
  "return n._validate_page{range_start='0xffffffffffffffff',range_end=0,limit=1,offset=0}",
  "local x,e=n._validate_read_size(-1); assert(x==nil and e.operation=='read_bytes')",
  "return detached()",
  R"LUA(
local v=core_detached(); collectgarbage()
for i,name in ipairs{'unspecified','eol','pre','post','plate','repeatable'} do assert(v.comment_kinds[i].kind==name) end
assert(v.r0.function_entry:decimal()=='18446744073709551615')
assert(v.r0.start_address:decimal()=='18446744073709551615')
assert(v.r0.end_address:decimal()=='18446744073709551615')
assert(math.type(v.r0.in_degree)=='integer' and v.r0.in_degree==4294967295)
assert(math.type(v.r0.out_degree)=='integer' and v.r0.out_degree==4294967295)
assert(v.r1.function_entry:decimal()=='18446744073709551615')
assert(v.r1.src_block_start:decimal()=='18446744073709551615')
assert(v.r1.dst_block_start:decimal()=='18446744073709551615')
assert(v.r1.edge_kind=='a\0b')
assert(v.r2.symbol_id:decimal()=='18446744073709551615')
assert(v.r2.address:decimal()=='18446744073709551615')
assert(v.r2.name=='a\0b')
assert(v.r2.full_name=='a\0b')
assert(v.r2.type=='a\0b')
assert(v.r2.namespace_name=='a\0b')
assert(v.r2.source=='a\0b')
assert(v.r2.is_primary==false)
assert(v.r2.is_external==false)
assert(v.r2.is_dynamic==false)
assert(v.r2.is_external_entry_point==false)
assert(v.r3.from_address:decimal()=='18446744073709551615')
assert(v.r3.to_address:decimal()=='18446744073709551615')
assert(math.type(v.r3.operand_index)=='integer' and v.r3.operand_index==-1)
assert(v.r3.ref_type=='a\0b')
assert(v.r3.is_primary==false)
assert(v.r3.source=='a\0b')
assert(math.type(v.r3.symbol_id)=='integer' and v.r3.symbol_id==math.mininteger)
assert(v.r3.is_external==false)
assert(v.r3.is_memory==false)
assert(v.r3.is_flow==false)
assert(v.r3.from_function_address:decimal()=='18446744073709551615')
assert(v.r3.from_function_name=='a\0b')
assert(v.r3.to_function_address:decimal()=='18446744073709551615')
assert(v.r3.to_function_name=='a\0b')
assert(v.r4.name=='a\0b')
assert(v.r4.start_address:decimal()=='18446744073709551615')
assert(v.r4.end_address:decimal()=='18446744073709551615')
assert(v.r4.size:decimal()=='18446744073709551615')
assert(v.r4.is_read==false)
assert(v.r4.is_write==false)
assert(v.r4.is_execute==false)
assert(v.r4.is_volatile==false)
assert(v.r4.is_initialized==false)
assert(v.r4.source_name=='a\0b')
assert(v.r4.comment=='a\0b')
assert(v.r5.type_id:decimal()=='18446744073709551615')
assert(v.r5.name=='a\0b')
assert(v.r5.path_name=='a\0b')
assert(v.r5.category_path=='a\0b')
assert(v.r5.display_name=='a\0b')
assert(v.r5.kind=='a\0b')
assert(math.type(v.r5.length)=='integer' and v.r5.length==-1)
assert(v.r5.is_not_yet_defined==false)
assert(v.r5.source_archive=='a\0b')
assert(v.r5.universal_id=='a\0b')
assert(v.r6.type_id:decimal()=='18446744073709551615')
assert(v.r6.path_name=='a\0b')
assert(v.r6.name=='a\0b')
assert(v.r6.target_type=='a\0b')
assert(v.r6.declaration=='a\0b')
assert(v.r7.type_id:decimal()=='18446744073709551615')
assert(v.r7.path_name=='a\0b')
assert(v.r7.name=='a\0b')
assert(v.r7.size:decimal()=='18446744073709551615')
assert(v.r7.declaration=='a\0b')
assert(v.r8.type_id:decimal()=='18446744073709551615')
assert(v.r8.path_name=='a\0b')
assert(v.r8.name=='a\0b')
assert(v.r8.width:decimal()=='18446744073709551615')
assert(v.r8.is_signed==false)
assert(v.r8.declaration=='a\0b')
assert(v.r9.type_id:decimal()=='18446744073709551615')
assert(v.r9.type_path_name=='a\0b')
assert(v.r9.type_name=='a\0b')
assert(v.r9.ordinal:decimal()=='18446744073709551615')
assert(v.r9.name=='a\0b')
assert(math.type(v.r9.value)=='integer' and v.r9.value==math.mininteger)
assert(v.r9.comment=='a\0b')
assert(v.r10.parent_type_id:decimal()=='18446744073709551615')
assert(v.r10.parent_type_path_name=='a\0b')
assert(v.r10.parent_type_name=='a\0b')
assert(v.r10.ordinal:decimal()=='18446744073709551615')
assert(v.r10.name=='a\0b')
assert(v.r10.member_type=='a\0b')
assert(math.type(v.r10.offset)=='integer' and v.r10.offset==math.mininteger)
assert(v.r10.size:decimal()=='18446744073709551615')
assert(v.r10.comment=='a\0b')
assert(math.type(v.r11.ordinal)=='integer' and v.r11.ordinal==-1)
assert(v.r11.name=='a\0b')
assert(v.r11.data_type=='a\0b')
assert(v.r11.formal_data_type=='a\0b')
assert(v.r11.is_auto_parameter==false)
assert(v.r11.is_forced_indirect==false)
assert(v.r12.function_entry_address:decimal()=='18446744073709551615')
assert(v.r12.function_name=='a\0b')
assert(v.r12.prototype=='a\0b')
assert(v.r12.return_type=='a\0b')
assert(v.r12.has_var_args==false)
assert(v.r12.calling_convention=='a\0b')
assert(v.r13.address:decimal()=='18446744073709551615')
assert(v.r13.kind==99)
assert(v.r13.text=='a\0b')
assert(v.r14.address:decimal()=='18446744073709551615')
assert(v.r14.value=='a\0b')
assert(math.type(v.r14.length)=='integer' and v.r14.length==4294967295)
assert(v.r14.data_type=='a\0b')
assert(v.r14.encoding=='a\0b')
assert(#v.r12.parameters==1 and v.r12.parameters[1].name=='a\0b' and v.r12.parameters[1].ordinal==-1)
)LUA",
  "local v=slice_detached(); assert(v.dec.completed==false and v.dec.is_fallback==true); "
  "assert(v.dec.pseudocode=='a\\0b' and v.dec.error_message=='diagnostic'); "
  "assert(v.fn.entry_address:decimal()=='18446744073709551615' and v.fn.is_thunk==false and v.fn.parameter_count==0); "
  "assert(v.dec.locals[1].ordinal==0 and v.dec.locals[1].kind=='param'); "
  "assert(v.dec.tokens[1].kind==99 and v.dec.tokens[1].line_number==-1 and v.dec.tokens[1].column_offset==0); "
  "assert(v.ins.address:decimal()=='0' and v.ins.length==0)"
 };
 size_t denials=0;
 for(const char* source:cases) {
  size_t hits=0; bool tail=false;
  for(size_t point=1;point<=512;++point) {
   Allocator a; lua_State* L=lua_newstate(allocate,&a); assert(L);
   luaL_openlibs(L); luaL_requiref(L,"libghidra._native",luaopen_libghidra__native,0); lua_setglobal(L,"n");
   lua_pushcfunction(L,detached); lua_setglobal(L,"detached");
   lua_pushcfunction(L,slice_detached); lua_setglobal(L,"slice_detached");
   lua_pushcfunction(L,core_detached); lua_setglobal(L,"core_detached");
   assert(luaL_dostring(L,"u=assert(n.u64('18446744073709551615')); z=assert(n.u64(0))")==LUA_OK);
   assert(luaL_loadstring(L,source)==LUA_OK);
   a.calls=a.refused=0; a.fail=point;
   int rc=lua_pcall(L,0,LUA_MULTRET,0); a.fail=SIZE_MAX;
   if(a.refused) { ++hits; assert(rc==LUA_ERRMEM); }
   else { assert(rc==LUA_OK && a.calls<point); tail=true; }
   assert(Owned::live==0 && SliceOwned::live==0 && CoreOwned::live==0);
   lua_settop(L,0);
   // Retry on SAME ordinary Lua VM after every actual error.
   assert(luaL_dostring(L,source)==LUA_OK); assert(Owned::live==0 && SliceOwned::live==0 && CoreOwned::live==0);
   lua_close(L); assert(a.bytes==0);
   if(tail) break;
  }
  assert(tail && hits>0); denials+=hits;
 }
 std::printf("UInt64/helper/error/detached per-path Lua OOM: %zu paths, %zu actual refusal points, same-VM retries PASS\n",sizeof(cases)/sizeof(cases[0]),denials);
}
int main() {
    edge_sweeps();
    size_t boundaries = 0;
    for (size_t failure = 0; ; ++failure) {
        Allocator a;
        lua_State* L = lua_newstate(allocate, &a); assert(L);
        luaL_openlibs(L); lua_checkstack(L, 64);
        lua_pushinteger(L, INT32_MAX);
        size_t count = a.calls; uint32_t size = 0;
        assert(llg::read_size(L, -1, &size) && size == INT32_MAX);
        assert(a.calls == count); lua_pop(L, 1);
        lua_pushinteger(L, UINT32_MAX); count = a.calls;
        assert(!llg::read_size(L, -1, &size) && a.calls == count);
        lua_pop(L, 1);
        lua_pushcfunction(L, sweep_body);
        lua_pushboolean(L, 0); bool flag = true;
        assert(llg::read_boolean(L, -1, &flag) && !flag);
        lua_Integer integer; assert(!llg::read_integer(L, -1, 0, 1, &integer));
        lua_pop(L, 1); lua_pushinteger(L, 0);
        assert(llg::read_integer(L, -1, 0, 1, &integer) && integer == 0);
        assert(!llg::read_boolean(L, -1, &flag));
        const char* text; size_t length; assert(!llg::read_text(L, -1, &text, &length));
        lua_pop(L, 1); lua_pushlstring(L, "a\0b", 3);
        assert(llg::read_text(L, -1, &text, &length) && length == 3); lua_pop(L, 1);
        const char* keys[] = {"x", nullptr};
        lua_newtable(L); lua_pushinteger(L, 0); lua_setfield(L, -2, "x");
        assert(llg::known_keys(L, -1, keys));
        lua_pushboolean(L, false); lua_setfield(L, -2, "unknown");
        assert(!llg::known_keys(L, -1, keys)); lua_pop(L, 1);
        size_t baseline = a.calls;
        if (failure) a.fail = baseline + failure;
        int rc = lua_pcall(L, 0, 0, 0);
        a.fail = SIZE_MAX;
        if (!failure) { assert(rc == LUA_OK); boundaries = a.calls - baseline; }
        assert(Owned::live == 0);
        lua_settop(L, 0);
        lua_pushcfunction(L, sweep_body);
        assert(lua_pcall(L, 0, 0, 0) == LUA_OK);
        assert(Owned::live == 0);
        lua_close(L); assert(a.bytes == 0);
        if (failure == boundaries) break;
    }
    assert(Owned::constructed==Owned::destroyed && Owned::constructed>0);
    std::printf("detached conversions + persistent OOM sweep: %zu allocation boundaries, %d matched owner destructions PASS\n", boundaries,Owned::destroyed);
}
