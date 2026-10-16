-- MIT Copyright 2026 Salvador Fandiño. Whole output consumer, no historical ledger input.
package.path='scripts/?.lua;'..package.path
local U,J,C=require('tool_util'),require('tool_json'),require('inventory_coverage')
local source=arg[1] or '.cache/native-inputs-patched/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d'
local native=require('inventory_native').inventory(source)
local tabletext=U.read('docs/COVERAGE.md')
local data=C.assemble(native,tabletext)
local counts=data.completeness_audit
assert(counts.included_operations==70 and counts.excluded_operations==40 and counts.expanded_response_paths==345 and counts.direct_request_paths==156 and counts.nested_request_paths==20)
local ops={}; for _,op in ipairs(data.operations) do ops[op.name]=op end
assert(ops.AddPerfBenchmark.request[1].nested_fields[1].consumer_review)
assert(ops.PatchBytesBatch.request[1].nested_fields[2].consumer_review)
assert(ops.GetCapabilities.state_transitions and ops.GetStatus.response.fields[6].semantics)
assert(data.lifecycle.factory_fields[1].semantics)
for _,op in ipairs(data.operations) do
 assert(op.evidence.positive.status=='unqualified' and op.evidence.negative.status=='unqualified')
 if op.tier~='excluded' then assert(not op.implementation.body); for _,f in ipairs(op.response.fields) do assert(f.producer_review and f.semantics) end end
end
local decoded=J.decode(require('tool_json_encode')(data))
require('inventory_completeness').validate(decoded)
local function rejects(fn) assert(not pcall(fn),'incomplete/false output accepted') end
local review=native.request_reviews.reviewed.AddPerfBenchmark['record.bench_id']
native.request_reviews.reviewed.AddPerfBenchmark['record.bench_id']=nil
rejects(function() C.assemble(native,tabletext) end)
native.request_reviews.reviewed.AddPerfBenchmark['record.bench_id']=review
local record=native.record_reviews.listTypeMembers; native.record_reviews.listTypeMembers=nil
rejects(function() C.assemble(native,tabletext) end); native.record_reviews.listTypeMembers=record
local slot=ops.ListFunctions.evidence.positive
slot.status='made-up green'; slot.fixture='mock'; slot.command='true'
rejects(function() require('inventory_completeness').validate(data) end)
print('Integrated native-only 110-operation/345-response/176-request-path JSON consumer and missing-review/false-evidence regressions PASS')
for _,c in ipairs{{'ListDataItems','rec.end_address = d.size > 0 ? d.address + d.size - 1 : d.address','rec.end_address = d.address + d.size'},{'GetComments','rec.kind = static_cast<CommentKind>(c.kind)','rec.kind = CommentKind::kUnspecified'},{'OpenProgram','resp.compiler_spec = request.compiler_spec_id','resp.compiler_spec = "detected"'}} do
 local impl=native.implementations[c[1]]; local old=impl.body; local i,j=assert(old:find(c[2],1,true)); impl.body=old:sub(1,i-1)..c[3]..old:sub(j+1)
 rejects(function() C.assemble(native,tabletext) end); impl.body=old
end
assert(require('tool_json_encode')(J.null)=='null')
assert(J.decode(require('tool_json_encode')({absent=J.null})).absent==J.null)
print('Conversion-source/order/default and actual JSON null regressions PASS')
