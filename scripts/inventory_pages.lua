-- MIT Copyright 2026 Salvador Fandiño. Native page branch/source reviews.
local S=require('inventory_source')
local M={}
local simple={
 ListFunctions={'listFunctions(range_start, range_end)','functions'},
 ListSymbols={'listSymbols(range_start, range_end)','symbols'},
 ListMemoryBlocks={'listMemoryBlocks()','blocks'},
 ListTypes={'listTypes(query)','types'}, ListTypeEnums={'listTypeEnums(query)','enums'},
 ListTypeAliases={'listTypeAliases(query)','aliases'}, ListTypeUnions={'listTypeUnions(query)','unions'},
 ListTypeMembers={'listTypeMembers(name)','members'}, ListTypeEnumMembers={'listTypeEnumMembers(name)','members'},
 ListInstructions={'listInstructions(range_start, range_end,','instructions'},
}
local special={'GetComments','ListDataItems','ListBasicBlocks','ListCFGEdges','ListXrefs','ListDecompilations','ListFunctionSignatures','ListLeafFunctions'}
local function contains(text,needle) assert(text:find(needle,1,true),'missing page branch: '..needle) end
local function before(text,a,b)
 local i,j=text:find(a,1,true),text:find(b,1,true)
 assert(i and j and i<j,'page ordering changed: '..a..' before '..b)
end
function M.review(local_source,fingerprint)
 local names={}; for name in pairs(simple) do names[#names+1]=name end
 for _,name in ipairs(special) do names[#names+1]=name end; table.sort(names)
 local reviews={}
 for _,name in ipairs(names) do
  local start,text=S.body(local_source,' '..name..'(')
  local code=S.mask(text,false)
  contains(code,'if (!ensure_loaded())')
  assert(not code:find('revision_++',1,true),'page revision changed')
  assert(not code:find('catch (',1,true),'page wrapper catch changed')
  local _,lines=local_source:sub(1,start-1):gsub('\n','')
  local r={path='cpp/src/local_client.cpp',line=lines+1,
   qualification='source branch accounting only; not runtime/iterator approval',
   error_policy='NO_PROGRAM guard; no wrapper catch; adapter exception policy separate',
   native_revision='unchanged; native analysis side effects still possible'}
  if fingerprint then r.body_sha256=fingerprint(text) end
  if simple[name] then
   local call,field=table.unpack(simple[name]); contains(code,call)
   contains(code,'resp.'..field..' = paginate(all, limit, offset)')
   r.order='adapter enumeration then paginate; no post-page removal'
   r.collection=field
   if name=='ListTypeMembers' or name=='ListTypeEnumMembers' then
    contains(code,'name = name.substr(1)'); r.name_normalization='strip exactly one leading slash'
   end
   if name=='ListInstructions' then contains(code,'limit + offset'); r.scan_bound='limit+offset before slicing; binding signed sum must fit INT_MAX' end
  elseif name=='GetComments' or name=='ListDataItems' then
   before(code,'auto all = paginate(','for (const ')
   contains(code,(name=='GetComments' and 'getComments' or 'listDataItems')..'(range_start, range_end)')
   r.order='paginate adapter records before one-to-one response conversion; candidate count preserved'
   if name=='GetComments' then
    contains(code,'static_cast<CommentKind>(c.kind)')
    r.fields={address='exact side-map address',kind='native int cast, preserve unknown numeric values',text='copied unchanged including empty string'}
   else
    contains(code,'d.size > 0 ? d.address + d.size - 1 : d.address')
    r.fields={address='exact mapped nonfunction symbol address',name='copied unchanged',data_type='datatype name or undefined',size='datatype size or zero; exact UInt64',end_address='inclusive address+size-1 if positive else address; unsigned wrap possible'}
   end
  elseif name=='ListBasicBlocks' or name=='ListCFGEdges' or name=='ListXrefs' then
   local collection=({ListBasicBlocks='all_blocks',ListCFGEdges='all_edges',ListXrefs='all_xrefs'})[name]
   contains(code,'pool_->size() <= 1'); contains(code,'f.get();'); contains(code,'paginate('..collection..', limit, offset)')
   r.order='function-range selection; aggregate per-function output then paginate; serial traversal concatenation, parallel mutex completion order; future errors propagate'
   if name=='ListXrefs' then
    assert(not code:find('.decompileAt(',1,true),'xref dispatch changed')
    contains(code,'listXrefsForFunction(func.entry_address)')
    r.analysis='xref helper owns same-instance decompilation; no preceding decompileAt'
   end
  elseif name=='ListDecompilations' then
   before(code,'auto funcs = paginate(','decompileMany(addresses, names)')
   r.order='paginate function candidates then one batch; returned failed records retained unchanged'
  elseif name=='ListFunctionSignatures' then
   before(code,'auto funcs = paginate(','if (sig) sigs.push_back')
   contains(code,'if (valid[i]) filtered.push_back')
   r.order='paginate candidates before filtering absent signatures; serial and indexed parallel relative order'
   r.exhaustion='empty filtered result does not establish candidate exhaustion'
  else
   before(code,'projectLeafEntries(leaves)','std::binary_search(')
   before(code,'std::binary_search(','paginate(matched, limit, offset)')
   r.order='project leaf index then binary search range-selected functions before paginate'
   r.unavailable='NOT_SUPPORTED; no graph fallback'
  end
  reviews[name]=r
 end
 return reviews
end
return M
