# Original validation/planning review — re-review

Reviewed revision: `ff23fac5cafadaf1ec088f676b20a489a1fdb902`.
Dimension: acceptance, real fixtures, milestone dependencies, autonomous execution
clarity, scope consistency and unnecessary infrastructure. Reviewed SPEC, DESIGN,
PLAN, COVERAGE, README, review index and operations against the original findings.
This verdict concerns documentation readiness, not executed runtime qualification
or authorization to implement, deploy or publish.

## Original findings

| Finding | Disposition | Corrected evidence |
| --- | --- | --- |
| Unsupported responses could satisfy core completion | Resolved | PLAN:61–67 requires positive supported core cases; COVERAGE:7–8 requires real supported inputs and separate negative tests. SPEC §6 applies this rule generally. |
| Analyzed fixtures lacked a readiness dependency | Resolved | PLAN:15–25 requires authored inputs, build/generator provenance, hashes and positive native binary/project evidence before M1. Development Java/Ghidra is expressly allowed without becoming a runtime dependency. |
| Decompilation lacked a positive semantic oracle | Resolved | PLAN:19–21 and 45–51 require completed nonfallback decompilation with expected semantics plus known byte/instruction results, followed by both public surfaces. SPEC §6 distinguishes fallback tests from successful qualification. |
| Save/discard tests lacked a behavioral oracle | Resolved | SPEC §4 defines the native/facade behavior matrix. PLAN:61–64 and DESIGN §4 require per-category reopen evidence, no-op discard, byte-overlay limitations and destructor no-save behavior. Returned flags no longer imply rollback or complete persistence. |
| Python oracle was optional and mandatory | Resolved | SPEC §6, PLAN:46–47 and 82–85 consistently require qualification comparisons; README:18–19 excludes Python as an installed runtime dependency. |
| Core release could bypass release qualification | Resolved | PLAN:66–67, 80–92 explicitly routes either coverage tier through M5 without requiring M4 for a core release. |

## Regression and readiness assessment

No outstanding substantive findings in this review dimension.

- COVERAGE names the tiered native scope and requires per-operation fields,
  defaults, fixture assertions and pagination evidence before adapters ship
  (lines 55–60). M0 reconciliation is an explicit task, not a claim that a
  completed implementation manifest already exists.
- M0 establishes real dependency/fixture feasibility; M1 blocks broad expansion
  on ownership/build safety; M2 demonstrates real binding behavior; M3/M4 demand
  positive coverage; M5 qualifies either release tier. These gates are objectively
  evaluable once implemented. Unexecuted experiments correctly remain pending.
- The two surfaces share dispatch, conversion and ownership. Handwritten adapters,
  bounded iterator state and a direct-C-API fallback avoid requiring a generator,
  separate transport layer or independent facade engine. The demanding ownership
  and fixture checks address concrete native-binding risks rather than substituting
  infrastructure for functionality.
- Local-only scope and the SWIG prohibition remain explicit. Development fixture
  generation and transitive native dependencies do not add a public remote API.
- The review index accurately labels writer corrections as proposed and does not
  claim reviewer convergence. This report approves only its assigned dimension.

Operator approval of the proposed surfaces/restrictions, platform/tier and license
determination remains necessary as PLAN:102–105 states. Those are declared choices
and prerequisites, not unresolved documentation contradictions. Exact fixture
commands, dependency digests and experimental evidence are M0/M1 deliverables;
their absence at this documentation stage is not a runtime pass or a review defect.

## Final verdict

VERDICT APPROVED
