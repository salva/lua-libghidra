# A — Implementation plan: facade and host boundaries

Draft execution plan for F01–F03, baseline `4903eb7`. No implementation or runtime
control is authorized by this record. All new filenames/targets below are planned,
not claims that code or passing results already exist. Root-relative links refer
to baseline source locations.

## Contract to implement

* Retain Session `open_program`, validate the same six program keys as factory
  `open`, preserve complete reopen response and the existing owner on failure.
  Reject ignored `read_only`/`project_name` keys before dispatch, including false
  and empty values. Native escape hatch remains faithful.
* Retain Session `shutdown`, add close_program's empty-state-path save guard,
  preserve native `accepted` envelope and logical-close semantics. Native shutdown
  remains unchanged. Neither acceptance nor a configured path promises durability.
* Carry selected Lua executable and headers into CMake; support ordinary PUC 5.4
  only. Check selected host at configuration and real module at trivial entry,
  before publication. Never link another Lua VM into the module.

See [design](02-DESIGN.md) for error precedence and exact grammar; this plan's
tests enforce those contracts. Native-local/no SWIG/no HTTP, the approved
unchanged upstream source generator and existing dependency patch authority stay
fixed. No upstream repair or additional dependency OOM qualification is needed.

## 0. Inputs and coordination before implementation

Record current HEAD and working-tree changes; preserve unrelated work. Confirm
the source paths still match baseline before applying this plan. Obtain explicit
implementation authorization, then coordinate the shared CMake/script edits with
B (package/manual) and C (test selection). Do not change deployments or services.

Required local validation inputs:

* Qualified Ubuntu 24.04 amd64 toolchain, ordinary Lua 5.4 development package,
  LuaRocks, Ninja, and the existing installed native SDK with Protobuf config.
* Authored ELF and analyzed project under `tests/fixtures`, with their existing
  provenance. Writable isolated work root outside source inputs.
* A provisioned PUC Lua 5.4 executable with an incompatible numeric configuration
  (prefer same integer width and non-double number size). This is solely a
  rejection fixture; its source/configuration identity must be recorded. Obtain
  it through the test-fixture owner, not a patch to the pinned native dependency.
  Do not silently substitute ordinary Lua if unavailable.

Use an already available qualified build environment. If execution requires a
container or runtime change, return that prerequisite to the operator; this plan
does not grant runtime-control authority. Commands below run inside the selected
environment with its own absolute paths and do not assume harness variables.

## 1. Facade policy batch (F01, F02)

Edits:

1. In [init.lua](/lua/libghidra/init.lua#L8), replace only the open_program and
   shutdown bulk aliases with explicit wrappers. Extract one private six-key
   program validator reused by factory open. Preserve
   [protected publication](/lua/libghidra/init.lua#L93).
2. Extract the existing close_program precondition into a private helper for
   exactly close_program/shutdown. Preserve unknown-key validation, operation
   names and [_has_state_path closed-owner behavior](/src/owner.cpp#L140).
   Do not change C++ dispatch, generations, flags or native persistence behavior.
3. Add `tests/facade_boundaries.lua`, installed-only, arguments `PREFIX ROOT WORK`.
   Require existing fixtures explicitly and fail if missing. Use unique temporary
   state files below WORK; leave input fixtures untouched. Include clear per-case
   diagnostics. Reuse existing installed path setup from
   [m2_slice.lua](/tests/m2_slice.lua#L3), not a second fixture loader framework.

Required assertions:

| Case | Observable success condition |
| --- | --- |
| Factory and Session rejected keys | Individually reject read_only=true, read_only=false, project_name='', nonempty project_name, unknown string/numeric keys and non-table program options; binding INVALID_ARGUMENT with correct operation |
| Raw semantics | __index/__pairs are not invoked to supply or hide program keys; allowed values still use native validation |
| Validation-only reopen | Generation token unchanged, buffered iterator remains usable, known ENDBR64 bytes still readable, existing owner remains live |
| Allowed Session reopen | Complete response with false/zero/empty fields preserved; same native owner; old buffered/exhausted iterators permanently invalid; factory metadata remains historical |
| Failed dispatched reopen | Native error preserved, generation changes, owner not released; do not require prior program to survive a native open failure |
| Native ignored fields | Native open still accepts both ignored options with valid values; no claim of read-only enforcement |
| Shutdown exposure | Session and native methods both exist and retain accepted envelope, not closed/boolean substitution |
| Save without path | Session shutdown and close_program return NO_STATE_PATH, leave generation/program/iterator unchanged; unknown keys return INVALID_ARGUMENT first |
| Save with path | On disposable writable path, preserve actual native outcome and verify logical closure; a path alone is not treated as a save-success assertion |
| Discard and native save caveat | Real Session/native shutdown returns native accepted outcome; program reads become NO_PROGRAM, status still usable, second client still CLIENT_IN_USE; explicit native save without path remains accepted as at the pin, without asserting persisted state |
| Reopen after shutdown | Same owner works again; old iterators remain invalid, detached responses survive |
| Closed owner | Valid Session shutdown(save) and reopen return CLOSED; malformed arguments retain validation precedence; binding close is idempotent and frees the client slot |

Use the authored ELF and project routes and explicit x86/gcc hints as in
[existing lifecycle coverage](/tests/m2_slice.lua#L86). Do not introduce an
all-operation abstraction or extend persistence categories owned by C.

## 2. Host ABI batch (F03)

Edits:

1. Put `luaL_checkversion(L)` first in
   [llg::module](/src/boundary.cpp#L185). Inspect all frames from exported entry
   and direct test calls: only trivial locals may precede/contain this raising
   check. No metatable, native object, lock or C++ owner may precede it.
2. In [Binding.cmake](/cmake/Binding.cmake#L2), accept `LLG_LUA_INCLUDE_DIR` and
   `LUA_EXECUTABLE`, default explicitly to ordinary system selection, enforce
   504/signed-int64/double headers, and invalidate compatibility check cache on
   changed inputs. Use selected headers consistently for native/test targets.
3. Add a small configure probe project under `cmake/lua-abi-probe/` and
   `scripts/check-lua-abi.lua`. Build a no-liblua MODULE via `try_compile`; run it
   through the selected host with `package.loadlib`/protected call. Return boolean
   true on compatibility; retain useful diagnostics on missing files, symbols or
   numeric mismatch. Run this with BUILD_TESTING both on and off.
4. Extend [rockspec](/lua-libghidra-scm-1.rockspec#L15) build arguments with selected
   `$(LUA)` and `$(LUA_INCDIR)`; extend [driver](/scripts/luarocks-build.lua#L17)
   to validate/forward them. Update direct driver invocations in
   [package-foundation.sh](/tests/package-foundation.sh#L11) so absent/ambiguous
   SDK/input tests still test that condition rather than failing on new arguments.
5. Add `tests/lua_abi_rejection.lua`, arguments `BUILD`, for use by the provisioned
   incompatible host. Load `BUILD/libghidra/_native.so` directly and pcall its
   entry. Require a numeric-size ABI diagnostic, absence of module metatables
   in the debug registry (use actual names from source), and subsequent ordinary
   Lua computation/GC success. Wrong-version, missing-library or missing-symbol
   errors must not count as this numeric mismatch regression. No engine creation
   is necessary to test a check that runs before the factory is published.
6. Add a configure regression driver `tests/lua_abi_configure.sh ROOT SDK WORK
   GOOD_HOST GOOD_INCLUDE BAD_HOST` using fresh build directories per case:
   ordinary explicit selection passes, nonexistent include fails, incompatible
   host with ordinary headers fails at ABI probe, and changing selection in an
   existing directory reruns rather than reuses compatibility success. Record
   actual diagnostics and fail if a negative case unexpectedly succeeds.

Do not link Lua into the configure module or production module; test executables
may link their own host VM. Keep guard linkage/whole-archive/PIC intact. Check
the runtime mismatch with the actual production module as well as the tiny probe.

## 3. Concrete validation commands

Set inputs explicitly in the qualified environment (paths below are variables,
not new standard installation locations):

```sh
export ROOT=/home/salva/g/ml/lua-libghidra
export WORK=/home/salva/g/ml/tmp/lua-libghidra-boundaries
: "${SDK:?absolute qualified installed SDK prefix}"
: "${BAD_LUA:?absolute provisioned incompatible numeric Lua 5.4 host}"
export GOOD_LUA=$(command -v lua5.4)
export GOOD_INC=$(pkg-config --variable=includedir lua5.4)
mkdir -p "$WORK"
cmake -S "$ROOT" -B "$WORK/build" -G Ninja \
  -DLIBGHIDRA_USE_SDK=ON -DCMAKE_PREFIX_PATH="$SDK" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON \
  -DLUA_EXECUTABLE="$GOOD_LUA" -DLLG_LUA_INCLUDE_DIR="$GOOD_INC" \
  -DCMAKE_INSTALL_PREFIX="$WORK/prefix"
cmake --build "$WORK/build" --parallel 4
ctest --test-dir "$WORK/build" --output-on-failure
cmake --install "$WORK/build"
lua5.4 "$ROOT/tests/facade_boundaries.lua" "$WORK/prefix" "$ROOT" "$WORK/state"
lua5.4 "$ROOT/tests/m2_slice.lua" "$WORK/prefix" "$ROOT"
lua5.4 "$ROOT/tests/m3_core.lua" "$WORK/prefix" "$ROOT"
"$BAD_LUA" "$ROOT/tests/lua_abi_rejection.lua" "$WORK/build"
sh "$ROOT/tests/lua_abi_configure.sh" "$ROOT" "$SDK" "$WORK/configure" \
  "$GOOD_LUA" "$GOOD_INC" "$BAD_LUA"
readelf -d "$WORK/prefix/lib/lua/5.4/libghidra/_native.so"
nm -D --defined-only "$WORK/prefix/lib/lua/5.4/libghidra/_native.so"
```

Inspect ELF output: no liblua DT_NEEDED or defined Lua/auxlib VM symbols; expected
guard SONAME and `$ORIGIN` remain. Existing CTest shared/static hosts must pass,
including initialization allocation-failure, independent states, loaded copies
and reentry. Run the targeted facade script again from a fresh directory if its
first invocation was in the source tree. Record executed test names/counts;
do not infer integration execution from aggregate CTest success alone.

For the selected-prefix LuaRocks case, require a provisioned compatible explicit
Lua prefix `LUA_PREFIX` (it may be the qualified `/usr` prefix). Verify LuaRocks
configuration resolves its executable and include directory as expected:

```sh
: "${LUA_PREFIX:?compatible Lua 5.4 prefix}"
cd "$ROOT"
LLG_BUILD_DIR="$WORK/rocks-build" LLG_SDK_PREFIX="$SDK" \
  luarocks --lua-version=5.4 --lua-dir="$LUA_PREFIX" --tree="$WORK/rocks" \
  make --deps-mode=none --no-manifest
grep -E '^(LUA_EXECUTABLE|LLG_LUA_INCLUDE_DIR):' "$WORK/rocks-build/CMakeCache.txt"
cd "$WORK"
lua5.4 "$ROOT/tests/facade_boundaries.lua" "$WORK/rocks" "$ROOT" "$WORK/rocks-state"
sh "$ROOT/tests/package-foundation.sh" "$SDK" "$WORK/package-regression"
```

Compare cache paths to the explicit LuaRocks selection, not merely to expected
version text. Test with an explicit nondefault compatible prefix when available
to demonstrate selection precedence. A fake renamed system interpreter is not
evidence of different numeric ABI handling. Inspect the LuaRocks-installed DSO's
ELF closure as for CMake. BUILD_TESTING=OFF must still run host compatibility.

These commands validate A's changes; they do not replace B's final source/SDK ×
CMake/LuaRocks install matrix or C's complete integration registration. Reuse
their source-route build to verify the same ABI selection code executes there;
the shared Binding.cmake path avoids a second ABI implementation. Run the
project's established wrapper sanitizer workflow if entry-frame or ownership
code changes beyond the stated first-call addition; retain existing boundary
fault tests regardless. No dependency-internal OOM sweep is required.

## 4. Documentation handoff and completion

Give B these precise changes for current SPEC/API/coverage and the final manual:
Session reopen is supported with six-key facade grammar; Session shutdown is a
supported save-guarded convenience returning `accepted`; native escape hatches
remain faithful; ordinary selected host/include inputs are explicit and mismatch
fails before publication. Correct current native-only wording without rewriting
old evidence as a new test result. The final-package Saivage-reference rule applies
to final package docs only (optional creation credit excepted), not source/tools/
tests. This developer plan is separate from the shipped manual.

Give C the new script interfaces, required fixtures, explicit failure behavior
and measured test counts. Agree registration in the corrected non-skipping driver
and ordinary CMake test path where fixtures are available; missing required
inputs must be diagnosed, not counted as successful integration. B and C's
completion need not block authoring A's code, but final merged validation must
use their final installation layout and selection behavior.

Completion requires all targeted assertions, ordinary host positives, actual
numeric-host rejection, explicit LuaRocks selection, no-second-VM ELF checks and
accurate final public contracts. Capture compiler/header/host identities and
commands alongside results; retain failures as failures. No broad portability,
complete persistence, distribution permission or new upstream support claim.

## 5. Batch isolation and rollback

Implement facade and ABI changes as separately attributable future batches with
their tests. Before each, record its exact changed paths and starting content.
If a batch fails, revert only that batch's own hunks/artifacts or its isolated
commit after checking for subsequent edits. Do not reset the repository, delete
shared work directories, revert other authors' manual/test changes, alter native
inputs or touch runtime state. Remove only disposable outputs created below the
chosen WORK subdirectories. If reverting the facade surface decision, coordinate
its current-contract text with B rather than leaving documentation and code
contradictory. This plan does not authorize commits, pushes or implementation now.
