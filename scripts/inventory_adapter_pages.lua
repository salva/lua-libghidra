-- MIT Copyright 2026 Salvador Fandiño. Adapter traversal is not public ordering.
local S=require('inventory_source')
local M={}
local contracts={
 ListTypeEnums={'listTypeEnums',{'path_name'},'dependentOrder after TypeEnum selection; not lexical path order','TypeEnum selection and substring query; filtered type_id counter',false},
 ListTypeEnumMembers={'listTypeEnumMembers',{'type_path_name','ordinal'},'TypeEnum traversal ordinal','findByName then TypeEnum cast; no post-page filtering',false},
 ListTypeMembers={'listTypeMembers',{'parent_type_path_name','ordinal'},'TypeStruct field traversal ordinal','findByName then TypeStruct cast; unions not handled',false},
 GetComments={'getComments',{'address','kind'},'side-map lexicographic address/native kind','side-map entries only, not project comment database',true},
 ListDataItems={'listDataItems',{'address'},'MapIterator traversal; no sort/dedup','skip functions/dynamic/unmapped entries; missing type undefined/zero',true},
 ListFunctions={'listFunctions',{'entry_address'},'MapIterator traversal; no explicit sort','mapped functions; next-function gap size then final footprint',true},
 ListSymbols={'listSymbols',{'address','name'},'MapIterator traversal; no name tie-break','dynamic/unmapped removed; symbol_id restarts per call',true},
 ListTypes={'listTypes',{'path_name'},'TypeFactory dependentOrder, not lexical path order','substring query; query-dependent type_id counter',false},
 ListTypeAliases={'listTypeAliases',{'path_name'},'TypeFactory dependentOrder, not lexical path order','getTypedef and substring query; filtered counter',false},
 ListTypeUnions={'listTypeUnions',{'path_name'},'TypeFactory dependentOrder, not lexical path order','TYPE_UNION and substring query; filtered counter',false},
 ListInstructions={'listInstructions',{'address'},'advancing decode address until gap/zero/wrap','decode exact start, inclusive end, scan cap then paginate',true},
 ListMemoryBlocks={'listMemoryBlocks',{'start_address','name'},'zero/one synthetic default code-space record','not segment enumeration; highest+1 can wrap uint64',false},
}
local function has(code,needle) assert(code:find(needle,1,true),'adapter branch missing '..needle) end
local function review(raw,signature,path,fingerprint)
 local start,text=S.body(raw,signature); local _,line=raw:sub(1,start-1):gsub('\n','')
 local r={path=path,line=line+1}; if fingerprint then r.body_sha256=fingerprint(text) end
 return r,text,S.mask(text,false)
end
function M.review(adapter,local_source,header,pool,fingerprint)
 local result={}
 for name,c in pairs(contracts) do
  local method,identity,order,filter,sentinel=table.unpack(c)
  local r,text,code=review(adapter,'ArchAdapter::'..method..'(','cpp/src/local_arch_adapter.cpp',fingerprint)
  local _,localbody=S.body(local_source,' '..name..'(')
  r.method=method; r.identity=identity; r.order=order; r.pre_page_filter=filter; r.range_zero_end=sentinel
  r.cursor_domain='adapter records after filtering before LocalClient paginate'
  r.comparator='source traversal not proof of public total order; preserve current pages-only/qualified-family policy'
  r.exception_policy=code:find('catch (...)',1,true) and 'catch/log may return partial or empty success' or 'no local catch-all; do not infer another family exception policy'
  if sentinel then has(code,'normalize_range_end(range_end)') end
  if name=='ListTypes' or name=='ListTypeAliases' or name=='ListTypeUnions' or name=='ListTypeEnums' then has(code,'dependentOrder') end
  if name=='ListTypeMembers' or name=='ListTypeEnumMembers' then has(S.mask(localbody,false),'name = name.substr(1)'); has(code,'ordinal++'); r.lookup='strip one slash; name/path, not numeric ID' end
  if name=='ListInstructions' then has(S.mask(localbody,false),'limit + offset'); r.scan_bound='checked signed limit+offset; no adapter fallback implied' end
  if name=='GetComments' then has(S.mask(header,false),'std::map<std::pair<std::uint64_t, int>, std::string> comments_') end
  r.qualification='source accounting only; no new runtime producer/iterator approval'
  result[name]=r
 end
 local r,_,cfg=review(adapter,'ArchAdapter::decompileAndExtractCFG(','cpp/src/local_arch_adapter.cpp',fingerprint)
 has(cfg,'collectBasicBlocks(structure.getBlock(i), basics)'); has(cfg,'collectBasicBlocks(raw.getBlock(i), basics)'); r.limitations='analysis may create/name missing function; catch/log may return partial results; blocks and CFG pages only'
 result.CFGExtraction=r
 local x,_,code=review(adapter,'ArchAdapter::listXrefsForFunction(','cpp/src/local_arch_adapter.cpp',fingerprint)
 local load,store=code:find('CPUI_LOAD',1,true),code:find('CPUI_STORE',1,true)
 assert(load and store and load<store,'xref extraction phase order changed')
 x.limitations='calls then constant-address LOAD then STORE subset; not project reference database; duplicates/partial success possible; pages only'
 result.XrefExtraction=x
 local b,_,batch=review(pool,'DecompilerPool::decompileMany(','cpp/src/decompiler_pool.cpp',fingerprint)
 has(batch,'results(addresses.size())'); has(batch,'results[i].completed = false')
 local assigned={}; for value in batch:gmatch('results%[i%]%.completed%s*=%s*([^;]+);') do assigned[#assigned+1]=S.norm(value) end
 assert(table.concat(assigned,',')=='true,false,true,false','serial/parallel batch completion branches changed')
 b.limitations='same-size candidate-indexed batch retains failed decompilation records; error_message not absent optional'
 result.DecompileBatch=b
 return result
end
return M
