# Local foundation qualification handoff — not shipping approval

For [[card:card-e-a]], supported Linux x86-64 ordinary C-built PUC Lua 5.4 only.
No HTTP/SWIG/upstream Python-binding dependency or parity gate. No permission to
publish, distribute linked dependencies or push. Original MIT wrapper does not
change upstream notices/source obligations. Final runtime matrix and shipping
coordination remain separate.

## Inputs and source accounting

- `native-inputs.lock.json`: exact pinned six inputs; libghidra
  `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`, engine
  `2035b8153afaf7ce2edde24a2c80b62bbcf5127f`, Ghidra 12.1.3 specs,
  Protobuf v29.3, Abseil 20240722.0, httplib v0.16.3.
- Only authorized `bfd-sleigh-target-autodetect` engine patch, SHA256
  `488eda3edc8c26cc93155240663f20d0512318428c4b69e2fbb3b409989ac82d`.
  No authored libghidra changes or other dependency patch.
- `native-system.lock.json`: Ubuntu 24.04 amd64 installed/binary identities and
  source-control metadata, not proof source archives were built/compliance met.
- `api/README.md`: current Lua-only native inventory generation, independent
  completeness and immutable historical M3 manual/runtime evidence separation.

Use fresh caller-selected directories. See `PACKAGE-FOUNDATION.md` for complete
local CMake/LuaRocks inputs and generator decision request. Configuration never
fetches dependencies. Optional refresh tooling is explicit, not install behavior.

## Existing local installed artifacts

The following are scope-local retained qualification artifacts, not redistributable
packages. The paths are relative to the card work root used for the qualification:

- `lua-source-offline/rocks`: network-isolated LuaRocks source installation, module
  `lib/lua/5.4/libghidra/_native.so` beside real
  `libllg_process_guard.so.1`, facade `share/lua/5.4/libghidra/init.lua`.
- `package-source/prefix`: source-built local SDK prefix; exact PIC standalone
  Protobuf/Abseil installed to complete installed CMake package closure.
- `fresh-sdk-handoff/consumer`: linked shared whole-archive `-z defs` SDK consumer
  and native probes; no ambient Protobuf fallback. Its dependency build was not
  network-isolated; do not call it blanket offline build evidence.
- `build/installed-qualification`: wrapper install with standalone/static/shared
  host qualification from `bash tests/installed-qualification.sh build`.

For source-rock installed runtime checks, from project root, ordinary Lua:

```sh
prefix="$SAIVAGE_CARD_WORK_ROOT/lua-source-offline/rocks"
lua5.4 tests/installed_owner.lua "$prefix" "$PWD"
lua5.4 tests/m2_slice.lua "$prefix" "$PWD"
lua5.4 tests/m3_core.lua "$prefix" "$PWD"
lua5.4 tests/m3_iterators.lua "$prefix" "$PWD"
```

The tests establish their own installed paths; no build-tree Lua search fallback.
Do not use `sh` to run `installed-qualification.sh` (it is Bash/pipefail).
Existing source-rock/all-five-explicit-source-override installs were isolated with
`unshare -Urn`; the real installed tests were outside the namespace. These facts
are not a final runtime-absence matrix. Known unmodified loader exit-4 probes
remain known-gap evidence, not readiness.

Preserve M2 extreme-address crash/raw FileBytes/producer limits and M3 pages-only
CFG/xref/type families, union/signature practical producer limits, category-specific
persistence, and no rollback/general restoration guarantee. Source inventory,
converter tests or positive acknowledgements do not override those facts.

## Upstream generator decision — pending authority

Unchanged pinned upstream `EmbedSpecs.cmake` invokes Python >=3.10 + stdlib/zlib
at source configure, even with bindings off. SDK/runtime paths do not need it.
The narrow build-time exception is **pending operator approval**, OR a
replacement/integration must be separately authorized and qualified. Neither
option is preapproved; alternatives and rationale remain in `PACKAGE-FOUNDATION.md`.
No Python bindings, project-owned Python tooling/test oracle, SDK-consumer dependency
or installed-runtime Python requirement is authorized. Technical source-build
success does not resolve this authority gate or establish M5/release acceptance.
No generator changes or new distribution permission are inferred.
