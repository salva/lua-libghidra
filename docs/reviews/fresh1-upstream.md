# Fresh independent review — native upstream compatibility

Reviewed project HEAD `699cc8a1efa534cc15f100a487f7afab50215cb1` against upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` in
`/home/salva/g/ml/tmp/lua-libghidra-upstream`. Read AGENTS, README, SPEC, DESIGN,
PLAN and COVERAGE without reading previous reviews. Source review only; future
qualification gates are not required to have run for this review. Paths beginning
`cpp/` below refer to that upstream checkout.

## F1 — Distinguish defined-string stub compatibility from supported discovery

**Priority: medium.** `docs/COVERAGE.md:6-8,24` puts ListDefinedStrings among core
operations requiring a positive real supported case, without identifying that it
cannot discover strings at this pin. `docs/DESIGN.md:78` also lists defined-string
iterator identity alongside productive listing families.

Evidence: `cpp/src/local_client.cpp:1299-1308` ignores both range and pagination
arguments and always returns an empty successful response after the loaded-program
check. This is not a fixture-dependent lack of strings. Meanwhile the native
capability response advertises listing support including strings
(`cpp/src/local_client.cpp:74-86`), and advertises types as full CRUD despite
DeleteTypeEnum being an excluded default and CreateType accepting only structs
(`cpp/src/local_client.cpp:685-705`). These broad native capability labels must
not become the binding's operation-level support oracle.

Recommendation: retain faithful ListDefinedStrings exposure, but explicitly label
it an always-empty compatibility operation, including ignored fields. Define its
positive test as faithful empty-success behavior on a loaded fixture, not actual
string discovery. State that GetCapabilities is an unmodified upstream subsystem
advertisement, distinct from the binding's qualified per-operation inventory.

## F2 — Extend the known ignored-field limitations beyond open and timeout

**Priority: medium.** `docs/SPEC.md:136-144` documents ignored native options, but
the full-tier mutation inventory at `docs/COVERAGE.md:27-30` omits consequential
known ignored fields. The future field manifest is useful, but these existing
source-proven limitations should already qualify the proposed coverage baseline.

Evidence in `cpp/src/local_client.cpp`:

- `560-575`: DeleteSymbol ignores `name` and selects by address. Supplying a name
  is not a deletion guard.
- `685-705`: CreateType ignores `size` and supports only `kind == "struct"`.
- `707-739`: AddTypeMember ignores `size`; placement is appended after existing
  fields and uses the referenced type through defineStruct.
- `742-757`: CreateTypeEnum ignores both `width` and `is_signed` when calling
  defineEnum.

Recommendation: add these to a pinned limitations table and require the manifest
to preserve them explicitly. Lowlevel can accept the native fields faithfully,
but documentation must not imply that they constrain the mutation. Include
ignored-field and unsupported-kind assertions in the planned tests; no upstream
implementation change is requested.

## F3 — Signature pagination uses input-function offsets, not output counts

**Priority: high.** The universal rule “advance by actual returned count” in
`docs/SPEC.md:157-160` and `docs/DESIGN.md:96-98` does not match
ListFunctionSignatures, which is included in core coverage
(`docs/COVERAGE.md:23`) and the iterator identity table (`docs/DESIGN.md:77`).

Evidence: `cpp/src/local_client.cpp:1059-1071` paginates functions first, then
omits functions for which getFunctionSignature returns no record. Consequently,
an input page of two functions may return one signature; advancing offset by one
revisits an already-consumed function. A page with no extractable signatures may
also precede later valid signatures, so an empty result does not prove exhaustion
of the input function sequence. Serial ordering and duplicate-page detection
cannot correct this offset-domain mismatch.

Recommendation: explicitly mark this family pages-only under the existing
qualification fallback, unless a separate input-aware traversal is designed.
Qualify the generic count/empty-page rules as applying only to operations whose
offset domain is the returned-record sequence. If a signature iterator is kept,
specify how it obtains input progress/exhaustion (for example from function pages)
and test missing signatures inside and across pages. This is a correction to the
planned algorithm, not a demand to execute future gates now.

## Other checked claims

The documented no-op discard, ignored read_only/project_name and decompilation
timeouts, empty-state-path close/save distinction, primary-only best-effort reload,
and selective type/symbol restoration agree with the inspected source:
`cpp/src/local_client.cpp:93-189,295-325,1670-1689`,
`cpp/src/decompiler_pool.cpp:87-95`, and
`cpp/src/engine/ghidra_decompiler.cpp:1035-1089`. The operation inventory broadly
matches the LocalClient overrides, and correctly excludes default-only APIs.
Local-only scope and the SWIG exclusion are consistent throughout. No runtime
acceptance or future persistence experiment is represented as completed.

VERDICT: CHANGES_REQUESTED

## Recheck — be084da

Rechecked corrections at `be084da9cb713aee39665d9e6acee476a56d992f`
against the same upstream pin. Reviewed the product-document changes, including
the new proposed examples, for resolution and regressions. Original assessment
above is preserved; this disposition supersedes its verdict.

- **F1 resolved.** `docs/COVERAGE.md:24-25,46-58` separates the constant-empty
  compatibility operation and coarse capability advertisements from actual
  discovery/support. `docs/SPEC.md:192-201,232-235` supplies the limitation and
  fidelity-only acceptance exception. DESIGN removes its iterator and PLAN
  carries the corresponding fidelity gate. No unattainable populated-string
  requirement remains.
- **F2 resolved.** `docs/SPEC.md:185-201` and `docs/COVERAGE.md:59-63` explicitly
  cover the ignored deletion selector, sizes, enum width/signedness and
  struct-only creation. `docs/PLAN.md:90-92` carries the behavior checks without
  inventing enforcement or replacement native implementations.
- **F3 resolved.** `docs/SPEC.md:213-220`, `docs/DESIGN.md:99-112` and
  `docs/COVERAGE.md:51-53` restrict the generic advancement rule to the correct
  offset domain and make signature listing pages-only. Candidate filtering,
  empty-page ambiguity and a separately designed future traversal are explicit;
  PLAN preserves the pages-only scope.

No substantive regression found in this review dimension. Added open-response
examples preserve detached metadata and shared ownership; the build/runtime
Python distinction and corrected CI archive provenance agree with inspected
upstream `cpp/embed_specs.py:20,37` and `.github/workflows/ci.yml:32`.
Persistence limitations, local-only scope and the SWIG exclusion remain intact.
This approves the documentation corrections, not implementation or execution of
the still-planned qualification gates.

VERDICT: APPROVED
