# A boundaries — independent design/plan review, round 1

Reviewer: fresh independent Astra reviewer A, never author. Reviewed the three
`docs/development/plans/package-fixes-2026-10-16/A-boundaries/` drafts against the
production source and the requested contracts/audit records. This is a static
review with read-only host discovery, not implementation or runtime qualification.

## Verdicts

| Document | Verdict | Reason |
| --- | --- | --- |
| 01-ANALYSIS.md | APPROVED | Correctly identifies the reachable inconsistencies and bounded ABI gap; alternatives and compatibility costs are proportionate. |
| 02-DESIGN.md | CHANGES_REQUESTED | Core facade and first-entry designs are sound; make the host-identity/negative-fixture qualification contract concrete as below. |
| 03-PLAN.md | CHANGES_REQUESTED | The ordinary include-directory command is wrong on Debian-style installations, and selected-prefix/negative-host validation needs executable prerequisites. |

## Required changes

### R1 — Resolve the directory containing Lua headers, not pkg-config's base includedir

**Location:** plan §3, `GOOD_INC=$(pkg-config --variable=includedir lua5.4)`;
design §3 default-header selection.

The declared `LLG_LUA_INCLUDE_DIR` must contain `lua.h`, `lauxlib.h` and
`luaconf.h`. `pkg-config --variable=includedir lua5.4` does not necessarily name
that directory. Read-only inspection here returned `/usr/include`, whereas
`pkg-config --cflags lua5.4` returned `-I/usr/include/lua5.4`; the actual headers
are in the latter. Supplying the former as an explicit directory must fail under
the proposed design. Thus the main positive validation recipe can stop at its
first configuration without testing the intended change.

**Change:** derive/find the header directory from pkg-config's include search
directories (and explicitly check the three required files), or require an
explicit verified `GOOD_INC`. State the same resolution rule for the CMake
default. Do not append a version suffix blindly or silently fall back when an
explicit directory is wrong. Add a positive check of the resolved directory to
the recipe and a diagnostic distinguishing this failure from host ABI rejection.

### R2 — Specify a reproducible incompatible-host fixture, including the actual ABI assumptions

**Location:** design §4; plan §0 and ABI batch steps 5–6.

The negative regression is mandatory, but the only acquisition interface is
“provisioned” by an unnamed test-fixture owner. No source identity, configuration
recipe or artifact validation command is provided. This leaves the most important
new rejection gate dependent on an unresolved prerequisite rather than an
executable bounded test plan.

The exact PUC 5.4.6 interface matters: `luaL_checkversion(L)` calls
`luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES)` where the second parameter
is itself `lua_Number`, and `LUAL_NUMSIZES` is
`sizeof(lua_Integer)*16 + sizeof(lua_Number)`. The host implementation obtains
`lua_version(L)` internally and checks the size token before comparing the
version argument. This supports the intended bounded size-mismatch test; it is
not a general ABI firewall. A custom number configuration also changes the
function's C signature. The test must establish the selected Linux amd64 case,
not infer clean rejection for every custom Lua configuration.

**Change:** specify one concrete standalone PUC 5.4.6 rejection fixture, for
example ordinary 64-bit integers with 32-bit float numbers on the existing amd64
toolchain. Provide a pinned source/artifact identity and reproducible isolated
fixture recipe or an exact existing fixture-provisioning reference/interface.
Explain how its configuration is set and checked; blindly adding a compiler
`-DLUA_FLOAT_TYPE` can be overridden by the normal `luaconf.h` configuration.
Include host-side observations such as
`string.packsize('j') == 8` and `string.packsize('n') == 4`, host version, exported
Lua symbols/dynamic loading support, and a protected load yielding the actual
numeric incompatibility diagnostic. Keep the existing requirements for no
metatable publication, successful subsequent Lua execution/GC and failure on
missing libraries/symbols. Run both probe and production-module rejection.

Fixture preparation is isolated test infrastructure, not a change to pinned
libghidra/engine dependencies and not qualification of float Lua as supported.
If provision is genuinely external, identify its owner/deliverable and mark it
as an explicit unresolved completion dependency. Do not claim the plan is fully
executable until that dependency has an actionable provisioning contract.

### R3 — Make selected-host identity validation discriminating and separate embedded-library identity

**Location:** design §3 build-input contract and embedded positives; plan §3
LuaRocks case and completion criteria.

The central F03 defect is loss of LuaRocks selection, yet the required positive
case may use `/usr` and a nondefault prefix is only tested “when available.” A
driver accidentally retaining ambient discovery can pass a system-prefix test.
`pkg-config lua5.4` identifies headers/libraries according to its search path;
it does not identify the executable returned by `command -v lua5.4`, nor the
interpreter selected by LuaRocks. The compatibility probe establishes its bounded
numeric-size/version result, not common installation provenance.

The current embedded targets additionally link `${LUA_LIBRARIES}` and an
independently found `LUA_STATIC_ARCHIVE` while compiling with `${LUA_INCLUDE_DIRS}`.
The proposal deliberately keeps ordinary system embedded libraries, which is
reasonable, but their identity must not be reported as that of a selected custom
interpreter. Changing `PKG_CONFIG_PATH` or archive caches can change these inputs.

**Change:** require one real nondefault compatible-prefix selection case (or
explicitly record its absence as an unmet gate). Record the resolved LuaRocks
executable/include values and compare them to CMake cache and actual compile
include flags; execute the installed smoke/regression with that selected host,
not always ambient `lua5.4`. State that system embedded positives are a separate
qualified ordinary-host lane, record their resolved shared/static library paths,
and bound matching-header assumptions to that lane. Preserve independent default
system discovery tests. No generalized discovery framework or additional linked
VM is needed.

## Accepted technical decisions

* **Retain reopen with shared key validation.** `init.lua:8–10` currently bypasses
  the factory check at `:105–111`; `owner.cpp:387–393` accepts the ignored native
  fields. The proposed six-key helper is the correct small boundary. Presence
  rejection includes false/empty values; native value parsing remains single-source.
  `next`/`rawget` avoid `__pairs`/`__index`. Factory success remains
  `session,nil,response`, reopen remains `response` or `nil,error`, and factory
  protected publication/cleanup stays intact. Existing-owner reopen failures must
  not release the owner.
* **Retain guarded shutdown.** Removing a working method is not necessary to
  reconcile old native-only prose. Sharing precisely the close/save precondition
  between two explicit wrappers is cleaner than either duplicated policy or a
  generic method-policy registry. `owner.cpp:394–399` owns raw policy grammar;
  `:140–143` makes closed owners defer to native `CLOSED`. Unknown keys before
  `NO_STATE_PATH`, correct operation names, `{accepted=...}` versus
  `{closed=...}`, and faithful native empty-path behavior are correctly specified.
* **Generation/lifetime.** Native generation increments at `owner.cpp:537`
  before dispatched lifecycle calls, including failed dispatches. Proposed Lua
  rejections must not manufacture changes. Logical closure versus owner release,
  `NO_PROGRAM` versus `CLOSED`, historical metadata, stale buffered/exhausted
  iterators and continued process-slot exclusion are properly distinguished.
* **Entry check.** `boundary.cpp:185–207` and its exported wrapper have trivial
  frames; adding the standard check first in `llg::module` reaches both production
  and directly linked test entrypoints before metatable creation. Do not move it
  after publication or wrap it in a live RAII scope. Lua errors propagate through
  a protected caller rather than an invented binding error table.
* **ABI boundaries.** Signed eight-byte integer and exact eight-byte C++ double
  header checks, cache invalidation, explicit LuaRocks inputs and a no-liblua
  host-loaded configure probe are coherent for the stated native platform. The
  draft correctly disclaims universal custom-ABI safety. Shared guard SONAME,
  whole-archive registration and host-resolved Lua symbols remain justified.
* **Integration and rollback.** B/C handoffs identify shared `Binding.cmake`,
  installed layout, direct-driver argument consumers and non-skipping test
  registration. Separate attributable facade/ABI batches and own-hunk rollback
  are bounded; final integration must use the final shared-file/layout versions.
  No upstream repair, extra dependency patch, HTTP, SWIG or platform expansion
  is introduced. Final-package documentation restrictions are correctly separated
  from source/tools/tests. Draft implementer bodies are self-contained rather
  than a reviewer-response transcript.

## Optional precision improvements

1. Add a hostile table/userdata unknown-key case with `__tostring` that raises
   or mutates state. Diagnostic formatting should not invoke it. Extend raw
   policy tests to shutdown/close_program, including an inherited `policy='save'`
   that must not become a real request. Existing `next`/raw parsing already give
   the intended implementation direction; these make it harder to regress.
2. Separate real-fixture response fidelity assertions from deliberately supplied
   false/zero/empty response cases. Authored ELF/project fixtures need not produce
   every possible open flag value. Supplement, rather than replace, installed
   native tests with a small forwarding test if those values cannot be elicited
   naturally. Never require an upstream behavior change to manufacture a flag.
3. Explicitly include a failing save destination outcome as well as a disposable
   writable path if an existing deterministic wrapper test supplies it; retain
   native error and iterator invalidation without asserting successful closure.

## Historical baggage / evolutionary bias assessment

The selected changes do not treat older prose as stronger evidence than shipped
behavior. Retaining two useful methods with focused policy is preferable to
deleting them merely to restore an old specialist-only taxonomy. Conversely,
bulk forwarding is not sacrosanct when it causes policy drift. The existing native
parser, protected publication, post-Lua owner recheck and process guard each
protect a reachable boundary and should remain.

The new configure probe is added ceremony, but has a distinct purpose: reject
the selected build host before installing an unusable package, including with
`BUILD_TESTING=OFF`. The production entry check protects later loads by a different
host. Keep one small probe project/script and direct tests; do not grow this into
a Lua discovery service, runtime type-certification framework, multi-platform
matrix or repeated approval choreography. The three required corrections above
make existing chosen gates executable and honest rather than inventing new
product scope.

## Inspection record and limits

Read repository AGENTS and SPEC/DESIGN/COVERAGE/PLAN, the requested audit index,
map, F01–F03 and all three dimension reports. Independently inspected production
facade, iterator, native parsing/generation/publication, build targets, rockspec,
LuaRocks driver, package driver and embedded/installed test interfaces. Checked
local Lua 5.4 headers and pkg-config outputs, plus upstream PUC Lua **v5.4.6**
`lauxlib.c` (especially `luaL_checkversion_`):
<https://github.com/lua/lua/blob/v5.4.6/lauxlib.c>.

No builds, shared suites, production edits, commits, pushes, dependency edits or
runtime-control operations were performed. Existing unrelated working-tree edits
were left alone. Only this requested review file was written. This review does
not approve a future master plan or constitute review of subsequent revisions.

VERDICT: CHANGES_REQUESTED
