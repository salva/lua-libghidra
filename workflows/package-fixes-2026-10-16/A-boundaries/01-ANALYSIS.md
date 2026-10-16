# A — Facade and Lua-host boundary analysis

Draft implementer record; baseline `4903eb7`. Scope: F01–F03 only. This document
does not authorize implementation, dependency changes, deployment or publication.
Links beginning `/` name repository-root paths; line anchors refer to the baseline.

## Required outcome and constraints

Users need a predictable convenience surface, a clearly named faithful native
escape hatch, and a module that rejects incompatible Lua numeric configurations
before publishing native objects. Preserve existing useful methods where a small
policy correction suffices. The supported profile remains Ubuntu 24.04 amd64,
ordinary PUC Lua 5.4 (qualified runtime 5.4.6), 64-bit integers and double numbers.
Alternate numeric hosts are rejection tests, not newly supported profiles.

The backend remains native-local libghidra at
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`, with the already authorized engine
profile. No HTTP, SWIG, additional VM, new dependency patches or upstream repair
campaign. Preserve the unchanged upstream source-build spec generator exception:
Python >=3.10 plus stdlib zlib/XML at build time only; SDK-consumer and installed
runtime paths do not acquire a Python dependency. These boundaries originate in
[SPEC](../../../../../docs/SPEC.md#L8), not in the age of a particular build recipe.

## F01 — Two facade paths implement different opening policies

### Reachable behavior

[Session forwarding](../../../../../lua/libghidra/init.lua#L8) includes `open_program` without
validation. [Factory open](../../../../../lua/libghidra/init.lua#L99) validates the outer table
and permits exactly six program keys before constructing a client. The native
[parser](../../../../../src/owner.cpp#L387) accepts those six plus `read_only` and `project_name`;
the [request copy](../../../../../src/owner.cpp#L531) and [dispatch](../../../../../src/owner.cpp#L606) forward
them to libghidra. The pin ignores those two options, as specified in
[the facade contract](../../../../../docs/SPEC.md#L223).

An existing-owner probe observed factory rejection and Session reopen success for
the same options containing `read_only=true` and `project_name='ignored'`. This is
an observable facade validation bypass; it is not evidence that read-only support
exists, nor a request to implement it in upstream. Even `read_only=false` must be
rejected by the facade: presence, not truthiness, determines the restriction.

### Owner need, compatibility and alternatives

* Focused correction: share the six-key program-table check between factory open
  and Session reopen. Preserve Session reopen's complete native response shape.
* Conceptual simplification: make facade opening a factory-only capability and
  remove Session reopen, directing all context changes through `native()`.
  This reduces policy entrypoints but breaks a working method and makes ordinary
  context replacement unnecessarily specialist.

Choose the focused correction. Valid Session reopen calls keep working. Calls
using ignored native-only keys now fail with binding `INVALID_ARGUMENT` before
dispatch; callers intentionally wanting those fields can use `native()`.
Do not duplicate the native value parser or invent immutable Program objects.
Factory failures must still release their new owner; reopen failure must never
release an existing Session owner.

## F02 — Shutdown surface and save policy are not reconciled

### Reachable behavior

[The same forwarding list](../../../../../lua/libghidra/init.lua#L8) exposes Session shutdown.
[Close-program convenience](../../../../../lua/libghidra/init.lua#L13) rejects save without a
state path; shutdown does not. Native
[policy parsing](../../../../../src/owner.cpp#L394) requires `save` or `discard`, and
[dispatch](../../../../../src/owner.cpp#L611) preserves distinct `closed` and `accepted` flags.
[SPEC's table](../../../../../docs/SPEC.md#L212) instead assigns shutdown exclusively to the
native escape hatch. Exposure of the Session method was observed. No data-loss
experiment or additional upstream shutdown failure is established by that fact.

The concrete risk is a caller assuming two convenience close operations share
the same protection against empty-state-path save. Successful native acceptance
is not proof of persistence. Native shutdown logically closes program access;
it does not terminate a service, release the client slot, or unload retained
engines ([lifecycle contract](../../../../../docs/SPEC.md#L184)).

### Owner need, compatibility and alternatives

* Focused correction: keep Session shutdown, add the same save-path precondition
  as Session close_program, document the intentional convenience, and preserve
  its `accepted` envelope. Extract only a private two-call policy helper.
* Conceptual simplification: expose one facade logical-close verb, remove
  Session shutdown and keep native shutdown exclusively through `native()`.
  This matches old prose but needlessly removes an existing useful alias.
* Minimal editorial alternative: explicitly document Session shutdown as a
  faithful native forwarder with the empty-path caveat. This preserves every
  call but leaves surprising asymmetry between two facade close operations.

Choose the focused correction. `shutdown{policy='discard'}` and save with a
configured state path retain behavior and return shape. Save with no state path
now returns binding `NO_STATE_PATH` without dispatch. The deliberate native
escape hatch retains the pinned permissive behavior. This is an explicit surface
decision, not removal of code to make historical documentation appear correct.

## F03 — Header selection does not establish the loading host ABI

[CMake discovery](../../../../../cmake/Binding.cmake#L2) uses ambient `pkg-config lua5.4` and
asserts only version 504 and an eight-byte integer. [LuaRocks](../../../../../lua-libghidra-scm-1.rockspec#L15)
invokes its selected interpreter, but [the driver](../../../../../scripts/luarocks-build.lua#L22)
passes neither that interpreter nor its headers to CMake. Test-host discovery
occurs only with [BUILD_TESTING](../../../../../cmake/Binding.cmake#L36).
[Module entry](../../../../../src/boundary.cpp#L185) immediately publishes metatables without
`luaL_checkversion`.

This is a static validation gap, not a reproduced crash. Existing ordinary
standalone, shared and static hosts were not shown broken. Eight-byte integers
alone do not prove an ordinary double-number ABI. Module symbols intentionally
resolve from the loading host; adding liblua to the module would introduce a
second-VM hazard rather than correct host selection.

### Alternatives and choice

* Focused correction: carry explicit LuaRocks executable/include-directory
  choices into CMake, restrict headers to the existing ordinary profile, check
  selected-host compatibility using a tiny host-loaded ABI probe, and call Lua's
  standard ABI check first in the real module entry.
* Proportional conceptual alternative: expose only the system pkg-config profile
  and reject LuaRocks hosts that cannot load its ABI probe. This is smaller but
  makes an explicitly selected compatible prefix inexplicably irrelevant.
* A generalized multi-version/platform Lua discovery layer is disproportionate:
  it solves no qualified-profile need and would enlarge support commitments.

Choose explicit executable/include selection with ordinary system defaults.
Headers outside the supported profile fail configuration. A differently
configured loading host fails a protected ABI check. Neither outcome qualifies
the alternate host, and no Lua library is linked into `_native.so`.

Default header resolution must inspect pkg-config's include search directories
for `lua.h`, `lauxlib.h` and `luaconf.h`, not use its base `includedir` variable:
on Debian-style layouts that base can be `/usr/include` while the actual headers
are in `/usr/include/lua5.4`. An explicit wrong directory must produce a missing
header diagnostic, distinguishable from a host numeric-size mismatch.

Qualification has three distinct identities: ordinary system standalone and
embedded shared/static hosts; a genuinely separately built compatible prefix
selected by LuaRocks; and an isolated rejection-only float host. The latter two
are built from PUC Lua 5.4.6's official `lua-5.4.6.tar.gz`, SHA-256
`7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88`.
The compatible prefix uses unchanged headers. The rejection fixture changes only
`LUA_FLOAT_DEFAULT` from `LUA_FLOAT_DOUBLE` to `LUA_FLOAT_FLOAT` in its copied
`luaconf.h`, retaining `LUA_INT_DEFAULT=LUA_INT_LONGLONG` and `LUA_32BITS=0`.
The plan supplies the complete isolated provisioning recipe; no unnamed fixture
owner or modification of libghidra/engine inputs is required.

This rejection claim is deliberately bounded to the qualified Linux amd64
toolchain: `luaL_checkversion_` itself takes a `lua_Number` version argument, so
the caller and float host have different C signatures. At this PUC pin its host
implementation checks the integer size token before comparing the version
argument. A clean protected numeric-error result must be observed for both the
tiny probe and real module; source reasoning alone is not a universal ABI
firewall. Record integer/number sizes (8/4 versus 8/8), executable/header paths,
compile flags and actual shared/static library identities separately. A `/usr`
LuaRocks test cannot demonstrate that a nondefault selection was respected.

## Historical baggage versus justified safeguards

Bulk method forwarding likely made facade policy drift easy; it is not a reason
to replace the entire facade with generated policy infrastructure. Chronological
native-only claims are not stronger compatibility evidence than shipped methods.
Likewise ambient pkg-config selection reflects the original ordinary deployment;
it should become an explicit default rather than a hidden constraint.

Retain safeguards that still protect reachable paths:

* [Factory protected publication](../../../../../lua/libghidra/init.lua#L93) closes a newly
  allocated owner when Lua publication raises; helper extraction must preserve it.
* [Raw native parsing and post-Lua recheck](../../../../../src/owner.cpp#L377) avoid metamethod
  defaults and stale owners after allocation-driven finalization.
* [Native generation increment](../../../../../src/owner.cpp#L537) invalidates iterators even
  when a dispatched lifecycle operation fails. Lua policy rejection must not
  manufacture generation changes or cached program state.
* [Owner release](../../../../../src/owner.cpp#L121) and the
  [shared process guard](../../../../../cmake/Binding.cmake#L25) preserve one live native client
  across ordinary module copies and independent states.
* [Host-only Lua linkage](../../../../../cmake/Binding.cmake#L19) and trivial Lua error frames
  remain essential. The new ABI check must run before C++ owners/locks exist.

Do not reopen dependency-internal OOM work, broaden concurrency, add a persistence
layer or change native outcome flags to close these three wrapper boundaries.

## Coordination

Group A owns facade/native-entry/build-selection changes and targeted regressions.
Group B owns manual organization, installed document closure and packaging text;
give it the selected Session contracts and CMake/LuaRocks inputs before it writes
current API/install material. Group C owns integration selection and wider test
registration; give it explicit commands and required non-skipping regressions.
Coordinate edits in `cmake/Binding.cmake` and existing integration scripts.
The final package-document restriction on Saivage references (optional creation
credit excepted) belongs to B; it does not prohibit references in source, tools,
tests or these separate developer records.
