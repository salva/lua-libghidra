# Fresh independent review — Lua layering

Reviewed HEAD `7cc4caa97d4fcca3f2f0ffaba9bb6d005e2ffa70`: SPEC, DESIGN, PLAN,
COVERAGE, EXAMPLES, README and AGENTS. No prior review reports or dispositions
were read. Upstream checkout independently confirmed at
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.

## Assessment and evidence

- **Small, idiomatic hybrid:** named modules, colon methods, options tables,
  dense arrays, binary strings and plain records provide a practical Lua surface.
  Session supplies common reads and lazy traversal without a second object model.
  Both layers share conversion/dispatch and ownership (SPEC 28–60; DESIGN 8–23).
  Complete low-level coverage does not force convenience wrappers for every
  specialist operation (COVERAGE 66–83). Local-only/no-SWIG scope is consistent.
- **Metadata survives convenience:** open returns its original detached response;
  unwrapped reads keep their envelope as the third result. `check` preserves that
  response while testing nil rather than truthiness. False outcomes and incomplete
  decompilation remain inspectable (SPEC 33–60; EXAMPLES 19–60). This matches the
  distinct entry-point presence flag in upstream `models.hpp:47–60` and the
  present-but-incomplete decompilation in `local_client.cpp:295–320`.
- **Errors are usable in scripts:** ordinary calls use value/error returns;
  explicit `check` supports fail-fast scripts; iterator failures raise structured
  errors rather than masquerading as exhaustion (SPEC 50–68). Optional function
  absence remains distinguishable from native failure, consistent with upstream
  `local_client.cpp:355–361`. The examples exercise both missing records and
  protected iteration.
- **Cleanup and escape hatch compose:** `native()` shares the owner, and explicit
  close, lexical cleanup and GC have separate specified responsibilities. Aliases
  become closed, detached data survives, and cleanup never saves implicitly
  (SPEC 153–183; DESIGN 19–30; EXAMPLES 56–67). Native mutations invalidate facade
  iterators even with buffered records; generation belongs to shared dispatch,
  not merely facade wrappers (SPEC 202–221; DESIGN 111–115; EXAMPLES 69–87).
- **Real scripting is a qualification requirement:** examples cover opening,
  metadata, bytes, lookup, pages, iteration, cleanup and hybrid mutation.
  M2/M3 explicitly execute them on real fixtures, checking outcomes rather than
  assuming a returned table means successful mutation (PLAN 42–77; upstream
  `local_client.cpp:406–421`). First-slice signatures are concrete; broader
  per-operation contracts must be recorded before those adapters ship.
- **Complexity is justified:** exact UInt64 values add ceremony but avoid address
  corruption; conversion, comparison and table-key rules are explicit (SPEC
  103–150). Bounded iterator checks and pages-only exceptions prevent fabricated
  traversal guarantees. Neither feature requires an additional record hierarchy.

## Necessary fixes

None identified in this review dimension. Approval is for the proposed contract
and layering, not runtime qualification; the documented M0/M1 decisions and
real-backend acceptance gates remain open.

## Optional preferences (not approval conditions)

- A later quick-start could show a shorter fail-fast read loop alongside the
  deliberately exhaustive acceptance example.
- A concise troubleshooting example printing `err.code`, `err.operation` and
  `err.message` would improve interactive use of structured errors. The present
  contract already exposes the required information.

VERDICT APPROVED
