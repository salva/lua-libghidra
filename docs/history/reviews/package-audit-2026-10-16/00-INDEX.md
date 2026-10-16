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
- [ ] User documentation, navigation and historical separation.
- [ ] Test quality, blind spots and reproducibility of qualification claims.
- [ ] Dependency integrity, license/notices and source/shipping claims (not legal clearance).
- [ ] Reconcile overlapping/unsupported findings and perform bounded validation.
- [ ] Consolidate stable per-issue inventory and a prioritized correction proposal.
- [ ] Design confirmed issues using separate Astra writer/reviewer sessions.
- [ ] Produce a sequenced implementation plan and self-contained Saivage handoff.
- [ ] Report outcome; obtain approval before implementation or Saivage submission.

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
- [Baseline execution](07-BASELINE-VALIDATION.md): existing configured build and
  registered tests passed 18/18; broader qualification was not rerun.
