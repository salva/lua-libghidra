// MIT Copyright 2026 Salvador Fandiño.
// Borrowed native records only; all frames remain trivial beneath pcall.
#pragma once
#include "boundary.hpp"
#include <libghidra/models.hpp>
namespace llg::slice {
namespace c = libghidra::client;
inline void value(lua_State*,const c::BasicBlockRecord&);
inline void value(lua_State*,const c::CFGEdgeRecord&);
inline void value(lua_State*,const c::SymbolRecord&);
inline void value(lua_State*,const c::XrefRecord&);
inline void value(lua_State*,const c::MemoryBlockRecord&);
inline void value(lua_State*,const c::TypeRecord&);
inline void value(lua_State*,const c::TypeAliasRecord&);
inline void value(lua_State*,const c::TypeUnionRecord&);
inline void value(lua_State*,const c::TypeEnumRecord&);
inline void value(lua_State*,const c::TypeEnumMemberRecord&);
inline void value(lua_State*,const c::TypeMemberRecord&);
inline void value(lua_State*,const c::ParameterRecord&);
inline void value(lua_State*,const c::FunctionSignatureRecord&);
inline void value(lua_State*,const c::CommentRecord&);
inline void value(lua_State*,const c::DefinedStringRecord&);

inline void value(lua_State* L,const c::FunctionRecord& v) {
 lua_createtable(L,0,10);
#define F(x) field(L,#x,v.x)
 F(entry_address); F(name); F(start_address); F(end_address); F(size);
 F(namespace_name); F(prototype); F(is_thunk); F(parameter_count);
}
inline void value(lua_State* L,const c::InstructionRecord& v) {
 lua_createtable(L,0,5); F(address); F(mnemonic); F(operand_text); F(disassembly); F(length);
}
inline void value(lua_State* L,const c::DecompileLocalRecord& v) {
 lua_createtable(L,0,7); F(local_id); F(name); F(data_type); F(storage); F(ordinal);
 const char* names[]={"unspecified","param","local","temp"};
 if(int(v.kind)>=0 && int(v.kind)<4) lua_pushstring(L,names[int(v.kind)]);
 else lua_pushinteger(L,int(v.kind));
 lua_setfield(L,-2,"kind");
}
inline void value(lua_State* L,const c::DecompileTokenRecord& v) {
 lua_createtable(L,0,8); F(text); F(line_number); F(column_offset); F(var_name); F(var_type); F(var_storage);
 const char* names[]={"unspecified","keyword","comment","type","function","variable","const","parameter","global","default","error","special"};
 if(int(v.kind)>=0 && int(v.kind)<12) lua_pushstring(L,names[int(v.kind)]);
 else lua_pushinteger(L,int(v.kind));
 lua_setfield(L,-2,"kind");
}
template<class T> void array(lua_State* L,const char* key,const std::vector<T>& records) {
 lua_createtable(L,static_cast<int>(records.size()),0);
 for(size_t i=0;i<records.size();++i) { value(L,records[i]); lua_rawseti(L,-2,i+1); }
 lua_setfield(L,-2,key);
}
inline void value(lua_State* L,const c::DecompilationRecord& v) {
 lua_createtable(L,0,10); F(function_entry_address); F(function_name); F(prototype); F(pseudocode);
 F(completed); F(is_fallback); F(error_message); array(L,"locals",v.locals); array(L,"tokens",v.tokens);
}
#undef F
template<class T> void optional(lua_State* L,const char* key,const std::optional<T>& v) {
 if(v) { value(L,*v); lua_setfield(L,-2,key); }
}
}
