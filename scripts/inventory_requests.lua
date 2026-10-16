-- MIT Copyright 2026 Salvador Fandiño. Native request consumption accounting.
local S=require('inventory_source')
local M={}
local ignored={DeleteSymbol={'name_filter'},GetDecompilation={'timeout_ms'},ListDecompilations={'timeout_ms'},CreateType={'size'},AddTypeMember={'size'},CreateTypeEnum={'width','is_signed'},ListDefinedStrings={'range_start','range_end','limit','offset'}}
local range={ListFunctions='listFunctions',ListSymbols='listSymbols',GetComments='getComments',ListDataItems='listDataItems',ListInstructions='listInstructions'}
for _,name in ipairs{'ListLeafFunctions','ListDecompilations','ListFunctionSignatures','ListXrefs','ListCFGEdges','ListBasicBlocks'} do range[name]='listFunctions' end
local query={ListTypes={'listTypes','dt'},ListTypeAliases={'listTypeAliases','dt'},ListTypeEnums={'listTypeEnums','te'},ListTypeUnions={'listTypeUnions','dt'}}
local open={
 project_path='nonempty selects project BEFORE binary route; empty binary requires nonempty program_path',
 program_path='project selector or binary filename; unchanged; also response name preference',
 project_name='never read; facade rejects presence',read_only='never read; false is not absence; facade rejects presence',
 language_id='binary empty uses default_arch without compiler suffix; nonempty request wins; project ignores; echo not detected metadata',
 compiler_spec_id='binary suffix only when language_id nonempty; echoed regardless; ignored by project load',
 format='binary only forwarded unchanged; empty preserved, not detected format',
 base_address='binary only literal exact UInt64; zero is not sentinel',
}
local function has(code,needle) assert(code:find(needle,1,true),'request consumer missing '..needle) end
local function before(code,a,b)
 local i,j=code:find(a,1,true),code:find(b,1,true); assert(i and j and i<j,'request branch ordering changed '..a)
end
local function members(code,var)
 local found={}; for name in code:gmatch('%f[%w_]'..var..'%.([%w_]+)') do found[name]=true end; return found
end
local function exact(actual,expected)
 for name in pairs(actual) do assert(expected[name],'unexpected request consumer '..name) end
 for name in pairs(expected) do assert(actual[name],'missing request consumer '..name) end
end
function M.review(raw,adapter,data,fingerprint)
 local result={reviewed={},unreviewed={},qualification='source/binding-domain accounting only; no new runtime approval'}
 local function body(source,signature) local _,text=S.body(source,signature); return S.mask(text,false),text end
 local paginate=body(raw,'Container paginate(const Container& all, int limit, int offset)')
 for _,token in ipairs{'int start = std::min(offset, n)','int end = (limit > 0) ? std::min(start + limit, n) : n','Container(all.begin() + start, all.begin() + end)'} do has(paginate,token) end
 local normalize=body(adapter,'std::uint64_t normalize_range_end(')
 has(normalize,'return range_end == 0 ? kAllRangeEnd : range_end;'); has(S.mask(adapter,false),'constexpr std::uint64_t kAllRangeEnd = UINT64_MAX;')
 local function record(name,arg,sem,kind,text)
  result.reviewed[name]=result.reviewed[name] or {}
  local r={semantics=sem,kind=kind}; if fingerprint then r.consumer_body_sha256=fingerprint(text) end
  result.reviewed[name][arg]=r
 end
 for name,impl in pairs(data.implementations) do
  local code,text=body(raw,' '..name..'(')
  local done={}
  for _,arg in ipairs(ignored[name] or {}) do
   local standalone=false; for pos in code:gmatch('()%f[%w_]'..arg..'%f[^%w_]') do if pos==1 or not code:sub(pos-1,pos-1):match('[.%w_]') then standalone=true end end
   assert(not standalone,'ignored request now consumed '..name..'.'..arg)
   record(name,arg,'native never reads argument; no advertised effect; ignored does not waive typed validation; timeout rejected by facade, size/enum layout not enforced', 'ignored',text); done[arg]=true
  end
  if range[name] then
   local consumer=range[name]; has(code,consumer..'(range_start, range_end')
   local producer=body(adapter,'ArchAdapter::'..consumer..'(')
   has(producer,'range_end = normalize_range_end(range_end)')
   if consumer=='listInstructions' then
    has(producer,'if (range_start > range_end) return result;'); has(producer,'cur <= range_end'); has(producer,'cur = range_start')
   end
   local target=consumer=='listInstructions' and 'instruction start addresses in exact-start linear sweep' or consumer=='listFunctions' and 'function entries, not returned graph/reference endpoints' or 'record start addresses, not extent overlap'
   record(name,'range_start','exact UInt64 inclusive lower bound default 0; zero literal; selects '..target,'range',text)
   record(name,'range_end','exact UInt64 inclusive upper bound default UINT64_MAX; explicit zero normalized to UINT64_MAX; reversed normalized range empty; selects '..target,'range',text)
   done.range_start=true; done.range_end=true
  end
  if data.page_wrapper_reviews[name] then
   for _,arg in ipairs{'limit','offset'} do
    has(code,arg)
    record(name,arg,arg=='limit' and 'positive bounded int default 100; reject native all-remaining <=0 behavior; offset+limit <=INT_MAX' or 'nonnegative zero-based candidate offset default 0; <=INT_MAX and offset+limit <=INT_MAX; filtered signature output not exhaustion', 'pagination',text)
    done[arg]=true
   end
  end
  if query[name] then
   local method,var=table.unpack(query[name]); has(code,method..'(query)')
   local producer=body(adapter,'ArchAdapter::'..method..'(')
   has(producer,'!query.empty() && '..var..'->getName().find(query) == std::string::npos')
   record(name,'query','unchanged byte substring; empty disables pre-page filter, case sensitive, not regex/glob; no implied Lua optionality','query',text); done.query=true
  end
  if name=='OpenProgram' then
   local consumed={project_path=true,program_path=true,language_id=true,compiler_spec_id=true,format=true,base_address=true}
   exact(members(code,'request'),consumed)
   before(code,'loadProject(','loadBinary('); has(code,'if (request.language_id.empty())'); has(code,'arch = opts_.default_arch')
   local expected={}; for _,field in ipairs(data.types.OpenProgramRequest.fields) do expected[field.name]=true end
   exact(expected,(function() local t={}; for k in pairs(open) do t[k]=true end; return t end)())
   for field,sem in pairs(open) do record(name,'request.'..field,sem,'nested',text) end; done.request=true
  elseif name=='AddPerfBenchmark' then
   exact(members(code,'record'),{bench_id=true}); has(code,'perf_benchmarks_.push_back(record)')
   for _,f in ipairs(data.types.PerfBenchmarkRecord.fields) do
    record(name,'record.'..f.name,f.name=='bench_id' and 'nonempty exact upsert key; erase matches then append moves replacement to tail' or 'caller supplied field copied unchanged, not native measurement; zero/empty not absence; finite/sign validation separate','nested',text)
   end; done.record=true
  elseif name=='PatchBytesBatch' then
   exact(members(code,'patch'),{address=true,data=true}); has(code,'d.writeBytes(patch.address, patch.data)')
   record(name,'patches.address','literal exact UInt64; input order, later overlap may overwrite, no sorting/coalescing','nested',text)
   record(name,'patches.data','binary bytes including NUL/empty unchanged; each/summed bytes and count <=UINT32_MAX; no rollback on partial effects','nested',text); done.patches=true
  end
  for _,arg in ipairs(S.split(data.declarations[name].arguments)) do
   local field=assert(arg:match('([%w_]+)$'))
   if not done[field] then result.unreviewed[#result.unreviewed+1]={operation=name,argument=field,reason='remaining direct consumption/domain review not migrated'} end
  end
 end
 local direct=require("inventory_direct").review(raw,adapter,data,fingerprint)
 for name,args in pairs(direct.requests) do for arg,r in pairs(args) do result.reviewed[name]=result.reviewed[name] or {}; assert(not result.reviewed[name][arg],"duplicate request review"); result.reviewed[name][arg]=r end end
 result.related_response_reviews=direct.responses
 local remaining={}; for _,r in ipairs(result.unreviewed) do if not (direct.requests[r.operation] and direct.requests[r.operation][r.argument]) then remaining[#remaining+1]=r end end; result.unreviewed=remaining
 table.sort(result.unreviewed,function(a,b) return a.operation..'.'..a.argument<b.operation..'.'..b.argument end)
 return result
end
return M
