# Original upstream-local re-review

Reviewed project `ff23fac5cafadaf1ec088f676b20a489a1fdb902` against upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`. Read SPEC, DESIGN, PLAN,
COVERAGE and reviews/00-INDEX. Scope: native LocalClient compatibility, Python
inspiration, lifecycle/persistence, offline limitations and operation coverage.
This is document readiness review, not runtime qualification. No product edits,
deployments, commits or subagents were performed.

Upstream paths below are relative to
`/home/salva/g/ml/tmp/lua-libghidra-upstream/`.

## Outstanding finding

### UL-01 — Medium — DeleteTypeEnum is incorrectly classified as locally supported

- Project: `docs/COVERAGE.md:6–8,28,36–43`; `docs/PLAN.md:71–78`.
- Confirmed evidence: `cpp/include/libghidra/types.hpp:86` declares the shared
  operation, but `cpp/include/libghidra/api.hpp:407–409` supplies only a
  NOT_SUPPORTED default. Inspection of the complete `cpp/src/local_client.cpp`
  finds no DeleteTypeEnum override. The separate DeleteType operation is
  implemented at `cpp/src/local_client.cpp:789–806`.
- Scenario: M4 attempts to implement and positively qualify every listed local
  operation. DeleteTypeEnum cannot have a positive native LocalClient case at
  this pin, so the documented full-tier gate is impossible as written. Mapping
  it silently to DeleteType would violate the faithful native-operation mapping.
- Correction: remove DeleteTypeEnum from the supported Full row and explicitly
  classify it as an unsupported shared-interface operation. Keep DeleteType in
  scope. Any enum deletion via DeleteType needs its own positive evidence; do
  not claim an implemented DeleteTypeEnum endpoint.

## Original findings resolved in documentation

- Persistence/no-op discard/save-without-path distinctions are now explicit in
  SPEC:125–136 and PLAN:61–64. They match local_client.cpp:164–189,1670–1689
  and engine/ghidra_decompiler.cpp:1064–1089.
- Ignored timeout and open options, echoed metadata and Python detection
  differences are explicit in SPEC:137–144. Evidence remains
  local_client.cpp:93–156,295–325 and python/src/libghidra/local.py:205–220.
- pool_size=1 and serial-order qualification address pooled state/pagination
  inconsistencies: SPEC:17 and DESIGN:63–98, consistent with
  decompiler_pool.cpp:87–95 and local_client.cpp:440–461,481–502.
- Destructor no-save behavior is explicit in SPEC:121,134, consistent with
  local_client.cpp:53, decompiler_pool.cpp:65 and
  engine/ghidra_decompiler.cpp:205–213.
- Native-only methods now have named tiers and layer dispositions. Cross-checking
  LocalClient operation definitions against COVERAGE found no omitted named
  override; the outstanding error is the extra unsupported operation above.
- Positive supported cases are required independently of negative limitation
  tests (SPEC:164–170; PLAN:63–64), fixing the original core-exit loophole.

## Open qualification questions, not document blockers

Exact loader/spec compatibility, actual bare-binary enumeration, per-category
state round trips, serial iterator identities/order, sequential engine lifecycle
and Python-normalized results still require M0–M5 evidence. The corrected docs
identify these as open gates rather than completed runtime claims. No additional
blocking regression was identified in this review dimension.

Document approval is withheld only for UL-01; the original behavioral findings
are otherwise addressed at design level.

VERDICT CHANGES_REQUESTED

## Follow-up disposition — UL-01 resolved

Verified the corrected `docs/COVERAGE.md:28,41`: DeleteTypeEnum is absent
from the supported Full tier and explicitly listed among excluded operations;
DeleteType remains included. This matches the pinned upstream evidence above.
UL-01 is resolved, with no outstanding findings in this review dimension.

This disposition supersedes the previous verdict while retaining its evidence.
Approval covers document readiness for the upstream-local dimension, not runtime
completion or satisfaction of the recorded M0–M5 qualification gates.

VERDICT APPROVED
