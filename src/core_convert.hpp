// MIT Copyright 2026 Salvador Fandiño.
// Explicit detached converters; borrowed references only beneath Packet pcall.
#pragma once
#include "slice_convert.hpp"
namespace llg::slice {
inline void value(lua_State* L,const c::BasicBlockRecord& v) {
 lua_createtable(L,0,16);
 field(L,"function_entry",v.function_entry);
 field(L,"start_address",v.start_address);
 field(L,"end_address",v.end_address);
 field(L,"in_degree",v.in_degree);
 field(L,"out_degree",v.out_degree);
}
inline void value(lua_State* L,const c::CFGEdgeRecord& v) {
 lua_createtable(L,0,16);
 field(L,"function_entry",v.function_entry);
 field(L,"src_block_start",v.src_block_start);
 field(L,"dst_block_start",v.dst_block_start);
 field(L,"edge_kind",v.edge_kind);
}
inline void value(lua_State* L,const c::SymbolRecord& v) {
 lua_createtable(L,0,16);
 field(L,"symbol_id",v.symbol_id);
 field(L,"address",v.address);
 field(L,"name",v.name);
 field(L,"full_name",v.full_name);
 field(L,"type",v.type);
 field(L,"namespace_name",v.namespace_name);
 field(L,"source",v.source);
 field(L,"is_primary",v.is_primary);
 field(L,"is_external",v.is_external);
 field(L,"is_dynamic",v.is_dynamic);
 field(L,"is_external_entry_point",v.is_external_entry_point);
}
inline void value(lua_State* L,const c::XrefRecord& v) {
 lua_createtable(L,0,16);
 field(L,"from_address",v.from_address);
 field(L,"to_address",v.to_address);
 field(L,"operand_index",v.operand_index);
 field(L,"ref_type",v.ref_type);
 field(L,"is_primary",v.is_primary);
 field(L,"source",v.source);
 field(L,"symbol_id",v.symbol_id);
 field(L,"is_external",v.is_external);
 field(L,"is_memory",v.is_memory);
 field(L,"is_flow",v.is_flow);
 field(L,"from_function_address",v.from_function_address);
 field(L,"from_function_name",v.from_function_name);
 field(L,"to_function_address",v.to_function_address);
 field(L,"to_function_name",v.to_function_name);
}
inline void value(lua_State* L,const c::MemoryBlockRecord& v) {
 lua_createtable(L,0,16);
 field(L,"name",v.name);
 field(L,"start_address",v.start_address);
 field(L,"end_address",v.end_address);
 field(L,"size",v.size);
 field(L,"is_read",v.is_read);
 field(L,"is_write",v.is_write);
 field(L,"is_execute",v.is_execute);
 field(L,"is_volatile",v.is_volatile);
 field(L,"is_initialized",v.is_initialized);
 field(L,"source_name",v.source_name);
 field(L,"comment",v.comment);
}
inline void value(lua_State* L,const c::TypeRecord& v) {
 lua_createtable(L,0,16);
 field(L,"type_id",v.type_id);
 field(L,"name",v.name);
 field(L,"path_name",v.path_name);
 field(L,"category_path",v.category_path);
 field(L,"display_name",v.display_name);
 field(L,"kind",v.kind);
 field(L,"length",v.length);
 field(L,"is_not_yet_defined",v.is_not_yet_defined);
 field(L,"source_archive",v.source_archive);
 field(L,"universal_id",v.universal_id);
}
inline void value(lua_State* L,const c::TypeAliasRecord& v) {
 lua_createtable(L,0,16);
 field(L,"type_id",v.type_id);
 field(L,"path_name",v.path_name);
 field(L,"name",v.name);
 field(L,"target_type",v.target_type);
 field(L,"declaration",v.declaration);
}
inline void value(lua_State* L,const c::TypeUnionRecord& v) {
 lua_createtable(L,0,16);
 field(L,"type_id",v.type_id);
 field(L,"path_name",v.path_name);
 field(L,"name",v.name);
 field(L,"size",v.size);
 field(L,"declaration",v.declaration);
}
inline void value(lua_State* L,const c::TypeEnumRecord& v) {
 lua_createtable(L,0,16);
 field(L,"type_id",v.type_id);
 field(L,"path_name",v.path_name);
 field(L,"name",v.name);
 field(L,"width",v.width);
 field(L,"is_signed",v.is_signed);
 field(L,"declaration",v.declaration);
}
inline void value(lua_State* L,const c::TypeEnumMemberRecord& v) {
 lua_createtable(L,0,16);
 field(L,"type_id",v.type_id);
 field(L,"type_path_name",v.type_path_name);
 field(L,"type_name",v.type_name);
 field(L,"ordinal",v.ordinal);
 field(L,"name",v.name);
 field(L,"value",v.value);
 field(L,"comment",v.comment);
}
inline void value(lua_State* L,const c::TypeMemberRecord& v) {
 lua_createtable(L,0,16);
 field(L,"parent_type_id",v.parent_type_id);
 field(L,"parent_type_path_name",v.parent_type_path_name);
 field(L,"parent_type_name",v.parent_type_name);
 field(L,"ordinal",v.ordinal);
 field(L,"name",v.name);
 field(L,"member_type",v.member_type);
 field(L,"offset",v.offset);
 field(L,"size",v.size);
 field(L,"comment",v.comment);
}
inline void value(lua_State* L,const c::ParameterRecord& v) {
 lua_createtable(L,0,16);
 field(L,"ordinal",v.ordinal);
 field(L,"name",v.name);
 field(L,"data_type",v.data_type);
 field(L,"formal_data_type",v.formal_data_type);
 field(L,"is_auto_parameter",v.is_auto_parameter);
 field(L,"is_forced_indirect",v.is_forced_indirect);
}
inline void value(lua_State* L,const c::FunctionSignatureRecord& v) {
 lua_createtable(L,0,16);
 field(L,"function_entry_address",v.function_entry_address);
 field(L,"function_name",v.function_name);
 field(L,"prototype",v.prototype);
 field(L,"return_type",v.return_type);
 field(L,"has_var_args",v.has_var_args);
 field(L,"calling_convention",v.calling_convention);
 array(L,"parameters",v.parameters);
}
inline void value(lua_State* L,const c::CommentRecord& v) {
 lua_createtable(L,0,16);
 field(L,"address",v.address);
 const char* names[]={"unspecified","eol","pre","post","plate","repeatable"};
 if(int(v.kind)>=0 && int(v.kind)<6) lua_pushstring(L,names[int(v.kind)]);
 else lua_pushinteger(L,int(v.kind));
 lua_setfield(L,-2,"kind");
 field(L,"text",v.text);
}
inline void value(lua_State* L,const c::DefinedStringRecord& v) {
 lua_createtable(L,0,16);
 field(L,"address",v.address);
 field(L,"value",v.value);
 field(L,"length",v.length);
 field(L,"data_type",v.data_type);
 field(L,"encoding",v.encoding);
}
}
