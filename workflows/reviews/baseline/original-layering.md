# Original layering review — re-review

Reviewed revision: `ff23fac5cafadaf1ec088f676b20a489a1fdb902`.

Scope: the original Lua-idiom, public-layering, ownership and scripting review.
Read AGENTS.md, README.md, SPEC.md, DESIGN.md, PLAN.md, COVERAGE.md and
reviews/00-INDEX.md. This is documentation approval in that scope, not native
behavior verification, implementation authorization or approval of other review
dimensions. No product documents were edited and no runtime experiments were run.

## Outstanding necessary corrections

None in this review dimension.

## Previous recommendations and regression checks

- **Two public surfaces, one implementation: addressed.** SPEC:25–40 and
  DESIGN:8–23 distinguish public `lowlevel` from private `_native`, share the
  owning handle and converters, and avoid a record-object hierarchy. COVERAGE:45–59
  explicitly distinguishes the convenience subset from full native coverage.
  Specialized calls remain available without another engine or duplicate SDK
  implementation.
- **Direct results without metadata loss: addressed.** SPEC:42–52 defines
  `value, nil, response`, absent-record normalization, original response evidence,
  complete mutation outcomes and incomplete decompilation records. Reserved
  `response["function"]` access is correct. `check` explicitly tests presence,
  not analysis quality, and preserves the response as its second return.
- **Ownership and stale iterators: addressed.** SPEC:34–36 names a mutable
  Session rather than pretending to expose an immutable Program. SPEC:116–120,
  148–160 and DESIGN:100–104 cover shared aliases and invalidation before buffered
  yields, including escape-hatch calls and failed mutating dispatch. Invalidating
  on every dispatched mutation is more conservative than my original suggestion,
  but coherent and documented.
- **Plain tables, bytes and exact values: addressed.** SPEC:64–104 retains detached
  records, binary strings and immutable UInt64, resolves the uint64/count ambiguity
  per native field type, and distinguishes native zero-based ordinals from Lua
  array positions. String-key guidance addresses userdata key identity. These
  representations favor fidelity without imposing a second object model.
- **Errors and iterator failures: addressed.** SPEC:42–60 distinguishes native
  failure, absent records, false outcome flags and incomplete analysis. Iterators
  raise; explicit page calls remain the non-throwing path. UInt64 helper errors
  are also specified rather than silently left to binding-library coercions.
- **Persistence and native limitations: addressed at the contract level.**
  SPEC:123–144 separates native behavior from facade policy, names no-op discard,
  nonpersistent byte overlays and ignored timeout/read-only options, and avoids
  autosave/rollback promises. The low-level escape hatch preserves native access
  while the facade rejects misleading options. These source observations still
  require the stated qualification; this review does not independently certify
  them.
- **Batches, discovery and staged adoption: addressed.** SPEC:38–40,
  COVERAGE:25–34,45–59 and PLAN:40–51,69–78 preserve native batches, provide a
  named operation inventory, and deliver both surfaces in the first slice.
  Per-operation names, fields, defaults and evidence remain explicit pre-adapter
  gates rather than permission to infer a new API during implementation.
- **Index accuracy:** index:21 records R11 as a proposed correction and
  index:32–39 correctly leaves actual reviewer acceptance to review reports.
  This report supplies approval for the original layering dimension only.

## Preferences and remaining design work — not change requests

- `open(path, options)` and `decompile(...)` were suggested conveniences, not
  correctness requirements. The selected `open(options)` and
  `get_decompilation(...)` are reasonable, especially for native discoverability.
  Exact factory/open key separation and common method signatures must be recorded
  through the already-required manifest before those adapters ship
  (SPEC:30–32; COVERAGE:55–58).
- The corrected SPEC no longer contains a worked Lua example. Restoring a short
  installed example showing open, direct records, binary bytes, iterator errors,
  explicit program close and the native escape hatch would improve readability.
  PLAN:50–51 already requires installed examples; absence of an example in this
  review baseline does not invalidate the now-explicit architecture.
- Third-result metadata and uniform UInt64 outputs impose some scripting cost,
  but their semantics are explicit and internally consistent. They are accepted
  tradeoffs, not reasons to demand another API redesign. Examples should show
  checked UInt64 construction/arithmetic and avoid claiming ordinary JSON encoding
  or numeric formatting works directly on userdata.
- One live client, positive bounded pages and pool_size=1 restrict composability
  and low-level fidelity. They are explicitly declared initial restrictions with
  qualification gates, not hidden facade behavior. Relaxation is a separate
  evidence-based decision, not a requirement of Lua idiomaticity.

The corrected design is sufficiently Lua-idiomatic for the proposed initial
release: a small direct-result facade, faithful public escape hatch, ordinary
records and one ownership/conversion model. No new layering regression requires
product changes.

VERDICT: APPROVED
