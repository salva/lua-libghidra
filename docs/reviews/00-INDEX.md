# Review correction index

2026-10-15 writer revision. IDs map the eleven supplied finding groups and remain
stable across rounds. **Addressed in documentation** means proposed correction,
not reviewer acceptance or passed runtime gate. Original-reviewer re-review and
fresh independent rounds remain pending with the owning session. No convergence
is claimed by this writer.

| ID | Severity | Proposed disposition / evidence | Objective gate |
| --- | --- | --- | --- |
| R01 | Critical | SPEC §§3,5; DESIGN §3: positive/compound limits, pool_size=1, bounded identities/order. Source: local_client.cpp paginate/ListInstructions/CFG; pool state reload | M2/M3 boundaries/order/stalls |
| R02 | High | SPEC §3: uint64 sizes/ordinals, helper/metamethod errors, backend=binding, native zero-based fields; field manifest | M1/M2 field/boundary coverage |
| R03 | Critical | DESIGN §§1–2: all-frame audit, trivial trampolines, external owners, no live-RAII lua_error, reset vs destruction, sol2 fallback | M1 allocator sweeps/alias/error teardown |
| R04 | High | SPEC §1; DESIGN §1: one live client, process serialization, independent-state restrictions; instance mutex insufficient | M1 engine globals and B after A close |
| R05 | High | SPEC §4 native/facade matrix; DESIGN §4; local_client.cpp save/discard/close and pool persistence | M3 per-category reopen/no-save |
| R06 | High | SPEC §4: ignored timeout/read_only/project_name, echoed metadata, explicit hints; local_client.cpp | M2 architecture/option tests |
| R07 | High | COVERAGE public-header inventory: native-only batches/edits/benchmarks/Shutdown; PLAN positive gates | M0 reconciliation; M3/M4 positive cases |
| R08 | Critical | DESIGN §5: whole archive, installed wrapper, separate source/spec pins, protobuf/httplib, offline/PIC/BFD/cache/embedded hosts; cpp CMake/generated headers | M0 lock/spec digest; M1/M5 build/cache/VM |
| R09 | High | SPEC §6; README: HOS §§1.10,1.14–1.15,2–4,8; conditional threshold, unchanged dependency exception, pre-implementation determination | M0 applicability; M5 notices/source |
| R10 | High | SPEC §6; PLAN M0/M2/M5: analyzed fixture readiness, semantic nonfallback acceptance, required qualification oracle, core → M5 without M4 | M0 fixtures; M2 semantics; M5 each release |
| R11 | High | SPEC §§2,4–5; DESIGN §§1,3; COVERAGE: two surfaces/one owner, third result, reserved key, buffered-yield invalidation, native batches | M2 surfaces; M3 invalidation; M4 batches |

## Subsystems and metaplan

1. Prerequisites (R07–R10): license, exact artifacts and real fixture readiness.
2. Native boundary (R02–R04, R08): conversion, lifetime, engine globals and build.
3. API behavior (R01, R05–R07, R11): common dispatch, faithful responses, small
   facade, truthful persistence and operation-specific iteration.
4. Qualification (all): M2 slice, M3 core, M5 release; optional M4 full then M5.
   Unsupported cases never replace positive supported evidence.

## Review round log

| Round | Status | Evidence |
| --- | --- | --- |
| Initial findings | Supplied to writer | Eleven groups mapped above |
| Writer corrections | Proposed | SPEC, DESIGN, PLAN, COVERAGE, README |
| Original reviewers | Pending owning-session dispatch | No approval recorded |
| Fresh rounds | Pending original re-review | Append actual reports until no unresolved findings |
