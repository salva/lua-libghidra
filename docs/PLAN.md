# Implementation plan

Status: proposed, 2026-10-15. No implementation milestone is complete.
[SPEC.md](SPEC.md) defines acceptance; [DESIGN.md](DESIGN.md) owns architecture.
Deployment and Run remain in [operations](../workflows/OPERATIONS.md).

## M0 — Confirm baseline and create a reproducible development environment

- Confirm `0xeb/libghidra` is the intended upstream and approve the Lua 5.4 /
  Linux-first scope, error convention and UInt64 representation.
- Record the inspected commit and select compatible Ghidra specs, sol2 release,
  compiler and dependency pins. Record applicable upstream packaging terms and
  the operator's binding-license choice before publishing packages.
- Inventory Python LocalClient methods, native local-supported methods,
  request/response fields and local limitations in `api/coverage.*`; classify release tiers and
  explicit deferrals. Resolve contradictory upstream docs with narrow experiments.
- Provision build tools, Lua development headers and local engine dependencies.
  Prepare reproducible local binary and analyzed-project fixtures as needed.

Exit: dependency setup is repeatable; manifest identifies exact first-slice calls
and fields. Product choices are recorded, not silently inferred by implementers.

## M1 — Binding-tool and ownership spike

- Build/load `libghidra._native` through the public facade in standalone Lua and
  an existing host state. Use C++20, pinned sol2 and PIC-correct dependencies.
- Implement UInt64, Error, ClientHandle, close/GC/`__close`, and conversions for
  one representative nested response plus a binary string.
- Exercise real local construction/status and missing-spec/input diagnostics;
  test the required local-enabled build profile.
- Validate protected error boundaries, caught native exceptions, invalid inputs,
  allocator failures, repeated create/close/state teardown and sanitizers.
- Record build time, dependency impact and the tool decision. If sol2 is unsuitable,
  change the internal boundary based on evidence while retaining the Lua contract.
  SWIG must not be used in the spike, fallback or later implementation.

Exit: installed module loads, the exact-integer tests pass, and cleanup remains
correct on failure. Stop broad adapter expansion until this boundary is sound.

## M2 — First real end-to-end slice

- Add open/close program, status/capabilities, function listing/lookup, read_bytes,
  instruction listing and get_decompilation with all returned metadata.
- Compile a small authored fixture, record symbols/addresses and exercise the
  offline path at known addresses without requiring full function discovery.
- Run equivalent reads through Python LocalClient and Lua against the same local
  fixtures. Adapt local exploration scenarios into original Lua examples using
  tables and explicit error handling.
- Compare selected Python/C++ and Lua results; establish genuine fallback and
  unsupported-operation cases without pretending these are successful analysis.

Exit: SPEC acceptance 1–5 passes for this slice using the real local engine.
Demonstrate a working example from an installed module.

## M3 — Core API and Lua conveniences

- Add remaining core reads, revisions, save/discard, renames and writes.
- Add lazy core iterators with per-method pagination semantics and failure tests.
- Verify response lifetime after close, request validation and copied-table
  mutation isolation. Exercise fixture writes/renames and save/reopen behavior
  on disposable programs; compare original and modified state deliberately.
- Publish a Python-to-Lua mapping guide, LuaLS annotations and practical examples
  for binary exploration, xrefs, CFG, comments and decompilation quality checks.

Exit: all core rows have passing local-backend evidence or demonstrated
upstream `NOT_SUPPORTED` behavior; core release acceptance is met.

## M4 — Full local coverage

- Complete the remaining operations supported by the pinned native LocalClient,
  including supported edits and listing/analysis queries identified in M0.
- Expand by coherent service groups, each including request validation, all
  response fields, examples, backend evidence and coverage updates.
- Preserve live-only distinctions. Do not fabricate local equivalents for
  Ghidra project management, analysis or other missing backend operations.
- Reconcile the full local operation inventory. Every omission is explicit, with
  a reason and release disposition; no claim of Python parity from method counts.

Exit: the full local coverage target is evidenced. HTTP, async, headless launch,
CLI duplication and additional platforms remain separate future scope.

## M5 — Packaging and release qualification

- Finalize CMake install/export integration and source rockspec; build local-enabled
  packages from clean directories with pinned dependencies.
- Run standalone/embedded Lua, boundary/lifecycle/sanitizer and real local-engine
  suites plus normalized Python comparisons. Validate examples after installation.
- Verify dependency discovery, license/notices, version metadata and offline
  build instructions. Record tested engine/spec/Lua/compiler combinations.
- Publish API reference, coverage report, explicit limitations and changelog.
  Add Lua 5.3 only after the same compatibility gates pass for its ABI.

Exit: all release acceptance criteria pass; unexecuted integration gates prevent
a fully validated release claim. Publication itself requires operator direction.

## Execution conventions

Follow M0 → M1 → M2 → M3 → M4 → M5; M3 may produce a clearly labelled core
release before full local coverage. Keep changes small and commit each implemented
slice with its meaningful tests. Update coverage as methods land, not at the end.
Build/package work starts in M1 and is hardened in M5.

Use authored fixtures rather than sibling PM assets. Keep target work inside
this repository and its isolated environment. Report environment blockers with
the exact pending gate; continue independent docs/conversion work where useful.
Do not replace real-backend verification with mocks or remove acceptance criteria
to make a milestone appear complete.

## Decisions to confirm before implementation

1. Upstream identity and chosen commit/release baseline.
2. Linux x86-64 / Lua 5.4 first, with Lua 5.3 and other platforms later.
3. Local-only scope is confirmed by operator direction; HTTP is deferred.
4. sol2 recommendation, subject to the bounded M1 build/ownership spike. SWIG is
   prohibited by operator direction.
5. Always-exact UInt64 values and `result` / `nil, error` convention.
6. Binding license/distribution intent and desired first-release coverage tier.
