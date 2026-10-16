# Independent packaging/build/install audit

Baseline: `4903eb7441242a742ffa97d502eb6fc7735c2355`, 2026-10-16.
Audit only; no implementation, commits, dependency changes or runtime controls.
Read project/workspace AGENTS, current SPEC/DESIGN/COVERAGE/PLAN and this audit's
map/index. Legal conclusions are expressly outside this dimension.

## Conclusion at a glance

The four retained source/SDK × CMake/LuaRocks installations have credible,
internally consistent **Ubuntu 24.04 amd64 / ordinary PUC Lua 5.4.6** packaging.
Direct inspection confirms adjacent real guard libraries, `$ORIGIN` lookup and
no linked/bundled Lua VM. I found no demonstrated failure of those installations.
Three focused findings remain: selected-host ABI rejection, installed-document
link closure, and an automation-only variable in the installation recipe. None
justifies replacing the qualified native integration or adding speculative
cross-platform machinery.

## Findings

### PKG-01 — Medium: the selected Lua host is disconnected from header selection, with no runtime ABI check

**Locations:** [cmake/Binding.cmake#L3](../../../../cmake/Binding.cmake#L3),
[cmake/Binding.cmake#L6](../../../../cmake/Binding.cmake#L6),
[lua-libghidra-scm-1.rockspec#L15](../../../../lua-libghidra-scm-1.rockspec#L15),
[scripts/luarocks-build.lua#L22](../../../../scripts/luarocks-build.lua#L22),
[src/boundary.cpp#L185](../../../../src/boundary.cpp#L185).

**Evidence and impact — static, not a reproduced crash:** LuaRocks invokes the
driver with its selected `$(LUA)`, but that identity and its headers are not
forwarded to CMake. CMake independently selects ambient `pkg-config lua5.4`.
Its assertion verifies header version and integer width, not the loading host
or `lua_Number` configuration. Module initialization immediately creates
metatables; it never calls `luaL_checkversion`. Thus a LuaRocks-selected custom
5.4 host can receive a module built for the system 5.4 numeric ABI without a
deliberate compatibility rejection. An eight-byte integer alone does not imply
the ordinary double-number ABI. No-second-VM linkage is necessary but does not
make mismatched host/header ABIs safe.

The retained system host and shared/static embedded hosts use the same ordinary
ABI and are not shown broken. This finding requests rejection of incompatible
hosts, not support for alternative Lua builds or versions.

**Focused correction:** make the selected Lua include/config identity explicit
in the LuaRocks-to-CMake handoff, and perform Lua's standard version/numeric-size
check at the trivial module entry boundary before publishing userdata/metatables.
Keep every Lua symbol resolved from the host; do not fix selection by linking a
second VM.

**Proportional alternative:** retain the single system-pkg-config profile, clearly
require LuaRocks's selected host to match it, and fail early on a mismatch. A
general Lua-discovery abstraction is unnecessary.

**Test:** existing ordinary standalone/static/shared positives plus one bounded
incompatible numeric-ABI host case that must reject `require` cleanly before
owner construction. Verify the actual header/host selection in a LuaRocks build
with an explicit Lua prefix. Do not claim that test as qualification of the
incompatible host.

### PKG-02 — Medium: installed document layout does not preserve its promised relative-link closure

**Locations:** [cmake/Binding.cmake#L143](../../../../cmake/Binding.cmake#L143),
[cmake/Binding.cmake#L151](../../../../cmake/Binding.cmake#L151),
[README.md#L20](../../../../README.md#L20),
[docs/PLAN.md#L7](../../../PLAN.md#L7),
[tests/installed_documents.lua#L11](../../../../tests/installed_documents.lua#L11).

**Evidence and impact — observed in an actual installed prefix:** the install
comment promises preservation of relative documentation/manifest/lock links,
but only README/LICENSE/locks and `docs/`/`api/` are installed together. A read-only
link walk of the retained `full-sdk-prefix/share/doc/lua-libghidra` found **15
missing local Markdown-link occurrences**. Examples:

- Installed README → `workflows/OPERATIONS.md`.
- Installed PLAN → `../workflows/OPERATIONS.md`, `../workflows/LAUNCH.md`,
  `../tests/installed-sdk/CMakeLists.txt`, `../scripts/check-tooling.lua`, and
  `../tests/fixtures/SHA256SUMS`.
- Installed NATIVE-READINESS → `../tests/fixtures/README.md`.

These files exist in the source checkout but not at those installed paths.
Installed README/API/INSTALLED-FULL/NOTICES/FIELDS were byte-identical to the
current checkout in the spot check: **fresh bytes do not establish link closure**.
The existing installed-document gate checks enumerated presence/content/freshness,
not local-link destinations. Users following the installed evidence/reproduction
navigation encounter dead ends.

**Focused correction:** define an explicit installed-document set and ensure its
links resolve within that set or to an exact source revision online. Include the
small required referenced artifacts where offline use is intended.

**Proportional alternative:** install a compact user-facing README/API/fields/
examples/limitations/provenance set and link clearly to source history. Do not
ship the entire automation and test tree merely to satisfy today's blanket
`install(DIRECTORY docs api)` design; the historical directory organization is
not itself a product requirement. Keep required provenance/notices available.

**Test:** walk local relative Markdown links under both CMake and LuaRocks's
versioned data prefix; remove or relocate one destination in a disposable copy
and require a path-specific failure. Separately retain byte freshness checks.

### PKG-03 — Medium: the published LuaRocks recipe expands an unset automation variable into root-level output paths

**Locations:** [docs/PACKAGE-FOUNDATION.md#L12](../../../PACKAGE-FOUNDATION.md#L12),
[docs/PACKAGE-FOUNDATION.md#L15](../../../PACKAGE-FOUNDATION.md#L15),
[docs/PACKAGE-FOUNDATION.md#L31](../../../PACKAGE-FOUNDATION.md#L31),
[scripts/luarocks-build.lua#L11](../../../../scripts/luarocks-build.lua#L11).

**Evidence and impact — shell expansion reproduced, installation not attempted:**
the installation section says to run from the locally checked-out project root,
but does not define `SAIVAGE_CARD_WORK_ROOT`. With it unset, the documented values
become `/my-rock-build` and `/my-rock-tree`. The driver accepts the first as an
absolute path and proceeds; an ordinary non-root user then fails on root-level
directory creation. The package-regression example has the same dependency.
The retained automation runs had the variable, so their success does not prove
the recipe is usable outside that harness.

**Focused correction:** introduce an ordinary caller-chosen absolute work
directory in the user recipe and use it consistently. Keep harness variable
examples in operator history only.

**Proportional alternative:** require an explicitly set work variable with shell
`${WORK:?set an absolute writable work directory}` expansion. No packaging
framework or permission changes are needed.

**Test:** expand/run the documented setup from a non-root shell with all Saivage
variables absent, using a disposable writable directory. A recipe that still
requires caller input should fail before CMake with a useful message, rather than
silently selecting `/my-rock-build`.

## Verified strengths and bounded limitations

### Native linking, guard, and relocation

- Read-only `readelf -d`, `nm -D --defined-only` and file-type inspection covered
  all four retained `card-g-a` prefixes: `full-sdk-prefix`, `full-sdk-rocks`,
  `full-source-prefix`, `full-source-rocks`. Each installed `_native.so` needs
  `libllg_process_guard.so.1`, has `RUNPATH=$ORIGIN`, and has an adjacent **regular
  file**, not a broken versioned symlink. None needs liblua or defines Lua/auxlib
  VM symbols. SDK-prefix `ldd` resolves the guard locally and the BFD/zlib/zstd/
  sframe/C/C++ system closure. No Python/Java runtime dependency was found.
- [Binding.cmake#L19](../../../../cmake/Binding.cmake#L19) intentionally borrows
  host Lua; [#L25](../../../../cmake/Binding.cmake#L25) uses a separately shared
  SONAME guard. These are justified safety mechanisms, not disposable historical
  ceremony. The loader-copy/concurrency suite belongs to the coordinator; this
  audit did not rerun it or infer all process-lifetime behavior from ELF metadata.
- Source mode uses `libghidra::local_whole`; SDK mode recreates WHOLE_ARCHIVE for
  `libghidra::local`. Global PIC and the dedicated `-z defs` native closure target
  are meaningful. Ordinary unresolved Lua symbols in the module are intentional.
- The installed native SDK's export contains absolute Ubuntu system paths for
  `libbfd.so`, `libsframe.so`, `libzstd.so`; installed modules need
  `libbfd-2.42-system.so`. Moving the wrapper prefix on the **same qualified
  system** is different from moving the SDK/binary to another distribution.
  Current [INSTALLED-FULL#L77](../../../INSTALLED-FULL.md#L77) accurately limits
  this to Ubuntu 24.04 amd64. Do not turn those expected constraints into a
  speculative portability rewrite or label the SDK generally relocatable.

### Preparation, source versus SDK, and offline reproducibility

- [native_prepare.lua#L12](../../../../scripts/native_prepare.lua#L12) checks all
  locked archive hashes before extraction; it preflights tar entry types/paths,
  streams ZIP language bytes into regular files and checks exact authorized patch
  identity. Explicit online preparation is separate from disconnected configure.
  The pinned-input scope makes this a reasonable small tool, not a general
  archive-extraction library requirement.
- [CMakeLists.txt#L8](../../../../CMakeLists.txt#L8) returns through the SDK branch
  before Python discovery. Source mode checks Python >=3.10/zlib, then invokes
  the unchanged upstream generator. The inspected upstream EmbedSpecs.cmake uses
  `Python3_EXECUTABLE`; no interpreter-selection discrepancy was found. The
  narrowly approved generator exception is appropriate; replacing it is not an
  audit recommendation. Installed SDK/runtime must remain Python-binding-free.
- Source overrides are supplied for all five prepared source trees; compiled
  specs arrive through the locked engine overlay. CMake requires shared BFD/
  sframe/zstd, bypasses static libiberty, and checks that BFD was enabled. It does
  **not** automatically certify arbitrary source overrides or ambient libraries
  against the committed lock. The separate system checker verifies archive hashes
  and installed dpkg source/binary identities; it does not prove source archives
  were fetched/built. Those limitations are already honestly documented.
- The SDK branch requires exact Protobuf 29.3.0 CONFIG before libghidra. The
  separate SDK builder installs PIC Protobuf/Abseil before installing the local
  library. A plain wrapper source installation is not automatically a complete
  reusable SDK; [PACKAGE-FOUNDATION#L132](../../../PACKAGE-FOUNDATION.md#L132)
  correctly explains that distinction.
- The four recorded clean offline builds are prior one-profile outcomes, not
  four fresh builds performed by this audit. Network-disabled qualification is
  stronger than the CMake disconnected setting alone. Namespace privileges,
  GNU utilities, Ninja, binutils shared development files and pkg-config Lua are
  real environmental prerequisites, not universal platform facilities.

### Clean source archive, rock, and documentation freshness

- Extracted `git archive 4903eb7` only under
  `/home/salva/g/ml/tmp/lua-libghidra-audit-package/source`. It includes the local
  driver, scripts, tests and fixtures, and excludes `.cache` dependency inputs.
  Consequently source-archive builds still need separately prepared inputs or an
  SDK. No hidden dependency-cache inclusion or claim of a self-contained archive
  is warranted. This was an extraction/content check, **not an archive build**.
- [rockspec#L5](../../../../lua-libghidra-scm-1.rockspec#L5) specifies `file://.`;
  this is a local `luarocks make` descriptor. Retained qualification uses `make`,
  not a fetched `.src.rock`. Inspection of the installed LuaRocks source-fetch/
  pack code shows that normal packing expects an archive source, not this local
  directory placeholder. A portable source-rock artifact has not been established.
  Because the descriptor explicitly says local development only, I classify this
  as a bounded delivery limitation, not a false claim of a published rock. Before
  a source-rock delivery is requested, select a revisioned archive/source URL and
  test pack→unpack→offline build from a fresh cwd; publication is not needed for
  that local test and was not performed here.
- CMake's full directory copy also ships chronological milestone/review material
  as user docs. For example [NATIVE-READINESS#L24](../../../NATIVE-READINESS.md#L24)
  still presents removed Python preparation commands; the clean source archive
  has no `scripts/prepare-native.py`. That document labels itself an M0 experiment,
  and the current Lua replacement is documented elsewhere. Preserve historical
  evidence but separate it visibly from runnable installation instructions, rather
  than requiring every old experiment to become a maintained entrypoint. This
  overlaps the dedicated documentation dimension and PKG-02; it is not a new
  Python dependency discovered in the actual build.

## Audit limits and final disposition

No shared builds, CTest, installs, fixture writes, namespaces, service controls,
source edits or dependency repairs were run. Container access was read-only
artifact/tool inspection. Scratch extraction and standalone read-only document/
shell probes stayed under the authorized workspace scratch policy. No full
runtime test, ABI-mismatch crash, moved-prefix execution, clean archive compile,
source-rock pack or new offline build is claimed. Full runtime/absence and test
suite results remain the coordinator's responsibility.

**Disposition:** retain the existing qualified Linux source/SDK integration and
host-VM/guard design. Correct the three focused boundaries above; describe
source-rock distribution, alternate hosts and cross-distribution relocation as
unqualified until actually exercised. Legal review and release approval remain
separate from these technical findings.
