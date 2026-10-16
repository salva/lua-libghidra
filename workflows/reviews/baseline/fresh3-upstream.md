# Fresh independent upstream review — round 3

Reviewed project HEAD `31cb7ee846f6cea4b583e1a4f633c4a46b71d6bd` against local upstream `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`. Read AGENTS, README, SPEC, DESIGN, PLAN, COVERAGE and EXAMPLES; no previous reviews were consulted.

## Assessment

No necessary concrete documentation defects found in the reviewed dimension: native local behavior, compatibility, coverage, options, persistence, listing and pinned source facts.

Evidence (upstream paths):

- `cpp/src/local_client.cpp:93–156`, `cpp/include/libghidra/local.hpp:16–33`, and `cpp/include/libghidra/session.hpp` support the separate client/open options, project-path precedence, ignored read-only/project-name fields and echoed architecture metadata. Pool size one and single-owner restrictions are clearly binding policies.
- `cpp/src/local_client.cpp:164–213,1670–1689`, `cpp/src/decompiler_pool.cpp:87–105`, and `cpp/src/engine/ghidra_decompiler.cpp:1005–1089` support explicit save, no-op discard, empty-state-path close behavior, logical closure retaining engines, and best-effort primary-only types/symbols restoration. The documents do not promise full persistence or rollback.
- `cpp/src/local_client.cpp:295–346,1053–1105,1191–1308` supports ignored decompilation timeouts, native batch dispatch, signature candidate pagination with subsequent filtering, instruction prefix pagination and the constant-empty defined-string compatibility operation.
- `cpp/src/local_arch_adapter.cpp:48–49,189–229,298–319,502–575,1316–1366` supports zero-end range normalization, ReadBytes' downstream signed length boundary and contiguous instruction decoding that stops at a gap. SPEC and examples preserve these limitations.
- `cpp/src/local_client.cpp:561–579,685–757` supports the documented ignored symbol/type mutation fields and struct-only CreateType. The coverage inventory accounts for all 70 LocalClient StatusOr overrides; default-interface operations are not represented as implemented local support.
- `cpp/include/libghidra/models.hpp:546–595` confirms the enum/member UInt64 fields, signed member offset and signed enum value, and integer parameter ordinal used by SPEC's concrete conversion examples.
- `cpp/CMakeLists.txt:124,298,387–389`, `cpp/bindings/CMakeLists.txt:29`, and `.github/workflows/ci.yml:32,322` corroborate the cited protobuf pin, spec embedding, source whole-archive target, engine revision and compiled-spec archive provenance. Runtime/build compatibility remains explicitly gated rather than asserted as tested.

The examples consistently distinguish detached historical open metadata, shared native ownership, logical program closure and final owner closure. Existing milestone gates cover real fixtures, persistence categories, iterator ordering, Python comparisons and native build qualification; this review does not treat those pending experiments as completed or require duplicate experiments.

## Required fixes

None.

VERDICT: APPROVED
