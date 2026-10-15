# Fresh independent review: Lua API layering

Reviewed HEAD `31cb7ee846f6cea4b583e1a4f633c4a46b71d6bd` against upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` at
`/home/salva/g/ml/tmp/lua-libghidra-upstream`.
Read AGENTS.md, README.md, SPEC, DESIGN, PLAN, COVERAGE and EXAMPLES before
forming this assessment; no prior review documents were read. Scope: idiomatic
Lua, practical scripting, high/low layering, ownership, metadata and escape hatch.
This is a documentation review, not runtime qualification.

## Necessary documentation defects

None found in this dimension. No corrective product edits are required.

## Evidence and assessment

- **The hybrid layering is justified and small.** SPEC:28–60 and DESIGN:8–17
  combine faithful low-level envelopes with direct records, binary strings and
  lazy iteration. One conversion/dispatch path avoids divergent semantics.
  COVERAGE:79–97 explicitly separates facade coverage from complete native
  coverage; specialist operations remain reachable without a record-object
  hierarchy. This is a practical Lua interface rather than merely renamed C++.
- **Common scripting retains access to evidence.** SPEC:33–40,50–60 supplies the
  original open response and read envelopes as additional results. Ordinary
  scripts can use `check(call())`; advanced callers retain false flags, absent
  records and incomplete decompilation. Upstream `models.hpp`:47–61,295–306,
  769–783 confirms separate entry-point presence, optional function/decompilation
  records and mutation outcome flags. EXAMPLES:19–42,57–75,90–97 exercises these
  distinctions without reopening merely to obtain metadata.
- **Ownership is explicit across both views.** SPEC:172–196 and DESIGN:19–38
  define shared closure, detached results, mutable program context and the
  distinction between logical program close and native-owner release. The
  escape hatch cannot silently create a second engine or leave the facade with
  stale cached program state. This fits upstream's owning `unique_ptr<IClient>`
  factory (`local.hpp`:36–38). EXAMPLES:60–75 demonstrates cross-view close,
  reopen and surviving-but-closed aliases; PLAN:65–70 requires qualification.
- **Lua conventions are coherent.** SPEC:62–68,113–162 defines nil/error returns,
  structured iterator errors, dense arrays, binary strings and exact UInt64
  values. `check` tests presence rather than outcome truth, avoiding accidental
  loss of false flags. Explicit checked UInt64 arithmetic and string table keys
  impose some verbosity but avoid precision and userdata-key traps. These are
  documented tradeoffs, not defects requiring a second numeric API.
- **The escape hatch remains faithful without overpromising.** SPEC:198–236
  distinguishes facade policy from ignored native options and unsupported
  behavior. Shared dispatch invalidates iterators even for native-view mutations
  (SPEC:238–257; DESIGN:132–136). No rollback, timeout, read-only, string discovery
  or batch atomicity is invented. Native `GetDecompilation`/`ListDecompilations`
  explicitly ignore timeout arguments (`local_client.cpp`:296,325).
- **Scope and delivery are clear.** README:16–21, SPEC:7–26 and PLAN:M0–M5 keep
  native local operation, no SWIG, and qualification distinct from delivery
  claims. Later field manifests and per-family iterator qualification are
  explicit prerequisites, not assertions that unfinished adapters already work.

## Optional preference, not a required fix

EXAMPLES:11–76 is deliberately an acceptance walkthrough. A short introductory
recipe showing open, one `check(session:get_function(address))`, and one loop
would make scripting simplicity easier to see. Keep the existing walkthrough
for metadata and lifecycle behavior. Its current length does not undermine the
API contract or block approval.

## Future qualification, not current documentation defects

The implementation must still demonstrate Lua 5.4 scope cleanup, shared alias
lifetime, exact conversions, metadata preservation, structured errors and
cross-view iterator invalidation on the real engine. PLAN:M1–M3 and M5 already
require these checks. Approval here does not waive those gates or the outstanding
operator decisions.

VERDICT: APPROVED
