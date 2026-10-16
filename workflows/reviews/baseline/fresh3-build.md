# Fresh independent review — build and distribution

Reviewed product HEAD `31cb7ee846f6cea4b583e1a4f633c4a46b71d6bd` against
upstream `/home/salva/g/ml/tmp/lua-libghidra-upstream` at verified clean HEAD
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.
Read AGENTS, README, SPEC, DESIGN, PLAN, COVERAGE and EXAMPLES before assessment;
no prior review reports were read. Scope: CMake/LuaRocks, dependency/spec
provenance, reproducible local builds, licensing and ABI packaging.

## Findings

No necessary concrete documentation corrections found. Required fixes: none.

## Evidence

- DESIGN §5 correctly distinguishes source `libghidra::local_whole` from the
  installed `libghidra::local` archive and requires a consumer whole-archive
  wrapper. Upstream `cpp/CMakeLists.txt:375–391,444–451` defines the wrapper but
  exports only the local archive. Its PIC requirement also addresses upstream's
  Python-only global PIC switch (`:33–44`).
- Source Python/zlib requirements are explicit in README, SPEC, DESIGN and M0.
  Upstream `cpp/CMakeLists.txt:286–298` includes embedding for every local build;
  `cpp/cmake/EmbedSpecs.cmake:12–35` runs Python at configuration time, and
  `cpp/embed_specs.py:20,37` imports zlib and evaluates union annotations.
- Dependency identities match upstream: protobuf v29.3 and httplib v0.16.3
  (`cpp/CMakeLists.txt:72–76,121–125`), engine commit and compiled-spec release
  (`.github/workflows/ci.yml:32,322`). DESIGN does not mistake the engine source
  pin for compiled specs or claim their compatibility is already demonstrated.
  Exact artifact hashes, transitive inputs and offline source overrides are M0
  requirements, not fabricated completed evidence.
- DESIGN requires a deterministic BFD profile, compatible binutils, PIC/link
  closure and actual dependency licenses. This addresses ambient optional BFD
  discovery and its unstable ABI (`cpp/cmake/GhidraSources.cmake:53–77`) and
  auxiliary link dependencies (`:162–186`). Installed protobuf resolution is
  likewise subject to the documented exact dependency lock; upstream's package
  alone uses unversioned `find_dependency(Protobuf)`
  (`cpp/cmake/libghidraConfig.cmake.in:5–19`).
- External and embedded spec profiles have separate acceptance gates; the latter
  explicitly exercises the HOME cache implemented in
  `cpp/src/engine/ghidra_cpp_init.cpp:103–114,277–299`. CMake and LuaRocks staged
  installation, fresh-directory loading, host-VM symbol resolution and both
  standalone/embedded hosts are required by DESIGN §5 and M1/M5.
- README attribution and SPEC §6 accurately distinguish unchanged dependency use
  from conditional derivative-wrapper restrictions (upstream LICENSE §§1.10,
  1.14–1.15,2.1,2.5). Applicability/binding licensing precede implementation;
  notices, source links, attribution and third-party obligations remain explicit
  distribution gates (§§3–4,8). No automatic permission or completed legal
  determination is claimed.

This approves the proposed documentation within this review dimension, not a
built package. Unexecuted M0–M5 experiments and forthcoming rockspec/build files
are intentionally gated work, not present documentation defects.

VERDICT: APPROVED
