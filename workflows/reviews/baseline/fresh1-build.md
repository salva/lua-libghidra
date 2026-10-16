# Fresh independent review: build and deployment

Reviewed project HEAD `699cc8a1efa534cc15f100a487f7afab50215cb1` against upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` in
`/home/salva/g/ml/tmp/lua-libghidra-upstream`.

Read AGENTS, README, SPEC, DESIGN, PLAN and COVERAGE before assessing; no previous
reviews were read. Scope: CMake/LuaRocks, dependency inputs, local specs,
packaging/licensing and embedded-host deployment. This is source/document review,
not runtime qualification. Pending experimental results are not findings.

## F1 — Document the mandatory source-build Python prerequisite (medium)

**Evidence:** README:18–19 describes Python only as a qualification oracle.
DESIGN:117–142 lists the native build prerequisites and locked inputs without
mentioning Python. However, upstream `cpp/CMakeLists.txt:297–298` unconditionally
includes `cmake/EmbedSpecs.cmake` for a local build; that file requires a Python3
interpreter at line 12 and runs `embed_specs.py` at configure time (30–39), even
with `LIBGHIDRA_BUILD_PYTHON=OFF`. The script uses evaluated `list[str] | None`
annotations (`cpp/embed_specs.py:37`, without postponed annotations), requiring
Python 3.10 or newer, and imports Python's zlib module (20).

**Impact:** The documented source-install prerequisites omit a required build
tool. A CMake/LuaRocks source installer with the advertised native toolchain can
fail before compiling; Python is not solely a qualification dependency. The
installed-runtime no-Python promise is compatible with this prerequisite.

**Fix:** Explicitly distinguish source-build, qualification and runtime
dependencies. Add Python >=3.10 with zlib to the upstream source-build profile
and toolchain record; require an early version/module check in the planned
CMake/LuaRocks path. Note that consuming a prebuilt SDK need not run this
generator. Preserve the no-Python installed-runtime requirement.

## F2 — Separate explicit-root and embedded-cache qualification modes (medium)

**Evidence:** DESIGN:144 says to require explicit `ghidra_root` in qualification,
then 145–147 requires cold/warm/missing/unwritable embedded-cache tests. PLAN:84–85
also combines cache tests and explicit specs without distinguishing construction
modes. Upstream `cpp/src/decompiler_pool.cpp:52–61` chooses the default Decompiler
only when `ghidra_root` is empty. `cpp/src/engine/ghidra_decompiler.cpp:190–203`
calls `EmbeddedSpecManager::acquire()` in that default constructor, whereas the
explicit-root constructor calls `startDecompilerLibrary(ghidra_root.c_str(), ...)`
directly. Explicit-root construction therefore bypasses embedded extraction.

**Impact:** Following the unconditional explicit-root qualification instruction
cannot exercise the embedded-cache behavior the same section requires. A clean
or unwritable HOME test could pass while never touching the relevant cache path.
This is a contradictory test prescription, not a demand for results now.

**Fix:** Define two qualification profiles: explicit-root tests for deterministic
external specs (including missing/unreadable roots), and empty-root tests for
embedded specs with isolated cold/warm/unwritable HOME caches. State which
deployment mode needs the cache and require evidence that each profile exercised
its intended constructor/path.

## Other assessed areas

The source/installed whole-archive distinction matches upstream exports. The
protobuf v29.3 pin, PIC requirement, deterministic BFD prerequisite, host-VM
symbol-resolution tests, offline-input gates and separate engine/spec identity
are appropriate for a proposed design. Licensing is explicitly unresolved before
implementation and distinguishes HOS-covered code from third-party materials;
no permission or compatibility result is presumed here. LuaRocks installation
and dependency-lock implementation remain planned gates, not claimed deliverables.

VERDICT: CHANGES_REQUESTED

## Recheck disposition — be084da

Reassessed corrections at `be084da9cb713aee39665d9e6acee476a56d992f`
against the original product baseline, including README, SPEC, DESIGN, PLAN,
COVERAGE and the new EXAMPLES. The original review above is preserved.

- **F1 resolved.** README and SPEC now distinguish source-build Python >=3.10
  with zlib from qualification Python and the Python-free runtime. DESIGN §5
  requires early CMake/LuaRocks version/module checks, recording the interpreter,
  and distinguishes prebuilt-SDK consumption. PLAN M0 carries the prerequisite.
- **F2 resolved.** DESIGN §5 now specifies separate nonempty-root external-spec
  and empty-root embedded-spec profiles, isolated HOME cache tests, and proof of
  constructor selection. PLAN M5 explicitly requires both. External-root success
  can no longer substitute for embedded-cache evidence.

No documentation regression found in the assigned build/deployment scope.
The corrected Ghidra release archive identity agrees with pinned upstream CI;
engine/spec compatibility, dependency locks, packaging and host-ABI qualification
remain explicitly pending gates. The explicit-root usage example is consistent
with the external profile and does not replace the embedded-profile tests.
Approval concerns the documentation only; no build or runtime result is implied.

VERDICT: APPROVED
