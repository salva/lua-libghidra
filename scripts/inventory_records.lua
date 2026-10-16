-- MIT Copyright 2026 Salvador Fandiño. Per-producer field/default accounting.
local S=require('inventory_source')
local M={}
local common={name='native datatype name',path_name='synthetic slash+name, not lookup/category proof'}
local function extend(base,extra) local r={}; for k,v in pairs(base) do r[k]=v end; for k,v in pairs(extra) do r[k]=v end; return r end
local details=extend(common,{display_name='native display name',kind='metatype_to_kind string, not independently detected',length='signed native size including unknown sentinel'})
local counter='filtered zero-based counter before paging, restarts each request, not durable ID'
local contracts={
 listFunctions={'FunctionRecord',{entry_address='mapped FunctionSymbol entry',start_address='same mapped entry, not body minimum',name='symbol name',size='gap to next strictly greater unfiltered function entry; last/nonincreasing fallback footprint or zero, not measured body',end_address='inclusive start+size-1 or start; uint64 wrap possible'}},
 getFunction={'FunctionRecord',{entry_address='Funcdata entry or requested fallback address',start_address='returned entry, not measured minimum',name='Funcdata or fallback symbol name',size='Funcdata size or positive consumed footprint; differs from listing gap',end_address='inclusive start+size-1 or start, wrap possible'}},
 listSymbols={'SymbolRecord',{symbol_id=counter,address='mapped address, not dynamic hash',name='symbol name',full_name='same name, not namespace expansion',is_primary='literal true, not detected distinction',type='function dynamic cast else label'}},
 getSymbol={'SymbolRecord',{address='requested address after lookup, not map-entry start',name='found name',full_name='same name, no qualification',is_primary='literal true',type='function dynamic cast else label'}},
 getInstruction={'InstructionRecord',{address='requested decode address, scan advances previous length',mnemonic='printAssembly mnemonic',operand_text='printAssembly body, may empty',disassembly='mnemonic then single space/body only if nonempty',length='positive int4 print result cast uint32; <=0 absent'}},
 listMemoryBlocks={'MemoryBlockRecord',{name='default code-space name not segment label',start_address='literal zero',end_address='code-space highest inclusive',size='highest+1 uint64 may wrap zero',is_read='literal true',is_execute='literal true',is_initialized='literal true',source_name='literal raw not source filename'}},
 getType={'TypeRecord',extend(details,{type_id='literal zero, not resolved ID'})},
 listTypes={'TypeRecord',extend(details,{type_id=counter})},
 listTypeAliases={'TypeAliasRecord',extend(common,{type_id=counter,target_type='typedef target name',declaration='typedef target alias without semicolon/general declarator fidelity'})},
 listTypeEnums={'TypeEnumRecord',extend(common,{type_id=counter,width='native size bytes to uint64, negative modulo; signedness not inferred'})},
 listTypeUnions={'TypeUnionRecord',extend(common,{type_id=counter,size='native signed size to uint64 modulo, not layout measurement'})},
 listTypeMembers={'TypeMemberRecord',{parent_type_name='resolved struct name only, not unions',parent_type_path_name='synthetic slash+name',ordinal=counter,name='field name',member_type='datatype name not canonical ID/declaration',offset='signed field offset, no compaction',size='datatype size to uint64 modulo, not requested size',comment='normalized requested name/current ordinal side-map value else empty; not native metadata'}},
 listTypeEnumMembers={'TypeEnumMemberRecord',{type_name='resolved enum name',type_path_name='synthetic slash+name',ordinal=counter,name='enum name-map entry, ordering may change on rebuild',value='uint64->int64 implementation-defined above INT64_MAX in C++ profile, boundary roundtrip separately qualified',comment='normalized name/current ordinal side-map or empty; no remap'}},
}
local checks={listFunctions={'size = fns[i + 1].addr - fns[i].addr'},listSymbols={'rec.symbol_id = id_counter++'},listMemoryBlocks={'rec.size = rec.end_address + 1'},listTypeAliases={'rec.declaration = "typedef " + target->getName() + " " + dt->getName()'},getType={'rec.type_id = 0'},getInstruction={'if (!emit.body.empty())'},listTypeMembers={'rec.offset = fit->offset','rec.size = fit->type->getSize()'},listTypeEnumMembers={'rec.value = static_cast<std::int64_t>(eit->first)'}}
local function has(c,x) assert(c:find(x,1,true),'record producer missing '..x) end
local function account(code,variable,semantics,model)
 local actual={}; for f in code:gmatch('%f[%w_]'..variable..'%.([%w_]+)%s*=') do actual[f]=true end
 for f in code:gmatch('%f[%w_]'..variable..'%.([%w_]+)%.push_back%(') do actual[f]=true end
 for f in pairs(actual) do assert(semantics[f],'unreviewed record assignment '..f) end
 local declared={}; for _,f in ipairs(model.fields) do declared[f.name]=f.native_default end
 local defaults={}; for f,v in pairs(declared) do if not actual[f] then defaults[f]=v end end
 for f in pairs(semantics) do assert(actual[f] and declared[f],'missing declared record assignment '..f) end
 return defaults
end
function M.review(adapter,types,fingerprint)
 local out={}
 for method,c in pairs(contracts) do
  local start,text=S.body(adapter,'ArchAdapter::'..method..'('); local code=S.mask(text,false)
  for _,t in ipairs(checks[method] or {}) do has(code,t) end
  if method=='listTypes' or method=='listTypeEnums' or method=='listTypeAliases' or method=='listTypeUnions' then has(code,'rec.type_id = id_counter++') end
  if method=='listTypeMembers' or method=='listTypeEnumMembers' then for _,t in ipairs{'rec.ordinal = ordinal;','ordinal++;','find({type_name, ordinal})','rec.comment = cit->second'} do has(code,t) end end
  local _,line=adapter:sub(1,start-1):gsub('\n',''); local r={path='cpp/src/local_arch_adapter.cpp',line=line+1,method=method,model=c[1],fields=c[2],default_only=account(code,'rec',c[2],assert(types[c[1]])),qualification='source fields/defaults only; retain independent runtime evidence'}
  if fingerprint then r.body_sha256=fingerprint(text) end; out[method]=r
 end
 local start,text=S.body(adapter,'ArchAdapter::getFunctionSignature('); local code=S.mask(text,false)
 for _,t in ipairs{'ret_type ? ret_type->getName() : "void"','pt ? pt->getName() : "undefined"','prec.formal_data_type = prec.data_type','if (rec.has_var_args)','if (num_params > 0)','rec.calling_convention = proto.getModelName()'} do has(code,t) end
 local signature={function_entry_address='requested address after queryFunction, not normalized entry',function_name='Funcdata name',has_var_args='native dotdotdot',return_type='output datatype name else void',calling_convention='separate proto model name, not encoded in prototype',parameters='native traversal order, signed zero-based ordinal not Lua index',prototype='return/name/parameter name+type/varargs reconstruction, not calling convention/general declarator fidelity'}
 local param={ordinal='signed int4 native index',name='native parameter name',data_type='datatype name else undefined',formal_data_type='copied data_type, not independent formal extraction'}
 for model,c in pairs{FunctionSignatureRecord={'rec',signature},ParameterRecord={'prec',param}} do
  local _,line=adapter:sub(1,start-1):gsub('\n',''); local r={path='cpp/src/local_arch_adapter.cpp',line=line+1,method='getFunctionSignature',model=model,fields=c[2],default_only=account(code,c[1],c[2],types[model]),qualification='source signature/defaults only; union/signature producer limitations preserved'}
  if fingerprint then r.body_sha256=fingerprint(text) end; out[model]=r
 end
 return out
end
return M
