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

## Re-review — `6b9dc5e23b3120cf190065c895d36fc263320b38`

Reviewed product-document changes since `7cc4caa`, especially logical program
state and cross-layer lifecycle behavior. Original assessment above is preserved.

- **No layering regression:** SPEC §4 and DESIGN §1 now explicitly distinguish
  native logical program closure from binding owner release. Session has no
  independent cached program state: native-view close produces local `NO_PROGRAM`
  through Session, while binding close produces `CLOSED` through both views.
  Program closure retains the process client slot; owner release frees it.
- **Source evidence supports the distinction:** upstream
  `local_client.cpp:1670–1689` preserves save failures and otherwise resets
  adapters, loaded state and benchmarks; `decompiler_pool.cpp:102–106` resets
  only adapters. Status/capabilities do not require a loaded program
  (`local_client.cpp:57–89`), and Shutdown propagates close errors (199–213).
  The revised wording corrects the previous unloading implication without adding
  a second lifecycle abstraction.
- **Escape hatch remains coherent:** reopening the same owner updates the
  existing Session's context, while old iterators remain invalidated and detached
  open metadata remains historical. EXAMPLES now demonstrates close through the
  native alias, Session's `NO_PROGRAM`, live owner status and native reopen;
  PLAN M2 explicitly requires cross-view and process-slot qualification. Failed
  lifecycle dispatch still invalidates iterators without fabricating closure.
- **Other changes preserve the hybrid:** the same ReadBytes effective bound and
  zero-end range sentinel apply to both surfaces. Instruction decoding limitations
  are documented rather than hidden behind a replacement scanner. Full envelopes,
  structured errors and the small facade remain intact.

Necessary fixes: none identified. Optional preferences from the original review
remain nonblocking. This is document/API-layering approval, not a claim that the
new lifecycle and boundary acceptance tests have run.

VERDICT APPROVED
