# Local package foundation (development only)

Original wrapper MIT, Copyright 2026 Salvador Fandiño. This is **not** permission
to distribute linked upstream artifacts, publish a rock or push changes. All
upstream notices and corresponding-source obligations remain applicable.

## Installed SDK with LuaRocks

Requires Linux x86-64, CMake >=3.26, Ninja, C++20, pkg-config Lua 5.4 with 64-bit
integers, LuaRocks 3.x and the pinned **local** SDK with exact Protobuf 29.3.0
CONFIG and its transitive dependencies. No upstream Python binding is used.
From the project root (source checked out locally):

```sh
LLG_BUILD_DIR="$SAIVAGE_CARD_WORK_ROOT/my-rock-build" \
LLG_SDK_PREFIX="$PWD/.cache/native-sdk-patched" \
luarocks --lua-version=5.4 --tree="$SAIVAGE_CARD_WORK_ROOT/my-rock-tree" \
  make --deps-mode=none --no-manifest
```

`LLG_BUILD_DIR` is mandatory and absolute: no hidden disposable build at the
project root. Exactly one input selector is required. Use a fresh build/tree
for a clean qualification, not a reused CMake cache. `BUILD_JOBS` defaults to 4.
The driver uses argument quoting and stops on each failed configure/build/install.
LuaRocks deploys Lua sources and the native module plus process guard into its
ordinary version-specific tree. `$ORIGIN` finds the adjacent real SONAME guard
file (no symlink chain to break during LuaRocks deployment). The module borrows
the host Lua symbols; it does not link or bundle a second VM.

```sh
sh tests/package-foundation.sh .cache/native-sdk-patched \
  "$SAIVAGE_CARD_WORK_ROOT/my-rock-regression"
```

This checks missing/ambiguous input rejection, installed module/guard closure and
real installed owner, M2 and M3 Lua paths from a fresh working directory, including
pages-only graph families and iterator safety. It does not establish a complete
release/runtime matrix, nor validate arbitrary third-party SDK provenance.

## Prepared source inputs

The same driver accepts `LLG_INPUT_ROOT` instead of `LLG_SDK_PREFIX`; it passes
`NATIVE_INPUT_ROOT` into the existing disconnected source CMake build. Inputs
must be prepared separately under `native-inputs.lock.json` and the authorized
`native-patched.lock.json` profile. No configure downloads are allowed.
Source overrides remain CMake's `NATIVE_{LIBGHIDRA,ENGINE,PROTOBUF,ABSEIL,HTTPLIB}_SOURCE`.
An installed SDK path does not run the source embedding generator. Source mode
still requires upstream Python >=3.10 with zlib; its policy decision is **open**,
not implicitly approved by this rockspec. See the retained-generator assessment
below. No project-owned Python qualification oracle is authorized by this file.

## Retained upstream generator: decision request, not an exception approval

The exact pinned `cpp/cmake/EmbedSpecs.cmake` unconditionally invokes
`cpp/embed_specs.py` at configure time, even with `LIBGHIDRA_BUILD_PYTHON=OFF`.
It compresses .sla/.pspec/.cspec/.ldefs into C++ arrays, constructs the language
index and writes generated Python language metadata as an upstream side effect.
It imports Python stdlib/zlib/XML only, not the upstream binding extension.
Installed SDK consumers need none of this at build/runtime.

Alternatives:

- Consume the exact prebuilt local SDK: no generator dependency; already usable
  for wrapper builds, but not a substitute for the required source-install path.
- Ship pregenerated C++ arrays: adds large generated source/artifact provenance
  and distribution questions, and the unchanged upstream CMake still invokes
  its generator. Cannot silently replace the required source path with this.
- Independently implement/qualify a Lua/C++ compression/XML generator and arrange
  an authorized integration point: feasible engineering, but replacing upstream
  generator behavior/integration requires a separately justified approach under
  DESIGN, not a new unapproved dependency patch or modified libghidra checkout.
- Request an explicit **build-time only** exception for the exact pinned upstream
  generator, Python >=3.10 with importable zlib. Reason: preserves unchanged
  upstream integration and compiled-in spec behavior with no binding dependency;
  excludes project-owned tooling, mandatory parity, installed runtime and SDK
  builds. If accepted, record Python/zlib identities per source qualification.

Operator decision requested: accept that narrow upstream source-build exception,
or authorize the separately qualified replacement approach. No option is
preapproved. Continue independent owned-tooling and package work meanwhile.

## Lua input preparation

```sh
unshare -Urn lua5.4 scripts/prepare-native.lua --offline \
  --archives /caller/locked-archives --output /caller/fresh-inputs \
  --profile bfd-sleigh-target-autodetect
lua5.4 tests/tooling_prepare.lua "$SAIVAGE_CARD_WORK_ROOT/preparation-tests"
```

Requires GNU tar, unzip, sha256sum, patch, realpath and ordinary core utilities;
explicit online preparation additionally uses curl (HTTPS only). No Lua packages
or Python are required. Every archive hash is checked before extraction; all
member names/kinds are preflighted. This pinned-input implementation deliberately
rejects tar symlinks, hardlinks, special files and escaped/ambiguous names rather
than emulating Python's more permissive safe-link filter. The six locked inputs
have no such required tar entries. Zip language overlay bytes are streamed to
regular files, not extracted with archive modes/links. Reusing an output path is
rejected, including a dangling symlink. A failed extraction/patch leaves an
incomplete output for diagnosis, never a successful profile marker; retry with a
fresh directory. Only the exact authorized patch hash/revisions/base lock can
produce the patched profile marker. Existing Python preparation is retained as
historical reference during migration, not needed by this entrypoint.

## Lua native validators

The following direct replacements take the predecessor's positional arguments
except the source-integrity checker additionally requires a fresh scratch path:

```sh
lua5.4 scripts/check-native-patched.lua BUILD SPECS FRESH_WORK
lua5.4 scripts/check-native-cache.lua PROBE ELF FRESH_HOME ADDRESS
lua5.4 scripts/check-native-loader-gap.lua UNMODIFIED_BUILD SPECS WORK
lua5.4 scripts/check-native-profile-inputs.lua ARCHIVES INPUTS FRESH_WORK
lua5.4 tests/tooling_native.lua FRESH_WORK
```

Run cache/permission controls as the ordinary guest user, not root or a namespace
that makes that user appear root. Probe stdout, stderr and exit/signal status are
checked separately; matching output cannot hide a failed process. Read-only
permission modes are restored on assertion failures. Cold/warm/unwritable cache
checks preserve nanosecond mtimes and sizes and additionally compare hashes.
The unmodified loader regression's expected failure is **not** readiness.
Source-integrity checking reconstructs the exact authorized profile from hashes,
compares all five source trees (including spec overlays and unexpected additions),
and excludes only upstream's normal generated known_languages.py metadata. It
never calls Python tooling or imports upstream bindings. Historical Python
validators remain until the overall tooling migration is complete.

A plain source wrapper install is not by itself a complete reusable SDK: upstream
suppresses Protobuf/Abseil install rules in that build. Build/install those pinned
PIC dependencies into the same SDK prefix first using `scripts/build-native-sdk.sh`
or its documented CMake commands. Do not silently fall back to an ambient
incompatible Protobuf when testing the newly installed SDK.

## Lua system closure lock

```sh
lua5.4 scripts/lock-native-system.lua ARCHIVES FRESH_CANDIDATE.json --offline
lua5.4 scripts/check-native-system.lua ARCHIVES [LOCK.json]
lua5.4 tests/tooling_system.lua FRESH_CANDIDATE.json ARCHIVES
```

Refresh uses installed dpkg source/binary identities and apt metadata, verifies
binary archive SHA256, and parses source-control checksum sections. Without
`--offline`, missing files are fetched by HTTPS curl during explicit refresh
only. Candidate output must not exist: this tool never silently changes the
accepted lock. Review identity changes before adopting a candidate. The checker
uses only the committed lock, local archives and dpkg, not current remote apt
metadata. Source-control hashes/checksums do **not** prove that source archives
were downloaded, built or that distribution obligations are discharged. The
current closure is the locked Ubuntu 24.04 amd64 profile, not portable packaging.

## Inventory migration in progress

`lua5.4 tests/test_inventory_api.lua [PINNED_LIBGHIDRA_SOURCE]` now independently
extracts native model fields/defaults/conversions/citations, enums, service
declarations and local overrides, and validates cross-ledger recursive expansions
and accounting. It tests lexer definition boundaries and corrupt ledgers without
reading upstream Python-binding source. This is **not yet a replacement** for the
complete semantic inventory generator/research helpers. The old all-unqualified
M0 evidence invariant is no longer valid for the M3-updated ledger: the Lua
validator preserves the exact scoped M3 evidence labels, including the special
success-empty union limitation, rather than erasing runtime evidence or claiming
unobserved populated producers. Generator/semantic-helper migration remains open.

Lua native artifact generation now includes all 18 LocalClient page-wrapper
branch reviews and exact body SHA256/citations. Run:

```sh
lua5.4 scripts/inventory-api.lua PINNED_SOURCE FRESH_NATIVE_JSON
lua5.4 tests/tooling_pages.lua [PINNED_SOURCE]
lua5.4 tests/tooling_page_artifact.lua FRESH_NATIVE_JSON
```

Reviews assert loaded guards, unchanged revision, no wrapper catch, slicing and
conversion order, serial/parallel aggregation and future error propagation,
member normalization, instruction scan bound, signature post-page filtering,
xref same-instance dispatch and leaf-index selection. Mutated-source tests alter
these branches (including presence-preserving order changes) and must fail. These
are source accounting, not new native runtime positives or iterator enablement.
The CLI removes its adjacent body-hash scratch file after success/failure; output
is still a native artifact, not the complete semantic coverage generator. Adapter,
request-field and remaining response/mutation semantic helpers still need porting.

The native artifact additionally includes adapter-page traversal/exception
reviews, CFG/xref extraction and indexed decompilation batch limits, six explicit
status producer/default/error reviews, and all four factory option consumers:

```sh
lua5.4 tests/tooling_adapter_pages.lua [PINNED_SOURCE]
lua5.4 tests/tooling_status.lua [PINNED_SOURCE]
lua5.4 tests/tooling_factory.lua [PINNED_SOURCE]
```

Tests change actual native branches/assignments (including both serial and
parallel completion status) rather than using Python as an oracle. Artifact
fingerprint qualification checks also compare status and adapter-page body hashes
against retained source reviews. Native factory checks do not replace existing
binding owner/failure cleanup tests. These additions still do not complete request,
remaining response/mutation/container or complete coverage-ledger generation.

Native generation now records all 20 nested request fields (open/benchmark/batch
patch), ignored inputs, range zero-end normalization, query substring and page
length/offset domains. `lua5.4 tests/tooling_requests.lua [PINNED_SOURCE]` mutates
actual consumers, including ignored-argument drift, query forwarding and range
normalization. Remaining direct arguments are explicitly emitted as unreviewed
(currently 83), not silently blessed. This is still partial semantic migration;
request presence/defaults must not be inferred from native initializer defaults.

`tests/tooling_direct.lua` and `tests/tooling_lookup.lua` qualify direct exact-address
consumers with related parameter mutation/write acknowledgement and lookup absence
branches. Native artifact now reports 57 remaining direct arguments (down from 83;
26 reviewed inputs include explicit service data_type to implementation new_type mapping).
ReadBytes length remains bounded by INT32_MAX **before** allocation/dispatch;
uint32 representation alone is insufficient. Lookup assigned/default field audit
matches the exact `rec` identifier, not nested `prec` parameter records. Successful
absent optional, present failed decompilation, constant-empty strings and reported
write input size must not be upgraded into native error/producer guarantees.

The next migrated batch adds **32 mutation result producers** and 14 related
string/local/comment/lifecycle inputs (`tests/tooling_mutations.lua` and
`tests/tooling_remaining_inputs.lua`). Mutation assignment and error/side-map
branches are source-corruption tested. All 32 result body hashes match the retained
review artifact. CloseProgram's loaded check is in closeProgramLocked, not the
public forwarding method; Shutdown already-unloaded handling stays distinct.
Remaining direct arguments are now **43** (superseding earlier progress counts),
primarily type/member/enum and benchmark consumers. This is not full migration or
runtime approval: request echoes/side-map flags are not readback or persistence,
failed all-slot mutations can be partial, and signature function_name stays default.

The type/member/enum and benchmark-delete input batch closes the remaining **43
direct input reviews**, including service/native argument origin mapping. Run
`lua5.4 tests/tooling_type_inputs.lua [PINNED_SOURCE]`. Real source mutations
cover loaded guards, exact one-slash normalization, parent forwarding, ordinal
reconstruction, signed offset casts/sums, enum value bit-pattern casts, unchecked
comment side-maps and conditional benchmark revision. New artifacts now require
**zero outstanding direct arguments**. This is source-accounting closure only:
records/graph/decompilation/performance/container/session semantic migration and
complete coverage output still remain. No inferred union producer, durable member
identity, comment persistence or mutation rollback guarantee is added.

Lua generation now includes 24 response-container population reviews, all four
caller-supplied performance store operations, and session open/save/discard/close/
shutdown transitions. Run `tests/tooling_containers_performance.lua` and
`tests/tooling_session.lua` with Lua5.4 and optional pinned source directory.
Container records preserve sequence/duplicates; failed decompilation remains a
present record. Performance fields remain caller data, never measured benchmark
qualification. Logical close resets adapters, not engines/owner; failed save
precedes reset, and discard acknowledgement is not rollback. Remaining migration
is nested record/graph/decompilation/special-result producers and full coverage
assembly, not direct-input or container closure. Native artifact remains partial.

Nested producer migration now includes graph/block/xref branch assignments,
single/batch decompilation success/failure defaults, local collection/extraction,
four special result paths and 15 ordinary/signature/parameter producer contracts.
Run `lua5.4 tests/tooling_producers.lua`, `tests/tooling_special.lua` and
`tests/tooling_records.lua` (each accepts optional pinned source directory).
These tests mutate actual producer branches/fields, not a mandatory Python oracle.
Exact body/default fingerprints are compared with retained review history as an
additional regression only. Inclusive block stop, heuristic edge kinds, subset
xref flags/defaults, empty unreachable tokens, signed ordinals, opaque local IDs,
synthetic type paths and non-durable enumeration IDs remain explicit. No graph
completeness, new union/signature producer or runtime success is inferred.
Full semantic-output assembly/replacement of the old owned entry points remains
open: generated native artifacts still say partial and do not replace coverage.json.
