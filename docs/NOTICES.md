# Licenses, notices and distribution requirements

Original Lua/C++ wrapper and documentation: Copyright 2026 Salvador Fandiño,
[MIT](../LICENSE). Native integration uses libghidra by Elias Bachaalany,
[upstream](https://github.com/0xeb/libghidra), pinned at
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`. This revision reports version 0.0.9;
that does not establish equivalence to a release tag.
Upstream's Human-Origin Source License v1.0 is retained
verbatim in [libghidra notice](notices/libghidra.txt).
Use this page to find the exact dependency notices and the obligations to consider
before distributing artifacts. The wrapper's MIT license does not replace
dependency terms or applicable upstream conditions for wrappers. This page is not
legal clearance or a finding that the combined licenses are compatible.

## Dependency versions and notices

The three installed lock files record exact URLs, revisions and SHA256 hashes:
[native-inputs.lock.json](../native-inputs.lock.json),
[native-patched.lock.json](../native-patched.lock.json), and
[native-system.lock.json](../native-system.lock.json). They identify the selected
inputs; they do not show that all required corresponding-source archives have been
obtained or delivered.

| Component | Selected identity | Retained license/notice |
| --- | --- | --- |
| libghidra | d51ca813ae1b6b59519551a9be8c0b1ad74d862d | Human-Origin Source License v1.0, libghidra.txt |
| ghidra engine | 2035b8153afaf7ce2edde24a2c80b62bbcf5127f | Apache-2.0, engine.txt; bundled third-party terms remain applicable |
| compiled Sleigh specs | Ghidra 12.1.3 PUBLIC 20260817 / Ghidra_12.1.3_build | Ghidra source/release license obligations, engine.txt; archive URL/hash in input lock |
| Protobuf | v29.3, generated ABI 5029003 | BSD-3-Clause, protobuf.txt |
| Abseil | 20240722.0 | Apache-2.0, abseil.txt |
| utf8_range | bundled in pinned Protobuf | MIT, utf8-range.txt |
| httplib | v0.16.3 (input, not an HTTP implementation claim) | MIT, httplib.txt |
| engine zlib | bundled 1.3.1 in pinned engine | zlib terms, [exact bundled notice](notices/engine-zlib.txt) |
| system zlib | Ubuntu zlib1g 1:1.3.dfsg-3.1ubuntu2.2 | [system notice](notices/zlib1g.txt) |
| BFD / sframe | Ubuntu binutils 2.42-4ubuntu2.10 shared libraries | binutils.txt, GPL terms (not permissive) |
| zstd | selected system binary/source lock | libzstd1.txt, retained dual-license terms |
| C runtime | Ubuntu libc6 2.39-0ubuntu8.9 | libc6.txt, LGPL terms |
| C++ / GCC runtime | GCC 14 libstdc++6 and libgcc-s1 14.2.0-4ubuntu2~24.04.1 (source gcc-14) | libstdc++6.txt, GPL/LGPL plus applicable exceptions |
| Lua host | PUC Lua 5.4.6, Ubuntu 5.4.6-3build2 | MIT, lua.txt; borrowed from host, not linked as a second VM |

Direct retained notices:

[libghidra.txt](notices/libghidra.txt), [engine.txt](notices/engine.txt), [protobuf.txt](notices/protobuf.txt), [abseil.txt](notices/abseil.txt), [utf8-range.txt](notices/utf8-range.txt), [httplib.txt](notices/httplib.txt), [binutils.txt](notices/binutils.txt), [libiberty-dev.txt](notices/libiberty-dev.txt), [zlib1g.txt](notices/zlib1g.txt), [libzstd1.txt](notices/libzstd1.txt), [libc6.txt](notices/libc6.txt), [libstdc++6.txt](notices/libstdc++6.txt), [lua.txt](notices/lua.txt).


The `libiberty-dev.txt` notice is retained because the package is a build input;
the selected shared BFD profile does **not** link `libiberty.a`. Not every input
appears as a dynamically loaded library (`DT_NEEDED`). Protobuf, Abseil, the engine
and local archives are incorporated into the module. BFD, zlib, zstd, sframe and
the C and C++ runtimes are shared-library dependencies. The build uses GCC 13.3.0,
CMake 3.28.3 and C++20.

The selected engine patch `bfd-sleigh-target-autodetect`, SHA256
`488eda3edc8c26cc93155240663f20d0512318428c4b69e2fbb3b409989ac82d`, is in use.
The [patch lock](../native-patched.lock.json) records the selected profile.
Source builds use `local_whole`; SDK builds use `WHOLE_ARCHIVE` rather than linking
the local archive alone. Incorporated archives must contain position-independent
code (PIC). Arbitrary static system BFD archives are not substitutes for the
selected libraries. See [installation](INSTALL.md) for dependency preparation and
SDK requirements.

## Bundled zlib source

The engine bundles zlib 1.3.1, distinct from system zlib. Its
[exact notice](notices/engine-zlib.txt) retains copyright, restrictions,
disclaimer and contact information from the
[pinned engine zlib.h](https://raw.githubusercontent.com/NationalSecurityAgency/ghidra/2035b8153afaf7ce2edde24a2c80b62bbcf5127f/Ghidra/Features/Decompiler/src/decompile/zlib/zlib.h).
The notice is not a complete corresponding-source bundle. GCC 13.3.0 is the
build compiler; the separately locked GCC 14 packages supply runtime libraries.

## Before distributing artifacts

The installed manual includes notices and dependency records. It is not
redistribution clearance or a complete corresponding-source bundle. Preserve
original notices and exact applicable license texts, author/origin attribution,
source links and any required change notices. MIT covers original wrapper work
only. HOS §§3–4 and §8 require the applicable attribution/notices/source handling;
its derivative conditions are not replaced by choosing MIT for original work.

Apache-2.0 components require license retention and applicable NOTICE/change
handling. BSD/MIT/zlib components require their specified notices and disclaimers.
For GPL BFD/sframe-containing linked binaries, merely linking a source URL does
not discharge corresponding-source obligations. Select a compliant conveyance
method under the applicable GPL version, supplying complete matching source,
local modifications, build/install scripts and required notices, or a valid offer
where permitted. Evaluate the combined linked work and HOS/GPL compatibility
before distribution; this document does not resolve it. Shared linking does not
automatically waive GPL obligations. For LGPL system libraries, preserve notices,
license/source access and the applicable relinking/reverse-engineering conditions;
consider each runtime exception on its actual terms, not a blanket compiler waiver.

The system lock's source metadata and archive hashes identify inputs; they do not
prove complete source delivery. Binary distribution must account for the exact
linked version and selected system source patches, not a generic upstream URL.
A source-only wrapper distribution must still retain its notices, locks, dependency
source/license references and build instructions; it must not suggest dependency
binaries or source are included when they are not. The local installation includes
notices and dependency records; it does not fetch corresponding source or publish
artifacts.
No new permission to distribute linked dependencies is granted.

## Build-time specification generator

Native SOURCE builds only run the unchanged pinned `cpp/embed_specs.py` through
`cpp/cmake/EmbedSpecs.cmake`, using Python >=3.10 with standard-library zlib/XML
support. This is a source-build dependency, not a Python binding dependency.
SDK consumers and Lua runtime do not need Python. Its use grants no new
distribution rights. The
obligations above still apply; a source URL is not source delivery.
