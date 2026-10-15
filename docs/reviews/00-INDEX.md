# Review correction index

2026-10-15 fresh1 writer corrections. IDs remain stable across rounds. All six
original dimensions have documentation approval (upstream after UL-01 follow-up).
Fresh1 has five changes-requested verdicts and one native-safety approval.
**Corrected, pending re-review** is not reviewer acceptance or a runtime pass.
The new corrections below await review; no convergence is claimed.

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
| R12 | Medium | Original upstream UL-01: DeleteTypeEnum removed from supported inventory and explicitly excluded in COVERAGE; DeleteType retained. Corrected in 699cc8a and approved by original reviewer follow-up. Source: api.hpp default, no local override | No impossible positive DeleteTypeEnum gate |
| R13 | High | Fresh1 API F1 / upstream F3: SPEC §5, DESIGN §3, COVERAGE and PLAN M3 now make signatures pages-only, distinguish candidate-function cursor domain/filtering from output count. Corrected, pending re-review. Source: local_client.cpp:1053–1071, models.hpp:612–614 | M3 native page semantics; any future iterator needs separate input-aware design |
| R14 | Medium | Fresh1 upstream F1 / validation V1: constant-empty ListDefinedStrings compatibility, ignored page fields, no facade iterator/discovery promise; coarse GetCapabilities is not operation support. SPEC §4/§6, DESIGN §3, COVERAGE, PLAN M2/M3. Corrected, pending re-review. Source: local_client.cpp:74–86,1299–1308 | Empty-success on known-string fixture, unloaded error, validation; no populated-page gate |
| R15 | Medium | Fresh1 upstream F2: SPEC §4/COVERAGE explicitly record ignored DeleteSymbol name, CreateType/AddTypeMember size, CreateTypeEnum width/is_signed and struct-only creation; PLAN M4 tests. Corrected, pending re-review. Source: local_client.cpp:560–575,685–757 | Positive actual effects, ignored-field/unsupported-kind assertions |
| R16 | Medium | Fresh1 build F1: source Python >=3.10 plus Python zlib, early version/import check, separate SDK/oracle/runtime roles; README, SPEC §1, DESIGN §5, PLAN M0. Corrected, pending re-review. Source: EmbedSpecs.cmake:12,30–39; embed_specs.py:20,37 | Source configuration prerequisite checks; no runtime Python |
| R17 | Medium | Fresh1 build F2: external-root versus empty-root embedded-cache profiles; DESIGN §5 and PLAN M5 require constructor/path evidence. Corrected, pending re-review. Source: decompiler_pool.cpp:52–61; engine/ghidra_decompiler.cpp:189–203 | External valid/missing/unreadable roots; embedded cold/warm/unwritable HOME |
| R18 | Medium | Fresh1 layering L1: open returns session,nil,open_response; full detached initial metadata, no repeat open; SPEC §2, EXAMPLES, PLAN M2. Corrected, pending re-review. Source: models.hpp:47–61 | Initial metadata including false/zero retained through closure/reopen |
| R19 | Medium | Fresh1 layering L2: SPEC first-slice signatures/options/helper exports and EXAMPLES; M2 executes first slice, M3 executes mutation/invalidation extension. Corrected, pending re-review. Source: local.hpp:16–33, session.hpp:14–23 and public operation signatures | Real fixture examples, third results, bounded pages/errors, same-owner closure |

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
| Writer initial corrections | ff23fac | SPEC, DESIGN, PLAN, COVERAGE, README |
| Original API | Approved | [Report](original-api.md) |
| Original build | Approved | [Report](original-build.md) |
| Original layering | Approved | [Report](original-layering.md) |
| Original native safety | Approved | [Report](original-native.md) |
| Original upstream | Approved after UL-01 correction (R12) | [Preserved initial report and follow-up](original-upstream.md); correction in 699cc8a |
| Original validation | Approved | [Report](original-validation.md) |
| Fresh1 API | Changes requested: F1 → R13 | [Report](fresh1-api.md) |
| Fresh1 build | Changes requested: F1 → R16, F2 → R17 | [Report](fresh1-build.md) |
| Fresh1 layering | Changes requested: L1 → R18, L2 → R19 | [Report](fresh1-layering.md) |
| Fresh1 native safety | Approved; audit reminders incorporated into DESIGN §2 | [Report](fresh1-native.md) |
| Fresh1 upstream | Changes requested: F1 → R14, F2 → R15, F3 → R13 | [Report](fresh1-upstream.md) |
| Fresh1 validation | Changes requested: V1 → R14 | [Report](fresh1-validation.md) |
| Fresh1 writer corrections | R13–R19 corrected in product docs; pending reviewer acceptance | No native experiments performed; reports preserved unchanged |
| Subsequent review rounds | Pending owning-session dispatch | Append actual results; convergence not yet established |
