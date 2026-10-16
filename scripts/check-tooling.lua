#!/usr/bin/env lua5.4
-- MIT Copyright 2026 Salvador Fandiño. Native inventory integration, no Python oracle.
package.path='scripts/?.lua;'..package.path
local U=require('tool_util')
local source=assert(arg[1],'usage: check-tooling.lua PINNED_SOURCE FRESH_WORK_DIRECTORY')
local work=assert(arg[2],'fresh work directory required'); assert(#arg==2 and not U.exists(work),'fresh work required')
U.run{'mkdir','-p',work}
for _,name in ipairs{'test_inventory_api','tooling_fields','tooling_coverage','tooling_pages','tooling_adapter_pages','tooling_factory','tooling_status','tooling_requests','tooling_direct','tooling_lookup','tooling_mutations','tooling_remaining_inputs','tooling_type_inputs','tooling_containers_performance','tooling_session','tooling_producers','tooling_records','tooling_special'} do U.run{'lua5.4','tests/'..name..'.lua',source} end
U.run{'lua5.4','scripts/inventory-api.lua',source,work..'/native.json'}
U.run{'lua5.4','tests/tooling_page_artifact.lua',work..'/native.json'}
U.run{'lua5.4','scripts/inventory-api.lua',source,work..'/coverage.json','--coverage'}
local J=require('tool_json'); local d=J.decode(U.read(work..'/coverage.json')); require('inventory_completeness').validate(d)
assert(d.surface_audit.grammar_accounted==70)
local historical=J.decode(U.read('api/runtime-evidence-m3.json'))
assert(historical.provenance.sha256==U.hash('api/history/coverage-m3.json'),'historical evidence provenance changed')
for _,op in ipairs(d.operations) do assert(historical.operations[op.name],'lost historical evidence row'); assert(op.evidence.positive.status=='unqualified','runtime evidence inferred by generator') end
print('All native Lua inventory suites, fresh CLI modes, JSON consumer and separate historical evidence provenance PASS')
U.run{'lua5.4','tests/package_documents.lua',assert(os.getenv('PWD')),work..'/package-documents'}
