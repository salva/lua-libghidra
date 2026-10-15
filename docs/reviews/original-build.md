# Original build/packaging reviewer — re-review

Reviewed revision: `ff23fac5cafadaf1ec088f676b20a489a1fdb902`.
Upstream inspected: `d51ca813ae1b6b59519551a9be8c0b1ad74d862d` in
`/home/salva/g/ml/tmp/lua-libghidra-upstream/`.

Scope: CMake/LuaRocks integration, native dependencies, standalone/embedded Lua
ABI, offline engine/spec packaging, pins and applicable distribution terms.
Read AGENTS.md, SPEC, DESIGN, PLAN, COVERAGE, README and reviews/00-INDEX.md.
This approves documentation readiness only; no build or runtime qualification
was performed. No product files were changed.

## Previous findings

| Finding | Disposition and documentation evidence | Upstream evidence |
| --- | --- | --- |
| Whole-archive registration and installed SDK wrapper | Resolved: DESIGN:117–122 requires both paths; PLAN M1 tests them. | cpp/CMakeLists.txt:375–391,436–452; cpp/bindings/CMakeLists.txt:29 |
| Engine source alone lacks compiled Sleigh grammars | Resolved: DESIGN:124–133 separates engine and compiled-spec inputs, hashes and compatibility; PLAN M0 requires positive native decompilation before M1. | .github/workflows/ci.yml:27–32,322,354–360; cpp/embed_specs.py:24,48–61,129–132 |
| License applicability deferred until publication | Resolved: SPEC §6 and PLAN M0 require determination before implementation, preserving both the unchanged-dependency permission and conditional derivative threshold. Distribution notices/source links and visible attribution are required; README identifies author/origin and AI-assisted review. | LICENSE:134–138,161–178,294–299,341–352,387–415 |
| SDK versus offline-source dependency closure | Resolved: DESIGN:117–142 rejects HTTP-only SDKs, specifies exact protobuf/httplib versions, all-input overrides and network-disabled builds; PLAN M1/M5 requires installed and offline paths. | cpp/CMakeLists.txt:67–79,85–92,121–131; cpp/cmake/libghidraConfig.cmake.in:5–19; cpp/generated/libghidra/common.pb.h:14–19; .github/workflows/ci.yml:127–142 |
| Ambient BFD selection, static PIC and third-party terms | Resolved: DESIGN:135–142 requires a pinned BFD profile, qualified archives/shared libraries and actual linked-library obligations. | cpp/cmake/GhidraSources.cmake:64–80,170–183; cpp/CMakeLists.txt:356–367; LICENSE:496–502 |
| Embedded specs still need runtime cache access | Resolved: DESIGN:144–147 and PLAN M5 require explicit-root and cold/unwritable-cache tests and diagnostics. | cpp/src/engine/ghidra_cpp_init.cpp:106–115,273–312 |
| Embedded-host ABI test underspecified | Resolved at design level: DESIGN:149–152 and PLAN M1 require dynamic and static-exporting hosts, symbol/dependency inspection and the existing VM; SPEC §1 retains Lua 5.4/64-bit integers. | Binding-owned requirement; execution remains an M1 gate. |

## Regression and readiness assessment

COVERAGE:7–8 explicitly marks all rows unqualified; its public-layer mapping
does not introduce another native engine or runtime dependency. PLAN M5 applies
packaging qualification to both core and full releases. The review index clearly
distinguishes writer corrections from reviewer acceptance and runtime evidence.
Local-only scope and the SWIG prohibition remain intact.

No substantive outstanding documentation findings in this dimension.

Exact artifact acquisition remains M0 work, not an approved lockfile. In
particular, DESIGN's `specs12.1.3` candidate is not a verified artifact identity:
the inspected upstream CI actually names the Ghidra 12.1.3 distribution ZIP at
`.github/workflows/ci.yml:32`. Record the selected artifact's real URL/digest and
engine compatibility before treating it as a reproducible input, as the revised
design already requires. Likewise, license applicability, linked third-party
terms, source/SDK dependency closure, PIC and host-VM resolution remain explicit
unexecuted gates, not reasons to withhold documentation approval.

VERDICT: APPROVED
