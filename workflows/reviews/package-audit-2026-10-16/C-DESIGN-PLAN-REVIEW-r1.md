# C regressions — independent analysis/design/plan review, round 1

Reviewer: fresh independent Astra REVIEWER C, not the author. Reviewed the current
`C-regressions/{01-ANALYSIS,02-DESIGN,03-PLAN}.md` against baseline `4903eb7` and
the current source. This is approval of the proposed correction specification,
not implementation authorization or a runtime qualification result.

## Inspection and limits

Read project AGENTS, SPEC, DESIGN, COVERAGE, PLAN, the package-audit index and
subsystem map, test-quality report, and F08–F10. Rechecked the installed driver,
profiles, absence and document scripts; M4 services/persistence, branch test,
package-foundation route, native project probe, fixture provenance, CMake test
registration, native dispatch and record converters. Inspected the pinned cached
native client's leaf, comment and parameter/local mutation implementations and
the adapter's local identity construction.

`git diff --name-only 4903eb7 HEAD` contained documentation changes only.
Untracked A/B planning documents were left alone. No builds, suites, runtime
experiments, fixture/state mutations, deployment operations or commits were
performed. Only this review report was written.

## Separate verdicts

### Analysis: APPROVED

The problem statements accurately distinguish test/evidence gaps from observed
production defects. In particular:

- `tests/installed-qualification.sh:44–73` really gates document probes,
  persistence, conditional CFG and runtime profiles/absence on the ambient work
  variable. `tests/installed-absence.sh:37` independently hard-codes build hosts;
  `tests/installed-profiles.sh:10` independently hard-codes the spec tree.
- `tests/m4_services.lua:26–52` reads members before edits, uses acknowledgement
  checks for the edits, performs an int-to-int parameter retype, and selects a
  local by array position. `tests/m4_persistence.lua:20–62` does not establish
  most claimed pre-save states before asserting disappearance/reset.
- `tests/m4_services.lua:15–16` only requires nonempty project leaves, whereas
  `tests/project_probe.cpp:19–23` has the two exact authored identities.

Focused and one-level-up alternatives are actually evaluated. Reusing the driver,
adding a thin named target, organizing local mutation blocks, and keeping three
authored address constants local are proportionate choices. No replacement test
framework or new evidence ledger is necessary.

### Design: APPROVED

**F08:** The explicit full/reduced contract closes the selection defect. The table
accounts for existing groups, distinguishes omissions from passes, and retains
three-host execution. Full-mode prerequisite failure cannot become reduced-mode
success. Unique work allocation, isolated cwd/HOME, explicit build/spec paths,
fresh prefixes and retained failure artifacts address the actual script inputs.
The opt-in target delegates selection to one driver and is separate from CTest.
The stated child-call ownership matches current callers; package-foundation is
correctly kept as its existing separate smoke route.

**F09:** Public readback fields needed by the proposal exist in
`src/core_convert.hpp:79–167` and `src/full_convert.hpp:5–20`. Native
`cpp/src/local_client.cpp:1374–1407` explicitly returns true for member-comment
delegation; lines 1448–1515 rebuild prototypes and return requested parameter
fields. Thus the distinction between acknowledgements and fresh inspection is
material, not cosmetic. The design requires real observations before freezing
deterministic expectations, permits accurately attributed ignored/unobservable
writes, and rejects a runtime branch that accepts either result.

The persistence design correctly requires pre-save observable scalar/identity
snapshots and a new owner without reseeding. It does not independently claim
comment loss when the whole member disappears. Distinguishing parameter-kind
records from true locals repairs the current fallback's coverage ambiguity.
Native `cpp/src/local_arch_adapter.cpp:1014–1042` supplies canonical parameter and
storage-based local identities; this supports identity-keyed inspection without
asserting that every conceivable local identity is universally stable.

**F10:** Exact count/order/UInt64 addresses, caller exclusion, limit-one offsets
through exhaustion, inclusive singleton ranges and the shortened range form a
meaningful Lua adapter oracle. `src/owner.cpp:566` forwards all four page fields;
native `cpp/src/local_client.cpp:382–403` filters the ranged function list by
project leaves and then paginates. The proposed checks target these independent
failure modes using the existing native probe's authored expectations. No new
fixture, zero-end assumption or convenience API is introduced.

### Plan: APPROVED

The batches have realistic ownership and dependencies: C changes orchestration
and M4 tests; A supplies the supported ABI/build; B supplies document-layout/probe
compatibility and applies evidence corrections. Shared CMake edits are explicitly
limited to coordinated hunks. Syntax/parser/prerequisite checks precede expensive
execution; bounded real-backend observations precede fixed state assertions.

The full invocation supplies explicit absolute build, staging, work and spec
paths. The reduced command is clearly limited evidence. Fixture hashes are checked
from the repository root, matching the manifest's paths. Focused commands match
existing Lua argument interfaces, and persistence gets a fresh directory. Final
qualification selects either direct or target execution instead of duplicating
the expensive full run. Sensitivity checks exercise dropped edits and incorrect
leaf pages through disposable tests without adding production hooks.

## Historical baggage, architecture and overall assessment

The proposal removes accidental ambient selection rather than preserving it as
policy. It retains useful native probes and bounded historical evidence without
promoting old passes to fresh qualification. No additional approval machinery,
ledger churn, upstream repair campaign, blanket state guarantee or invented
atomicity is required. Conditional real-backend discovery during implementation
is appropriately followed by fixed assertions, not permanent success-shaped
fallbacks. Existing partial-effect and byte-overlap checks remain relevant.

The documents are usable implementer specifications, not a transcript of reviewer
negotiation. Their final-package documentation constraint is correctly separated
from source/tool identifiers; removing harness references from test code is not a
new requirement. Documentation claim corrections are assigned to B rather than
creating competing edits or another accounting system.

No blocking defect was established in analysis, design or plan. Implementation
must still establish the explicitly unresolved native readback outcomes; this
review does not pre-approve those future observations.

Required changes: none.

VERDICT: APPROVED
