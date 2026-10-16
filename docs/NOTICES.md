# Local artifact notices and source obligations

Original Lua/C++ wrapper and documentation: Copyright 2026 Salvador Fandiño,
[MIT](../LICENSE). Native integration uses **libghidra by Elias Bachaalany**,
[upstream](https://github.com/0xeb/libghidra), pinned at
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` (reports 0.0.9, not tag equivalence).
No endorsement is implied. Upstream's Human-Origin Source License v1.0 is retained
verbatim in [libghidra notice](evidence/native-notices/libghidra.txt).
The operator accepted that license for planning only: no legal clearance,
combined-license compatibility finding, additional rights or publication approval.
See [bounded disposition](M0-LICENSE.md).

## Exact selected inputs, provenance and linked closure

The three installed root locks are authoritative machine-readable URL/revision/
SHA256 records: [native-inputs.lock.json](../native-inputs.lock.json),
[native-patched.lock.json](../native-patched.lock.json), and
[native-system.lock.json](../native-system.lock.json). They are separate from a
claim that all corresponding-source archives have been obtained or delivered.

| Component | Selected identity | Retained license/notice |
| --- | --- | --- |
| libghidra | d51ca813ae1b6b59519551a9be8c0b1ad74d862d | Human-Origin Source License v1.0, libghidra.txt |
| ghidra engine | 2035b8153afaf7ce2edde24a2c80b62bbcf5127f | Apache-2.0, engine.txt; bundled third-party terms remain applicable |
| compiled Sleigh specs | Ghidra 12.1.3 PUBLIC 20260817 / Ghidra_12.1.3_build | Ghidra source/release license obligations, engine.txt; archive URL/hash in input lock |
| Protobuf | v29.3, generated ABI 5029003 | BSD-3-Clause, protobuf.txt |
| Abseil | 20240722.0 | Apache-2.0, abseil.txt |
| utf8_range | bundled in pinned Protobuf | MIT, utf8-range.txt |
| httplib | v0.16.3 (input, not an HTTP implementation claim) | MIT, httplib.txt |
| engine zlib | bundled 1.3.1 in pinned engine | zlib terms, [exact bundled notice](evidence/native-notices/engine-zlib.txt) |
| system zlib | Ubuntu zlib1g 1:1.3.dfsg-3.1ubuntu2.2 | [system notice](evidence/native-notices/zlib1g.txt) |
| BFD / sframe | Ubuntu binutils 2.42-4ubuntu2.10 shared libraries | binutils.txt, GPL terms (not permissive) |
| zstd | selected system binary/source lock | libzstd1.txt, retained dual-license terms |
| C runtime | Ubuntu libc6 2.39-0ubuntu8.9 | libc6.txt, LGPL terms |
| C++ / GCC runtime | GCC 14 libstdc++6 and libgcc-s1 14.2.0-4ubuntu2~24.04.1 (source gcc-14) | libstdc++6.txt, GPL/LGPL plus applicable exceptions |
| Lua host | PUC Lua 5.4.6, Ubuntu 5.4.6-3build2 | MIT, lua.txt; borrowed from host, not linked as a second VM |

All notice filenames above are in [evidence/native-notices](evidence/native-notices/).
`libiberty-dev.txt` is retained as input accounting; the selected shared BFD
profile does **not** link libiberty.a. No claim that every input is a DT_NEEDED
library: Protobuf/Abseil/engine/local archives are incorporated into the module;
BFD/zlib/zstd/sframe and C/C++ runtimes form its shared closure. Compiler GCC
13.3.0, CMake 3.28.3, C++20 and build interpreter identities are retained in
[evidence/native-toolchain.txt](evidence/native-toolchain.txt).

Only authorized engine patch `bfd-sleigh-target-autodetect`, SHA256
`488eda3edc8c26cc93155240663f20d0512318428c4b69e2fbb3b409989ac82d`, is in use.
No authored libghidra modification or new dependency patch. Actual patch and source
integrity are described by [native readiness](NATIVE-READINESS.md) and patch lock.
Source profile uses local_whole; installed SDK uses a WHOLE_ARCHIVE consumer
interface, not bare local archive linkage. PIC applies to incorporated archives;
installed shared `-z defs` closure qualification is in [handoff](PACKAGE-HANDOFF.md).
Do not substitute arbitrary system static BFD archives. Exact standalone PIC
Protobuf/Abseil SDK closure and offline-input overrides are in
[foundation](PACKAGE-FOUNDATION.md). A dependency download in one SDK qualification
was not isolated; do not label all builds offline.

## Bundled zlib notice provenance

The engine bundles zlib 1.3.1, distinct from the system zlib package above.
The [exact bundled notice](evidence/native-notices/engine-zlib.txt) is the full
opening zlib.h comment, including copyright, restrictions, disclaimer and contact
information, without whitespace or line-ending changes. Source:
[pinned engine zlib.h](https://raw.githubusercontent.com/NationalSecurityAgency/ghidra/2035b8153afaf7ce2edde24a2c80b62bbcf5127f/Ghidra/Features/Decompiler/src/decompile/zlib/zlib.h).
The complete 96,885-byte header SHA256 is
`5b3dc1c20e9b852ec1ef77f598c89129bae58de98d3773f91a4fc3071dd8cabf`.
The extract is lines **5–33 inclusive**, bytes **56–1384** (zero-based,
start-inclusive/end-exclusive), including the final LF: **1,328 bytes**.
Its separate SHA256 is
`02421fcfbfb1d656ef0b6ff4cd3c39f2946f08c3219fa42db482add7ce1f53ea`.
Line-based extraction and an independent byte-range comparison against the verified
header agree. This notice extract is not a complete corresponding-source bundle.
GCC **13.3.0 is the build compiler**, not the identity of the separately locked
GCC 14 runtime packages; the rows above describe the retained profile, not a new
inventory of whatever packages happen to be installed today.

## Obligations before conveying artifacts

This installed collection is a **local source documentation artifact**, not a
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

System lock source-control metadata/archive hashes are provenance, not proof of
complete source delivery. Eventual binary conveyance must account for the exact
linked version and selected system source patches, not a generic upstream URL.
A source-only wrapper handoff must still retain its notices, locks, dependency
source/license references and build instructions; it must not suggest dependency
binaries or source are included when they are not. The local install deliberately
ships retained notices and accounting rather than fetching source or publishing.
No new permission to distribute linked dependencies is granted.

Operator YES/19d0945 approves ONLY unchanged pinned `cpp/embed_specs.py` via
`cpp/cmake/EmbedSpecs.cmake`, Python >=3.10 stdlib zlib/XML during native
SOURCE builds only. This excludes upstream Python bindings, owned Python tools/tests/parity,
SDK consumers and Lua runtime. No replacement, patch or new distribution rights.
Interpreter/module identities and pinned generator hashes are recorded in
[evidence/source-generator-qualification.txt](evidence/source-generator-qualification.txt).
No push or publication authorized; pre-conveyance obligations above remain.
