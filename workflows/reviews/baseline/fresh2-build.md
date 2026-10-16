# Fresh independent review — build and packaging

Reviewed baseline `7cc4caa97d4fcca3f2f0ffaba9bb6d005e2ffa70` against local upstream
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` on 2026-10-15. Read SPEC, DESIGN,
PLAN, COVERAGE, README, AGENTS and EXAMPLES before assessing; no review history
was consulted. Scope: reproducible CMake/LuaRocks builds, local spec assets,
packaging, Lua ABI and factual licensing requirements.

## Assessment and evidence

No necessary documentation corrections found in this dimension.

- **Native linkage:** DESIGN:128–133 correctly distinguishes source
  `libghidra::local_whole` from installed `libghidra::local`. Upstream
  `cpp/CMakeLists.txt`:314–323, 375–391, 436–452 defines the static local archive,
  registration-preserving wrapper and exports only the underlying local target.
  Recreating whole-archive handling for installed consumers is an explicit gate.
- **Build tools and dependency closure:** upstream `cpp/CMakeLists.txt`:14–20,
  29–44, 62–131, 346–395 confirms CMake 3.26/C++20, local opt-in, Python-only
  automatic PIC, protobuf/httplib dependencies and BFD/thread link propagation.
  `cpp/cmake/libghidraConfig.cmake.in`:5–22 resolves consumer Protobuf rather than
  bundling its installation. DESIGN:142–162 requires exact locked inputs, PIC,
  offline overrides and verified closure; generated `common.pb.h`:15 enforces
  protobuf `5029003`. These are requirements, not claims that an SDK is already
  relocatable or complete.
- **Python at build time:** `cpp/cmake/EmbedSpecs.cmake`:12–43 runs the generator
  at local configuration irrespective of Python bindings. `cpp/embed_specs.py`:20,
  37 uses zlib and evaluated union annotations. SPEC:16–18 and DESIGN:135–140
  correctly require Python >=3.10 plus zlib without making Python a runtime
  dependency.
- **Specs and provenance:** upstream `.github/workflows/ci.yml`:32,322 contains
  the exact release archive and engine revision recorded in DESIGN:145–150.
  Compatibility and artifact hashes are explicitly pending, not asserted.
  `cpp/src/decompiler_pool.cpp`:51–61 selects distinct empty/explicit-root
  constructors; `cpp/src/engine/ghidra_cpp_init.cpp`:103–114,277–299 implements
  HOME-based extraction/cache handling. DESIGN:164–176 and PLAN:100–103 require
  independent evidence for both profiles.
- **Lua ABI and installation:** SPEC:11–13,240 and DESIGN:178–181 require the
  selected 64-bit-integer Lua 5.4 ABI, existing host VM, dynamic and static-host
  testing, dependency inspection and fresh-directory staged CMake/LuaRocks loads.
  PLAN M1/M5 makes these release gates. EXAMPLES explicitly presents proposed
  Lua 5.4 acceptance examples, not currently executable installation instructions.
- **License facts:** upstream LICENSE §§1.10,1.14–1.15,2.1,2.5–2.6,3–4,8 supports
  SPEC:242–251's distinction between unmodified dependency use and conditional
  derivative-wrapper restrictions, prior applicability/permission determination,
  attribution and separate third-party obligations. README visibly credits Elias
  Bachaalany and discloses AI-assisted source-informed design. DESIGN:158–162
  does not mislabel BFD as permissive and requires actual linked-license evidence.

## Required fixes versus pending qualification

Required fixes: **none**. Dependency digests, exact binutils/Abseil/toolchain
selection, engine/spec compatibility, license applicability, actual rockspec and
CMake implementation, offline installation and host-VM symbol-resolution results
remain intentionally open M0/M1/M5 work. Their absence does not contradict this
explicitly proposed, unimplemented baseline. No build or runtime pass is inferred
from this source review; no product files were changed.

VERDICT: APPROVED

## Re-review — `6b9dc5e`

On 2026-10-15 reviewed the complete product-document diff from `7cc4caa` to
`6b9dc5e23b3120cf190065c895d36fc263320b38` for regressions in this dimension.
The earlier assessment and evidence above remain historical.

Changes add ReadBytes downstream bounds, zero-end range semantics, instruction
decode limitations, shared logical program closure/reopening, and corresponding
examples and qualification cases. These introduce no additional build dependency,
Lua ABI change, packaging assumption or license claim. The INT32_MAX validation
case explicitly avoids requiring a multi-gigabyte allocation; small real reads
remain the positive integration gate.

DESIGN's reproducible-native-build section and PLAN's M0/M5 build and packaging
gates are preserved, including whole-archive linkage, PIC, locked offline inputs,
Python/zlib build requirements, both spec profiles, existing-host-VM resolution
and clean CMake/LuaRocks installation. README and AGENTS are unchanged. No build
implementation or passed runtime qualification is newly claimed.

Required documentation fixes: **none**. Previously recorded pending qualification
remains pending. This re-review is a documentation regression assessment, not an
executed build qualification.

VERDICT: APPROVED
