-- MIT Copyright 2026 Salvador Fandiño. Graph/decompilation branch mutations.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_producers')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local l=U.read(root..'/cpp/src/local_client.cpp'); local a=U.read(root..'/cpp/src/local_arch_adapter.cpp'); local p=U.read(root..'/cpp/src/decompiler_pool.cpp')
local types=S.header('models.hpp',U.read(root..'/cpp/include/libghidra/models.hpp')); local r=R.review(l,a,p,types)
assert(r.Xrefs.default_only and #r.SingleDecompilation.default_only==4)
local count=0
local function reject(where,sig,needle,replacement)
 local raw=({l=l,a=a,p=p})[where]; local _,text,opening,ending=S.body(raw,sig); local i,j=assert(text:find(needle,1,true))
 local changed=raw:sub(1,opening-1)..text:sub(1,i-1)..replacement..text:sub(j+1)..raw:sub(ending+1)
 assert(not pcall(R.review,where=='l' and changed or l,where=='a' and changed or a,where=='p' and changed or p,types),'producer mutation accepted '..needle); count=count+1
end
for _,c in ipairs{
 {'a','ArchAdapter::decompileAndExtractCFG(','stop.isInvalid() ? rec.start_address : stop.getOffset()','stop.getOffset() + 1'},
 {'a','ArchAdapter::decompileAndExtractCFG(','static_cast<std::uint32_t>(bb->sizeOut())','0'},
 {'a','ArchAdapter::decompileAndExtractCFG(','dst_bb->getIndex() <= bb->getIndex()','dst_bb->getIndex() < bb->getIndex()'},
 {'a','ArchAdapter::decompileAndExtractCFG(','(j == 0) ? "FALSE" : "TRUE"','(j == 0) ? "TRUE" : "FALSE"'},
 {'a','ArchAdapter::listXrefsForFunction(','rec.is_primary = true','rec.is_primary = false'},
 {'a','ArchAdapter::listXrefsForFunction(','rec.is_memory = true','rec.is_memory = false'},
 {'a','ArchAdapter::listXrefsForFunction(','rec.ref_type = "DATA"','rec.ref_type = "WRITE"'},
 {'a','ArchAdapter::listXrefsForFunction(','rec.source = "ANALYSIS"','rec.source = "USER"'},
 {'l',' GetDecompilation(','resp.decompilation->completed = false','resp.decompilation->completed = true'},
 {'l',' GetDecompilation(','rec.locals = std::move(dl.locals)','rec.locals = {}'},
 {'p','DecompilerPool::decompileMany(','results[i].error_message = dl.error','results[i].error_message = ""'},
 {'p','DecompilerPool::decompileMany(','results[i].completed = false','results[i].completed = true'},
 {'p','DecompilerPool::decompileMany(','results(addresses.size())','results(0)'},
 {'a','void collect_function_locals(','if (sym->isHiddenReturn()) return','if (false) return'},
 {'a','void collect_function_locals(','if (!seen_ids.insert(rec.local_id).second) return','if (false) return'},
 {'a','void collect_function_locals(','dt->getName() : ""','dt->getName() : "undefined"'},
 {'a','ArchAdapter::decompileWithLocals(','reapplyLocalRenames(func_entry, fd)','ignoreRenames()'},
 {'a','ArchAdapter::decompileWithLocals(','result.ok = !result.pseudocode.empty()','result.ok = true'},
 {'a','ArchAdapter::decompileWithLocals(','result.error = describe_current_exception()','result.error = ""'},
} do reject(table.unpack(c)) end
print('Lua graph/xref/decompilation/local producer reviews and '..count..' branch mutations PASS')
