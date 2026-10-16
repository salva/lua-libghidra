# Installed core qualification — current evidence, not release approval

Current package foundation `04eb4e2` (earlier clean evidence at `2abb88c`), Linux x86-64 ordinary C-built Lua 5.4/64-bit integers,
authorized patched native-local engine only. The current [API](API.md),
[field manifest](../api/FIELDS.md), [notices](NOTICES.md) and installed examples
are local handoff artifacts. Independent review and M5 approval are not inferred.

See [full installed qualification and local handoff](INSTALLED-FULL.md) for the
current full-tier route matrix and [operation/field crosswalk](FULL-CROSSWALK.md).
Historical core evidence below is not promoted into full acceptance.

## Applicable evidence and its limits

Current applicability: changed M4 adapters are not the pre-M4 wrapper.
M4 independent review v6 at `595b77c` traces protected request/converter copying,
post-Lua-phase owner rechecks and extended fault/exception/finalizer/read-order
coverage, plus ordinary and wrapper/host ASan/LSan/UBSan evidence. Its historical
pending-policy disposition is superseded only by explicit YES/19d0945 below.
Current foundation 04eb4e2 rebuilt owner.cpp and the SDK module; the rebuilt
installed primary `work:///cards/card-e-a/processes/proc-1abfafa389c2/stdout.log`
confirms real core ELF/project, standalone/static/shared hosts, lifecycle/pages/
mutation/persistence, constructor/cache and runtime-absence regressions. This is
current exercised evidence, not an assertion that old adapters remained unchanged.


| Gate | Evidence and disposition |
| --- | --- |
| Historical installed CMake runtime, standalone/static/shared hosts | `bash tests/installed-qualification.sh build`, exit 0 at unchanged 2abb88c in this card's red node. Real ELF and analyzed project, exact values/lifecycle/process exclusion, both views, M3 core pages/iterators, persistence, conditional populated CFG, both installed examples. No second VM; $ORIGIN shared process guard. This is not fresh-install evidence. |
| Earlier source/SDK host closure | M1-BOUNDARY integrated current-source report, source ab03d37: 18/18 source and 17/17 SDK tests, installed standalone/static/shared profiles. Historical source/SDK closure only; current changed-wrapper applicability is reconciled above. Provenance and detailed limits retained there. |
| Wrapper safety | M1-BOUNDARY all-frame audit and M1-OWNERSHIP wrapper fault/reentry/exception evidence, M3-CORE request/conversion/iterator follow-through. Dependency-internal allocation recovery excluded by operator a0289f5, not wrapper safety. No claim of instrumented dependency internals. Historical pre-M4 broader rerun (not sufficient alone for current adapters): `ctest --test-dir build --output-on-failure` 18/18 (10.67s); `bash tests/wrapper-sanitize.sh "$PWD/.cache/native-sdk-patched"` 18/18 (27.93s), ASan/LSan/UBSan wrapper/host instrumentation with unchanged precompiled dependencies and system Lua. |
| Native roots/cache profiles | NATIVE-READINESS and native-patched-qualification.log retain actual external valid/missing/unreadable and embedded cold/warm/unwritable outcomes. Native-only success does not qualify all installed Lua constructor paths: installed Lua qualification is now recorded below. |
| Package foundation | PACKAGE-FOUNDATION/HANDOFF record source/SDK/LuaRocks local installs, offline source-input overrides, installed closure and tooling cutover provenance. These remain distinct from final runtime-absence qualification. |
| Tooling migration | 2abb88c retires owned Python tools/tests, replacing them with Lua source-driven inventory/completeness/semantic regressions. api/README documents the current entry points and immutable history separation. The upstream embedding exception is approved only for unchanged pinned SOURCE-build generation (YES/19d0945; exact exclusions below), not permission to reintroduce a Python oracle. |
| Shipping documentation gap | Current CMake install includes API, all native field facts, retained grammar/limits/runtime evidence, locks, original license and third-party notices. `lua5.4 tests/installed_documents.lua PREFIX` checks presence and current claims; `lua5.4 scripts/render-fields.lua --check` detects stale generated field prose. Installation does not claim redistribution compliance is complete. |

Fresh SDK-backed CMake Release configure/build/install also passed document and
real installed owner/Session checks. Fresh LuaRocks SDK-backed `make` passed;
its non-module data resides in the versioned package prefix, not the tree root:

```sh
lua5.4 tests/installed_documents.lua "$tree" \
  "$tree/lib/luarocks/rocks-5.4/lua-libghidra/scm-1"
lua5.4 tests/installed_owner.lua "$tree" "$PWD"
```

Both passed after explicitly selecting the correct prefix. An initial assertion
at `$tree/share/doc/...` failed; it was a test-path hypothesis error, not missing
LuaRocks packaging. These local builds did not run source embedding and were not
network-isolated. Those initial install checks alone did not qualify the full
installed matrix/absence gates; the subsequent completed profile and absence
qualification, including current rebuilt-wrapper applicability, is recorded below.

Primary existing-install output for this card:
`work:///cards/card-e-b/processes/proc-2fa0fbad51b0/stdout.log` and
`work:///cards/card-e-b/processes/proc-2fa0fbad51b0/stderr.log`.
Negative decode/unmapped decompilation diagnostics and overlap warnings are
preserved, not treated as undisclosed failures or erased by later success.

Source-generated `api/coverage.json` intentionally says unqualified; it does not
replace manual/runtime qualification. Immutable M3 history and its SHA256-pinned
runtime index remain included. A full field table says what is converted, not
that every field has a native producer or every operation supports all inputs.

## Completed installed runtime gates and remaining acceptance

Installed Lua constructor and runtime-absence gates now pass for the retained
fresh SDK-backed CMake and LuaRocks installations. Run from the project root:

```sh
bash tests/installed-profiles.sh "$prefix" "$SAIVAGE_CARD_WORK_ROOT/fresh-profiles"
bash tests/installed-absence.sh "$prefix" "$SAIVAGE_CARD_WORK_ROOT/fresh-absence"
```

Profile checks run as ordinary uid 1000: explicit external engine root succeeds
for real ELF and analyzed project with exact ENDBR64 bytes and completed,
nonfallback authored `* 3 + 7` arithmetic. Missing/unreadable roots return local
LOAD_FAILED / No sleigh specification at open; no embedded extraction occurs.
Empty root selects the pinned default Decompiler constructor (decompiler_pool.cpp
lines 56–60); cold HOME creates one .complete sentinel, warm and warm-unwritable
reuse leaves file timestamps/sizes/hashes unchanged. Cold unwritable HOME reports
extraction failures then LOAD_FAILED at open. Permission restoration is trapped;
only caller-owned work paths are chmod'ed. No engine/library modification.

Absence checks use short-lived private mount/network user namespaces: Python/Java
executable targets are masked with /dev/null, Python runtime trees and JVM tree
with empty tmpfs; interpreter launch probes must fail. Namespace-local /proc/net
shows no external interface/routes. The inherited sysfs mount is deliberately not
used to infer network namespace interfaces. Installed-only owner, M2 binary/project,
M3 core/iterator checks run through standalone Lua and existing static/shared C-built
hosts for **both** package prefixes, plus real persistence. All pass. Namespace
mounts disappear on process exit; no host interpreter files are edited. These are
runtime-absence results, not source-build generator exception approval.

Evidence in this card: profile CMake proc-7891f59e5351 and LuaRocks
proc-148742527018; strengthened diagnostic checks plus LuaRocks absence
proc-5fdd7c4d6c70; CMake absence proc-0ccda443c77e (stdout/stderr tool captures).
Initial test hypotheses retained in status: wrong pseudocode field and inherited
sysfs/exact route-line assertion; both corrected at the test primitive.

Earlier source/offline installs and real seeded category/conditional CFG tests,
whole-archive/PIC/no-second-VM and wrapper fault/sanitizer evidence above remain
applicable to unchanged locked dependencies and package mechanics, not unchanged
adapters. Current M4 safety and rebuilt installed core evidence above cover the
changed wrapper. Earlier clean tests remain historical; source configuration
invoked the unchanged generator with 385 files up-to-date, not fresh regeneration.
Fresh SDK-backed package qualification
plus both installed host matrices close independent runtime engineering evidence;
they do not claim all dependency builds were offline or every native producer works.
Independent acceptance review and pre-conveyance obligations remain; the
source-generator authority decision is closed as stated below.

Preserve M2 extreme-address crash/raw FileBytes/producer limits and M3 pages-only
blocks/CFG/xrefs/types, union/signature practical producers and saved=true category
loss. Unknown findings are not automatically upstream. No upstream repair campaign
or new dependency patch is authorized.

Operator YES/19d0945 approves ONLY unchanged pinned `cpp/embed_specs.py` via
`cpp/cmake/EmbedSpecs.cmake`, Python >=3.10 stdlib zlib/XML during native
SOURCE builds only. This excludes upstream Python bindings, owned Python tools/tests/parity,
SDK consumers and Lua runtime. No replacement, patch or new distribution rights.
Interpreter/module identities and pinned generator hashes are recorded in
[evidence/source-generator-qualification.txt](evidence/source-generator-qualification.txt).
B1 is closed; no new external generator decision is required.
Corresponding-source delivery/combined linked-license compliance and any eventual
distribution form still need resolution before conveyance; see NOTICES. Planning
license disposition is not legal clearance or new rights. No push, publication,
full-tier acceptance or overall M5 approval.
