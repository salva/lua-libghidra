# Package corrections — master plan

**Draft coordination index. Not yet reviewed or ready for implementation.**
The operator requested a master plan linking the smaller implementation plans.
This file will become the self-contained sequenced handoff after the component
designs and plans have passed fresh independent review. It is development
planning material, not final package documentation.

## Component plans

| Track | Scope | Implementation plan | Status |
| --- | --- | --- | --- |
| A — boundaries | Facade reopen/shutdown policy and Lua host/header ABI rejection | `A-boundaries/03-PLAN.md` | Authoring |
| B — documentation | Current user manual, reference generation, notices and installed-document policy | `B-documentation/03-PLAN.md` | Authoring |
| C — regressions | Explicit integration selection, mutation/reload readbacks and exact Lua leaf tests | [Regression plan](C-regressions/03-PLAN.md) | Independent review underway |

Links for A and B will be activated when their drafts exist. Final execution
ordering is not the alphabetical track order; shared-file and contract
dependencies must be reconciled before this plan is ready.

## Required final contents

- Chosen solutions and complete coverage of the stable issue inventory.
- Ordered, coherent implementation batches linking each component plan.
- Importance/transversality, shared-file ownership and dependency graph.
- Concrete prerequisites and validation commands, supported profiles and truthful
  distinctions between fresh results and applicable historical evidence.
- Per-batch acceptance and bounded rollback, without discarding unrelated work.
- Final package documentation separate from development history, without Saivage
  references except optional creation acknowledgment. This restriction does not
  apply to source code, tools or tests.
- Self-contained implementation handoff and explicit unresolved decisions.

## Authority

Planning and independent review are authorized. Implementation, submission to
Saivage, deployment changes and push remain unapproved. Completion of this master
plan does not itself authorize execution or grant distribution/legal clearance.
