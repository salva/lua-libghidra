# A boundaries — independent design/plan review, round 2

Fresh independent Astra reviewer A; reviewer, not author. Reviewed the revised
`A-boundaries/01-ANALYSIS.md`, `02-DESIGN.md` and `03-PLAN.md` against the requested
contracts, audit records and actual source. This is static plan approval, not
implementation authorization or evidence that the proposed tests have passed.

## Separate verdicts

| Document | Verdict | Assessment |
| --- | --- | --- |
| 01-ANALYSIS.md | APPROVED | Correct reachable facade inconsistencies and bounded ABI gap; distinguishes observed behavior from unexecuted qualification. |
| 02-DESIGN.md | APPROVED | Focused facade policies, explicit host/header selection, separate embedded identities and pre-publication check are coherent. |
| 03-PLAN.md | APPROVED | R1–R3 now have concrete inputs, fixture provisioning, discriminating observations and runnable future test interfaces. |

## Required changes

None. No unresolved round-one objection remains in these three revised documents.
The two-round budget is not being used to infer approval from elapsed rounds:
the corrections below independently satisfy the objections.

## Round-one corrections re-evaluated

### R1 — Actual header-directory discovery: resolved

Design lines 103–113 and plan lines 231–252 search the pkg-config include search
directories and require `lua.h`, `lauxlib.h` and `luaconf.h` in the selected
directory. The Bash extraction removes `-I`, checks each candidate and resolves
the actual directory; it does not assume base `includedir` or append a guessed
suffix. Its no-spaces restriction is explicit and appropriate to this bounded
Ubuntu recipe. CMake uses the list-valued include directories directly.

Explicit missing headers must fail without ambient fallback. The configure
regression distinguishes missing-header errors from numeric-profile/host mismatch,
and independently exercises no-override discovery. This corrects the command
that previously supplied `/usr/include` on a versioned-header installation.

### R2 — Pinned float rejection fixture and ABI claim: resolved

Independently checked the official Lua FTP checksum entry, PUC **v5.4.6**
`luaconf.h`, `lauxlib.h`, `lauxlib.c`, and the release archive's two Makefiles.
The stated archive SHA-256 matches the official entry. The one-definition edit
of `LUA_FLOAT_DEFAULT` selects float while retaining `LUA_INT_DEFAULT` as long
long and `LUA_32BITS=0`; unlike a `-DLUA_FLOAT_TYPE` override, it survives the
header's default-selection branch. Non-C89 GCC on the qualified amd64 toolchain
is consistent with the chosen integer configuration.

The proposed `make -C src all` explicitly supplies Linux/dlopen support,
`-Wl,-E` and `-ldl`; the archive Makefile supplies `-lm` and builds both interpreter
and archive. The top-level install target copies the resulting executables and
headers to the isolated prefix. Readline is not required by this recipe. These
are test-only copies, not edits to installed Lua or the locked native dependencies.

The host assertions establish 8/8 versus 8/4 integer/number sizes, patch version,
exported symbols and identities. Both the ordinary-header probe and actual module
must resolve their entry symbols and fail under `pcall` with the numeric-type
diagnostic; loader failures do not count. Registry absence, no published factory,
and continued Lua execution/GC explicitly test the pre-publication boundary
without constructing a native owner.

The signature caveat is now accurate: `luaL_checkversion_` takes `lua_Number`
as its version argument, so caller and float host signatures differ. At this
pin the host obtains its own version and tests `LUAL_NUMSIZES` before comparing
the version argument. Tokens 136 and 132 and the Linux amd64 argument-location
reasoning justify this specific experiment, not universal custom-ABI safety.
The documents require an observed protected diagnostic rather than declaring
source reasoning a runtime pass. Actual execution remains future work.

### R3 — Discriminating selection and embedded identities: resolved

Plan §3a builds an unchanged, genuinely nondefault compatible interpreter/header
prefix. Section 3c leaves ambient pkg-config selecting system Lua, checks distinct
realpaths, records LuaRocks's resolved executable/include variables and driver
arguments, asserts CMake cache values, and inspects actual module compilation
commands. Installed regressions run with that selected interpreter. This can
detect a driver that silently retains system selection; a renamed system binary
or `/usr`-only build no longer satisfies the test.

The system-default configure case remains independent. Embedded shared/static
positives use separately resolved system headers and absolute library identities,
including targets compiling boundary/owner sources directly. Configure/cache,
verbose link commands, hashes, `ldd`, exported symbols and DT_NEEDED inspection
distinguish those executables from the custom standalone prefix. An independently
cached archive or bare `-llua5.4` is not presented as provenance proof.

## Source-contract and scope checks

* `init.lua` currently forwards reopen/shutdown and separately validates factory
  program keys. The shared six-key validator preserves factory
  `session,nil,response`, complete Session reopen envelopes, and existing-owner
  lifetime on failure. Presence rejection includes false/empty ignored fields.
  Raw iteration/access and fixed unknown-key diagnostics avoid hostile
  `__pairs`, `__index` and `__tostring`; native value parsing remains authoritative.
* `owner.cpp:394–399` owns the raw save/discard grammar; `:140–143` deliberately
  lets closed owners reach native `CLOSED`. The two-method save precondition
  preserves unknown-key precedence and operation names, and distinguishes
  `{closed=...}` from `{accepted=...}` without inventing persistence guarantees.
* `owner.cpp:537` increments generation before dispatched lifecycle operations;
  validation-only rejection must not increment it. Existing iterator checks run
  even after exhaustion. The proposed tests preserve that distinction, logical
  closure versus owner release, process-slot exclusion and historical metadata.
  `ownership_close_failure.lua` supplies the concrete Linux `/dev/null/child`
  failing-destination setup referenced by the revised plan.
* `boundary.cpp:185–204` has a trivial module/exported entry chain. Making the
  standard check the first operation precedes both metatable publications and
  reaches direct-call test hosts. Neither production nor configure module links
  liblua; embedded executables own their separate test-host VMs. Existing guard,
  whole-archive and `$ORIGIN` requirements remain intact.
* Real installed ELF/project regressions remain primary. The optional small
  forwarding supplement covers response values absent from real fixtures without
  demanding fabricated upstream outcomes. No upstream repair, additional engine
  patch, persistence expansion, second linked VM or broad test framework appears.

## Self-containment, integration and evolutionary bias

The revised documents explain their contracts and commands directly rather than
requiring the implementer to reconstruct a reviewer-response conversation.
Planned filenames are explicitly prospective. The fixture setup is substantial
but bounded to two copies of one pinned Lua source and directly answers F03;
it does not introduce a general discovery/certification framework.

A hands its settled surface/build contracts to B and runnable test interfaces to
C, and requires final merged validation against their final layout and selection
behavior (plan lines 346–370). The master plan's shared-file ordering is consistent:
A ABI/driver changes precede C integration and B installation-manifest changes;
B finalizes the document manifest only after required content exists. B's manifest
propagation remains B/C work, not a second manifest owned by A. A's standalone ABI
checks remain necessary even if C's full integration has no mismatch-host flag.
This is a cross-group consistency check, not approval of the master plan itself.

Retaining useful shipped facade methods with small explicit policies avoids
privileging historical native-only prose. Existing native parsing, publication
cleanup, generation and process guards protect actual boundaries and are not
removed merely for conceptual neatness. No newly introduced blocking contradiction,
historical acceptance ritual or disproportionate gate was found.

## Inspection limits

Read repository/workspace guidance, SPEC/DESIGN/COVERAGE/PLAN, requested audit
index/map/F01–F03/R1 review, revised A documents, relevant production/build/package
and regression sources, and cross-group ordering. Upstream references checked:
<https://www.lua.org/ftp/>, <https://www.lua.org/ftp/lua-5.4.6.tar.gz>, and
<https://github.com/lua/lua/tree/v5.4.6>.

No builds/tests, author-document/source/test edits, commits, pushes, deployments
or runtime controls were performed. Only this requested review file was written.
Approval covers the reviewed proposal; missing future execution results remain
missing evidence, not successful qualification.

VERDICT: APPROVED
