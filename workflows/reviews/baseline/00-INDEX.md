# Review correction index

2026-10-15: **documentation review converged** on product-document baseline
`31cb7ee`. All six original reviewers approved their corrections, and the first
two fresh cohorts approved after correction/re-review. A third entirely fresh
cohort returned six approvals without requiring product-document changes.

All R01–R23 corrections are accepted at documentation level. The entries below
retain historical correction-stage wording; the round log and final dispositions
supersede “pending re-review” in those entries. No native implementation, build,
runtime qualification, license determination or Saivage Run is claimed by these
approvals. Operator decisions and M0/M1 experiments remain explicit in PLAN.

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
| R20 | High | Fresh2 API-1 / upstream U1: SPEC grammar/value restrictions, DESIGN boundary validation, COVERAGE effective numeric bounds, PLAN M1/M2; public uint32 ReadBytes restricted to 0..INT32_MAX before allocation/dispatch. Corrected, pending re-review. Source: local_arch_adapter.cpp:502–514 | Reject INT32_MAX+1/UINT32_MAX without requested allocation; validator-only upper-bound acceptance and small real reads |
| R21 | Medium | Fresh2 API-2 / upstream U2 (sentinel): SPEC, DESIGN, COVERAGE and EXAMPLES explicitly preserve zero range_end as UINT64_MAX in applicable methods; no literal zero upper-bound promise. Corrected, pending re-review. Source: local_arch_adapter.cpp:41–50 and normalization call sites | M2 explicit zero/omitted/max/nonzero inclusive bounds, positive start with zero end |
| R22 | Medium | Fresh2 upstream U2 (scan): SPEC/EXAMPLES document linear ListInstructions from exact start until first decode gap; DESIGN/COVERAGE/PLAN require mapped/unmapped/gap cases, no replacement region scanner. Corrected, pending re-review. Source: local_arch_adapter.cpp:547–577 | M2 known-start positive and unmapped/gap negatives, no global absence inference |
| R23 | Medium | Fresh2 upstream U3: SPEC lifecycle matrix/shared public state, DESIGN ownership, COVERAGE and EXAMPLES distinguish logical close from native-owner release; PLAN M2 cross-view close/reopen/NO_PROGRAM/CLOSED and process-slot gates. Corrected, pending re-review. Source: local_client.cpp:1670–1689; decompiler_pool.cpp:102–105 | Program close retains engines/slot; owner close releases owner; historical metadata and invalid iterators persist |

R13–R19 were approved in fresh1 follow-ups; R20–R23 were approved in fresh2
follow-ups. Fresh3 independently approved the complete corrected baseline.
No runtime gate is passed by these documentation dispositions.

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
| Fresh1 writer corrections | be084da; R13–R19 approved in all six follow-ups, recorded in 7cc4caa | Follow-up dispositions in each fresh1 report above; initial findings retained |
| Fresh2 API | Changes requested: API-1 → R20, API-2 → R21 | [Report](fresh2-api.md) |
| Fresh2 build | Approved | [Report](fresh2-build.md) |
| Fresh2 layering | Approved | [Report](fresh2-layering.md) |
| Fresh2 native safety | Approved | [Report](fresh2-native.md) |
| Fresh2 upstream | Changes requested: U1 → R20, U2 → R21/R22, U3 → R23 | [Report](fresh2-upstream.md) |
| Fresh2 validation | Approved | [Report](fresh2-validation.md) |
| Fresh2 writer corrections | 6b9dc5e; all six re-reviews approved, recorded in 31cb7ee | Follow-up dispositions in each fresh2 report; initial findings retained |
| Fresh3 API | Approved independently, no required changes | [Report](fresh3-api.md) |
| Fresh3 build | Approved independently, no required changes | [Report](fresh3-build.md) |
| Fresh3 layering | Approved independently, optional preferences only | [Report](fresh3-layering.md) |
| Fresh3 native safety | Approved independently, no required changes | [Report](fresh3-native.md) |
| Fresh3 upstream | Approved independently, no required changes | [Report](fresh3-upstream.md) |
| Fresh3 validation | Approved independently, no required changes | [Report](fresh3-validation.md) |

## Completion boundary

The loop stops after a completely fresh six-dimension round finds no substantive
documentation corrections. There are no unresolved required review findings.
Optional presentation preferences are not blockers and do not change the approved
contracts. Review approval is readiness to proceed through the documented
prerequisites, not permission to start implementation or proof that its tests pass.

Validation performed on the documents: whitespace checks, local Markdown link
resolution, and Lua 5.4 syntax checks of proposed example blocks. Runtime examples
remain unexecuted until the binding exists. No project service was started.
