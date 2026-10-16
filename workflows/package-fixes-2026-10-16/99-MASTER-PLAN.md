# Package corrections — master implementation contract

Baseline `4903eb7`, 2026-10-16. This is a developer implementation contract for
twelve audited corrections, the final-documentation condition and a static website
feature, not a package user manual. The operator authorized main-planner notification
and supported project resume once this master plan is ready. Confirm final independent
approval and committed reconciliation before that handoff. The separate
[assignment](98-SAIVAGE-HANDOFF.md) does not itself submit or start work.

## 1. Scope, authority and component contracts

Deliver consistent facade policies and host rejection, truthful real-native
regressions, and a usable, closed installed manual. Preserve native-local scope,
Linux x86-64/Ubuntu 24.04, ordinary PUC Lua 5.4 with signed 64-bit integers and
eight-byte double numbers; 5.4.6 is the retained qualified runtime. Lua 5.3 and
custom numeric hosts are not newly qualified. Keep libghidra
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`, engine
`2035b8153afaf7ce2edde24a2c80b62bbcf5127f`, and the already authorized
`bfd-sleigh-target-autodetect` profile and locks. No HTTP, SWIG, second VM, new
dependency patch, publication/push, deployment/service/configuration changes,
runtime-state edits or upstream repair campaign is authorized by this plan.

Use the unchanged pinned upstream spec generator's narrowly approved Python
>=3.10/stdlib zlib/XML exception for native source builds only. No Python bindings,
owned Python test oracle, SDK-consumer Python or installed-runtime Python/Java/
network dependency. Preserve wrapper-owned allocation/lifetime safety; dependency
internal OOM sweeps and repairs are outside scope. Attribute upstream limitations
with bounded evidence, narrow claims, and continue independent work. A new wrapper
defect remains a failure, not an automatically accepted upstream limitation.

Read all three documents for the owning component before editing:

| Owner | Analysis | Selected design | Detailed implementation plan |
| --- | --- | --- | --- |
| A: boundary owner | [A analysis](A-boundaries/01-ANALYSIS.md) | [A design](A-boundaries/02-DESIGN.md) | [A plan](A-boundaries/03-PLAN.md) |
| B: package/manual owner | [B analysis](B-documentation/01-ANALYSIS.md) | [B design](B-documentation/02-DESIGN.md) | [B plan](B-documentation/03-PLAN.md) |
| C: regression owner | [C analysis](C-regressions/01-ANALYSIS.md) | [C design](C-regressions/02-DESIGN.md) | [C plan](C-regressions/03-PLAN.md) |
| D: website owner | [D analysis](D-website/01-ANALYSIS.md) | [D design](D-website/02-DESIGN.md) | [D plan](D-website/03-PLAN.md) |

This master sets integration order and completion boundaries. Component designs
supply detailed assertions, parser grammar and document disposition. Do not
silently choose between inconsistent contracts: stop only the dependent batch,
record exact conflicting interfaces for the owner, and continue independent work.
Historical `docs/PLAN.md` is evidence, not this work's execution sequence.

## 2. Coverage, importance and choices

P1 means a correctness/safety or trustworthy-acceptance prerequisite; P2 means a
necessary package usability/reference correction. Both are required for closure.
F13 is an explicit operator condition regardless of severity. Order reflects
dependencies, not merely severity. Issue evidence is in the
[audit inventory](../../../history/reviews/package-audit-2026-10-16/00-INDEX.md).

| Finding | Importance; transversality | Selected correction; rejected alternative | Batch |
| --- | --- | --- | --- |
| F01 | P1 medium; facade/API/tests | Keep Session reopen, share six-key facade check; do not remove a useful method or duplicate native value parsing | 1, 4 |
| F02 | P2 low; lifecycle/API/docs | Keep Session shutdown with close/save guard and native `accepted` envelope; do not remove it to fit old prose or preserve asymmetric save policy | 1, 4 |
| F03 | P1 medium; native entry/CMake/LuaRocks/hosts | Explicit host/include selection, header restriction, tiny host-loaded probe and first-call `luaL_checkversion`; no generalized Lua discovery framework or linked second VM | 1, 5 |
| F04 | P1 medium; docs/install/tests | Explicit file manifest, graph/anchor closure and installed equality; do not ship all workflow/test trees to repair old links | 5 |
| F05 | P2 medium; user install recipes | Defined absolute writable inputs and four install routes; no ambient work-root dependency | 4, 5 |
| F06 | P2 medium; manual/developer/history | Four maintained prose pages plus fields, source-only developer index; no wholesale moves, redirect tree or duplicated normative manuals | 4, 5 |
| F07 | P2 low; generator/converters/reference | Resolve scalar/model/enum categories at generator, preserve excluded-only schema distinction; no rendered hand edits | 3, 4 |
| F08 | P1 medium; test drivers/CMake/docs | Explicit full/reduced driver and thin opt-in target; no ambient selection, scheduler or CTest rebranding | 2, 5 |
| F09 | P1 medium; tests/qualification claims | Local create/read/edit/read/delete sequences and observable pre-save snapshots; no acknowledgement-only oracle or generic mutation framework | 2, 4 |
| F10 | P1 medium; Lua semantic/paging tests | Authored two-leaf oracle and caller/range/offset checks; no new fixture or expectation sampled from adapter output | 2 |
| F11 | P2 low; notices/provenance | Separate GCC 13 compiler from locked GCC 14 runtimes; no new inventory framework | 3, 4 |
| F12 | P2 low; notices/install | Separate bundled/system zlib and exact verified bundled extract; no substituted system notice or claimed complete source bundle | 3, 5 |
| F13 | Required; all final package docs | Manifest-selected content check with at most one exact optional README creation credit; no source/tool/test ban or history scrubbing | 4, 5 |
| F14 | Required feature; user docs/site/toolchain/publication | Render B's maintained sources into an allowlisted static project website; no duplicate API generator/manual, repository upload or implicit publishing | 6 |

F14's feature contract is recorded in the
[website finding](../../../history/reviews/package-audit-2026-10-16/F14-github-pages-website.md).

These choices deliberately reject evolutionary accidents: bulk forwarding is not
the facade policy; milestone order is not current API authority; ambient card
variables are not suite selection; historical approval phrases are not document
acceptance tests. Keep useful protected publication, native dispatch generation,
host-only Lua linkage, exact notice bytes, fixture provenance and bounded native
evidence because they protect present contracts, not because they appeared in
an earlier milestone.

## 3. Dependency graph and edit ownership

Default execution is six serial, coherent batches:

```text
1 A contracts/ABI ──> 2 C scoped driver work + semantic regressions ──> 3 B fields/notices
       │                       │                              │
       └───────────────────────┴──────────────────────────────┴──> 4 B manual
                                                                     │
                                                                     v
                                                  5 B checker/install + C callers
                                                      and final integration
                                                                     │
                                                                     v
                                                        6 D website build/check
                                                                     │
                                                    separate operator authorization
                                                                     v
                                                   Pages enablement/publication
```

Batch 3 has no semantic dependence on batch 2 and may be prepared independently,
but this assignment uses serial edits to simplify integration. Batch 4 requires
A's settled surface/build contract, C's final command interface and observation
payload, and generated field/notice content. Batch 5's manifest is finalized only
after all required files exist. Do not install missing future documents merely
to unblock another check.

Batch 2 validates parser/preflight and semantic tests only; it does not close F08.
Stage C's document caller replacement for batch 5 and land it together with B's
checker/probe/export implementation. Do not commit a driver calling an unavailable
checker signature, introduce a compatibility adapter, or count a temporary broken
integration state as a pass. Batch 4 can document the exact interface specified
below before execution; batch 5 supplies its first final merged evidence.

Batch 6 integrates only after B's source documents, generated fields, exact notices,
example, manifest export and checks pass. D consumes B's list, not a second shipping
inventory. Shared anchor/content helper changes go D proposal → B integration and
source/install revalidation → D site validation, serially. Website acceptance
adds artifact/presentation evidence, not another native qualification run.

| Shared area | Exclusive edit sequence / consumer |
| --- | --- |
| `cmake/Binding.cmake` | A ABI/header/test-host hunks → C opt-in integration target → B manifest/example install hunks; merge existing content, never restore baseline file |
| `tests/installed-qualification.sh` | C owns orchestration; B supplies document-check contract/results without concurrent driver edits |
| `tests/installed-profiles.sh`, `installed-absence.sh` | C explicit child arguments only; caller paths updated together |
| `tests/installed-documents.sh`, `installed_documents.lua` | B implements the exact source/installed/four-argument shell contracts below; C lands both pristine and mutation caller updates in the same batch 5 integration |
| `tests/m4_services.lua`, `m4_persistence.lua` | C serially implements readbacks then leaves; B consumes evidence, does not edit tests |
| rockspec, `scripts/luarocks-build.lua`, `tests/package-foundation.sh` | A selected-host interface first; B verifies published recipes/installed docs against it |
| SPEC/DESIGN/COVERAGE, README/API/EXAMPLES/NOTICES, `api/README.md` | B writes after contract handoffs; A/C send correction payloads, not competing edits |
| generator, current coverage/FIELDS | B updates together; historical ledgers/raw evidence/locks remain byte-identical |
| package manifest/shared document helper | B exports BUILD/package-documents.txt; C consumes that build's export and D makes a script-mode export of the same list. B integrates any D compatibility changes before both validations |
| `site/*`, site scripts/tests/workflows | D owns isolated presentation/build/check tooling after B; no concurrent edits to B's maintained pages or shared helper |

A's fixture and standalone configure/numeric-host regressions are mandatory
siblings of C full integration. C's exact driver has no mismatch-host flag; no new
flag or ambient selector is needed. Run the standalone facade regression on the
final installed prefix too. `FULL INTEGRATION PASS` covers C's named groups, never
ABI rejection by implication. Overall acceptance requires both sets of evidence.

## 4. Common validation setup and evidence rules

When implementation is authorized, read AGENTS and the project validation skill,
record HEAD/worktree changes, and use an already provisioned qualified non-root
environment. Do not restart or change a deployment to obtain one. Record actual
compiler, headers/host, SDK, engine/spec profile and fixture identities. Existing
18/18 CTest evidence is a bounded baseline, not fresh integration or clean build
evidence. Reuse unchanged native-probe/fixture/closure evidence with its original
scope; rerun affected checks, not an unrelated upstream qualification campaign.

The commands below describe future interfaces explicitly identified in the
component plans. They are not claims those files exist or tests have run now.
Run the ordered blocks in one Bash shell after authorization and implementation
of each referenced script; expected-failure tests must capture/assert nonzero
status rather than treating it as successful execution of the positive suite.
Use an absolute checkout `ROOT`; `SDK`, `SPECS`, `PINNED_SOURCE`, `ARCHIVES` and
the pinned Lua test archive must be supplied or explicitly fetched and verified,
not guessed. A provisions BAD_LUA and the nondefault LUA_PREFIX below.
SPECS is the prepared engine tree containing `Ghidra/Processors`; PINNED_SOURCE
is the pinned libghidra source. ARCHIVES holds all six locked source archives.
BAD_LUA is the isolated PUC 5.4.6 int64/float32 rejection fixture, not another name
for ordinary Lua. Both test hosts retain their source notices outside the package.

```sh
set -eu
ROOT=$(pwd -P)
WORK=$(mktemp -d /home/salva/g/ml/tmp/llg-package-fixes.XXXXXX)
GOOD_LUA=$(realpath "$(command -v lua5.4)")
unset LUA_INIT LUA_INIT_5_4 LUA_PATH LUA_PATH_5_4 LUA_CPATH LUA_CPATH_5_4
unset PKG_CONFIG_PATH PKG_CONFIG_LIBDIR MAKEFLAGS MFLAGS CFLAGS CPPFLAGS LDFLAGS
export LC_ALL=C
GOOD_INC=
for flag in $(pkg-config --cflags-only-I lua5.4); do
  case "$flag" in
    -I*) candidate=${flag#-I}
      if test -f "$candidate/lua.h" && test -f "$candidate/lauxlib.h" && test -f "$candidate/luaconf.h"; then
        GOOD_INC=$(realpath "$candidate")
        break
      fi ;;
  esac
done
: "${GOOD_INC:?no complete Lua header directory in pkg-config include paths}"
BUILD="$WORK/build"
sha256sum -c tests/fixtures/SHA256SUMS
git status --short
git rev-parse HEAD
```

Run from the checkout unless a fresh cwd is specified. Require absolute readable
input paths, writable work storage, Ninja/CMake >=3.26/C++20, exact Protobuf
29.3.0 CONFIG and qualified PIC/shared BFD closure. Full integration additionally
requires non-root permission semantics, `cc`, `readelf`, `nm`, `ldd`, `unshare`
and working user/mount/network namespaces. Missing prerequisites are named
blocked checks; reduced evidence must never fill their result cells.

This Bash/pkg-config/Make recipe is bounded to ordinary Ubuntu paths without
spaces; CMake itself searches list-valued LUA_INCLUDE_DIRS. Never use base
`includedir` or a guessed suffix. Missing headers fail distinctly from numeric
ABI rejection. Missing archive/toolchain/test results remain blocked evidence.
System embedded shared/static library identities remain separate from the
selected nondefault standalone host and headers.

Preserve before/after hashes of all root native locks, historical coverage/runtime
ledgers, M0 license TSV, raw evidence and existing notices. Report each check's
actual command, profile, result and artifact path; keep failures. No generated
runtime evidence slot becomes a pass merely because source fields are corrected.

## 5. Batch 1 — facade policies and Lua-host boundary (A)

Implement A plan sections 1–2, with separately attributable facade and ABI hunks.
The facade uses one six-key program validator; native ignored keys remain accepted
only through the deliberate native view. Retain reopen response/owner semantics,
shutdown's `accepted` flag, validation-before-dispatch generation behavior,
NO_STATE_PATH protection and CLOSED precedence. Do not invent save guarantees.

Select headers/host explicitly through CMake and LuaRocks. Require ordinary
504/signed-int64/double headers, invalidate stale compatibility cache, load a tiny
no-liblua configure probe even with BUILD_TESTING off, and check the real module
before metatables or RAII owners exist. Keep whole-archive, shared process guard
and `$ORIGIN` closure.

Prerequisites: common SDK profile, real ELF/project fixtures, BAD_LUA and
nondefault LUA_PREFIX with its resolved selected executable. A provisions both
hosts from official `https://www.lua.org/ftp/lua-5.4.6.tar.gz`, SHA256
`7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88`.
Use the common fresh WORK above (do not re-run A's alternative WORK initialization).
The complete provisioning/identity instructions are also in A plan §3a–3c.

```sh
test "$(uname -m)" = x86_64
mkdir -p "$WORK/fixture/good-src" "$WORK/fixture/float-src"
if test -n "${LUA_TARBALL:-}"; then
  cp "$LUA_TARBALL" "$WORK/fixture/lua-5.4.6.tar.gz"
else
  curl --fail --location https://www.lua.org/ftp/lua-5.4.6.tar.gz --output "$WORK/fixture/lua-5.4.6.tar.gz"
fi
printf '%s  %s\n' 7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88 "$WORK/fixture/lua-5.4.6.tar.gz" | sha256sum --check
tar -xzf "$WORK/fixture/lua-5.4.6.tar.gz" --strip-components=1 -C "$WORK/fixture/good-src"
tar -xzf "$WORK/fixture/lua-5.4.6.tar.gz" --strip-components=1 -C "$WORK/fixture/float-src"
"$GOOD_LUA" - "$WORK/fixture/float-src/src/luaconf.h" <<'LUA'
local path=assert(arg[1]); local f=assert(io.open(path,'rb'))
local s=f:read('a'); f:close()
assert(s:match('#define%s+LUA_INT_DEFAULT%s+LUA_INT_LONGLONG'))
assert(s:match('#define%s+LUA_32BITS%s+0'))
local changed,n=s:gsub('(#define%s+LUA_FLOAT_DEFAULT%s+)LUA_FLOAT_DOUBLE','%1LUA_FLOAT_FLOAT')
assert(n==1); f=assert(io.open(path,'wb')); assert(f:write(changed)); assert(f:close())
LUA
for variant in good float; do
  make -C "$WORK/fixture/$variant-src/src" -j4 all CC=gcc \
    MYCFLAGS='-DLUA_USE_LINUX' MYLDFLAGS='-Wl,-E' MYLIBS='-ldl' \
    > "$WORK/fixture/$variant-build.log" 2>&1
  make -C "$WORK/fixture/$variant-src" install INSTALL_TOP="$WORK/fixture/$variant-prefix" \
    > "$WORK/fixture/$variant-install.log" 2>&1
  "$WORK/fixture/$variant-prefix/bin/lua" -v
  nm -D --defined-only "$WORK/fixture/$variant-prefix/bin/lua" > "$WORK/fixture/$variant-symbols.txt"
  grep -E ' T luaL_checkversion_$' "$WORK/fixture/$variant-symbols.txt"
  grep -E ' T lua_version$' "$WORK/fixture/$variant-symbols.txt"
  gcc -DLUA_USE_LINUX -I"$WORK/fixture/$variant-prefix/include" -dM -E -include lua.h - < /dev/null > "$WORK/fixture/$variant-macros.txt"
  sha256sum "$WORK/fixture/$variant-prefix/bin/lua" "$WORK/fixture/$variant-prefix/include/luaconf.h"
done
LUA_PREFIX="$WORK/fixture/good-prefix"
SELECTED_LUA="$LUA_PREFIX/bin/lua"
BAD_LUA="$WORK/fixture/float-prefix/bin/lua"
"$SELECTED_LUA" -e 'assert(_VERSION=="Lua 5.4"); assert(string.packsize("j")==8); assert(string.packsize("n")==8)'
"$BAD_LUA" -e 'assert(_VERSION=="Lua 5.4"); assert(string.packsize("j")==8); assert(string.packsize("n")==4); assert(type(package.loadlib)=="function")'
```

Record patch version 5.4.6, compiler identity and observed macros (long long,
LUA_32BITS=0, double versus float). No C89 or ineffective -DLUA_FLOAT_TYPE override.
These are test-only copied sources, not native-dependency patches. Execute the
following only after implementing the planned binding and regression scripts:

```sh
cmake -S "$ROOT" -B "$BUILD" -G Ninja \
  -DLIBGHIDRA_USE_SDK=ON -DCMAKE_PREFIX_PATH="$SDK" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DLUA_EXECUTABLE="$GOOD_LUA" -DLLG_LUA_INCLUDE_DIR="$GOOD_INC" \
  -DCMAKE_INSTALL_PREFIX="$WORK/a-install"
cmake --build "$BUILD" --parallel 4 --verbose > "$WORK/a-build.log" 2>&1
ctest --test-dir "$BUILD" --output-on-failure
cmake --install "$BUILD"
mkdir -p "$WORK/a-cwd" "$WORK/a-state"
(cd "$WORK/a-cwd" && "$GOOD_LUA" "$ROOT/tests/facade_boundaries.lua" "$WORK/a-install" "$ROOT" "$WORK/a-state")
"$GOOD_LUA" tests/m2_slice.lua "$WORK/a-install" "$ROOT"
"$GOOD_LUA" tests/m3_core.lua "$WORK/a-install" "$ROOT"
"$BAD_LUA" tests/lua_abi_rejection.lua "$BUILD"
sh tests/lua_abi_configure.sh "$ROOT" "$SDK" "$WORK/a-configure" "$GOOD_LUA" "$GOOD_INC" "$BAD_LUA"
readelf -d "$WORK/a-install/lib/lua/5.4/libghidra/_native.so"
nm -D --defined-only "$WORK/a-install/lib/lua/5.4/libghidra/_native.so"
test "$(realpath "$SELECTED_LUA")" != "$GOOD_LUA"
test "$(realpath "$LUA_PREFIX/include")" != "$GOOD_INC"
luarocks --lua-version=5.4 --lua-dir="$LUA_PREFIX" config variables.LUA > "$WORK/a-rock-host.txt"
luarocks --lua-version=5.4 --lua-dir="$LUA_PREFIX" config variables.LUA_INCDIR > "$WORK/a-rock-include.txt"
test "$(realpath "$(cat "$WORK/a-rock-host.txt")")" = "$(realpath "$SELECTED_LUA")"
test "$(realpath "$(cat "$WORK/a-rock-include.txt")")" = "$(realpath "$LUA_PREFIX/include")"
env -u LLG_INPUT_ROOT LLG_BUILD_DIR="$WORK/a-rock-build" LLG_SDK_PREFIX="$SDK" \
  luarocks --lua-version=5.4 --lua-dir="$LUA_PREFIX" --tree="$WORK/a-rocks" make --deps-mode=none --no-manifest
grep -E '^(LUA_EXECUTABLE|LLG_LUA_INCLUDE_DIR):' "$WORK/a-rock-build/CMakeCache.txt"
ninja -C "$WORK/a-rock-build" -t commands lua_ghidra > "$WORK/a-rock-native-commands.txt"
grep -F -- "-I$LUA_PREFIX/include" "$WORK/a-rock-native-commands.txt"
if grep -F -- "-I$GOOD_INC" "$WORK/a-rock-native-commands.txt"; then exit 1; fi
mkdir -p "$WORK/a-rock-state"
(cd "$WORK/a-cwd" && "$SELECTED_LUA" "$ROOT/tests/facade_boundaries.lua" "$WORK/a-rocks" "$ROOT" "$WORK/a-rock-state")
(cd "$WORK/a-cwd" && "$SELECTED_LUA" "$ROOT/tests/m2_slice.lua" "$WORK/a-rocks" "$ROOT")
sh tests/package-foundation.sh "$SDK" "$WORK/a-package"
```

If LuaRocks emits quoted config values, explicitly normalize that known format
while retaining raw output; never accept a system path as equivalent. Assert exact
CMake cache values and driver-resolved arguments match the recorded selections;
inspect boundary.cpp/owner.cpp actual includes, not just a version string.
Record system embedded header/shared/static absolute paths and hashes from
configure/verbose compile-link commands. Check `ldd "$BUILD/boundary_shared_host"`,
`readelf -d "$BUILD/boundary_static_host"` and its exported Lua symbols: the
shared host resolves its recorded system library; static host has no liblua
DT_NEEDED. Neither is claimed as the nondefault standalone prefix.

Acceptance: A's full assertion table holds on real ELF/project routes; ordinary
standalone/static/shared tests pass; incompatible numeric host fails with the
specific ABI diagnostic before publication and remains usable; missing include,
host mismatch and changed-cache cases fail correctly; no-override system discovery
also builds/loads its probe. `tests/lua_abi_rejection.lua BUILD` loads both
BUILD/lua-abi-probe.so and BUILD/libghidra/_native.so, resolves both entry symbols,
and requires `core and library have incompatible numeric types` from protected
entry. Missing libraries/symbols/version errors do not count. Registry entries
libghidra.UInt64/libghidra.owner and factory publication remain absent; the same
host executes integer/table operations and GC afterward. This is the bounded
amd64 136-versus-132 numeric-size-token experiment, not universal ABI safety.
Cache paths match actual
LuaRocks selection. No liblua DT_NEEDED/defined VM symbols; guard closure intact.
Apply the same ELF/facade checks to the rock installation using its selected
nondefault host, not ambient lua5.4. Verify the incompatible fixture's version,
integer/number sizes, symbol/loading support, protected diagnostic and subsequent
execution using A's concrete recipe; a custom-number ABI is not universally made
safe by luaL_checkversion. Run wrapper sanitizers
if ownership/entry frames change beyond the planned trivial first-call addition,
using the validation skill's established workflow. Do not waive existing fault
tests. Deliver B/C exact contracts, test interfaces and measured results.

## 6. Batch 2 — explicit integration and meaningful state oracles (C)

Implement C plan in order: orchestration, specialist readbacks, leaf oracle,
bounded sensitivity checks. The driver requires `--build`, `--prefix`,
`--work-root`; default mode is full, which also requires `--external-specs`.
Reject duplicate/unknown/legacy arguments and existing prefix including symlinks.
Preflight before build, allocate unique retained run/HOME/cwd, and make every
child failure fatal with group/path diagnostics. Reduced mode enumerates omissions
and cannot claim full qualification. The named CMake target calls this driver,
is opt-in, not ALL and not a replacement for CTest.

Strengthen observed state before mutation/deletion/save and compare the same
identities after reopen. Freeze deterministic actual upstream limitations instead
of accepting either changed or unchanged state. Parameter retyping must differ;
parameter-kind local records cannot qualify true locals. For project leaves,
require ordered `0x401106`, `0x40113c`, exclude caller `0x40111f`, test limit-one
offsets 0/1/2 and inclusive/shortened ranges; retain raw-ELF NOT_SUPPORTED.

```sh
bash -n tests/installed-qualification.sh
bash -n tests/installed-profiles.sh
bash -n tests/installed-absence.sh
bash tests/installed-qualification.sh --help
"$GOOD_LUA" tests/m4_services.lua "$WORK/a-install" "$ROOT"
PERSIST=$(mktemp -d "$WORK/persistence.XXXXXX")
"$GOOD_LUA" tests/m4_persistence.lua "$WORK/a-install" "$ROOT" "$PERSIST"
```

Additionally execute the explicit malformed/missing-input parser cases in C plan
section 1, including missing selected-build package-documents.txt, and require
nonzero, diagnostic failures. Stage new document callers for batch 5 as specified
above; missing B implementation cannot satisfy either mode's acceptance. Run disposable real-backend
mutants for dropped observable edit, ordinary-function-as-leaf page and repeated
offset-zero leaf; each must fail its intended assertion and the unmodified tests
must pass. No production mutation hook/framework. Full driver execution is
deferred to batch 5 after B's installed documents/probes land; batch 2 cannot
claim complete F08 qualification from parser/focused tests alone.

Deliver B measured acknowledgement/observed-state/reload distinctions and exact
commands. Correct current claims without rewriting M4/crosswalk historical
evidence; specifically do not retain unsupported GetRevision citations or infer
ignored enum signedness from width alone.

## 7. Batch 3 — generated fields and exact notices (B)

Implement B plan sections 4–5's generation and notice work before manifest work.
Resolve int32, uint64, bytes, nested records and actual converted enum spellings;
distinguish native-only schemas. Use existing extraction, not a C++ parser rewrite.
Regenerate current ledger and fields together; preserve fingerprints and historical
digest chains. Add representative rendering tests to existing Lua tooling suite.

```sh
"$GOOD_LUA" scripts/inventory-api.lua "$PINNED_SOURCE" "$WORK/coverage-candidate.json" --coverage
"$GOOD_LUA" scripts/check-tooling.lua "$PINNED_SOURCE" "$WORK/tooling-check"
# Inspect candidate semantic differences before replacing current api/coverage.json.
"$GOOD_LUA" scripts/render-fields.lua
"$GOOD_LUA" scripts/render-fields.lua --check
```

FRESH_JSON/work destinations must not already exist. Candidate replacement is a
reviewed edit, not a command that overwrites history. If the new tooling suite
expects the new current ledger, run it after reviewed replacement as well; do not
rewrite historical expected bytes to make it pass.

Verify the engine zlib header at the locked engine path, SHA256
`5b3dc1c20e9b852ec1ef77f598c89129bae58de98d3773f91a4fc3071dd8cabf`.
Extract the entire exact notice block into future
`docs/evidence/native-notices/engine-zlib.txt`; record source URL, header hash,
line/byte boundaries and separately computed extract hash. Check with `sha256sum`
and independent byte comparison against that exact range. The header hash is not
the extract hash. Missing verifiable source blocks F12, not permission to use a
placeholder. Separate bundled 1.3.1 from system zlib and GCC 13.3.0 compiler from
GCC 14 runtime package `14.2.0-4ubuntu2~24.04.1`; retain exact existing notices.

Acceptance: representative type/category tests pass, current render is fresh,
source-only evidence remains source-only, immutable hashes unchanged, and notice
bytes/provenance match. Final local links and installed copies are batch 5 gates.

## 8. Batch 4 — coherent current manual and own-input example (B)

After A/C handoffs and batch 3, rewrite README, docs/EXAMPLES, API and NOTICES as
the compact maintained user layer; add source-only `docs/development/README.md`.
API becomes current grammar authority, including reopen, guarded Session shutdown,
native escape hatch and get_revision envelope. Correct developer DESIGN's actual
file map, make SPEC/COVERAGE defer duplicate grammar, and classify PLAN/milestone
reports as dated evidence without moving or rewriting them. Avoid false public
URLs for unpublished commits; use source-only path text until a real revision
link exists. No push is implied.

All maintained local Markdown links resolve relative to their source file and
stay inside the package manifest, including from README to docs and from nested
API/guide pages to FIELDS/notices. Do not use repository-root `/docs/...` links in
the installed manual. The source-only developer index and changed developer pages
also need valid explicit local links; existence of excluded history in the source
tree does not make it a valid package-doc destination.

Guide defines absolute ordinary paths and all prerequisites for source/SDK ×
CMake/LuaRocks; distinguish online archive preparation, offline cached preparation
and disconnected configure. No claimed public SDK download. Preserve ignored
fields, effective bounds, lazy discovery, unsafe extreme-address limitations,
raw/FileBytes gaps, logical closure, limited persistence, pages-only families,
empty string stub, partial outcomes and absent upstream OOM guarantees.

Add `examples/decompile.lua BINARY ADDRESS LANGUAGE_ID COMPILER_SPEC_ID
[GHIDRA_ROOT]`: checked exact address, checked open, decompile then inspect
completed/fallback/error fields, deterministic Lua 5.4 close before exit. Known
mapped virtual function address, never a file offset or arbitrary crash probe.
No fixture-manifest dependence in its interface. Once installed in batch 5:

Prefix `nm`'s displayed hexadecimal address with `0x` (for example `0x401106`);
bare all-digit strings are decimal to u64, not hexadecimal.

```sh
"$GOOD_LUA" "$EXAMPLE" "$BINARY" "$ADDRESS" "$LANGUAGE_ID" "$COMPILER_SPEC_ID" "$SPECS"
"$GOOD_LUA" "$EXAMPLE" "$BINARY" "$ADDRESS" "$LANGUAGE_ID" "$COMPILER_SPEC_ID"
```

Set EXAMPLE to the actual installed data-prefix example, and BINARY/ADDRESS/hints
to the existing authored supported fixture's verified values. Run from a fresh
cwd/HOME, with installed search paths. Positive output must be complete/nonfallback
and semantically match authored input. Malformed address and nonexistent file
must return nonzero structured diagnostics without retaining an owner. Incomplete/
fallback is not nil/error and must not report success. Verify both spec modes;
external success does not establish embedded-cache behavior.

Acceptance also requires editorial reconciliation of every exported signature and
B design's limitation checklist. F09's revised claims live in current API/guide
and the developer index's correction explanation, not altered historical reports
or a new runtime ledger. Batch 5 executes the published installation recipes.

## 9. Batch 5 — final document manifest and integrated package acceptance (B + C)

B now installs exactly B design section 1's explicit list through
`cmake/PackageDocuments.cmake`, preserving relative paths. No recursive docs/api
copy, plans, history, workflow or developer-index shipment. The own-input example
is an example deliverable outside the doc root. Account for all installed prose,
not just one preferred directory. Configure exports the sole LLG_PACKAGE_DOCUMENTS
list to `BUILD/package-documents.txt`: one repository-relative path per line,
final newline, no comments/blanks. Reconfigure after list changes. The export is
build-owned, not installed or independently edited. B implements these exact
interfaces, with all path arguments absolute:

```text
lua5.4 tests/installed_documents.lua source SOURCE_ROOT MANIFEST
lua5.4 tests/installed_documents.lua installed DOCUMENT_ROOT SOURCE_ROOT MANIFEST
bash tests/installed-documents.sh DOCUMENT_ROOT SOURCE_ROOT MANIFEST FRESH_WORK
```

DOCUMENT_ROOT is the actual `share/doc/lua-libghidra` directory, never a module or
data prefix. MANIFEST is that install's build export. Source mode checks only the
selected files/graph/content, allowing other source files; installed mode also
requires exact membership and source-byte equality. Missing/malformed manifest
fails without guessing another build. Land B implementation and C caller updates
together before either full or reduced integration. C derives
`manifest="$build/package-documents.txt"` and
`document_root="$prefix/share/doc/lua-libghidra"`; both pristine checks run in both
modes, and only the four-argument mutation driver is full-only. No manifest CLI
selector, legacy adapter or second file inventory.

Check source and each actual clean CMake/LuaRocks doc root: valid nonescaping unique
paths, exact set, byte equality, local links/images/reference links/fragments and
anchors. Detect unsupported local markup rather than silently skipping it. External
URL availability is separate from local closure. Check all bytes including code
fences/comments for case-insensitive Saivage and card/record/work process markers.
Only optional exact README acknowledgment `Saivage was used in creating this
project.` is allowed once. No path-wide exemptions. Never redact immutable license
bytes to satisfy a scanner: an actual conflict needs explicit owner resolution.
Source, tools, tests and separate developer records have no blanket naming ban.

Run B's disposable checker mutations: missing target, broken fragment, stale
installed bytes, unlisted plan, process name/URI, duplicated/misplaced credit.
Require path-specific failures and pristine success before and after restoring
each mutation. FRESH_WORK must not exist: B creates an untouched installed snapshot
and mutable FRESH_WORK/documents, keeping SOURCE_ROOT/MANIFEST unchanged. Replace
old M4-FULL/coverage mutation targets with manifest members and restore from that
snapshot, never the source dossier. Check membership/existence first, graph/content
second, freshness last. Require the intended category/path: missing-member,
stale-bytes, missing-link-target, missing-fragment, forbidden-content, invalid-credit
or unlisted-document. A harmless prose change tests stale bytes without masking
graph/content faults. Remove deliberate extra files during restoration; check
pristine at completion. Invalid/duplicate/escaping manifest probes use copies.

### Clean four-route installation matrix

Use B plan section 2's exact recipes with separate fresh build/prefix/tree for
every route. In this master setup the source CMake offline route is:

```sh
"$GOOD_LUA" scripts/prepare-native.lua --archives "$ARCHIVES" --output "$WORK/inputs" --profile bfd-sleigh-target-autodetect --offline
cmake -S "$ROOT" -B "$WORK/source-build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF \
  -DLIBGHIDRA_USE_SDK=OFF -DNATIVE_INPUT_ROOT="$WORK/inputs" \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
  -DLUA_EXECUTABLE="$GOOD_LUA" -DLLG_LUA_INCLUDE_DIR="$GOOD_INC" \
  -DCMAKE_INSTALL_PREFIX="$WORK/source-install"
cmake --build "$WORK/source-build" --parallel 4
cmake --install "$WORK/source-build"
env -u LLG_SDK_PREFIX LLG_BUILD_DIR="$WORK/source-rock-build" LLG_INPUT_ROOT="$WORK/inputs" \
  luarocks --lua-version=5.4 --lua-dir="$LUA_PREFIX" --tree="$WORK/source-rocks" make --deps-mode=none --no-manifest
env -u LLG_INPUT_ROOT LLG_BUILD_DIR="$WORK/final-sdk-rock-build" LLG_SDK_PREFIX="$SDK" \
  luarocks --lua-version=5.4 --lua-dir="$LUA_PREFIX" --tree="$WORK/final-sdk-rocks" make --deps-mode=none --no-manifest
```

Final SDK CMake route is the fresh install made by the full driver below. The
source generator exception applies only to source routes; test SDK compatibility
with BUILD_TESTING off through rock builds. At every route run installed require,
the own-input example and B's source/install doc equality/closure checks from a
fresh cwd with correct LUA_PATH/LUA_CPATH (or the selected rock tree's `path`).
For CMake loads use PREFIX/share/lua/5.4/?.lua and ?/init.lua in LUA_PATH and
PREFIX/lib/lua/5.4/?.so in LUA_CPATH. For rock loads use that tree's LuaRocks `path`
output and SELECTED_LUA; example data lives under the versioned package prefix.
Confirm each ROCK_PACKAGE_PREFIX below against its route's CMakeCache/install log
(the driver's actual PREFIX). If configured differently, explicitly set the
observed prefix, not a search result from another tree. The baseline layout is:

| Route | MANIFEST | DOCUMENT_ROOT |
| --- | --- | --- |
| Source CMake | `$WORK/source-build/package-documents.txt` | `$WORK/source-install/share/doc/lua-libghidra` |
| SDK CMake | `$BUILD/package-documents.txt` | `$WORK/final-sdk-install/share/doc/lua-libghidra` |
| Source LuaRocks | `$WORK/source-rock-build/package-documents.txt` | `$WORK/source-rocks/lib/luarocks/rocks-5.4/lua-libghidra/scm-1/share/doc/lua-libghidra` |
| SDK LuaRocks | `$WORK/final-sdk-rock-build/package-documents.txt` | `$WORK/final-sdk-rocks/lib/luarocks/rocks-5.4/lua-libghidra/scm-1/share/doc/lua-libghidra` |

Execute source/install/probe verification for each route with its own export.
This small shell shorthand repeats the exact checker contract, not a new tool:

```sh
check_route_docs() {
  manifest="$1/package-documents.txt"
  document_root="$2/share/doc/lua-libghidra"
  test -f "$manifest" && test -d "$document_root"
  "$GOOD_LUA" "$ROOT/tests/installed_documents.lua" source "$ROOT" "$manifest"
  "$GOOD_LUA" "$ROOT/tests/installed_documents.lua" installed "$document_root" "$ROOT" "$manifest"
  bash "$ROOT/tests/installed-documents.sh" "$document_root" "$ROOT" "$manifest" "$3"
}
check_route_docs "$WORK/source-build" "$WORK/source-install" "$WORK/source-doc-probes"
check_route_docs "$WORK/source-rock-build" \
  "$WORK/source-rocks/lib/luarocks/rocks-5.4/lua-libghidra/scm-1" "$WORK/source-rock-doc-probes"
check_route_docs "$WORK/final-sdk-rock-build" \
  "$WORK/final-sdk-rocks/lib/luarocks/rocks-5.4/lua-libghidra/scm-1" "$WORK/sdk-rock-doc-probes"
```

The SDK CMake row is executed by C's full driver below with the identical source/
installed commands and `bash tests/installed-documents.sh DOCUMENT_ROOT ROOT
MANIFEST "$run/documents/probes"`; run is its unique absolute directory and
probes is nonexistent. Do not repeat it afterward without changed inputs/failure.
The installed own-input example is `DATA_PREFIX/share/libghidra/examples/decompile.lua`,
where DATA_PREFIX is the CMake prefix or confirmed versioned rock package prefix.
Missing archives/SDK/source/namespace
inputs leave the affected matrix cell explicitly unverified, not substituted
with another route. An online preparation is not offline evidence. Do not claim
clean upgrade from an old recursively populated prefix; use fresh destinations
and document bounded removal of only the old doc subtree when a user chooses it.

### Final merged integration

Reconfigure BUILD with its established SDK/ABI inputs so new CMake hunks apply,
then run CTest and one full direct-driver invocation. Avoid a duplicate expensive
full invocation solely to demonstrate the named target.

```sh
cmake -S "$ROOT" -B "$BUILD"
cmake --build "$BUILD" --parallel 4
ctest --test-dir "$BUILD" --output-on-failure
env -u SAIVAGE_CARD_WORK_ROOT bash tests/installed-qualification.sh \
  --build "$BUILD" --prefix "$WORK/final-sdk-install" --work-root "$WORK" \
  --external-specs "$SPECS" --mode full
env SAIVAGE_CARD_WORK_ROOT="$WORK/unrelated-ambient-path" \
  bash tests/installed-qualification.sh --build "$BUILD" \
  --prefix "$WORK/reduced-install" --work-root "$WORK" --mode reduced
"$BAD_LUA" tests/lua_abi_rejection.lua "$BUILD"
```

Rerun facade_boundaries on final-sdk-install from fresh cwd with a new state
directory. Verify no artifacts appeared at the unrelated ambient path. Full
completion includes all three hosts, owner/M2/M3/M4 suites, examples/pristine docs,
document mutations, persistence, branch CFG, external/embedded cold/warm/permission
profiles and runtime absence. Reduced output must enumerate all omitted groups
and state full integration NOT QUALIFIED. Test the named target's missing-input
failure path; if using it for the real full run instead, configure C plan's three
LLG_INTEGRATION cache paths and use `cmake --build "$BUILD" --target integration`
with a fresh prefix. Neither mode nor CTest alone proves release qualification.

## 10. Batch 6 — static website from maintained package content (D)

Implement [D's plan](D-website/03-PLAN.md) after batch 5: rendering/toolchain,
artifact/presentation validation, then CI and publication preparation. D owns
F14 and the website application of F13. The target is
`https://salva.github.io/lua-libghidra/`, not an asserted live deployment.

Reuse B's five maintained pages and manifest-selected LICENSE/locks/exact notices;
render the complete own-input example from its single executable source and offer
the byte-exact download. Route README to index.html and retain nested docs/api
routes. Stage only computed allowlisted outputs plus local CSS/example/.nojekyll;
never upload the checkout or recursively copy history. Native fields come from
B's checked generated FIELDS, not a second source/API parser. Keep safety,
limitations, attribution and notice obligations visible without historical dossiers.

Use Pandoc with bounded Lua presentation filters and one local template. Annotated
LDoc and topics-only LDoc are feasible without rewriting dispatch; explicitly locked
Jekyll in Actions is also viable. Pandoc's GFM and Lua AST fit these five maintained
pages with fewer metadata/backend/staging adaptations. No second API authority,
annotation migration or further framework comparison is required. Record
an actual pinned converter version/archive URL/hash and verify a local executable;
no floating download or invented hash. Tools are website build-only dependencies,
not package native-build/runtime prerequisites. Script-mode CMake exports B's
manifest as site-work `package-documents.txt` without configuring the native project.
The site build invokes `lua5.4 tests/installed_documents.lua source SOURCE_ROOT
MANIFEST` with absolute checkout/export paths. B's installed and shell interfaces
remain package checks, not HTML checker interfaces. Verify script-mode/shared-helper
compatibility during implementation; do not infer a sibling native build's export.
If the pinned converter needs unbounded adaptations, report a specific blocker
rather than silently switching frameworks. Build/check are offline once
tools exist. Optional loopback preview uses BusyBox; no required browser JS,
remote theme/assets or application framework.

Acceptance commands after implementing D and integrating B's manifest/helper:

```sh
SITE_WORK=$(mktemp -d /home/salva/g/ml/tmp/llg-package-site.XXXXXX)
: "${PANDOC:?absolute verified converter matching site/toolchain.lock.json}"
lua5.4 scripts/render-fields.lua --check
lua5.4 scripts/build-site.lua --pandoc "$PANDOC" \
  --baseurl /lua-libghidra --origin https://salva.github.io \
  --output "$SITE_WORK/preview/lua-libghidra" --report "$SITE_WORK/build.json"
lua5.4 scripts/check-site.lua --root "$SITE_WORK/preview/lua-libghidra" \
  --baseurl /lua-libghidra --report "$SITE_WORK/build.json" --source .
lua5.4 tests/site_contract.lua --work "$SITE_WORK/mutations" --pandoc "$PANDOC"
lua5.4 scripts/build-site.lua --pandoc "$PANDOC" \
  --baseurl /lua-libghidra --origin https://salva.github.io \
  --output "$SITE_WORK/rebuilt" --report "$SITE_WORK/rebuilt.json"
diff -r "$SITE_WORK/preview/lua-libghidra" "$SITE_WORK/rebuilt"
lua5.4 scripts/build-site.lua --pandoc "$PANDOC" \
  --baseurl '' --origin https://salva.github.io \
  --output "$SITE_WORK/root-site" --report "$SITE_WORK/root-build.json"
lua5.4 scripts/check-site.lua --root "$SITE_WORK/root-site" \
  --baseurl '' --report "$SITE_WORK/root-build.json" --source .
sh scripts/preview-site.sh --root "$SITE_WORK/preview" --bind 127.0.0.1 --port 8088
```

Preview serves the parent so browser checks use
`http://127.0.0.1:8088/lua-libghidra/`. Check direct nested API/FIELDS/notice links,
assets, downloads and fragments under that actual prefix; root-relative escaping
URLs must fail. Validate actual emitted IDs, query/fragment/percent encoding,
README rewrites and duplicate heading IDs, using B's shared anchor logic where
practical. Compare current sources as well as build reports for freshness, exact
output set, byte-identical notices/locks/license/example and reproducible rebuild.

Run D's negative mutations: missing notice/fragment, escaping asset, bad README
rewrite, duplicate ID, stale content/report, altered example, extra private/history
file, symlink and encoded prohibited reference or misplaced/duplicate credit.
Each must fail for the intended defect. Scan source, raw HTML, decoded content,
attributes/comments, metadata, paths and downloadable bytes; only B's exact
optional single landing-page creation credit is permitted. Never redact license
bytes or silently relax the allowlist. External links are inventoried, not claimed
reachable. Revalidate B source/install checks after any shared-helper edits.

Record browser checks at 360px and desktop width, 200% zoom, keyboard skip/nav/TOC,
visible focus, contrast and bounded table/code scrolling; no complete accessibility
audit claim from a smoke check. Verify about → install → own-input example → API/
fields/limitations/notices is usable without JavaScript or development history.

Prepare read-only build CI and a separate manual publication workflow as D defines:
reviewed full-SHA action pins, locked converter, no PR deployment/secrets,
default-branch guard using the actual branch, deploy-only pages/id-token privileges,
github-pages environment and serialized publication. Only a checked staged artifact
may be deployed. Build/local validation and workflow authoring do not authorize
push, Pages enablement, repository/environment settings changes or deployment.
These are separate operator-authorized terminal actions, not prerequisites to
local website build acceptance. Do not advertise the URL as live before actual
authorized publication verification; no custom domain/DNS work is included.

Before publication, rollback of D is limited to its own tooling/workflow edits;
B reconciles any shared-helper reversal and retains its manual/exact notices.
Any later rollback deployment also requires separate operator authority and a
checked artifact from a known accepted revision. Never repair a site failure by
uploading the repository or weakening the allowlist.

## 11. Completion, commits and rollback

Completion is fourteen mapped dispositions with actual evidence and no missing
mandatory route/prerequisite disguised as a pass. Record changed paths, profile
identities, commands/results, bounded upstream limitations and remaining release/
distribution gates. Retain substantive license/source obligations; no legal
clearance, complete corresponding-source delivery or publication authority follows
from these fixes. Independent review is separate from executed test results.

After authorized implementation, commit each coherent validated batch promptly,
using Salvador Fandiño <sfandino@yahoo.com> as author and committer. Do not commit
unrelated work, generated runtime state, credentials or build outputs. No push.

Rollback only the implementer's own future hunks or isolated commits after checking
for intervening edits. Revert facade contract and current manual together; revert
generator/current outputs together; revert manifest/install checks together.
Preserve A/B/C and operator work, immutable evidence, locks, native inputs and
historical failures. No reset of the worktree, deletion of shared roots or changes
to live runtime. Remove only exact newly allocated disposable children after
inspection. Verify rollback using a new prefix, never by treating a restored
recursive dossier install as F13-compliant. A blocked dependent batch remains
unaccepted; report its precise blocker instead of expanding authority.
