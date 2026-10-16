# Independent package audit — 2026-10-16

## Scope and authority

Audit baseline: `4903eb7`. The operator requested independent Astra reviews across
multiple dimensions, including documentation structure/usability and a clear
separation between user documentation and development history. Scope is the whole
native-local Lua package. Initial audit is followed, by explicit operator request,
by an independent Astra design/review process and an implementation plan suitable
for later Saivage handoff. No runtime/package fixes, documentation reorganization,
dependency edits, Saivage execution/submission or push are authorized. This directory contains
review history, not user instructions or a revised acceptance contract.

Saivage was confirmed idle with no active cards before review. The initial working
tree was clean. Original upstream-fix exclusions, narrow build-time Python
exception, MIT/upstream notice policy, Lua5.4/Linux qualification and no HTTP/SWIG
remain applicable. Review package defects and honest limitations, not a dependency
repair campaign. Prior milestone approval does not replace fresh inspection.

## Review plan / progress

- [x] Confirm operator scope: audit including docs; no implementation/reorganization.
- [x] Verify baseline, clean tree and idle autonomous runtime; resolve Astra model.
- [x] Map subsystems and assign independent review dimensions.
- [x] Native boundary, ownership, GC/reentrancy, process lifetime.
- [x] API semantics, Lua ergonomics, conversions, iteration and persistence.
- [x] Build/install/package reproducibility and dependency/VM closure.
- [x] User documentation, navigation and historical separation.
- [x] Test quality, blind spots and reproducibility of qualification claims.
- [x] Dependency integrity, license/notices and source/shipping claims (not legal clearance).
- [x] Reconcile overlapping/unsupported findings and perform bounded validation.
- [x] Consolidate stable per-issue inventory; correction proposal in progress.
- [x] Design confirmed issues using separate Astra writer/reviewer sessions.
- [x] Produce a sequenced implementation plan and self-contained Saivage handoff.
- [x] Obtain independent master review and gated operator execution authorization.
- [x] Notify the root planner, resume through supported controls and verify fresh root execution.
- [ ] Verify fresh child-stage execution after root planning.

All dimension reviewers use fresh `openai/gpt-6-astra` sessions. At most four run
concurrently. Reports must distinguish observed defects, static risks, documented
upstream limits and optional improvements, with exact paths/lines and practical
impact. Review historical baggage/evolutionary bias without manufacturing new
gates. Maximum two editorial clarification rounds per dimension; persistent
disagreement is reported, not hidden behind an approval claim. For confirmed issue
groups, use separate fresh Astra design writer/reviewer sessions with up to two
revision rounds per document, report unresolved disagreement and never invent
approval. Self-contained proposed implementer documents live under
`docs/development/plans/package-fixes-2026-10-16/`; critique and review history stay
under this audit directory. Design/planning authorization is not implementation
or submission authorization.

Dimension reports and consolidated findings are added as they complete.

## Completed dimension reports

- [Native safety](01-NATIVE-SAFETY.md): no actionable defect established by bounded
  static review; not an assertion of absolute safety.
- [API semantics](02-API-SEMANTICS.md): reproduced medium Session reopen validation
  bypass and low Shutdown facade/documentation inconsistency. Findings await
  stable consolidated issue IDs and independently reviewed design proposals.
- [Packaging](03-PACKAGING.md): three medium findings concerning Lua host/header
  ABI rejection, installed-document link closure and harness-dependent user install
  recipes. Ordinary retained installations were not found broken by this review.
- [Documentation](04-DOCUMENTATION.md): no coherent fresh-user installation and
  own-binary journey; fixture/prose mismatch, obsolete commands, stale status and
  field/surface claims, and insufficient user/developer/history separation. The
  report proposes an audience tree and document disposition map without moving
  files. Packaging/documentation overlaps will be consolidated, not counted twice.
- [Baseline execution](07-BASELINE-VALIDATION.md): existing configured build and
  registered tests passed 18/18; broader qualification was not rerun.

## Stable issue inventory

| ID | Issue | Severity | Transversality |
| --- | --- | --- | --- |
| [F01](F01-facade-reopen-policy.md) | Facade reopen option policy | Medium | API |
| [F02](F02-shutdown-surface.md) | Shutdown surface disposition | Low | API/docs |
| [F03](F03-lua-host-abi.md) | Lua host/header ABI rejection | Medium | Build/native boundary |
| [F04](F04-installed-document-closure.md) | Installed document link closure | Medium | Docs/package/tests |
| [F05](F05-user-install-workpaths.md) | Harness-dependent user install paths | Medium | User docs |
| [F06](F06-documentation-audiences.md) | Manual/history separation and currentness | Medium | Documentation |
| [F07](F07-field-representation.md) | Generated scalar/enum wording | Low | Tooling/reference |
| [F08](F08-integration-selection.md) | Silent integration selection | Medium | Test drivers |
| [F09](F09-specialist-state-oracles.md) | Mutation/persistence state oracles | Medium | Tests/claims |
| [F10](F10-leaf-function-oracle.md) | Lua leaf-function semantic oracle | Medium | Tests |
| [F11](F11-runtime-identity.md) | Compiler/runtime identity wording | Low | Notices |
| [F12](F12-bundled-zlib-notice.md) | Exact bundled-zlib notice reference | Low | Notices/install |
| [F13](F13-harness-independent-deliverable.md) | No Saivage references in final package docs except creation credit | Owner requirement | Package docs |
| [F14](F14-github-pages-website.md) | Static GitHub Pages project website | Owner feature request | Docs/site |

F06 consolidates related documentation symptoms rather than treating each page
as a separate repair project. These are provisional dispositions for design;
static gaps are not reproduced product failures. Dependency DEP-01 overlaps F06;
it is not counted again. F13 records the operator's additional delivery condition,
not an independently discovered defect. There are twelve consolidated findings
(eight medium, four low) plus that owner requirement.
F14 is a subsequent requested feature and is not counted as an audit defect.

## Design/planning batches

Three independent Astra authors will develop analysis, alternatives and executable
plans for coherent groups: A (F01–F03, native/facade boundaries), B (F04–F07,
F11–F13, docs/tooling/package audience), C (F08–F10, test selection and assertions).
Each group's design and plan receive a separate fresh Astra reviewer. The combined
metaplan/handoff then receives another fresh independent Astra review. Maximum
two correction rounds; unresolved objections are reported, not called approved.
No implementation or submission is authorized by completion of these documents.

The operator explicitly requested a master plan pointing to the smaller plans.
Its stable location is
[99-MASTER-PLAN.md](../../../development/plans/package-fixes-2026-10-16/99-MASTER-PLAN.md).
It carries the approved final sequence and handoff;
historical `docs/PLAN.md` is not being repurposed as the new execution contract.

### Current independent review status

- A boundaries: revised analysis/design/plan independently approved;
  [final component review](A-DESIGN-PLAN-REVIEW-r2.md).
- B documentation and C regressions: shared manifest/checker/caller interfaces
  reconciled and both tracks independently approved;
  [final joint review](BC-DESIGN-PLAN-REVIEW-r2.md).
- D website: revised analysis/design/plan independently approved, retaining
  Pandoc/Lua after LDoc/Jekyll comparison;
  [final component review](D-DESIGN-PLAN-REVIEW-r2.md).
- Master plan and handoff: independently approved with no required changes;
  [final master review](MASTER-REVIEW-r1.md). All readiness conditions for the
  operator-authorized planner handoff are met. Supported reopen/normal notice/Run
  succeeded; fresh root tool results confirm it read the master and assignment.
  New `card-h` was created for F01–F14. Child execution verification is pending.

These approvals concern proposed documents, not results from unimplemented tests
or permission to execute, deploy, publish, push or change repository settings.

### Subsequent operator execution authorization

The operator subsequently authorized notifying the main planner and resuming the
dedicated Saivage process **once the master plan is ready**. After final independent
approval and committed reconciliation, use a normal planner notice with the master
plan/handoff, supported lifecycle controls and ordinary Run, preserving all history.
Verify fresh owning-planner/child execution. This supersedes the earlier hold on
submission/implementation only at that readiness gate; it does not authorize push,
Pages publication/settings changes, deployment modification or upstream patches.

## Outcome and operations evidence

- [Consolidated outcome](09-AUDIT-RESULTS.md)
- [Planner handoff and execution evidence](08-PLANNER-HANDOFF.md)
