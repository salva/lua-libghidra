-- MIT Copyright 2026 Salvador Fandiño. Page semantics and mutated-source tests.
package.path='scripts/?.lua;'..package.path
local U,S,P=require('tool_util'),require('inventory_source'),require('inventory_pages')
local source=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(source..'/cpp/src/local_client.cpp'); local reviews=P.review(raw)
local n=0; for _ in pairs(reviews) do n=n+1 end; assert(n==18)
assert(reviews.ListFunctionSignatures.exhaustion:find('does not',1,true))
assert(reviews.ListXrefs.analysis:find('no preceding',1,true))
assert(reviews.ListTypeMembers.name_normalization=='strip exactly one leading slash')
local function mutation(name,needle,replacement)
 local _,body,opening,ending=S.body(raw,' '..name..'(')
 local first,last=body:find(needle,1,true); assert(first,'fixture branch absent')
 local changed=body:sub(1,first-1)..replacement..body:sub(last+1)
 local bad=raw:sub(1,opening-1)..changed..raw:sub(ending+1)
 local ok,e=pcall(P.review,bad); assert(not ok,'source mutation silently accepted '..name..' '..needle)
 print('Rejected source mutation',name,needle)
end
for _,name in ipairs{'ListFunctions','ListSymbols','ListMemoryBlocks','ListTypes','ListTypeEnums','ListTypeAliases','ListTypeUnions','ListTypeMembers','ListTypeEnumMembers','ListInstructions','GetComments','ListDataItems','ListBasicBlocks','ListCFGEdges','ListXrefs','ListDecompilations','ListFunctionSignatures','ListLeafFunctions'} do
 mutation(name,'if (!ensure_loaded())','if (false)')
end
mutation('ListFunctions','paginate(all, limit, offset)','paginate(all, offset, limit)')
mutation('ListInstructions','limit + offset','limit')
mutation('ListTypeMembers','name = name.substr(1)','name = name.substr(2)')
mutation('ListTypeEnumMembers','name = name.substr(1)','name = name.substr(2)')
mutation('GetComments','static_cast<CommentKind>(c.kind)','CommentKind::kUnspecified')
mutation('ListDataItems','d.size > 0 ? d.address + d.size - 1 : d.address','d.address + d.size')
mutation('ListBasicBlocks','pool_->size() <= 1','pool_->size() == 0')
mutation('ListCFGEdges','f.get();','f.wait();')
mutation('ListXrefs','listXrefsForFunction(func.entry_address)','decompileAt(func.entry_address)')
mutation('ListDecompilations','decompileMany(addresses, names)','decompileMany(names, addresses)')
mutation('ListFunctionSignatures','if (valid[i]) filtered.push_back','filtered.push_back')
mutation('ListLeafFunctions','std::binary_search(','std::find(')
mutation('ListSymbols','{','{ revision_++;')
print('Lua 18 page wrapper reviews and 31 meaningful mutated-source rejection paths PASS')
-- The signature may intentionally start with whitespace, but comments/literals
-- containing the same signature remain invisible to definition selection.
local _,body=S.body('// probe( ) {decoy}\nvoid probe() { return; }',' probe(')
assert(body=='{ return; }')
local ok=pcall(S.body,'// probe() {decoy}\nvoid caller() {}',' probe('); assert(not ok)
local original=raw
local _,sig,opening,ending=S.body(raw,' ListFunctionSignatures(')
local a=assert(sig:find('auto funcs = paginate(',1,true))
local b=assert(sig:find('if (sig) sigs.push_back',1,true))
assert(a<b)
-- Make the after-pagination filtering statement appear before candidate slicing
-- while keeping all required branch text: presence-only checks must not pass.
local changed=sig:sub(1,a-1)..'if (sig) sigs.push_back; '..sig:sub(a)
local reordered=raw:sub(1,opening-1)..changed..raw:sub(ending+1)
assert(not pcall(P.review,reordered),'candidate/filter ordering mutation accepted')
print('Leading-space signature masking and presence-preserving ordering mutation PASS')
