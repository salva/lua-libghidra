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
