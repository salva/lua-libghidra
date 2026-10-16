# Regression selection and semantic evidence: analysis

## Scope and authority

This is a proposed implementer specification for F08–F10 against package baseline
`4903eb7`. Subsequent audit documents do not constitute implementation. The three
deliverables are explicit routine integration selection, observable specialist
mutation/persistence assertions, and an authored Lua leaf-function oracle. This
document does not authorize implementation or submission. Drafts await independent
review. No builds or runtime experiments were performed to prepare this design.

The contract remains native-local, Linux x86-64/PUC Lua 5.4, no HTTP or SWIG, and
the existing pinned SDK/engine profile. The sole approved Python exception is the
unchanged upstream source-build spec generator; no Python test oracle or installed
runtime dependency is introduced. Dependency repairs, engine OOM exploration,
new fixtures and a new test framework are outside these corrections.

## F08: implicit integration selection

[The driver](/tests/installed-qualification.sh#L5) builds and installs into a
build-local prefix, executes standalone/static/shared services, then conditionally
selects document mutation probes, persistence, populated conditional CFG and
profiles/runtime absence based on `SAIVAGE_CARD_WORK_ROOT`. An ordinary successful
invocation silently omits those groups. Its intermediate PASS line is narrower
than full qualification, but there is no final selection summary.

[CTest registration](/cmake/Binding.cmake#L35) covers boundary/ownership and a
native-seeded core test, not the complete installed M2/M3/M4 suites. The recorded
[18/18 baseline](/docs/history/reviews/package-audit-2026-10-16/07-BASELINE-VALIDATION.md#L3)
is credible within that scope, not a clean build or full integration result.

Additional hidden inputs matter: [absence](/tests/installed-absence.sh#L37) uses
`root/build` hosts irrespective of the selected build directory; [profiles](/tests/installed-profiles.sh#L10)
hard-codes the external spec tree. Profiles require non-root permission semantics;
absence needs working user/mount/network namespaces. Neither may become an
automatic success-shaped skip.

Focused option: explicit work/prefix/build inputs and full/reduced mode in the
existing driver. One-level-up option: a named CMake integration target wrapping
that same interface. Choose the focused interface first, plus a thin named target
for discoverability. Do not duplicate selection in CTest or write a scheduler.

## F09: acknowledgements are not observable changes

[Services](/tests/m4_services.lua#L26) reads a member before mutation, then largely
checks flags for member/alias/enum edits and deletion. Parameter retyping is
currently int-to-int. Local response fields echo the request without a fresh
decompilation readback. [Persistence](/tests/m4_persistence.lua#L20) saves many
acknowledged writes and then asserts absence/reset without proving the corresponding
state existed before save. The overlay read is stronger, but currently occurs
after save; move/add the prerequisite read before save too.

Public readback fields already exist in [core conversion](/src/core_convert.hpp#L79):
alias target, member identity/name/type/comment, enum member value/comment,
signature parameters. No production API addition is required for these probes.
The pinned native client unconditionally acknowledges type-member and enum-member
comment calls after delegation; parameter setters rebuild prototypes and echo
requested fields. Acknowledgement therefore cannot substitute for inspection.
This is a test/claim defect, not evidence all those native writes work or fail.

Focused option: add readbacks at the existing mutation sites. One-level-up option:
organize those small blocks into create/read/edit/read/delete/absent sequences,
and reuse the same identities for pre-save/post-reopen comparisons. Choose that
bounded organization, with small local helpers only. Avoid a generic mutation
framework, exhaustive combinations, and new ledgers. Where real upstream behavior
does not expose/honor a write, pin the observed limitation and narrow the claim;
never add a conditional assertion that passes whether the write worked or not.

## F10: nonempty is not a leaf oracle

[The Lua positive](/tests/m4_services.lua#L15) accepts any nonempty project result.
[The authored native probe](/tests/project_probe.cpp#L19) already fixes the range
`0x401106..0x40113f`, exact leaves `0x401106` and `0x40113c`, and excludes caller
`main` at `0x40111f`; [fixture provenance](/tests/fixtures/README.md#L30) explains
the analyzed reference index. A native result alone does not test Lua forwarding,
conversion or pagination.

Focused option: exact addresses and range/page assertions in the existing Lua
services test. One-level-up option: share those constants via the example fixture
manifest. Choose local authored constants with provenance links: changing the
installed example manifest adds coupling without useful reuse for this small
correction. Never derive expected leaves from the function list under test.

## Historical baggage and coordination

Milestone probes grew into a suite while retaining ambient work-root assumptions
and success-flag checks. Preserve useful native reproducers and history, but do
not perpetuate their accidental selection policy or add process ceremony to fix
it. Existing inventories remain source accounting, not runtime proof.

Group A owns API/ABI boundary changes. Group B owns docs/install manifests,
document probes and final audience relocation. C owns driver orchestration and
the two M4 tests; B consumes C's claim corrections and commands. B's configure
export `BUILD/package-documents.txt` is the sole shipping-list projection consumed
by C's source/installed pristine checks in both modes and mutation probes in full
mode. C derives it from the selected build, and passes the actual document root
`PREFIX/share/doc/lua-libghidra`, source root and manifest as absolute paths.
Missing export is a prerequisite failure; no fallback list or legacy interface
is retained. B owns checker/probe implementation; C owns those caller arguments.
The separate website track D consumes B's manual/manifest and adds no C work.
Final package
documentation must have no automation-product references except creation credit;
that condition does not ban identifiers in code, tools or tests. No extra code
renaming is required. Coordinate the shared CMake file by distinct hunks rather
than overwriting another group's changes.
