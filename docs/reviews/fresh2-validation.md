# Fresh independent validation review

Reviewed baseline: `7cc4caa97d4fcca3f2f0ffaba9bb6d005e2ffa70`.
Upstream inspected: `/home/salva/g/ml/tmp/lua-libghidra-upstream`, verified HEAD
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.

Read SPEC, DESIGN, PLAN, COVERAGE, EXAMPLES, README, AGENTS and
workflows/OPERATIONS. No review history or other reviewers' reports was read.
This is document/source assessment, not executed binding qualification.

## Assessment and evidence

- **Test adequacy:** SPEC §§3–6 and PLAN M1–M5 require real binary and analyzed
  fixtures, semantic completed/nonfallback decompilation, exact integer and binary
  conversions, absent/false/zero preservation, native errors, alias lifetimes,
  independent Lua states, allocator failures, longjmp auditing and sanitizers.
  DESIGN §§2, 5 additionally cover finalizer reentrancy, existing-host VM linkage,
  offline installation and both external/embedded spec-loading paths. These are
  appropriate acceptance obligations; mocks or a successful import cannot pass.
- **Milestone dependencies:** M0 resolves licensing and engine/spec readiness and
  proves native fixture usefulness before binding implementation. M1 gates broad
  adapters on the ownership/value boundary; M2 supplies both surfaces; M3 completes
  core; M4 adds full-tier operations. Both release paths explicitly pass M5.
  Preparing analyzed fixtures early is justified by native project-backed queries:
  upstream `cpp/src/local_client.cpp:382–403` requires a project reference index
  for ListLeafFunctions. It does not require implementing a full-tier Lua adapter
  at M0.
- **Objective acceptance:** COVERAGE requires per-operation positive assertions,
  field maps and negative evidence before adapters ship. SPEC §6 and PLAN clearly
  distinguish source observations from experiments and keep missing evidence as
  blocking gates. Python comparisons supplement known fixture semantics rather
  than replacing them. No milestone or runtime result is claimed complete.
- **Native limitations and feasible tests:** upstream
  `cpp/src/local_client.cpp:1053–1105` paginates candidate functions before filtering
  absent signatures, supporting the documented pages-only restriction.
  Lines 1299–1308 confirm the defined-string empty-success exception, avoiding an
  impossible populated-discovery acceptance test. Lines 1200–1211 justify checking
  `limit + offset`; lines 164–189 justify explicit persistence failure and no-op
  discard tests. PLAN M3 and DESIGN §§3–4 address these distinctions directly.
- **Scope and complexity:** Linux/Lua 5.4, one live client, pool size one, native
  local-only operation and no SWIG bound the initial target. A small shared-path
  facade, detached records, bounded iterator state and pages-only fallbacks avoid
  a second engine or speculative object hierarchy. The substantial failure-path
  audit is warranted by C-built Lua longjmp and native ownership, not unnecessary
  framework work. EXAMPLES separates the M2 slice from the M3 mutation extension.
  OPERATIONS keeps deployment and autonomous-run authority separate from product
  acceptance; AGENTS and README agree with that scope.

## Findings and necessary fixes

No blocking defect found in the reviewed dimensions. No product-document changes
are necessary. Dependency artifacts, manifests, fixtures and experimental proof
remain future milestone work, not corrections required for this document review.
Only this review report was added; no product files or runtime state were changed.

VERDICT: APPROVED

## Re-review — 6b9dc5e

Reviewed product-document changes from the original baseline to
`6b9dc5e23b3120cf190065c895d36fc263320b38` for validation-gate regressions.
The original assessment above is retained. No other review reports were consulted.

- ReadBytes now has an explicit effective signed-length bound, matching upstream
  `cpp/src/local_arch_adapter.cpp:502–511` (allocation precedes the int4 cast).
  M1's validator/dispatch-observer checks establish rejection without huge buffer
  allocations; M2 retains real small-read integration and checks both surfaces.
  This is feasible boundary testing, not a substitution for real-backend evidence.
- Range-sentinel and linear instruction-decoding tests are now explicit in M2,
  with integer/UInt64 zero, omitted maximum, positive starts and decode gaps.
  Upstream `local_arch_adapter.cpp:547–577` confirms normalization and stopping at
  the first failed decode. The example uses a fixture-known code address without
  introducing a scanner or extending iterator scope.
- Shared-view logical close/reopen tests now distinguish NO_PROGRAM from CLOSED,
  retain the process slot until owner release, and require stale iterator and
  historical metadata behavior. Upstream `local_client.cpp:1670–1689` preserves
  save errors before resetting adapters and logical loaded state. These added M2
  checks depend only on first-slice operations, not full-tier Shutdown support.
- The M0/M1 prerequisites, both release paths through M5, positive real-fixture
  requirements and uncompleted-gate status remain intact. README, AGENTS and
  OPERATIONS are unchanged. No scope expansion or infeasible new acceptance
  requirement was found.

No necessary product-document fixes or validation regressions found. This remains
document/source approval, not a claim that runtime gates passed. Only this report
was appended; no product edits or commits were made.

VERDICT: APPROVED
