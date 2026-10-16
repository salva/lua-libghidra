-- MIT Copyright 2026 Salvador Fandiño. Published native page fingerprints.
package.path='scripts/?.lua;'..package.path
local U,J,S=require('tool_util'),require('tool_json'),require('inventory_source')
local artifact=J.decode(U.read(assert(arg[1])))
local ledger=J.decode(U.read('api/coverage.json'))
local ops={}; for _,op in ipairs(ledger.operations) do ops[op.name]=op end
local count=0
for name,r in pairs(artifact.page_wrapper_reviews) do
 count=count+1
 local old=assert(ops[name].page_wrapper_review,'missing retained review '..name)
 assert(r.path==old.path and r.line==old.line and r.body_sha256==old.body_sha256,'page source fingerprint mismatch '..name)
end
assert(count==18)
assert(not U.exists(arg[1]..'.body-hash'),'fingerprint scratch leaked')
print('All 18 Lua page body SHA256/citations match retained native review artifact PASS')
for name,r in pairs(artifact.status_reviews or {}) do
 local old=assert(ops[name].status_field_review)
 assert(r.line==old.line and r.body_sha256==old.body_sha256,'status fingerprint mismatch '..name)
end
for name,r in pairs(artifact.adapter_page_reviews or {}) do
 if ops[name] then
  local old=assert(ops[name].pagination.source_review)
  assert(r.line==old.line and r.body_sha256==old.body_sha256,'adapter fingerprint mismatch '..name)
 end
end
print('Additional status and adapter page body fingerprints match retained source reviews PASS')
local mutation_count=0
for name,r in pairs(artifact.mutation_reviews or {}) do
 mutation_count=mutation_count+1
 local old=assert(ops[name].mutation_result_review,'missing retained mutation review '..name)
 assert(r.body_sha256==old.body_sha256,'mutation result fingerprint mismatch '..name)
end
assert(mutation_count==32,'mutation artifact coverage incomplete')
local req=artifact.request_reviews
assert(req.reviewed.SetFunctionLocalType.data_type and req.reviewed.CloseProgram.policy and req.reviewed.Shutdown.policy)
assert(#req.unreviewed==0,'remaining request ledger changed')
print('32 mutation fingerprints and reconciled zero outstanding direct-input ledger PASS')
local reconstructed=0
for name,r in pairs(req.type_reconstruction_reviews) do
 reconstructed=reconstructed+1
 if ops[name].reconstruction_source_review then
  local old=ops[name].reconstruction_source_review
  assert(r.body_sha256==old.body_sha256 and r.line==old.line,'member reconstruction fingerprint changed '..name)
 end
end
assert(reconstructed==20)
print('Type-family source fingerprints and complete direct request ledger PASS (not runtime approval)')
