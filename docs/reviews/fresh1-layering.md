# Fresh independent review — Lua layering

Reviewed project HEAD `699cc8a1efa534cc15f100a487f7afab50215cb1` against upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` (both checked locally).
Read AGENTS, README, SPEC, DESIGN, PLAN and COVERAGE, then relevant upstream
public models, session API and local factory. No prior reviews were read.
This is a documentation/architecture assessment, not runtime qualification.

## Assessment

The two-surface hybrid is appropriate and acceptably small. There is no reason
to collapse it into one API or replace it with a record-object hierarchy.
SPEC 25–52 and DESIGN 10–23 provide one conversion/dispatch implementation,
plain detached records, a Lua convenience facade and a faithful escape hatch.
The user accepts this architecture; layer count is not a finding.

Strong decisions include:

- `value, nil, response` preserves read metadata while permitting ordinary Lua
  error handling. Incomplete decompilation remains inspectable rather than
  being confused with a missing result (SPEC 44–52).
- Mutations retain outcome tables, so `renamed=false` is not transformed into
  success merely because a call returned a table. `check` explicitly checks
  presence, not business success.
- Session and `native()` share one owner. Idempotent closure, surviving closed
  aliases, detached results and cross-surface iterator invalidation are explicit
  (SPEC 114–153; DESIGN 19–30, 100–104).
- Specialist operations stay available without inflating the facade; native
  batches remain batches (COVERAGE 47–53; SPEC 38–40).
- Exact UInt64 values impose some Lua friction, but the contract is consistent,
  explains table-key identity and avoids silent precision loss. This is a
  reasonable tradeoff, not a reason to request a second numeric conversion path.

## Required substantive documentation changes

### L1 — Preserve the initial open response through the Session factory

**Evidence:** SPEC 30–36 says `open(options)` returns a Session. Its third-result
preservation rule is explicitly for unwrapped facade reads (44–48); neither
that rule nor COVERAGE 47–53 defines how to obtain the response consumed by the
factory. Upstream `cpp/include/libghidra/models.hpp:47–61` defines meaningful
`OpenProgramResponse` fields: program name, language/compiler metadata, image
base, hashes, executable format, entry point and its independent presence flag.

**Impact:** An implementation can comply with the written factory contract
while throwing away this metadata. `session:native()` exposes subsequent native
calls, not the response of the already-completed open. Reopening to obtain it is
a lifecycle operation and invalidates iterators; it is not a metadata accessor.
This is a concrete gap in the otherwise metadata-preserving hybrid.

**Fix:** Specify the factory's complete success/error tuple and expose its
detached open response. A minimal consistent choice is
`session, nil, open_response` on success, compatible with `check`; an explicitly
documented accessor is also sufficient. Define that it describes that particular
open, not continuously refreshed Session state after native close/reopen.
Retain all fields, including `has_entry_point=false` and zero addresses, and
retain the caveat that architecture metadata is not authoritative detection.
Add a first-slice acceptance assertion for metadata preservation through `open`.

### L2 — Supply a concrete first-slice Lua usage contract and examples

**Evidence:** SPEC 30–32 promises separately documented/validated factory and
open keys, but supplies no option layout. Upstream distinguishes
`LocalClientOptions` (`local.hpp:16–33`) from `OpenProgramRequest`
(`session.hpp:14–23`). SPEC names `get_function(address)` but does not establish
representative page/iterator call shapes or where `check` and `u64` are exported.
COVERAGE 55–58 defers exact mappings until adapters land. None of the reviewed
product documents contains a Lua usage example; PLAN 50–51 and 87 defer examples
to implementation/release.

**Impact:** The architecture is understandable, but a reader cannot yet write
even the proposed open/read/iterate/close workflow without inventing API choices.
This prevents review of the claimed Lua usability and leaves implementers to
choose the most visible part of the contract. This finding does not require
freezing every specialist adapter before M0.

**Fix:** Document a small representative first-slice call grammar and add clearly
labelled proposed examples covering:

1. module imports, explicit factory/open option separation and an architecture
   hint, with `check` and Lua 5.4 `<close>`;
2. function lookup and binary byte access, showing the full third-result tuple
   and missing-result handling;
3. one bounded page call and its lazy iterator counterpart, including where
   options/page size go and how structured iterator errors are caught;
4. the same Session's native escape hatch, preserving a mutation outcome flag,
   plus the consequence for an existing iterator;
5. retrieval of the open metadata from L1 and closure of a surviving alias.

Keep examples short and coherent, and add their execution against the real
backend to M2. They should demonstrate the shared design rather than introduce
another wrapper layer or promise unqualified behavior.

## Optional preferences, not blockers

- A compact return-shape table would make the read/mutation/iterator distinction
  easier to scan; the existing prose already establishes most of it correctly.
- Naming `native()` as `lowlevel()` might be more literal, but the current name
  is clearly defined and does not imply a raw pointer. No rename is required.
- Broad facade expansion, arithmetic metamethods and record methods are not
  necessary for idiomatic Lua. Their absence is intentional simplicity.

No product files were edited and no runtime tests were run. The two findings
require documentation fixes, not a change to the accepted two-layer direction.

VERDICT: CHANGES_REQUESTED
