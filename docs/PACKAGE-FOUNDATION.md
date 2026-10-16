# Local package foundation (development only)

Original wrapper MIT, Copyright 2026 Salvador Fandiño. This is **not** permission
to distribute linked upstream artifacts, publish a rock or push changes. All
upstream notices and corresponding-source obligations remain applicable.

## Installed SDK with LuaRocks

Requires Linux x86-64, CMake >=3.26, Ninja, C++20, pkg-config Lua 5.4 with 64-bit
integers, LuaRocks 3.x and the pinned **local** SDK with exact Protobuf 29.3.0
CONFIG and its transitive dependencies. No upstream Python binding is used.
From the project root (source checked out locally):

```sh
LLG_BUILD_DIR="$SAIVAGE_CARD_WORK_ROOT/my-rock-build" \
LLG_SDK_PREFIX="$PWD/.cache/native-sdk-patched" \
luarocks --lua-version=5.4 --tree="$SAIVAGE_CARD_WORK_ROOT/my-rock-tree" \
  make --deps-mode=none --no-manifest
```

`LLG_BUILD_DIR` is mandatory and absolute: no hidden disposable build at the
project root. Exactly one input selector is required. Use a fresh build/tree
for a clean qualification, not a reused CMake cache. `BUILD_JOBS` defaults to 4.
The driver uses argument quoting and stops on each failed configure/build/install.
LuaRocks deploys Lua sources and the native module plus process guard into its
ordinary version-specific tree. `$ORIGIN` finds the adjacent real SONAME guard
file (no symlink chain to break during LuaRocks deployment). The module borrows
the host Lua symbols; it does not link or bundle a second VM.

```sh
sh tests/package-foundation.sh .cache/native-sdk-patched \
  "$SAIVAGE_CARD_WORK_ROOT/my-rock-regression"
```

This checks missing/ambiguous input rejection, installed module/guard closure and
real installed owner, M2 and M3 Lua paths from a fresh working directory, including
pages-only graph families and iterator safety. It does not establish a complete
release/runtime matrix, nor validate arbitrary third-party SDK provenance.

## Prepared source inputs

The same driver accepts `LLG_INPUT_ROOT` instead of `LLG_SDK_PREFIX`; it passes
`NATIVE_INPUT_ROOT` into the existing disconnected source CMake build. Inputs
must be prepared separately under `native-inputs.lock.json` and the authorized
`native-patched.lock.json` profile. No configure downloads are allowed.
Source overrides remain CMake's `NATIVE_{LIBGHIDRA,ENGINE,PROTOBUF,ABSEIL,HTTPLIB}_SOURCE`.
An installed SDK path does not run the source embedding generator. Source mode
still requires upstream Python >=3.10 with zlib; its policy decision is **open**,
not implicitly approved by this rockspec. See the retained-generator assessment
below. No project-owned Python qualification oracle is authorized by this file.

## Retained upstream generator: decision request, not an exception approval

The exact pinned `cpp/cmake/EmbedSpecs.cmake` unconditionally invokes
`cpp/embed_specs.py` at configure time, even with `LIBGHIDRA_BUILD_PYTHON=OFF`.
It compresses .sla/.pspec/.cspec/.ldefs into C++ arrays, constructs the language
index and writes generated Python language metadata as an upstream side effect.
It imports Python stdlib/zlib/XML only, not the upstream binding extension.
Installed SDK consumers need none of this at build/runtime.

Alternatives:

- Consume the exact prebuilt local SDK: no generator dependency; already usable
  for wrapper builds, but not a substitute for the required source-install path.
- Ship pregenerated C++ arrays: adds large generated source/artifact provenance
  and distribution questions, and the unchanged upstream CMake still invokes
  its generator. Cannot silently replace the required source path with this.
- Independently implement/qualify a Lua/C++ compression/XML generator and arrange
  an authorized integration point: feasible engineering, but replacing upstream
  generator behavior/integration requires a separately justified approach under
  DESIGN, not a new unapproved dependency patch or modified libghidra checkout.
- Request an explicit **build-time only** exception for the exact pinned upstream
  generator, Python >=3.10 with importable zlib. Reason: preserves unchanged
  upstream integration and compiled-in spec behavior with no binding dependency;
  excludes project-owned tooling, mandatory parity, installed runtime and SDK
  builds. If accepted, record Python/zlib identities per source qualification.

Operator decision requested: accept that narrow upstream source-build exception,
or authorize the separately qualified replacement approach. No option is
preapproved. Continue independent owned-tooling and package work meanwhile.
