# Full installed local qualification and artifact handoff

Original wrapper Copyright 2026 Salvador Fandiño, MIT. Native libghidra by
Elias Bachaalany. Linux x86-64, ordinary C-built PUC Lua 5.4.6 / 64-bit integers
only. This is local writer qualification, **not independent approval**, legal
clearance, publication or permission to convey dependency binaries. Lua 5.3 and
other engines/platforms are not qualified. Historical core evidence remains in
[INSTALLED-CORE](INSTALLED-CORE.md); full field/operation reconciliation is in
[FULL-CROSSWALK](FULL-CROSSWALK.md) and [M4-FULL](M4-FULL.md).

## Accepted scope and evidence applicability

The native wrapper at `f8def730` is unchanged from reviewed M4/core code; the
subsequent handoff gate repair `3bb62c3` changes only document verification.
It fixes a false green: current-source mode previously accepted stale API,
M4-FULL, FIELDS and source-ledger bytes. `tests/installed-documents.sh` preserves
that reproducer independently per file, including missing-file cases; it checks
pristine/restored positives and path-specific rejection. The actual retained
installation was not demonstrated stale. Source-mode freshness compares every
required artifact; source-less mode checks presence/claims, not byte freshness.
Neither mode manufactures runtime acceptance from a generated source ledger.

The [operation crosswalk](FULL-CROSSWALK.md) enumerates all 70 local service rows;
40 excluded defaults retain reasons in the ledger. SPEC/M3/M4 define grammar and
all field dispositions, with FIELDS recording exact types/defaults. Existing
immutable historical M3 evidence and generated unqualified slots stay separate.
Full native specialist calls use Session native(), not new facade conveniences.

## Qualification matrix

| Criterion | Evidence / applicability |
| --- | --- |
| Current SDK CMake and LuaRocks clean offline installs | Fresh Release builds in private `unshare -Urn` network namespaces, no dependency fetch; `full-sdk-cmake`/`full-sdk-prefix` and `full-sdk-rock-build`/`full-sdk-rocks` below this card's work root. Primary `work:///cards/card-g-a/processes/proc-c3dfbd18a331/stdout.log` and stderr. SDK CMake unused disconnected-variable warning is harmless: this branch calls installed package lookup, not FetchContent or Python. |
| Installed real full Lua runtime, both fresh SDK prefixes | `tests/installed-profiles.sh` and extended `installed-absence.sh`; exact bytes/completed nonfallback arithmetic, full services/contracts, all three borrowed-VM hosts, both real ELF/project fixtures, limited persistence. Primary `work:///cards/card-g-a/processes/proc-b53009790063/stdout.log` and stderr. Fresh working directory, installed-only paths, no Python/Java/network. |
| Host VM/whole-archive/PIC | Source uses local_whole; SDK recreates WHOLE_ARCHIVE interface. Installed SDK shared `-z defs` consumer and module no-second-VM checks are recorded in the current card status. Module borrows host Lua, adjacent SONAME guard via $ORIGIN; static host exports its VM, shared host uses system liblua. No bundled VM or permission to mix independent engines. |
| Exact values / lifecycle / concurrency / errors | Current CTest 18/18 (primary proc-79a145cfb961 stdout), unchanged native wrapper: boundary/static/shared hosts, UInt64, wrapper allocator/publication, close aliases, independent states/process guard, dispatch ordering, deterministic finalizer rechecks and seeded native records. Existing M1-BOUNDARY/M1-OWNERSHIP/M3/M4 audits remain applicable. Test-only seeded setup is not claimed to be a public producer. |
| Longjmp / exception / sanitizer scope | Reviewed M4 independent v6 at 595b77c plus core review v9: protected packet/request conversion, all-frame proof, exception/retry, wrapper allocation/longjmp/finalizer paths and wrapper/host ASan/LSan/UBSan. No C++/Lua source edits since that baseline. Dependencies/system Lua are not fully instrumented; internal dependency OOM cleanup/recovery is explicitly excluded by a0289f5. No new sanitizer run is claimed for documentation-only changes. |
| Pagination / persistence / native limitations | FULL-CROSSWALK, M3-CORE, M4-FULL and unchanged real Lua suites. Only functions/symbols/memory_blocks iterators; other families pages-only. Publication-safe generation checks retained. Native batches are not loops substituted in Lua, have no invented rollback/atomicity. Saved=true does not promise category restoration. |
| Tooling / fields / generator authority | Lua source inventory/completeness/semantic regressions and render-fields --check; exact pins in root locks. ONLY unchanged SOURCE embed_specs.py via EmbedSpecs.cmake may run Python >=3.10 stdlib zlib/XML under YES/19d0945. No upstream binding, owned Python oracle/tool/test, SDK or runtime Python dependency. Actual source interpreter identities are retained in source-generator-qualification.txt and current qualification command logs. |
| Docs / notices / local artifacts | API, complete field manifest, crosswalk, examples, locks, original MIT and upstream notices/source links installed by CMake/LuaRocks. Pristine/stale/missing regression checks explicit LuaRocks versioned data prefix. NOTICES governs remaining pre-conveyance duties; this is not a complete corresponding-source bundle. |

## Current source-route gate

Clean network-isolated SOURCE CMake Release configure/build/install passed:
`work:///cards/card-g-a/processes/proc-284640be86c8/stdout.log` (stderr empty).
Its installed pristine/stale/missing gate, both constructor profiles and full
three-host real Lua runtime-absence matrix passed in
`work:///cards/card-g-a/processes/proc-bc609da6c6c8/stdout.log` and stderr.
The separate clean SOURCE LuaRocks Release build/install passed in
`work:///cards/card-g-a/processes/proc-1050b7e134b4/stdout.log` (only ordinary
LuaRocks manifest rebuild notice on stderr). Its installed document mutation gate,
constructor profiles, three-host full runtime-absence and installed examples
passed in `work:///cards/card-g-a/processes/proc-ecd86694058e/stdout.log` and stderr.
Thus all four package routes have their own installed real Lua evidence; this
does not imply arbitrary downstream SDK compatibility or distribution approval.

Both fresh source configurations report **Generated 385 embedded specs** using
the unchanged pinned generator, rather than the earlier up-to-date incremental
observation. Exact authored/spec input integrity was independently reconstructed
from all six SHA256-verified archives and the authorized patch, offline, and every
file compared (only normal generated language metadata excluded):
`work:///cards/card-g-a/processes/proc-115df0e47616/stdout.log`, exit 0.
Current inline interpreter/module identities and all Lua inventory/semantic
regressions passed at
`work:///cards/card-g-a/processes/proc-6997ea3eb506/stdout.log`, exit 0.
Historical PACKAGE-HANDOFF observations remain historical, not current results.

## Exact selected inputs and linked-license closure

The root locks are authoritative URL/archive SHA256 records: libghidra
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d` (reports 0.0.9), engine
`2035b8153afaf7ce2edde24a2c80b62bbcf5127f`, Ghidra 12.1.3 PUBLIC 20260817
specs, Protobuf v29.3 / ABI 5029003, Abseil 20240722.0, httplib v0.16.3.
Only engine patch SHA256
`488eda3edc8c26cc93155240663f20d0512318428c4b69e2fbb3b409989ac82d` applies.
No authored libghidra changes; source trees are copied prepared inputs, not a
new upstream fork. GCC 13.3.0, CMake 3.28.3, C++20, PUC Lua 5.4.6 and Ubuntu
24.04 amd64 system closure are the accepted profile, not portable packaging.
BFD/sframe 2.42 shared GPL closure includes zlib/zstd and C/C++ runtimes;
Protobuf/Abseil/utf8_range/engine archives are incorporated with PIC. httplib
is a locked source input, not a wrapper HTTP implementation or runtime service.
NOTICES retains each exact license/source link, visible attribution and remaining
corresponding-source/combined-license duties. No static libiberty substitution.

Actual source interpreter `/usr/bin/python3` resolves to Python 3.12.3, with
stdlib zlib 1.3 and XML ElementTree/pyexpat. Generator SHA256
`8423f0da6b63aa112351286d90fd9665c60c38aeb3fa9bf2dccaa7b19333ed82`;
EmbedSpecs.cmake SHA256
`9b12059e13a3c6aff67b3ed1b721b4e539d362413dd6713b79de8a40ec3e5d5d`.
See source-generator-qualification.txt and current card primary identity output
for executable/module hashes. Inline identity observation does not create an
owned Python tooling or oracle exception. SDK consumer/runtime need neither
this interpreter nor Java/network.

## Local artifact map and reproduction

Card work root `$SAIVAGE_CARD_WORK_ROOT` holds `full-sdk-prefix` (CMake),
`full-sdk-rocks` (LuaRocks), `full-source-prefix` and `full-source-rocks`
(completed source CMake and LuaRocks routes). LuaRocks documentation prefix is
`TREE/lib/luarocks/rocks-5.4/lua-libghidra/scm-1`, not TREE itself.

```sh
bash tests/installed-documents.sh "$prefix" "$data_prefix" "$fresh_doc_work"
bash tests/installed-profiles.sh "$prefix" "$fresh_profile_work"
bash tests/installed-absence.sh "$prefix" "$fresh_runtime_work"
```

Use absolute prefixes and new purpose-named caller-work directories. Profile
checks require ordinary uid permissions and restore chmod on exit; absence masks
interpreters/runtime trees only inside a disposable mount/network namespace.
Expected decode/unmapped, overlapping-name and cold-unwritable diagnostics are
preserved with exact process statuses. No fixture/project source files are mutated.
Examples need the retained fixture tree (`LIBGHIDRA_FIXTURE_ROOT`), not merely the
installed module. API/EXAMPLES document installed invocation.

## Handoff limits and next authority

No independent M5 review or overall acceptance is claimed by this writer. The
current status identifies any still-unmet criteria and exact primary logs; missing
evidence is never a pass. Preserve raw FileBytes/extreme-address crash and native
producer/category-loss limits; unknown findings are not automatically upstream.
No upstream repair/factory detour or broader patch is authorized. MIT original
wrapper and HOS planning-only disposition grant no new distribution rights.
Before conveyance resolve combined linked-license obligations and corresponding
source under NOTICES (notably GPL BFD/sframe, plus HOS and other licenses).
No push, publication, HTTP/SWIG or independent-engine concurrency permission.
