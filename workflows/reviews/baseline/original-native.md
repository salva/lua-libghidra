# Original native-safety review — corrected baseline

Reviewed project commit `ff23fac5cafadaf1ec088f676b20a489a1fdb902` against
upstream `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.
Dimension: C++/Lua ABI, sol2 suitability, longjmp/exception/allocation safety,
ownership/GC/__close, concurrency and exact numeric conversion.

Read AGENTS.md, SPEC.md, DESIGN.md, PLAN.md, COVERAGE.md and
reviews/00-INDEX.md. Rechecked the upstream pagination, parallel aggregation and
engine construction/destruction source cited below. This is documentation review,
not executed qualification. No builds, fault injection or runtime tests were run.

## Original findings

### 1. High: protected marshalling did not establish all-frame safety — resolved in design

`DESIGN.md:34–59` now explicitly requires trivial automatic storage throughout
every jumped frame, external native owners, separate native execution, departure
from catch frames before marshalling, and destruction before propagating Lua
errors. Registration, validation, errors, UInt64 and userdata publication are
included. `PLAN.md:29–38` makes the audit and failure qualification a blocking M1
gate rather than assuming sol2 protects C-built Lua.

The original mechanism remains valid: pcall protects its caller, not C++ owners
inside frames crossed by longjmp. sol2's authoritative error documentation
explicitly warns about skipped destructors under C-built Lua:
<https://sol2.readthedocs.io/en/latest/errors.html#destructors-and-safety>.
The revised raw-C-API/external-owner architecture is feasible; sol2 is now an
optional implementation choice whose internal frames must satisfy the same rule.
No sol2 suitability or allocation-safety experiment is claimed passed.

### 2. High: individually valid page integers can overflow upstream — resolved in contract

Upstream `cpp/src/local_client.cpp:29–34` still computes signed `start + limit`
before clamping. `SPEC.md:106–112` now requires positive sizes, native INT_MAX
bounds and overflow-safe validation of `offset + limit <= INT_MAX` on both
surfaces. For supported nonnegative collection sizes, start is at most offset,
so this compound restriction addresses the identified addition overflow.

`DESIGN.md:63–66` additionally records the native collection-size narrowing and
excludes collections at/above INT_MAX; qualification of supported collection
sizes remains required. `PLAN.md:55–59` names compound-boundary tests.
This is a specified binding mitigation, not an upstream fix or test result.

### 3. High: parallel aggregation destabilizes pagination — resolved by scope restriction

Upstream `cpp/src/local_client.cpp:424–461` appends block results in asynchronous
completion order before applying pagination. The source-proven mechanism is
unchanged. `SPEC.md:17` rejects pool sizes other than one, and
`DESIGN.md:67–69` explains why per-page sorting cannot repair it.

Serial ordering is not assumed automatically: `DESIGN.md:71–98` requires
operation-specific identities/comparators and withholds iterators where order is
unqualified. `SPEC.md:148–160` and `PLAN.md:55–59` cover generation changes,
buffered yields and serial ordering. These are coherent restrictions and gates.

### 4. High: independent-state/process-global engine safety was unqualified — resolved in scope

Upstream `cpp/src/engine/ghidra_decompiler.cpp:189–212` initializes the engine
library per engine and invokes shutdown per destruction. The original review
identified a qualification question, not a demonstrated race in a selected
engine revision.

`SPEC.md:17–23` now limits the process to one live binding-owned client, rejects
a second with CLIENT_IN_USE, serializes native phases, and excludes independently
managed engines in the same process. `DESIGN.md:25–30` prohibits holding the
guard across longjmp-capable Lua allocations and requires sequential/state
teardown tests. `PLAN.md:33–35` retains the engine-global audit. This adequately
bounds the initial contract without falsely asserting native concurrency safety.

### 5. Medium: close versus final object destruction was underspecified — resolved in design

`DESIGN.md:19–23` separates owner reset by close/__close from final C++ handle
destruction by __gc, includes partial-publication state, shared aliases and
preservation of the active scope error. `DESIGN.md:50–53` requires finalizable
Lua storage before native ownership transfer. `SPEC.md:116–119` makes surviving
aliases explicitly closed. `PLAN.md:31–34` requires publication-failure,
alias/error-unwinding and double-finalization qualification. These address the
original object-lifetime mechanism rather than merely promising idempotence.

## Regression and integration checks

- Exact values: `SPEC.md:71–104` consistently distinguishes uint64 userdata from
  signed/narrow integral fields, preserves zero-based ordinals, rejects floating
  inputs and specifies checked helper/error behavior. The representative native
  field table and `COVERAGE.md:55–58` make complete field mapping a delivery gate.
- ABI: `DESIGN.md:149–152` explicitly requires host-VM symbol resolution for both
  dynamic and statically embedded Lua; `PLAN.md:29–38` blocks expansion until
  installed loading and no-second-VM checks pass.
- Shared ownership: the new two-surface API shares one handle
  (`SPEC.md:27–36`), and mutation classification is shared before dispatch
  (`DESIGN.md:100–104`). It does not introduce a second engine or an independently
  closable borrowed owner.
- Error phases: native exceptions must remain inside C++, whereas allocation
  and runtime failures remain Lua errors (`SPEC.md:54–60`). The all-frame rules
  apply to translating those failures as well as successful responses.
- `COVERAGE.md:7–8` and `reviews/00-INDEX.md:3–7` correctly distinguish planned
  corrections from runtime evidence and reviewer convergence.

No new substantive documentation defect was identified in this dimension.

## Outstanding qualification, not document change requests

M0/M1 must still establish exact dependency/engine compatibility, the complete
allocation/exception frame audit, safe partial construction and process-guard
release, sequential engine lifecycle, and actual host Lua ABI resolution.
M2/M3 must establish field conversion and per-operation pagination behavior;
M5 remains required for release. Sanitizers supplement the structural longjmp
audit; their passing alone would not prove that all skipped-destructor paths
have been excluded. None of these experiments has passed by virtue of this review.

Documentation is ready for the specified gated work, subject to the existing
operator and M0 prerequisites. This approval is limited to the native-safety
dimension and does not declare overall review convergence or runtime readiness.

VERDICT APPROVED
