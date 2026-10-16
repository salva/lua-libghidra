-- MIT Copyright 2026 Salvador Fandiño. Real population/storage mutation regressions.
package.path='scripts/?.lua;'..package.path
local U,S,C,P=require('tool_util'),require('inventory_source'),require('inventory_containers'),require('inventory_performance')
local root=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local raw=U.read(root..'/cpp/src/local_client.cpp'); local data=require('inventory_native').inventory(root)
local r=C.review(raw,data); local count=0
local function reject(name,needle,replacement,review)
 local _,text,opening,ending=S.body(raw,' '..name..'('); local i,j=assert(text:find(needle,1,true))
 local changed=raw:sub(1,opening-1)..text:sub(1,i-1)..replacement..text:sub(j+1)..raw:sub(ending+1)
 assert(not pcall(review,changed),'population/storage mutation accepted '..name..' '..needle); count=count+1
end
local methods=0
for name,v in pairs(r) do
 methods=methods+1
 reject(name,'if (!ensure_loaded())','if (false)',function(x) C.review(x,data) end)
 local _,text=S.body(raw,' '..name..'(')
 local needle='resp.'..v.field
 -- Rename every actual population reference without modifying declarations.
 local i,j=assert(text:find(needle,1,true))
 reject(name,text:sub(i,j),'resp.fabricated',function(x) C.review(x,data) end)
end
assert(methods==24)
for _,c in ipairs{
 {'AddPerfBenchmark','record.bench_id.empty()','false'},
 {'AddPerfBenchmark','r.bench_id == record.bench_id','r.bench_id != record.bench_id'},
 {'AddPerfBenchmark','perf_benchmarks_.push_back(record)','perf_benchmarks_.push_back({})'},
 {'ListPerfBenchmarks','resp.records = perf_benchmarks_','resp.records = {}'},
 {'ClearPerfBenchmarks','resp.removed_count = static_cast<std::uint32_t>(perf_benchmarks_.size())','resp.removed_count = 0'},
 {'ClearPerfBenchmarks','resp.cleared = true','resp.cleared = false'},
 {'DeletePerfBenchmark','if (deleted) revision_++;','revision_++;'},
} do reject(c[1],c[2],c[3],function(x) P.review(x,data.types) end) end
print('Lua 24 response containers/four performance stores and '..count..' source mutations PASS')
