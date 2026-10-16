// MIT Copyright 2026 Salvador Fandiño.
#include "boundary.hpp"
#include "full_convert.hpp"
#include <climits>
#include <cmath>
#include "process_guard.hpp"
#include "native_phase_test.hpp"
#include <libghidra/local.hpp>
#include <mutex>
#include <memory>
#include <exception>
#include <cstring>
#include <cstdio>
#include <stdexcept>
namespace llg {
#ifdef LLG_CORE_FIXTURE
void seed_core_fixture(libghidra::client::IClient*);
#endif
#ifdef LLG_ADAPTER_OBSERVER
void before_adapter_dispatch(int);
#endif
#ifdef LLG_REENTRY_OBSERVER
void before_owner_recheck(lua_State*);
#endif
#ifdef LLG_READ_OBSERVER
// Test-build-only observer: no Lua calls, allocations or production exports.
void observe_read_phase(int phase, uint32_t size) noexcept;
#endif
namespace {
namespace c = libghidra::client;
constexpr const char* mt = "libghidra.owner";
// Shared support DSO owns the process guard even for RTLD_LOCAL module copies.
// Never hold its mutex during any Lua call.
struct Handle { std::unique_ptr<c::IClient> client; uint64_t generation = 0; bool has_state_path = false; };
const char* const operation_names[]={"get_status","open_program","close_program","shutdown","get_revision","get_capabilities","read_bytes","get_function","list_functions","get_instruction","list_instructions","get_decompilation","save_program","discard_program","rename_function","list_basic_blocks","list_cfg_edges","get_symbol","list_symbols","rename_symbol","list_xrefs","list_memory_blocks","write_bytes","get_type","list_types","list_type_aliases","list_type_unions","list_type_enums","list_type_enum_members","list_type_members","get_function_signature","list_function_signatures","get_comments","list_defined_strings","create_type","delete_type","rename_type","create_type_alias","delete_type_alias","set_type_alias_target","create_type_enum","add_type_enum_member","delete_type_enum_member","rename_type_enum_member","set_type_enum_member_value","set_type_enum_member_comment","add_type_member","delete_type_member","rename_type_member","set_type_member_type","set_type_member_comment","set_function_signature","rename_function_parameter","set_function_parameter_type","rename_function_local","set_function_local_type","apply_data_type","list_decompilations","list_leaf_functions","delete_symbol","set_comment","delete_comment","list_data_items","rename_data_item","delete_data_item","add_perf_benchmark","list_perf_benchmarks","clear_perf_benchmarks","delete_perf_benchmark","patch_bytes_batch"};
struct Slot { Handle* p; };
struct Packet {
 const char* op; std::string code, message; const char* backend = "local";
 const char* exception_code = nullptr; char exception_message[2048] = {};
 c::HealthStatus health; c::OpenProgramResponse opened; c::RevisionResponse revision;
 std::vector<c::Capability> capabilities; c::ReadBytesResponse bytes;
 c::GetFunctionResponse function; c::ListFunctionsResponse functions;
 c::GetInstructionResponse instruction; c::ListInstructionsResponse instructions;
 c::GetDecompilationResponse decompilation;
 c::SaveProgramResponse core_12;
 c::DiscardProgramResponse core_13;
 c::RenameFunctionResponse core_14;
 c::ListBasicBlocksResponse core_15;
 c::ListCFGEdgesResponse core_16;
 c::GetSymbolResponse core_17;
 c::ListSymbolsResponse core_18;
 c::RenameSymbolResponse core_19;
 c::ListXrefsResponse core_20;
 c::ListMemoryBlocksResponse core_21;
 c::WriteBytesResponse core_22;
 c::GetTypeResponse core_23;
 c::ListTypesResponse core_24;
 c::ListTypeAliasesResponse core_25;
 c::ListTypeUnionsResponse core_26;
 c::ListTypeEnumsResponse core_27;
 c::ListTypeEnumMembersResponse core_28;
 c::ListTypeMembersResponse core_29;
 c::GetFunctionSignatureResponse core_30;
 c::ListFunctionSignaturesResponse core_31;
 c::GetCommentsResponse core_32;
 c::ListDefinedStringsResponse core_33;
 c::CreateTypeResponse full_34;
 c::DeleteTypeResponse full_35;
 c::RenameTypeResponse full_36;
 c::CreateTypeAliasResponse full_37;
 c::DeleteTypeAliasResponse full_38;
 c::SetTypeAliasTargetResponse full_39;
 c::CreateTypeEnumResponse full_40;
 c::AddTypeEnumMemberResponse full_41;
 c::DeleteTypeEnumMemberResponse full_42;
 c::RenameTypeEnumMemberResponse full_43;
 c::SetTypeEnumMemberValueResponse full_44;
 c::SetTypeEnumMemberCommentResponse full_45;
 c::AddTypeMemberResponse full_46;
 c::DeleteTypeMemberResponse full_47;
 c::RenameTypeMemberResponse full_48;
 c::SetTypeMemberTypeResponse full_49;
 c::SetTypeMemberCommentResponse full_50;
 c::SetFunctionSignatureResponse full_51;
 c::RenameFunctionParameterResponse full_52;
 c::SetFunctionParameterTypeResponse full_53;
 c::RenameFunctionLocalResponse full_54;
 c::SetFunctionLocalTypeResponse full_55;
 c::ApplyDataTypeResponse full_56;
 c::ListDecompilationsResponse full_57;
 c::ListFunctionsResponse full_58;
 c::DeleteSymbolResponse full_59;
 c::SetCommentResponse full_60;
 c::DeleteCommentResponse full_61;
 c::ListDataItemsResponse full_62;
 c::RenameDataItemResponse full_63;
 c::DeleteDataItemResponse full_64;
 c::AddPerfBenchmarkResponse full_65;
 c::ListPerfBenchmarksResponse full_66;
 c::ClearPerfBenchmarksResponse full_67;
 c::DeletePerfBenchmarkResponse full_68;
 c::PatchBytesBatchResponse full_69;
 bool lua_error_pending=false;
 bool flag = false; int kind = 0;
};
void seterror(Packet& p, const char* code, const char* message) {
 p.code=code; p.message=message;
}
void exception(Packet& p, const char* message) noexcept {
 p.exception_code="NATIVE_EXCEPTION"; p.backend="binding";
 std::snprintf(p.exception_message,sizeof(p.exception_message),"%s",message);
}
int failure(lua_State* L, const char* op, const char* code, const char* msg, const char* backend) {
 lua_pushnil(L); lua_createtable(L,0,4);
 lua_pushstring(L,code); lua_setfield(L,-2,"code");
 lua_pushstring(L,msg); lua_setfield(L,-2,"message");
 lua_pushstring(L,op); lua_setfield(L,-2,"operation");
 lua_pushstring(L,backend); lua_setfield(L,-2,"backend"); return 2;
}
Slot* slot(lua_State* L) { return static_cast<Slot*>(luaL_testudata(L,1,mt)); }
void release(Slot* s) noexcept {
 if (!s || !s->p) return;
 std::lock_guard<std::mutex> guard(process_guard().engine);
 if (s->p->client) { LLG_NATIVE_PHASE(2); s->p->client.reset(); process_guard().occupied = false; ++s->p->generation; }
}
int close(lua_State* L) { release(slot(L)); lua_pushboolean(L,1); return 1; }
int gc(lua_State* L) {
 Slot* s = slot(L); release(s);
 if (s) { delete s->p; s->p = nullptr; } return 0;
}
int generation(lua_State* L) {
 Slot* s = slot(L);
 if (!s || !s->p) return failure(L,"generation","CLOSED","owner released","binding");
 push_u64(L,s->p->generation); return 1;
}
// Iterator guard must not allocate: publishing a UInt64 generation snapshot can
// itself run a finalizer after reading the old value. Compare the rooted token
// directly and return only a nonallocating boolean, with no Lua-running phase
// between checking the live owner and observing its generation.
int has_state_path(lua_State* L) {
 Slot* s=slot(L);
 // Closed owners defer to dispatch so CLOSED takes precedence over policy.
 lua_pushboolean(L,!s || !s->p || !s->p->client || s->p->has_state_path); return 1;
}
int generation_matches(lua_State* L) {
 uint64_t expected=0;
 if(!read_u64(L,2,&expected)) { lua_pushboolean(L,0); return 1; }
 Slot* s=slot(L);
 lua_pushboolean(L,s && s->p && s->p->client && s->p->generation==expected);
 return 1;
}
int convert(lua_State* L) {
 const Packet* p = static_cast<Packet*>(lua_touserdata(L,1));
 if(p->exception_code) return failure(L,p->op,p->exception_code,p->exception_message,p->backend);
 if(!p->code.empty()) return failure(L,p->op,p->code.c_str(),p->message.c_str(),p->backend);
 lua_createtable(L,0,10);
 switch(p->kind) {
 case 0:
  field(L,"ok",p->health.ok); field(L,"service_name",p->health.service_name);
  field(L,"service_version",p->health.service_version); field(L,"host_mode",p->health.host_mode);
  field(L,"modification_number",p->health.modification_number); field(L,"warnings",p->health.warnings); break;
 case 1:
  field(L,"program_name",p->opened.program_name); field(L,"language_id",p->opened.language_id);
  field(L,"compiler_spec",p->opened.compiler_spec); field(L,"image_base",p->opened.image_base);
  field(L,"md5",p->opened.md5); field(L,"sha256",p->opened.sha256);
  field(L,"executable_format",p->opened.executable_format); field(L,"entry_point",p->opened.entry_point);
  field(L,"has_entry_point",p->opened.has_entry_point); break;
 case 2: field(L,"closed",p->flag); break;
 case 3: field(L,"accepted",p->flag); break;
 case 4:
  field(L,"program_id",p->revision.program_id); field(L,"modification_number",p->revision.modification_number);
  field(L,"program_path",p->revision.program_path); field(L,"file_id",p->revision.file_id);
  field(L,"file_version",p->revision.file_version); field(L,"file_last_modified_time",p->revision.file_last_modified_time); break;
 case 5:
  for(size_t i=0;i<p->capabilities.size();++i) {
   lua_createtable(L,0,3); field(L,"id",p->capabilities[i].id);
   field(L,"status",p->capabilities[i].status); field(L,"note",p->capabilities[i].note);
   lua_rawseti(L,-2,i+1);
  } break;
 case 12:
  field(L,"saved",p->core_12.saved);
  break;
 case 13:
  field(L,"discarded",p->core_13.discarded);
  break;
 case 14:
  field(L,"renamed",p->core_14.renamed);
  field(L,"name",p->core_14.name);
  break;
 case 15:
  slice::array(L,"blocks",p->core_15.blocks);
  break;
 case 16:
  slice::array(L,"edges",p->core_16.edges);
  break;
 case 17:
  slice::optional(L,"symbol",p->core_17.symbol);
  break;
 case 18:
  slice::array(L,"symbols",p->core_18.symbols);
  break;
 case 19:
  field(L,"renamed",p->core_19.renamed);
  field(L,"name",p->core_19.name);
  break;
 case 20:
  slice::array(L,"xrefs",p->core_20.xrefs);
  break;
 case 21:
  slice::array(L,"blocks",p->core_21.blocks);
  break;
 case 22:
  field(L,"bytes_written",p->core_22.bytes_written);
  break;
 case 23:
  slice::optional(L,"type",p->core_23.type);
  break;
 case 24:
  slice::array(L,"types",p->core_24.types);
  break;
 case 25:
  slice::array(L,"aliases",p->core_25.aliases);
  break;
 case 26:
  slice::array(L,"unions",p->core_26.unions);
  break;
 case 27:
  slice::array(L,"enums",p->core_27.enums);
  break;
 case 28:
  slice::array(L,"members",p->core_28.members);
  break;
 case 29:
  slice::array(L,"members",p->core_29.members);
  break;
 case 30:
  slice::optional(L,"signature",p->core_30.signature);
  break;
 case 31:
  slice::array(L,"signatures",p->core_31.signatures);
  break;
 case 32:
  slice::array(L,"comments",p->core_32.comments);
  break;
 case 33:
  slice::array(L,"strings",p->core_33.strings);
  break;
 case 34: field(L,"updated",p->full_34.updated); break;
 case 35: field(L,"deleted",p->full_35.deleted); break;
 case 36: field(L,"updated",p->full_36.updated); field(L,"name",p->full_36.name); break;
 case 37: field(L,"updated",p->full_37.updated); break;
 case 38: field(L,"deleted",p->full_38.deleted); break;
 case 39: field(L,"updated",p->full_39.updated); break;
 case 40: field(L,"updated",p->full_40.updated); break;
 case 41: field(L,"updated",p->full_41.updated); break;
 case 42: field(L,"deleted",p->full_42.deleted); break;
 case 43: field(L,"updated",p->full_43.updated); break;
 case 44: field(L,"updated",p->full_44.updated); break;
 case 45: field(L,"updated",p->full_45.updated); break;
 case 46: field(L,"updated",p->full_46.updated); break;
 case 47: field(L,"deleted",p->full_47.deleted); break;
 case 48: field(L,"updated",p->full_48.updated); break;
 case 49: field(L,"updated",p->full_49.updated); break;
 case 50: field(L,"updated",p->full_50.updated); break;
 case 51: field(L,"updated",p->full_51.updated); field(L,"function_name",p->full_51.function_name); field(L,"prototype",p->full_51.prototype); break;
 case 52: field(L,"updated",p->full_52.updated); field(L,"name",p->full_52.name); break;
 case 53: field(L,"updated",p->full_53.updated); field(L,"data_type",p->full_53.data_type); break;
 case 54: field(L,"updated",p->full_54.updated); field(L,"local_id",p->full_54.local_id); field(L,"name",p->full_54.name); break;
 case 55: field(L,"updated",p->full_55.updated); field(L,"local_id",p->full_55.local_id); field(L,"data_type",p->full_55.data_type); break;
 case 56: field(L,"updated",p->full_56.updated); field(L,"data_type",p->full_56.data_type); break;
 case 57: slice::array(L,"decompilations",p->full_57.decompilations); break;
 case 58: slice::array(L,"functions",p->full_58.functions); break;
 case 59: field(L,"deleted",p->full_59.deleted); field(L,"deleted_count",p->full_59.deleted_count); break;
 case 60: field(L,"updated",p->full_60.updated); break;
 case 61: field(L,"deleted",p->full_61.deleted); break;
 case 62: slice::array(L,"data_items",p->full_62.data_items); break;
 case 63: field(L,"updated",p->full_63.updated); field(L,"name",p->full_63.name); break;
 case 64: field(L,"deleted",p->full_64.deleted); break;
 case 65: field(L,"added",p->full_65.added); break;
 case 66: slice::array(L,"records",p->full_66.records); break;
 case 67: field(L,"cleared",p->full_67.cleared); field(L,"removed_count",p->full_67.removed_count); break;
 case 68: field(L,"deleted",p->full_68.deleted); break;
 case 69: field(L,"patch_count",p->full_69.patch_count); field(L,"bytes_written",p->full_69.bytes_written); break;
 case 7: slice::optional(L,"function",p->function.function); break;
 case 8: slice::array(L,"functions",p->functions.functions); break;
 case 9: slice::optional(L,"instruction",p->instruction.instruction); break;
 case 10: slice::array(L,"instructions",p->instructions.instructions); break;
 case 11: slice::optional(L,"decompilation",p->decompilation.decompilation); break;
 case 6:
  lua_pushlstring(L,reinterpret_cast<const char*>(p->bytes.data.data()),p->bytes.data.size());
  lua_setfield(L,-2,"data"); break;
 }
 return 1;
}
template<class T> bool take(Packet& p, c::StatusOr<T>&& result, T& out) {
 if (!result.status.ok()) { seterror(p,result.status.code.c_str(),result.status.message.c_str()); return false; }
 if (!result.value) { seterror(p,"NATIVE_EXCEPTION","successful response missing value"); return false; }
 out = std::move(*result.value); return true;
}
struct Text { const char* s = ""; size_t n = 0; };
bool stringfield(lua_State* L,int table,const char* key,Text* out) {
 lua_pushstring(L,key); lua_rawget(L,table);
 bool ok = lua_isnil(L,-1) || (read_text(L,-1,&out->s,&out->n) && !memchr(out->s,0,out->n));
 // Leave borrowed strings rooted across later Lua-running phases.
 return ok;
}
bool read_count_page(lua_State* L,int table,Page* page) {
 if(lua_isnoneornil(L,table)) return true;
 const char* const keys[]={"limit","offset",nullptr};
 return known_keys(L,table,keys) && read_page(L,table,page);
}
std::string copy(Text t) { return std::string(t.s,t.n); }
int construct(lua_State* L) {
 lua_settop(L,1);
 const char* const keys[] = {"ghidra_root","state_path","default_arch","pool_size",nullptr};
 Text root,state,arch; bool ok = true;
 if (!lua_isnoneornil(L,1)) {
  ok = known_keys(L,1,keys);
  if(ok) ok = stringfield(L,1,"ghidra_root",&root) && stringfield(L,1,"state_path",&state) && stringfield(L,1,"default_arch",&arch);
  if(ok) { lua_pushliteral(L,"pool_size"); lua_rawget(L,1);
   ok = lua_isnil(L,-1) || (lua_isinteger(L,-1) && lua_tointeger(L,-1)==1); lua_pop(L,1); }
 }
 if(!ok) return error(L,"local_client","invalid client options");
 luaL_checkstack(L,32,"owner stack");
 Slot* s = static_cast<Slot*>(lua_newuserdatauv(L,sizeof(Slot),0)); s->p=nullptr;
 luaL_setmetatable(L,mt); // GC ready BEFORE ownership, including partial failure.
 int rc, n;
 const int top=lua_gettop(L);
 {
  Packet p; p.op="local_client"; p.backend="binding";
  try {
   c::LocalClientOptions opts; opts.ghidra_root=copy(root); opts.state_path=copy(state); opts.default_arch=copy(arch);
   auto h = std::make_unique<Handle>();
   std::lock_guard<std::mutex> guard(process_guard().engine);
   if(process_guard().occupied) { seterror(p,"CLIENT_IN_USE","one binding-owned client per process"); }
   else { LLG_NATIVE_PHASE(0); h->has_state_path=!opts.state_path.empty(); h->client=c::CreateLocalClient(std::move(opts)); if(!h->client) throw std::runtime_error("native factory returned null"); process_guard().occupied=true; s->p=h.release(); }
  } catch(const std::exception& e) { exception(p,e.what()); }
    catch(...) { exception(p,"unknown native exception"); }
  if(s->p) return 1; // No allocating Lua API after transfer.
  lua_pushcfunction(L,convert); lua_pushlightuserdata(L,&p); rc=lua_pcall(L,1,LUA_MULTRET,0); n=lua_gettop(L);
 }
 if(rc) return lua_error(L);
 return n-top; // All borrowed strings and unpublished userdata precede results
}
struct PatchLuaError {};
struct PatchInvalid {};
struct PatchRead { std::vector<c::BytePatch>* patches; size_t count; bool failed=false; bool invalid=false; };
int read_patches(lua_State* L) {
 PatchRead* r=static_cast<PatchRead*>(lua_touserdata(L,2));
 // All Lua access has trivial locals. Native allocations are caught before
 // returning to Lua; the outer vector owns every partially copied element.
 for(size_t i=0;i<r->count;++i) {
  lua_rawgeti(L,1,i+1); int t=lua_gettop(L); uint64_t addr=0; const char* data=nullptr; size_t n=0;
  lua_pushliteral(L,"address"); lua_rawget(L,t); bool valid=read_u64(L,-1,&addr); lua_pop(L,1);
  lua_pushliteral(L,"data"); lua_rawget(L,t); valid=valid && read_text(L,-1,&data,&n) && n<=INT_MAX;
  if(!valid) { r->invalid=true; return 0; }
  bool failed=false;
  try { r->patches->push_back({addr,{}}); r->patches->back().data.assign(reinterpret_cast<const uint8_t*>(data),reinterpret_cast<const uint8_t*>(data)+n); }
  catch(...) { failed=true; }
  if(failed) { r->failed=true; return 0; }
  lua_pop(L,2);
 }
 return 0;
}

// Single dispatch primitive; parse raw options first, then reserve/revalidate,
// native phase, protected detached conversion, destroy packet, trivial rethrow.
int dispatch(lua_State* L) {
 int kind = static_cast<int>(lua_tointeger(L,lua_upvalueindex(1)));
 const char* op=operation_names[kind]; Text path,project,name,lang,compiler,format; uint64_t base=0,address=0; uint32_t size=0;
 Page page; lua_Integer timeout=30000; Text text_arg;
 double perf_numbers[6]={}; Text perf_text[4]; size_t patch_count=0;
 c::CommentKind comment_kind=c::CommentKind::kUnspecified;
 Text full_text[5]; uint64_t full_u64[5]={}; lua_Integer full_int=0; bool full_bool=false;
 bool readonly=false,ok=true; c::ShutdownPolicy policy=c::ShutdownPolicy::kDiscard;
 if(kind==1) {
  const char* const keys[]={"program_path","project_path","project_name","language_id","compiler_spec_id","format","base_address","read_only",nullptr};
  ok=known_keys(L,2,keys);
  if(ok) ok=stringfield(L,2,"program_path",&path) && stringfield(L,2,"project_path",&project) && stringfield(L,2,"project_name",&name) && stringfield(L,2,"language_id",&lang) && stringfield(L,2,"compiler_spec_id",&compiler) && stringfield(L,2,"format",&format);
  if(ok) { lua_pushliteral(L,"base_address"); lua_rawget(L,2); ok=lua_isnil(L,-1)||read_u64(L,-1,&base); lua_pop(L,1); }
  if(ok) { lua_pushliteral(L,"read_only"); lua_rawget(L,2); ok=lua_isnil(L,-1)||read_boolean(L,-1,&readonly); lua_pop(L,1); }
  ok=ok && (path.n || project.n);
 } else if(kind==2 || kind==3) {
  const char* const keys[]={"policy",nullptr}; Text t;
  ok=known_keys(L,2,keys) && stringfield(L,2,"policy",&t);
  if(ok && t.n==4 && !memcmp(t.s,"save",4)) policy=c::ShutdownPolicy::kSave;
  else if(!(ok && t.n==7 && !memcmp(t.s,"discard",7))) ok=false;
 } else if(kind==6) ok=read_u64(L,2,&address) && read_size(L,3,&size);
 if(kind==7 || kind==9 || kind==11) ok=read_u64(L,2,&address);
 if(kind==8 || kind==10) ok=read_page(L,2,&page);
 if(kind==11 && ok && !lua_isnoneornil(L,3)) {
  const char* const keys[]={"timeout_ms",nullptr};
  ok=known_keys(L,3,keys);
  if(ok) { lua_pushliteral(L,"timeout_ms"); lua_rawget(L,3);
   ok=lua_isnil(L,-1)||read_integer(L,-1,0,INT_MAX,&timeout); lua_pop(L,1); }
 }

 if(kind==14 || kind==19 || kind==22) {
  ok=read_u64(L,2,&address) && read_text(L,3,&text_arg.s,&text_arg.n);
  if(kind==22 && text_arg.n>INT_MAX) ok=false;
 }
 if(kind==17 || kind==30) ok=read_u64(L,2,&address);
 if(kind==23) ok=read_text(L,2,&text_arg.s,&text_arg.n);
 if((kind>=24 && kind<=29) || kind==21) {
  const int opt=kind==21?2:3;
  if(kind!=21) ok=read_text(L,2,&text_arg.s,&text_arg.n);
  if(ok) ok=read_count_page(L,opt,&page);
 }
 if(kind==15 || kind==16 || kind==18 || kind==20 || kind==31 || kind==32 || kind==33)
  ok=read_page(L,2,&page);
 if(kind==34) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_text(L,3,&full_text[2].s,&full_text[2].n) && read_u64(L,4,&full_u64[3]);
 if(kind==35) ok=read_text(L,2,&full_text[1].s,&full_text[1].n);
 if(kind==36) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_text(L,3,&full_text[2].s,&full_text[2].n);
 if(kind==37) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_text(L,3,&full_text[2].s,&full_text[2].n);
 if(kind==38) ok=read_text(L,2,&full_text[1].s,&full_text[1].n);
 if(kind==39) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_text(L,3,&full_text[2].s,&full_text[2].n);
 if(kind==40) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_u64(L,3,&full_u64[2]) && read_boolean(L,4,&full_bool);
 if(kind==41) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_text(L,3,&full_text[2].s,&full_text[2].n) && read_integer(L,4,LUA_MININTEGER,LUA_MAXINTEGER,&full_int);
 if(kind==42) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_u64(L,3,&full_u64[2]);
 if(kind==43) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_u64(L,3,&full_u64[2]) && read_text(L,4,&full_text[3].s,&full_text[3].n);
 if(kind==44) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_u64(L,3,&full_u64[2]) && read_integer(L,4,LUA_MININTEGER,LUA_MAXINTEGER,&full_int);
 if(kind==45) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_u64(L,3,&full_u64[2]) && read_text(L,4,&full_text[3].s,&full_text[3].n);
 if(kind==46) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_text(L,3,&full_text[2].s,&full_text[2].n) && read_text(L,4,&full_text[3].s,&full_text[3].n) && read_u64(L,5,&full_u64[4]);
 if(kind==47) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_u64(L,3,&full_u64[2]);
 if(kind==48) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_u64(L,3,&full_u64[2]) && read_text(L,4,&full_text[3].s,&full_text[3].n);
 if(kind==49) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_u64(L,3,&full_u64[2]) && read_text(L,4,&full_text[3].s,&full_text[3].n);
 if(kind==50) ok=read_text(L,2,&full_text[1].s,&full_text[1].n) && read_u64(L,3,&full_u64[2]) && read_text(L,4,&full_text[3].s,&full_text[3].n);
 if(kind==51) ok=read_u64(L,2,&full_u64[1]) && read_text(L,3,&full_text[2].s,&full_text[2].n);
 if(kind==52) ok=read_u64(L,2,&full_u64[1]) && read_integer(L,3,0,INT_MAX,&full_int) && read_text(L,4,&full_text[3].s,&full_text[3].n);
 if(kind==53) ok=read_u64(L,2,&full_u64[1]) && read_integer(L,3,0,INT_MAX,&full_int) && read_text(L,4,&full_text[3].s,&full_text[3].n);
 if(kind==54) ok=read_u64(L,2,&full_u64[1]) && read_text(L,3,&full_text[2].s,&full_text[2].n) && read_text(L,4,&full_text[3].s,&full_text[3].n);
 if(kind==55) ok=read_u64(L,2,&full_u64[1]) && read_text(L,3,&full_text[2].s,&full_text[2].n) && read_text(L,4,&full_text[3].s,&full_text[3].n);
 if(kind==56) ok=read_u64(L,2,&full_u64[1]) && read_text(L,3,&full_text[2].s,&full_text[2].n);
 if(kind==57 || kind==58 || kind==62) ok=read_page(L,2,&page);
 if(kind==57 && ok && !lua_isnoneornil(L,3)) {
  const char* const keys[]={"timeout_ms",nullptr};
  ok=known_keys(L,3,keys);
  if(ok) { lua_pushliteral(L,"timeout_ms"); lua_rawget(L,3);
   ok=lua_isnil(L,-1)||read_integer(L,-1,0,INT_MAX,&timeout); lua_pop(L,1); }
 }
 if(kind==59 || kind==63) ok=read_u64(L,2,&address) && read_text(L,3,&text_arg.s,&text_arg.n);
 if(kind==64) ok=read_u64(L,2,&address);
 if(kind==60 || kind==61) {
  ok=read_u64(L,2,&address) && read_text(L,3,&full_text[1].s,&full_text[1].n);
  const char* names[]={"unspecified","eol","pre","post","plate","repeatable"};
  bool found=false;
  if(ok) for(int i=0;i<6;++i) if(full_text[1].n==strlen(names[i]) && !memcmp(full_text[1].s,names[i],full_text[1].n)) { comment_kind=static_cast<c::CommentKind>(i); found=true; }
  ok=ok && found;
  if(kind==60) ok=ok && read_text(L,4,&text_arg.s,&text_arg.n);
 }
 if(kind==65) {
  const char* const keys[]={"bench_id","query_family","dataset_profile","status","cold_ms_p50","cold_ms_p95","warm_ms_p50","warm_ms_p95","throughput_qps","regression_pct",nullptr};
  ok=known_keys(L,2,keys);
  for(int i=0;ok && i<4;++i) {
   lua_pushstring(L,keys[i]); lua_rawget(L,2);
   ok=lua_isnil(L,-1) || read_text(L,-1,&perf_text[i].s,&perf_text[i].n);
  }
  for(int i=0;ok && i<6;++i) {
   lua_pushstring(L,keys[i+4]); lua_rawget(L,2);
   if(!lua_isnil(L,-1)) { ok=lua_type(L,-1)==LUA_TNUMBER; if(ok) { perf_numbers[i]=lua_tonumber(L,-1); ok=std::isfinite(perf_numbers[i]); } }
   lua_pop(L,1);
  }
 }
 if(kind==68) ok=read_text(L,2,&text_arg.s,&text_arg.n);
 if(kind==69) {
  ok=lua_istable(L,2); uint64_t total=0;
  if(ok) {
   patch_count=lua_rawlen(L,2); ok=patch_count<=UINT32_MAX;
   lua_pushnil(L);
   while(lua_next(L,2)) {
    if(!lua_isinteger(L,-2) || lua_tointeger(L,-2)<1 || static_cast<uint64_t>(lua_tointeger(L,-2))>patch_count) ok=false;
    lua_pop(L,1);
   }
   const char* const keys[]={"address","data",nullptr};
   for(size_t i=0;ok && i<patch_count;++i) {
    lua_rawgeti(L,2,i+1); int t=lua_gettop(L); uint64_t addr=0; Text data;
    ok=known_keys(L,t,keys);
    if(ok) { lua_pushliteral(L,"address"); lua_rawget(L,t); ok=read_u64(L,-1,&addr); lua_pop(L,1); }
    if(ok) { lua_pushliteral(L,"data"); lua_rawget(L,t); ok=read_text(L,-1,&data.s,&data.n) && data.n<=INT_MAX; total+=data.n; ok=ok && total<=UINT32_MAX; lua_pop(L,1); }
    lua_pop(L,1);
   }
  }
 }
 if(!ok) return error(L,op,"invalid operation arguments");
#ifdef LLG_READ_OBSERVER
 if(kind==6) observe_read_phase(0,size); // validated, before native request/lock
#endif
 luaL_checkstack(L,32,"dispatch stack");
#ifdef LLG_REENTRY_OBSERVER
 before_owner_recheck(L); // test-only deterministic GC at the recheck edge
#endif
 Slot* s=slot(L); // Revalidate AFTER all Lua-running parsing/stack growth.
 int top=lua_gettop(L),rc,n;
 {
  Packet p; p.op=op; p.kind=kind;
  try {
   std::vector<c::BytePatch> patches;
   if(kind==69) {
    PatchRead read{&patches,patch_count};
    lua_pushcfunction(L,read_patches); lua_pushvalue(L,2); lua_pushlightuserdata(L,&read);
    int result=lua_pcall(L,2,0,0);
    if(result) { rc=result; n=1; throw PatchLuaError{}; }
    if(read.failed) throw std::bad_alloc();
    if(read.invalid) { seterror(p,"INVALID_ARGUMENT","batch changed during parsing"); p.backend="binding"; throw PatchInvalid{}; }
    s=slot(L); // batch parsing may run finalizers; recheck before native access
   }
   c::PerfBenchmarkRecord perf;
   if(kind==65) {
    perf.bench_id=copy(perf_text[0]); perf.query_family=copy(perf_text[1]); perf.dataset_profile=copy(perf_text[2]); perf.status=copy(perf_text[3]);
    perf.cold_ms_p50=perf_numbers[0]; perf.cold_ms_p95=perf_numbers[1]; perf.warm_ms_p50=perf_numbers[2]; perf.warm_ms_p95=perf_numbers[3]; perf.throughput_qps=perf_numbers[4]; perf.regression_pct=perf_numbers[5];
   }
   std::string full_strings[5];
   if(kind>=34 && kind<=56) for(int i=1;i<5;++i) full_strings[i]=copy(full_text[i]);
   if(kind==59 || kind==60 || kind==63 || kind==68) full_strings[0]=copy(text_arg);
   c::OpenProgramRequest request;
   std::vector<uint8_t> write_data;
   std::string request_text;
   if(kind==14 || kind==19 || (kind>=23 && kind<=29)) request_text=copy(text_arg);
   if(kind==22) write_data.assign(reinterpret_cast<const uint8_t*>(text_arg.s),reinterpret_cast<const uint8_t*>(text_arg.s)+text_arg.n);
   if(kind==1) { request.program_path=copy(path); request.project_path=copy(project); request.project_name=copy(name); request.language_id=copy(lang); request.compiler_spec_id=copy(compiler); request.format=copy(format); request.base_address=base; request.read_only=readonly; }
   std::lock_guard<std::mutex> guard(process_guard().engine);
   if(!s || !s->p || !s->p->client) { seterror(p,"CLOSED","owner closed"); p.backend="binding"; }
   else {
    LLG_NATIVE_PHASE(1);
    c::IClient* client=s->p->client.get();
    if(kind==1 || kind==2 || kind==3 || kind==12 || kind==13 || kind==14 || kind==19 || kind==22 || (kind>=34 && kind<=56) || kind==59 || kind==60 || kind==61 || kind==63 || kind==64 || kind==65 || kind==67 || kind==68 || kind==69) ++s->p->generation;
#ifdef LLG_ADAPTER_OBSERVER
    before_adapter_dispatch(kind); // test-only: exception across native boundary
#endif
    switch(kind) {
     case 34: take(p,client->CreateType(full_strings[1],full_strings[2],full_u64[3]),p.full_34); break;
     case 35: take(p,client->DeleteType(full_strings[1]),p.full_35); break;
     case 36: take(p,client->RenameType(full_strings[1],full_strings[2]),p.full_36); break;
     case 37: take(p,client->CreateTypeAlias(full_strings[1],full_strings[2]),p.full_37); break;
     case 38: take(p,client->DeleteTypeAlias(full_strings[1]),p.full_38); break;
     case 39: take(p,client->SetTypeAliasTarget(full_strings[1],full_strings[2]),p.full_39); break;
     case 40: take(p,client->CreateTypeEnum(full_strings[1],full_u64[2],full_bool),p.full_40); break;
     case 41: take(p,client->AddTypeEnumMember(full_strings[1],full_strings[2],full_int),p.full_41); break;
     case 42: take(p,client->DeleteTypeEnumMember(full_strings[1],full_u64[2]),p.full_42); break;
     case 43: take(p,client->RenameTypeEnumMember(full_strings[1],full_u64[2],full_strings[3]),p.full_43); break;
     case 44: take(p,client->SetTypeEnumMemberValue(full_strings[1],full_u64[2],full_int),p.full_44); break;
     case 45: take(p,client->SetTypeEnumMemberComment(full_strings[1],full_u64[2],full_strings[3]),p.full_45); break;
     case 46: take(p,client->AddTypeMember(full_strings[1],full_strings[2],full_strings[3],full_u64[4]),p.full_46); break;
     case 47: take(p,client->DeleteTypeMember(full_strings[1],full_u64[2]),p.full_47); break;
     case 48: take(p,client->RenameTypeMember(full_strings[1],full_u64[2],full_strings[3]),p.full_48); break;
     case 49: take(p,client->SetTypeMemberType(full_strings[1],full_u64[2],full_strings[3]),p.full_49); break;
     case 50: take(p,client->SetTypeMemberComment(full_strings[1],full_u64[2],full_strings[3]),p.full_50); break;
     case 51: take(p,client->SetFunctionSignature(full_u64[1],full_strings[2]),p.full_51); break;
     case 52: take(p,client->RenameFunctionParameter(full_u64[1],full_int,full_strings[3]),p.full_52); break;
     case 53: take(p,client->SetFunctionParameterType(full_u64[1],full_int,full_strings[3]),p.full_53); break;
     case 54: take(p,client->RenameFunctionLocal(full_u64[1],full_strings[2],full_strings[3]),p.full_54); break;
     case 55: take(p,client->SetFunctionLocalType(full_u64[1],full_strings[2],full_strings[3]),p.full_55); break;
     case 56: take(p,client->ApplyDataType(full_u64[1],full_strings[2]),p.full_56); break;
     case 57: take(p,client->ListDecompilations(page.start,page.end,page.limit,page.offset,static_cast<int>(timeout)),p.full_57); break;
     case 58: take(p,client->ListLeafFunctions(page.start,page.end,page.limit,page.offset),p.full_58); break;
     case 59: take(p,client->DeleteSymbol(address,full_strings[0]),p.full_59); break;
     case 60: take(p,client->SetComment(address,comment_kind,full_strings[0]),p.full_60); break;
     case 61: take(p,client->DeleteComment(address,comment_kind),p.full_61); break;
     case 62: take(p,client->ListDataItems(page.start,page.end,page.limit,page.offset),p.full_62); break;
     case 63: take(p,client->RenameDataItem(address,full_strings[0]),p.full_63); break;
     case 64: take(p,client->DeleteDataItem(address),p.full_64); break;
     case 65: take(p,client->AddPerfBenchmark(perf),p.full_65); break;
     case 66: take(p,client->ListPerfBenchmarks(),p.full_66); break;
     case 67: take(p,client->ClearPerfBenchmarks(),p.full_67); break;
     case 68: take(p,client->DeletePerfBenchmark(full_strings[0]),p.full_68); break;
     case 69: take(p,client->PatchBytesBatch(patches),p.full_69); break;
     case 12: take(p,client->SaveProgram(),p.core_12); break;
     case 13: take(p,client->DiscardProgram(),p.core_13); break;
     case 14: take(p,client->RenameFunction(address,request_text),p.core_14); break;
     case 15: take(p,client->ListBasicBlocks(page.start,page.end,page.limit,page.offset),p.core_15); break;
     case 16: take(p,client->ListCFGEdges(page.start,page.end,page.limit,page.offset),p.core_16); break;
     case 17: take(p,client->GetSymbol(address),p.core_17); break;
     case 18: take(p,client->ListSymbols(page.start,page.end,page.limit,page.offset),p.core_18); break;
     case 19: take(p,client->RenameSymbol(address,request_text),p.core_19); break;
     case 20: take(p,client->ListXrefs(page.start,page.end,page.limit,page.offset),p.core_20); break;
     case 21: take(p,client->ListMemoryBlocks(page.limit,page.offset),p.core_21); break;
     case 22: take(p,client->WriteBytes(address,write_data),p.core_22); break;
     case 23: take(p,client->GetType(request_text),p.core_23); break;
     case 24: take(p,client->ListTypes(request_text,page.limit,page.offset),p.core_24); break;
     case 25: take(p,client->ListTypeAliases(request_text,page.limit,page.offset),p.core_25); break;
     case 26: take(p,client->ListTypeUnions(request_text,page.limit,page.offset),p.core_26); break;
     case 27: take(p,client->ListTypeEnums(request_text,page.limit,page.offset),p.core_27); break;
     case 28: take(p,client->ListTypeEnumMembers(request_text,page.limit,page.offset),p.core_28); break;
     case 29: take(p,client->ListTypeMembers(request_text,page.limit,page.offset),p.core_29); break;
     case 30: take(p,client->GetFunctionSignature(address),p.core_30); break;
     case 31: take(p,client->ListFunctionSignatures(page.start,page.end,page.limit,page.offset),p.core_31); break;
     case 32: take(p,client->GetComments(page.start,page.end,page.limit,page.offset),p.core_32); break;
     case 33: take(p,client->ListDefinedStrings(page.start,page.end,page.limit,page.offset),p.core_33); break;
     case 7: take(p,client->GetFunction(address),p.function); break;
     case 8: take(p,client->ListFunctions(page.start,page.end,page.limit,page.offset),p.functions); break;
     case 9: take(p,client->GetInstruction(address),p.instruction); break;
     case 10: take(p,client->ListInstructions(page.start,page.end,page.limit,page.offset),p.instructions); break;
     case 11: take(p,client->GetDecompilation(address,static_cast<int>(timeout)),p.decompilation); break;
     case 0: take(p,client->GetStatus(),p.health); break;
     case 1: if(take(p,client->OpenProgram(request),p.opened)) {
#ifdef LLG_CORE_FIXTURE
      seed_core_fixture(client); // test-only native fixture setup; no Lua calls
#endif
     } break;
     case 2: { c::CloseProgramResponse r; if(take(p,client->CloseProgram(policy),r)) p.flag=r.closed; break; }
     case 3: { c::ShutdownResponse r; if(take(p,client->Shutdown(policy),r)) p.flag=r.accepted; break; }
     case 4: take(p,client->GetRevision(),p.revision); break;
     case 5: take(p,client->GetCapabilities(),p.capabilities); break;
     case 6:
#ifdef LLG_READ_OBSERVER
      observe_read_phase(1,size); // immediately before SDK invocation
#endif
      take(p,client->ReadBytes(address,size),p.bytes); break;
    }
   }
  } catch(const PatchInvalid&) {}
  catch(const PatchLuaError&) { p.lua_error_pending=true; }
  catch(const std::exception& e) { exception(p,e.what()); p.backend="binding"; }
    catch(...) { exception(p,"unknown native exception"); p.backend="binding"; }
  if(!p.lua_error_pending) { lua_pushcfunction(L,convert); lua_pushlightuserdata(L,&p); rc=lua_pcall(L,1,LUA_MULTRET,0); n=lua_gettop(L)-top; }
 }
 if(rc) return lua_error(L);
 return n;
}
void fn(lua_State* L,const char* name,lua_CFunction f) { lua_pushcfunction(L,f); lua_setfield(L,-2,name); }
}
void owner_module(lua_State* L) {
 luaL_newmetatable(L,mt);
 fn(L,"__gc",gc); fn(L,"__close",close); fn(L,"close",close); fn(L,"_generation",generation); fn(L,"_generation_matches",generation_matches); fn(L,"_has_state_path",has_state_path);
 for(int i=0;i<static_cast<int>(sizeof(operation_names)/sizeof(*operation_names));++i) { lua_pushinteger(L,i); lua_pushcclosure(L,dispatch,1); lua_setfield(L,-2,operation_names[i]); }
 lua_pushvalue(L,-1); lua_setfield(L,-2,"__index");
 lua_pushliteral(L,"native owner"); lua_setfield(L,-2,"__metatable"); lua_pop(L,1);
 fn(L,"local_client",construct);
}
}
