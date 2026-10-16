-- MIT Copyright 2026 Salvador Fandiño. Request source drift regression suite.
package.path='scripts/?.lua;'..package.path
local U,S,R=require('tool_util'),require('inventory_source'),require('inventory_requests')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local adapter=U.read(root..'/cpp/src/local_arch_adapter.cpp')
local data=require('inventory_native').inventory(root)
local reviews=R.review(raw,adapter,data); local nested=0
for _,fields in pairs(reviews.reviewed) do for _,r in pairs(fields) do if r.kind=='nested' then nested=nested+1 end end end
assert(nested==20); assert(#reviews.unreviewed>0,'must not claim remaining direct arguments reviewed')
local function changed(source,signature,needle,replacement)
 local _,text,opening,ending=S.body(source,signature); local i,j=assert(text:find(needle,1,true))
 return source:sub(1,opening-1)..text:sub(1,i-1)..replacement..text:sub(j+1)..source:sub(ending+1)
end
local count=0
local function reject(source,a) assert(not pcall(R.review,source,a,data),'request mutation accepted'); count=count+1 end
for _,case in ipairs{
 {' GetDecompilation(','{','{ timeout_ms;'},
 {' DeleteSymbol(','{','{ name_filter;'},
 {' CreateType(','{','{ size;'},
 {' CreateTypeEnum(','{','{ width;'},
 {' OpenProgram(','{','{ request.read_only;'},
 {' OpenProgram(','arch = opts_.default_arch','arch = ""'},
 {' AddPerfBenchmark(','{','{ record.status;'},
 {' PatchBytesBatch(','d.writeBytes(patch.address, patch.data)','d.writeBytes(0, patch.data)'},
 {' ListTypes(','listTypes(query)','listTypes("")'},
 {' ListFunctions(','listFunctions(range_start, range_end)','listFunctions(0, 0)'},
 {'Container paginate(const Container& all, int limit, int offset)','int start = std::min(offset, n)','int start = 0'},
} do reject(changed(raw,case[1],case[2],case[3]),adapter) end
reject(raw,changed(adapter,'std::uint64_t normalize_range_end(','return range_end == 0 ? kAllRangeEnd : range_end;','return range_end;'))
reject(raw,changed(adapter,'ArchAdapter::listTypes(','!query.empty() && dt->getName().find(query) == std::string::npos','true'))
print('Lua nested 20 fields, range/query/pagination/ignored reviews and '..count..' real source mutations PASS; '..#reviews.unreviewed..' direct arguments explicitly outstanding')
