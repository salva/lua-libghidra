-- MIT Copyright 2026 Salvador Fandiño. Container population, not record approval.
local S=require('inventory_source')
local M={}
local optional={GetFunction={'function','getFunction(address)'},GetSymbol={'symbol','getSymbol(address)'},GetInstruction={'instruction','getInstruction(address)'},GetType={'type','getType(name)'},GetFunctionSignature={'signature','getFunctionSignature(address)'}}
local simple={ListFunctions='functions',ListSymbols='symbols',ListMemoryBlocks='blocks',ListTypes='types',ListTypeEnums='enums',ListTypeAliases='aliases',ListTypeUnions='unions',ListTypeMembers='members',ListTypeEnumMembers='members',ListInstructions='instructions'}
local special={GetComments={'comments','resp.comments.push_back(std::move(rec))'},ListDataItems={'data_items','resp.data_items.push_back(std::move(rec))'},ListBasicBlocks={'blocks','resp.blocks = paginate(all_blocks, limit, offset)'},ListCFGEdges={'edges','resp.edges = paginate(all_edges, limit, offset)'},ListXrefs={'xrefs','resp.xrefs = paginate(all_xrefs, limit, offset)'},ListDecompilations={'decompilations','resp.decompilations = std::move(records)'},ListFunctionSignatures={'signatures','resp.signatures = std::move(sigs)'},ListLeafFunctions={'functions','resp.functions = paginate(matched, limit, offset)'}}
function M.review(raw,data,fingerprint)
 local names={GetDecompilation=true}; for n in pairs(optional) do names[n]=true end; for n in pairs(simple) do names[n]=true end; for n in pairs(special) do names[n]=true end
 local out={}
 local function has(c,t) assert(c:find(t,1,true),'container population missing '..t) end
 for name in pairs(names) do
  local start,text=S.body(raw,' '..name..'('); local code=S.mask(text,false); has(code,'if (!ensure_loaded())')
  local field,sem
  if optional[name] then
   local f,call=table.unpack(optional[name]); field=f
   local expression='resp.'..f..' = pool_->primaryAdapter().'..call; has(code,expression)
   if name=='GetFunctionSignature' then local i=assert(code:find('decompileAt(address)',1,true)); assert(i<code:find(expression,1,true),'signature preparation order changed') end
   sem='optional copied directly; absence remains nil, including caught adapter failure; lowlevel success not native NOT_FOUND; facade synthetic error separate'
  elseif name=='GetDecompilation' then
   field='decompilation'
   for _,t in ipairs{'resp.decompilation = DecompilationRecord{}','resp.decompilation = std::move(rec)','resp.decompilation->completed = false'} do has(code,t) end
   sem='loaded success always present record even completed=false; failure is not absence or nil,error; branch-specific defaults separate'
  else
   if simple[name] then field=simple[name]; has(code,'resp.'..field..' = paginate(all, limit, offset)') else field=special[name][1]; has(code,special[name][2]) end
   assert(data.page_wrapper_reviews[name],'page pipeline missing')
   sem='dense array preserves sequence/duplicates/false/zero/empty; no sorting/address keying/dedup; empty vector empty table not absence; pipeline and nested producers separate, no iterator approval'
  end
  local fields=assert(data.types[data.declarations[name].response_type]).fields; local found=0
  for _,f in ipairs(fields) do if f.name==field then found=found+1 end end; assert(found==1,'container model mismatch')
  local _,line=raw:sub(1,start-1):gsub('\n',''); local r={path='cpp/src/local_client.cpp',line=line+1,field=field,semantics=sem,qualification='source-only container population'}
  if fingerprint then r.body_sha256=fingerprint(text) end; out[name]=r
 end
 return out
end
return M
