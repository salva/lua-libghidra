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
* Official PUC Lua 5.4.6 source archive, pinned below, plus GNU make/GCC/binutils.
  Batch A itself provisions an isolated ordinary nondefault prefix and a float
  rejection host using §3a. Neither changes installed system Lua or libghidra/
  engine inputs. Download only during explicit fixture preparation, or supply
  the identical verified archive offline. No external fixture owner is assumed.

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
| Raw semantics | __index/__pairs are not invoked to supply or hide program keys; inherited policy='save' is not accepted by shutdown/close_program; unknown table/userdata keys with raising or mutating __tostring are rejected without invoking it; allowed values still use native validation |
| Validation-only reopen | Generation token unchanged, buffered iterator remains usable, known ENDBR64 bytes still readable, existing owner remains live |
| Allowed Session reopen | Complete real response preserved; same native owner; old buffered/exhausted iterators permanently invalid; factory metadata remains historical. Assert false/zero/empty values when actually present; use a small forwarding-only supplement for values the real fixtures do not produce, never manufacture upstream outcomes |
| Failed dispatched reopen | Native error preserved, generation changes, owner not released; do not require prior program to survive a native open failure |
| Native ignored fields | Native open still accepts both ignored options with valid values; no claim of read-only enforcement |
| Shutdown exposure | Session and native methods both exist and retain accepted envelope, not closed/boolean substitution |
| Save without path | Session shutdown and close_program return NO_STATE_PATH, leave generation/program/iterator unchanged; unknown keys return INVALID_ARGUMENT first |
| Save with path | On disposable writable path, preserve actual native outcome and verify logical closure; a path alone is not treated as a save-success assertion |
| Save failure | Reuse the deterministic failing-destination setup in tests/ownership_close_failure.lua if applicable; preserve the actual native error and invalidated iterator without asserting successful closure |
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
   changed inputs. Default header selection searches pkg-config include search
   directories for all three headers, not the base includedir variable. Use
   selected headers for the module/probe; use separately resolved ordinary system
   headers and absolute shared/static libraries for embedded test executables.
   Record the latter identities in cache/output and compile/link commands.
3. Add a small configure probe project under `cmake/lua-abi-probe/` and
   `scripts/check-lua-abi.lua`. Build a no-liblua MODULE via `try_compile`; run it
   through the selected host with `package.loadlib`/protected call. Return boolean
   true on compatibility; retain useful diagnostics on missing files, symbols or
   numeric mismatch. Retain the built probe at `BUILD/lua-abi-probe.so` for direct
   rejection tests. Run this with BUILD_TESTING both on and off.
4. Extend [rockspec](/lua-libghidra-scm-1.rockspec#L15) build arguments with selected
   `$(LUA)` and `$(LUA_INCDIR)`; extend [driver](/scripts/luarocks-build.lua#L17)
   to validate/forward them. Update direct driver invocations in
   [package-foundation.sh](/tests/package-foundation.sh#L11) so absent/ambiguous
   SDK/input tests still test that condition rather than failing on new arguments.
5. Add `tests/lua_abi_rejection.lua`, arguments `BUILD`, for the §3a int64/float
   PUC 5.4.6 host. Assert `_VERSION=='Lua 5.4'`, `string.packsize('j')==8` and
   `string.packsize('n')==4`; record executable `-v` separately for patch version.
   Load both `BUILD/lua-abi-probe.so` (`luaopen_llg_abi_probe`) and
   `BUILD/libghidra/_native.so` (`luaopen_libghidra__native`) with package.loadlib,
   require successful symbol resolution, then pcall each entry. Each must fail
   with `core and library have incompatible numeric types`. Assert registry
   keys `libghidra.UInt64` and `libghidra.owner` absent before and after, no module
   factory published, and subsequent integer arithmetic/table use/GC succeeds
   in the same process. Wrong-version, missing-library or missing-symbol errors
   are failures of this test, not successful ABI rejection. No engine construction
   is necessary. At this PUC pin the size token (136 caller, 132 host) is checked
   before the version value; `lua_Number` in the C signature differs, so this
   must be observed on the qualified amd64 toolchain, not claimed as a generic
   ABI firewall or float-host support.
6. Add a configure regression driver `tests/lua_abi_configure.sh ROOT SDK WORK
   GOOD_HOST GOOD_INCLUDE BAD_HOST` using fresh build directories per case:
   ordinary explicit selection and no-override system discovery pass; nonexistent
   include fails with a missing-header diagnostic (not a numeric ABI error); incompatible
   host with ordinary headers fails at ABI probe, and changing selection in an
   existing directory reruns rather than reuses compatibility success. Record
   actual diagnostics and fail if a negative case unexpectedly succeeds.

Do not link Lua into the configure module or production module; test executables
may link their own host VM. Keep guard linkage/whole-archive/PIC intact. Check
the runtime mismatch with the actual production module as well as the tiny probe.

## 3. Concrete validation commands

All commands here are for later authorized implementation/validation, not evidence
of execution. Run blocks in order in the same Bash shell in the qualified Ubuntu
24.04 amd64 environment. WORK must be a fresh disposable path without spaces for
the bounded Make/pkg-config shell recipes; do not repurpose another batch's work.

### 3a. Pinned isolated fixture provisioning

Official source: <https://www.lua.org/ftp/lua-5.4.6.tar.gz>; checksum published at
<https://www.lua.org/ftp/>. Both test hosts come from this same source. The
nondefault compatible prefix is real compiled Lua, not a symlink to system Lua.
Only the float copy's numeric configuration changes. This test infrastructure
does not patch any locked libghidra/engine dependency or installed Lua, and its
artifacts are not packaged. Retain Lua's source copyright/license in WORK.

```sh
set -eu
export ROOT=/home/salva/g/ml/lua-libghidra
export WORK=/home/salva/g/ml/tmp/lua-libghidra-boundaries
: "${SDK:?absolute qualified installed SDK prefix}"
test "$(uname -m)" = x86_64
test ! -e "$WORK"
mkdir -p "$WORK/fixture/good-src" "$WORK/fixture/float-src"
export GOOD_LUA=$(realpath "$(command -v lua5.4)")
unset LUA_INIT LUA_INIT_5_4 LUA_PATH LUA_PATH_5_4 LUA_CPATH LUA_CPATH_5_4
unset PKG_CONFIG_PATH PKG_CONFIG_LIBDIR
unset MAKEFLAGS MFLAGS CFLAGS CPPFLAGS LDFLAGS
export LC_ALL=C
# Supply LUA_TARBALL for offline preparation, or fetch this exact archive now.
if test -n "${LUA_TARBALL:-}"; then
  cp "$LUA_TARBALL" "$WORK/fixture/lua-5.4.6.tar.gz"
else
  curl --fail --location https://www.lua.org/ftp/lua-5.4.6.tar.gz \
    --output "$WORK/fixture/lua-5.4.6.tar.gz"
fi
printf '%s  %s\n' \
  7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88 \
  "$WORK/fixture/lua-5.4.6.tar.gz" | sha256sum --check
tar -xzf "$WORK/fixture/lua-5.4.6.tar.gz" --strip-components=1 -C "$WORK/fixture/good-src"
tar -xzf "$WORK/fixture/lua-5.4.6.tar.gz" --strip-components=1 -C "$WORK/fixture/float-src"
"$GOOD_LUA" - "$WORK/fixture/float-src/src/luaconf.h" <<'LUA'
local path=assert(arg[1])
local f=assert(io.open(path,'rb')); local s=f:read('a'); f:close()
assert(s:match('#define%s+LUA_INT_DEFAULT%s+LUA_INT_LONGLONG'))
assert(s:match('#define%s+LUA_32BITS%s+0'))
local changed,n=s:gsub('(#define%s+LUA_FLOAT_DEFAULT%s+)LUA_FLOAT_DOUBLE',
                       '%1LUA_FLOAT_FLOAT')
assert(n==1,'expected exactly one default-number configuration')
f=assert(io.open(path,'wb')); assert(f:write(changed)); assert(f:close())
LUA
gcc --version > "$WORK/fixture/compiler.txt"
gcc -dumpmachine >> "$WORK/fixture/compiler.txt"
for variant in good float; do
  src="$WORK/fixture/$variant-src"
  prefix="$WORK/fixture/$variant-prefix"
  make -C "$src/src" -j4 all CC=gcc \
    MYCFLAGS='-DLUA_USE_LINUX' MYLDFLAGS='-Wl,-E' MYLIBS='-ldl' \
    > "$WORK/fixture/$variant-build.log" 2>&1
  make -C "$src" install INSTALL_TOP="$prefix" \
    > "$WORK/fixture/$variant-install.log" 2>&1
  "$prefix/bin/lua" -v > "$WORK/fixture/$variant-version.txt" 2>&1
  grep -F 'Lua 5.4.6' "$WORK/fixture/$variant-version.txt"
  gcc -DLUA_USE_LINUX -I"$prefix/include" -dM -E -include lua.h - < /dev/null \
    > "$WORK/fixture/$variant-macros.txt"
  nm -D --defined-only "$prefix/bin/lua" > "$WORK/fixture/$variant-symbols.txt"
  grep -E ' T luaL_checkversion_$' "$WORK/fixture/$variant-symbols.txt"
  grep -E ' T lua_version$' "$WORK/fixture/$variant-symbols.txt"
  sha256sum "$prefix/bin/lua" "$prefix/include/luaconf.h" \
    > "$WORK/fixture/$variant-identities.txt"
done
export LUA_PREFIX="$WORK/fixture/good-prefix"
export SELECTED_LUA="$LUA_PREFIX/bin/lua"
export BAD_LUA="$WORK/fixture/float-prefix/bin/lua"
"$SELECTED_LUA" -e 'assert(_VERSION=="Lua 5.4"); assert(string.packsize("j")==8); assert(string.packsize("n")==8); print("int64/double",arg[-1])'
"$BAD_LUA" -e 'assert(_VERSION=="Lua 5.4"); assert(string.packsize("j")==8); assert(string.packsize("n")==4); assert(type(package.loadlib)=="function"); print("int64/float",arg[-1])'
```

The make commands deliberately set `LUA_USE_LINUX`, not `LUA_USE_C89`, and enable
dlopen/exported symbols without requiring readline. Inspect the recorded macros:
integer default remains LONGLONG, `LUA_32BITS` is zero, the good number default is
DOUBLE, the negative default is FLOAT. Do not replace this header edit with a
command-line `-DLUA_FLOAT_TYPE`, which luaconf.h can redefine. Both hosts are
standalone fixtures; the good prefix's liblua.a is not the system embedded lane.

### 3b. Ordinary system header/host and embedded lanes

Find the actual header directory among pkg-config include search paths. The
following parsing is deliberately bounded to the ordinary no-spaces Ubuntu
paths; CMake uses its list-valued `LUA_INCLUDE_DIRS` directly. Never use
`pkg-config --variable=includedir` as the header directory.

```sh
GOOD_INC=
for flag in $(pkg-config --cflags-only-I lua5.4); do
  case "$flag" in
    -I*) candidate=${flag#-I}
      if test -f "$candidate/lua.h" && test -f "$candidate/lauxlib.h" && \
         test -f "$candidate/luaconf.h"; then
        GOOD_INC=$(realpath "$candidate")
        break
      fi ;;
  esac
done
: "${GOOD_INC:?no complete Lua header directory in pkg-config include paths}"
export GOOD_INC
test -f "$GOOD_INC/lua.h"
test -f "$GOOD_INC/lauxlib.h"
test -f "$GOOD_INC/luaconf.h"
pkg-config --cflags --libs lua5.4 > "$WORK/system-pkg-config.txt"
pkg-config --variable=pcfiledir lua5.4 >> "$WORK/system-pkg-config.txt"
"$GOOD_LUA" -v
"$GOOD_LUA" -e 'assert(string.packsize("j")==8); assert(string.packsize("n")==8)'
printf 'system host=%s\nactual header directory=%s\n' "$GOOD_LUA" "$GOOD_INC"
cmake -S "$ROOT" -B "$WORK/build" -G Ninja \
  -DLIBGHIDRA_USE_SDK=ON -DCMAKE_PREFIX_PATH="$SDK" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DLUA_EXECUTABLE="$GOOD_LUA" -DLLG_LUA_INCLUDE_DIR="$GOOD_INC" \
  -DCMAKE_INSTALL_PREFIX="$WORK/prefix" > "$WORK/system-configure.log" 2>&1
cmake --build "$WORK/build" --parallel 4 --verbose > "$WORK/system-build.log" 2>&1
ctest --test-dir "$WORK/build" --output-on-failure
cmake --install "$WORK/build"
cd "$WORK"
"$GOOD_LUA" "$ROOT/tests/facade_boundaries.lua" "$WORK/prefix" "$ROOT" "$WORK/state"
"$GOOD_LUA" "$ROOT/tests/m2_slice.lua" "$WORK/prefix" "$ROOT"
"$GOOD_LUA" "$ROOT/tests/m3_core.lua" "$WORK/prefix" "$ROOT"
"$BAD_LUA" "$ROOT/tests/lua_abi_rejection.lua" "$WORK/build"
sh "$ROOT/tests/lua_abi_configure.sh" "$ROOT" "$SDK" "$WORK/configure" \
  "$GOOD_LUA" "$GOOD_INC" "$BAD_LUA"
ldd "$WORK/build/boundary_shared_host" > "$WORK/system-shared-host-ldd.txt"
readelf -d "$WORK/build/boundary_static_host" > "$WORK/system-static-host-dynamic.txt"
nm -D --defined-only "$WORK/build/boundary_static_host" > "$WORK/system-static-host-symbols.txt"
readelf -d "$WORK/prefix/lib/lua/5.4/libghidra/_native.so"
nm -D --defined-only "$WORK/prefix/lib/lua/5.4/libghidra/_native.so"
```

Inspect ELF output: no liblua DT_NEEDED or defined Lua/auxlib VM symbols; expected
guard SONAME and `$ORIGIN` remain. Existing CTest shared/static hosts must pass,
including initialization allocation-failure, independent states, loaded copies
and reentry. Inspect system configure/cache and verbose link commands for the
absolute shared/static Lua paths and header directory; record their realpaths and
SHA-256 hashes. Shared-host ldd must resolve the recorded system liblua, while
static-host ELF must have no liblua DT_NEEDED and must export the Lua symbols.
These observations identify the system embedded hosts, not the custom prefix.
`lua_abi_configure.sh` must additionally configure/build/load the tiny probe with
neither Lua input overridden to preserve independent system-default discovery
coverage; report its resolved paths. Record executed test names/counts;
do not infer integration execution from aggregate CTest success alone.

### 3c. Discriminating nondefault LuaRocks selection

Use the separately compiled §3a prefix with ambient pkg-config still selecting
the system installation. Require LuaRocks to select that actual executable and
its actual `include` directory. Record driver-resolved arguments as part of the
planned build-driver output (not just an inferred interpreter version). Enable
compile-command export in the driver's CMake options for this evidence.

```sh
cd "$ROOT"
test "$(realpath "$SELECTED_LUA")" != "$GOOD_LUA"
test "$(realpath "$LUA_PREFIX/include")" != "$GOOD_INC"
luarocks --lua-version=5.4 --lua-dir="$LUA_PREFIX" config variables.LUA \
  > "$WORK/rocks-selected-executable.txt"
luarocks --lua-version=5.4 --lua-dir="$LUA_PREFIX" config variables.LUA_INCDIR \
  > "$WORK/rocks-selected-include.txt"
test "$(realpath "$(cat "$WORK/rocks-selected-executable.txt")")" = "$(realpath "$SELECTED_LUA")"
test "$(realpath "$(cat "$WORK/rocks-selected-include.txt")")" = "$(realpath "$LUA_PREFIX/include")"
LLG_BUILD_DIR="$WORK/rocks-build" LLG_SDK_PREFIX="$SDK" \
  luarocks --lua-version=5.4 --lua-dir="$LUA_PREFIX" --tree="$WORK/rocks" \
  make --deps-mode=none --no-manifest > "$WORK/rocks-build.log" 2>&1
grep -E '^(LUA_EXECUTABLE|LLG_LUA_INCLUDE_DIR):' "$WORK/rocks-build/CMakeCache.txt"
"$GOOD_LUA" - "$WORK/rocks-build/CMakeCache.txt" "$SELECTED_LUA" "$LUA_PREFIX/include" <<'LUA'
local f=assert(io.open(arg[1])); local s=f:read('a'); f:close()
local function value(k) return s:match('\n'..k..':[^=\n]+=([^\n]+)') end
assert(value('LUA_EXECUTABLE')==arg[2], 'wrong cached selected host')
assert(value('LLG_LUA_INCLUDE_DIR')==arg[3], 'wrong cached selected headers')
LUA
ninja -C "$WORK/rocks-build" -t commands lua_ghidra > "$WORK/rocks-native-commands.txt"
grep -F -- "-I$LUA_PREFIX/include" "$WORK/rocks-native-commands.txt"
if grep -F -- "-I$GOOD_INC" "$WORK/rocks-native-commands.txt"; then
  echo 'ambient Lua headers leaked into selected-prefix module compile' >&2
  exit 1
fi
cd "$WORK"
"$SELECTED_LUA" -v
"$SELECTED_LUA" "$ROOT/tests/facade_boundaries.lua" "$WORK/rocks" "$ROOT" "$WORK/rocks-state"
"$SELECTED_LUA" "$ROOT/tests/m2_slice.lua" "$WORK/rocks" "$ROOT"
sh "$ROOT/tests/package-foundation.sh" "$SDK" "$WORK/package-regression"
```

Inspect the `boundary.cpp` and `owner.cpp` compile commands specifically: both
must use the nondefault Lua include path, with no system Lua include path taking
precedence. Compare the recorded driver values with the LuaRocks config/cache
assertions above. The selected host executes both configure probe and installed
regressions. The final package-foundation invocation is a separate ordinary
system default lane, not evidence for custom selection. Inspect the LuaRocks
DSO's ELF closure as for CMake. BUILD_TESTING=OFF must still run host compatibility.
Failure to provision or run the real nondefault host is an unmet test, not an
optional omission. If the installed LuaRocks config interface produces quoted
values rather than raw paths, explicitly normalize that format in the test driver
and retain the raw output; never silently accept a system path as equivalent.

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
