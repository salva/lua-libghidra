# A — Facade and Lua-host boundary design

Draft design for F01–F03 against `4903eb7`; implementation requires separate
authorization. Repository-root links describe baseline paths. Supported scope is
Ubuntu 24.04 amd64, ordinary PUC Lua 5.4/64-bit integers/double numbers, native
local libghidra only. Preserve the existing dependency pins, approved engine
profile and unchanged upstream Python spec-generator exception. No HTTP, SWIG,
new dependency patches or upstream repair work is part of this design.

## 1. Session opening: one facade key policy, one native parser

Retain `Session:open_program(program_options)`. Remove it from the unconditional
[forwarding list](../../../../../lua/libghidra/init.lua#L8) and implement a small explicit wrapper.
Extract the [factory's key check](../../../../../lua/libghidra/init.lua#L105) into a private
helper accepting a program table and error-operation name. Use `type`, `next`
and `rawget` as appropriate; do not invoke `pairs`, `__index` or `__pairs`.
Use fixed diagnostics for unknown keys; do not call `tostring` on an arbitrary
table/userdata key or otherwise invoke its `__tostring` while rejecting it.

The helper requires a table with only:

`program_path`, `project_path`, `language_id`, `compiler_spec_id`, `format`,
`base_address`.

Unknown keys, including `read_only=false` and `project_name=''`, are rejected on
presence. Nil has no table entry and therefore is omission. Return `nil,error`
with code `INVALID_ARGUMENT`, backend `binding` and operation `open` for factory
validation or `open_program` for Session validation. Messages identify an invalid
program table or unknown program option; exact wording is not a compatibility
contract. Outer factory keys remain `client` and `program` only.

The helper validates only facade table/key policy. Native
[field parsing](../../../../../src/owner.cpp#L387) remains authoritative for types, NULs, exact
UInt64 conversion, nonempty path requirement and native defaults. No copied
option table, synthetic native read-only enforcement or duplicated C++ grammar.

| Entry | Resource behavior | Success |
| --- | --- | --- |
| `gh.open{client=...,program=...}` | Validate facade keys first; construct new owner; retain protected publication and close-on-failure | `session,nil,open_response` |
| `session:open_program(program)` | Validate facade keys; dispatch on existing owner; never close it on failure | Complete `open_response` (or `nil,error`) |
| `session:native():open_program(program)` | Existing faithful native grammar, including ignored fields | Complete `open_response` (or `nil,error`) |

Valid-grammar calls on an owner-closed Session reach native dispatch and return
`CLOSED`. Invalid keys may return `INVALID_ARGUMENT` first, consistent with
[native parse-before-owner-validation](../../../../../src/owner.cpp#L495). Reopen is mutable
context replacement, not a new owner. Preserve historical detached factory
metadata. Policy rejection leaves generation and current program unchanged;
every actually dispatched open retains native generation invalidation, including
failure. Existing iterators never become valid again after a dispatch.

**Choice:** a shared small validator rather than removing working Session reopen
or introducing a generic policy registry. This addresses the two actual callers.

## 2. Session shutdown: retained convenience with close/save precondition

Retain `Session:shutdown(options)` as an intentional facade convenience. Remove
it from [bulk forwarding](../../../../../lua/libghidra/init.lua#L8). Factor the existing
[close-program policy](../../../../../lua/libghidra/init.lua#L13) into a private helper used by
`close_program` and `shutdown`, with the operation name supplied explicitly.
This helper is limited to these two policy-identical lifecycle operations.

Contract for both methods:

1. The native grammar requires a table with the sole key `policy`, equal to
   `save` or `discard`. Malformed options return binding `INVALID_ARGUMENT`.
2. For a live owner with no configured state path and raw `policy='save'`, check
   for unknown keys before returning binding `NO_STATE_PATH`. No native dispatch
   or generation change occurs. Use operation `shutdown` or `close_program` in
   the error; do not report all such errors as close_program.
3. Otherwise forward to the exact original native method. Preserve the existing
   [_has_state_path behavior](../../../../../src/owner.cpp#L140): closed owners defer to native
   dispatch, so valid save requests return `CLOSED`, not `NO_STATE_PATH`.
   Malformed options can still fail before owner checks.
4. `close_program` returns the native `{closed=...}` envelope; `shutdown` returns
   `{accepted=...}`. False flags remain false. Neither is converted to `true` or
   to the other method's envelope.

No claim that a nonempty state path is writable or sufficient for successful
save: errors from actual dispatch are preserved. No new state-path cache on the
Session. No probing files or attempting speculative save before shutdown.

Successful logical closure produces native `NO_PROGRAM` on program-dependent
reads through either view. Owner-level status remains usable; another client is
still excluded. Reopen uses the same owner. Binding `close()` alone releases the
owner and makes aliases `CLOSED`. Dispatch invalidates all prior iterators even
on a native error. Validation-only failures do not.

Native `shutdown{policy='save'}` retains the empty-path caveat and its native
`accepted` flag. Neither that flag nor `saved=true` is proof of full persistence.
Discard is not rollback; byte overlays do not become durable binary patches;
reload remains category-limited. No destructor save is introduced.

**Choice:** retain the working convenience with consistent facade policy.
Removing it would simplify the conceptual surface but unnecessarily break callers;
documenting a faithful alias alone would leave the close/save asymmetry intact.
Current manual and contract tables must name this deliberate exception to the
otherwise native-only full-specialist surface.

## 3. Lua ABI: explicit inputs and two bounded checks

### Build input contract

Add a cache path `LLG_LUA_INCLUDE_DIR` for the directory containing `lua.h`,
`lauxlib.h` and `luaconf.h`. Use existing `LUA_EXECUTABLE` as the selected absolute
host executable. Resolve defaults from ordinary `pkg-config lua5.4` headers and
`find_program(lua5.4)` only when those inputs are absent. For default headers,
search pkg-config's `LUA_INCLUDE_DIRS` for a directory containing all three
required files; fail with the searched paths if none is complete. Do not use
pkg-config's base `includedir` or append a guessed version suffix. An explicit
directory must itself contain all three files; missing-header diagnostics are
distinct from compile-profile and selected-host ABI diagnostics. Log resolved executable,
include path and header version/profile. Never silently substitute ambient
headers when an explicit directory is missing or incompatible.

[LuaRocks build command](../../../../../lua-libghidra-scm-1.rockspec#L15) must pass its resolved
`$(LUA)` and `$(LUA_INCDIR)` as quoted extra build-driver arguments. The driver
validates nonempty values and forwards them as `-DLUA_EXECUTABLE=...` and
`-DLLG_LUA_INCLUDE_DIR=...`. Verify the installed LuaRocks variable names by a
real explicit-prefix build; an unexpanded variable is an error, not a fallback.
Install phase continues to install the already configured build. Direct driver
callers/tests must be updated for the explicit build arguments.

Extend [header checks](../../../../../cmake/Binding.cmake#L6) to require version 504, a signed
eight-byte `lua_Integer` and `lua_Number` of C++ type `double` with eight-byte
size. Do not accept same-sized but different floating types. Ensure checks rerun
when executable/header selection changes (do not reuse the current unkeyed
`NATIVE_LUA_ABI_OK` cache result). Fresh build directories remain recommended.

Build a tiny configure-time MODULE probe with those exact headers and the
selected toolchain; it exports one `luaopen_llg_abi_probe` function. Its trivial
body calls `luaL_checkversion(L)` then returns Lua boolean true. It links no Lua,
native SDK or process guard. Use a small CMake `try_compile` project producing
the module, then run the selected host on a checked-in Lua probe script using
`package.loadlib` and `pcall`. Fail configuration with the host/include identities
and original loader/ABI diagnostic on failure. This check runs even when
`BUILD_TESTING=OFF`, covering LuaRocks. Keep the probe narrow; this is not a Lua
discovery framework, arbitrary cross-compile feature or native engine test.

Keep the probe artifact at a reported stable path, `BUILD/lua-abi-probe.so`, so
the exact ordinary-header probe can also be loaded by the rejection fixture.

Embedded positive tests form a separate ordinary system lane. Resolve their
header directory from system pkg-config include directories and their shared
library and static archive to absolute paths in that installation's library
directories; retain those paths in configure output/cache. Use those headers for
embedded executables, including test targets compiling boundary/owner sources,
and those absolute library paths for their links. Do not conflate `${LUA_LIBRARIES}`
bare link names or an old independently cached archive with the selected custom
interpreter's identity. Check these system headers against the same ordinary
numeric profile. These executables own their host VM; their libraries are never
module dependencies. Record compile/link commands and shared-host `ldd` output.

Require a separate, real nondefault compatible prefix for LuaRocks selection
qualification. Provision unchanged PUC 5.4.6 from the pinned archive described
below into WORK, leaving ambient system discovery in place. Compare LuaRocks's
resolved executable/include settings and build-driver arguments to the CMake
cache and actual native-module compile flags. Execute installed regressions with
that selected host. A system-prefix-only run or renamed system executable is not
a substitute. Retain an independent no-overrides system-default build as well.

### Real module entry contract

Make `luaL_checkversion(L)` the first operation in
[llg::module](../../../../../src/boundary.cpp#L185), covering both the exported luaopen entry
and test hosts that call this function directly. At this point there must be
no automatic C++ owner, lock, string, exception object, metatable creation or
userdata publication. Lua's standard version/numeric-size mismatch raises a Lua
error, caught by `require`/caller `pcall`; it is not a native error envelope.
Do not preflight with a module-side call returning `lua_Number`, and do not
replace the standard numeric-size check with only `_VERSION` string comparison.

At PUC 5.4.6, `luaL_checkversion` calls
`luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES)`, with a `lua_Number`
second argument and size token `sizeof(lua_Integer)*16 + sizeof(lua_Number)`.
The host implementation calls its own `lua_version(L)` and checks that size
token before comparing the received version. For an ordinary module versus
int64/float host the tokens are 136 versus 132. On Linux amd64 the integer token
and pointer use the same argument locations even though the floating parameter
type differs. This motivates the bounded test, not a portable C ABI guarantee:
the differing signatures preclude a general arbitrary-host safety claim. Require
an observed protected numeric-type diagnostic for this exact fixture/toolchain.

The configure probe prevents accidental selected-host mismatch during package
build. The real entry check remains necessary because a completed module can
later be loaded by a different host. `luaL_checkversion` checks Lua's supported
version/numeric-size contract; it does not prove arbitrary custom ABIs safe.
Header restrictions and the stated qualified profile bound that claim.

Keep [no-liblua module linking](../../../../../cmake/Binding.cmake#L19), whole-archive native
registration, shared guard SONAME and `$ORIGIN` unchanged. Never solve mismatch
by linking/bundling another VM. Keep source/SDK generator separation unchanged.

**Choice:** explicit compatible selection plus runtime rejection, rather than
forcing every compatible prefix to be the system prefix or expanding platform
support. Both checks have a reachable purpose, not an historical acceptance ritual.

## 4. Regression boundaries and ownership

Add real installed facade tests, not only mocked forwarding tests. Observe
generation via existing private test-visible methods and verify semantic program
reads after rejection. Use writable disposable state paths and copies for save
cases; never modify authored input fixtures. Exercise both ELF and analyzed
project routes using the current explicit architecture hints.

ABI tests require ordinary standalone/shared/static positives, the nondefault
compatible-prefix positive, and a real incompatible numeric host. Provision two
isolated copies of official PUC Lua **5.4.6** from
<https://www.lua.org/ftp/lua-5.4.6.tar.gz>, SHA-256
`7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88`
(official checksum: <https://www.lua.org/ftp/>). Build the compatible copy
unchanged. In the negative copy's `src/luaconf.h`, replace exactly one definition
of `LUA_FLOAT_DEFAULT LUA_FLOAT_DOUBLE` with `LUA_FLOAT_DEFAULT LUA_FLOAT_FLOAT`;
retain `LUA_INT_DEFAULT LUA_INT_LONGLONG`, `LUA_32BITS 0` and non-C89 compilation.
Do not rely on `-DLUA_FLOAT_TYPE`, which the header can overwrite. Compile on the
qualified amd64 toolchain with `LUA_USE_LINUX`, `-Wl,-E` and `-ldl` for exported
symbols and dynamic module loading. The plan provides executable commands and
configuration assertions; these fixture-only copies are not dependency repairs.

Require version 5.4.6 observations, `string.packsize('j')==8` on both hosts, and
`string.packsize('n')==8`/`==4` on compatible/negative hosts. Inspect exported
`luaL_checkversion_` and `lua_version` symbols and successful `package.loadlib`
resolution. Protected entry of both the ordinary-header probe and production
module must report `core and library have incompatible numeric types`, not a
missing-symbol/search-path/version error. After each failure the same host must
execute Lua and collect garbage normally. The production check must leave
`libghidra.UInt64` and `libghidra.owner` absent from the registry and publish no
factory. Do not instantiate an engine to prove a pre-publication check.
This qualifies only clean rejection of the specified amd64 case, never float
Lua support or a broad ABI firewall. Provisioning and test execution are future
implementation work; absent actual results are not passes.

Group B updates current public grammar, compatibility notes and build inputs,
including selected shutdown behavior, without rewriting historical evidence as
new results. Group C integrates A's test commands into its non-skipping drivers;
A must supply standalone runnable regressions regardless of that integration.
Agree shared-file edits before implementation. No new release architecture,
upstream qualification campaign or package-doc cleanup in source/tools/tests is
required by this design.
