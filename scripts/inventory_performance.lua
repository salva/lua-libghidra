-- MIT Copyright 2026 Salvador Fandiño. Caller-supplied storage is not measurement.
local S=require('inventory_source')
local M={}
function M.review(raw,types,fingerprint)
 local code,texts,starts={},{},{}
 for _,name in ipairs{'AddPerfBenchmark','ListPerfBenchmarks','ClearPerfBenchmarks','DeletePerfBenchmark'} do
  local start,text=S.body(raw,' '..name..'('); starts[name]=start; texts[name]=text; code[name]=S.mask(text,false)
 end
 local function has(c,x) assert(c:find(x,1,true),'performance branch missing '..x) end
 local function before(c,a,b) local x,y=c:find(a,1,true),c:find(b,1,true); assert(x and y and x<y,'performance order changed') end
 local add,clear,delete=code.AddPerfBenchmark,code.ClearPerfBenchmarks,code.DeletePerfBenchmark
 for _,t in ipairs{'perf_benchmarks_.push_back(record)','record.bench_id.empty()','r.bench_id == record.bench_id','resp.added = true'} do has(add,t) end
 before(add,'perf_benchmarks_.erase(','perf_benchmarks_.push_back(record)')
 has(code.ListPerfBenchmarks,'resp.records = perf_benchmarks_')
 has(clear,'resp.removed_count = static_cast<std::uint32_t>(perf_benchmarks_.size())'); before(clear,'resp.removed_count =','perf_benchmarks_.clear()'); has(clear,'resp.cleared = true')
 has(delete,'const bool deleted = perf_benchmarks_.size() != before'); has(delete,'resp.deleted = deleted'); has(delete,'if (deleted) revision_++;')
 local fields={bench_id='nonempty exact upsert/delete key stored unchanged',query_family='caller label, no family validation',dataset_profile='caller label, no dataset validation',status='caller text, not computed pass/fail'}
 for _,f in ipairs{'cold_ms_p50','cold_ms_p95','warm_ms_p50','warm_ms_p95','throughput_qps','regression_pct'} do fields[f]='caller supplied double copied unchanged; no computation, finite/sign/range guarantee; Lua number precision qualification separate' end
 local count=0; for _,f in ipairs(types.PerfBenchmarkRecord.fields) do assert(fields[f.name],'unreviewed performance field'); count=count+1 end; assert(count==10)
 local flags={AddPerfBenchmark='added true even replacement; erase then append moves to tail',ListPerfBenchmarks='complete caller-record copy, insertion/upsert order, no pagination or measurement',ClearPerfBenchmarks='cleared true even empty; removed_count pre-clear uint32 cast requires count<=UINT32_MAX',DeletePerfBenchmark='deleted iff count decreased; absent ID successful false with no native revision'}
 local out={}
 for name in pairs(code) do local _,line=raw:sub(1,starts[name]-1):gsub('\n',''); local r={path='cpp/src/local_client.cpp',line=line+1,record_fields=fields,semantics=flags[name],qualification='source storage only; not runtime or benchmark evidence'}; if fingerprint then r.body_sha256=fingerprint(texts[name]) end; out[name]=r end
 return out
end
return M
