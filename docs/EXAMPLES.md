# Install and use lua-libghidra

## Supported environment and route selection

Use an actual source checkout for build commands: installed documentation is not
an installed build kit. Supported profile is Ubuntu 24.04 amd64/Linux x86-64,
ordinary PUC Lua 5.4 signed-int64/eight-byte-double ABI (qualified 5.4.6), GCC
13.3.0/C++20, CMake >=3.26, Ninja, pkg-config, Lua host and development headers.
LuaRocks 3.x is additionally needed for rock routes. Custom numeric hosts and
Lua 5.3 are not qualified. Select the matching executable and directory containing
lua.h, luaconf.h and lauxlib.h explicitly if not using the system defaults.

Native builds require shared BFD/sframe/zstd/zlib development closure consistent
with the [system lock](../native-system.lock.json), GNU tar, unzip, sha256sum,
patch, realpath and core utilities; curl is used only for explicit online
preparation. Historical locked package versions may not be available from today's
package-manager repositories. Do not substitute static system BFD archives.
Native SOURCE builds additionally run unchanged upstream cpp/embed_specs.py via
cpp/cmake/EmbedSpecs.cmake with Python >=3.10 standard-library zlib/XML. This is
the only Python exception: no upstream Python bindings, project-owned Python
tools/tests, SDK-consumer or installed-runtime Python. Java/Ghidra application
and network are not required for installed execution.

Choose **source** prepared inputs or a **caller-supplied qualified local SDK**;
there is no claimed public prebuilt SDK download. SDK must contain compatible
libghidra CONFIG, exact Protobuf **29.3.0 CONFIG** and incorporated PIC
Protobuf/Abseil closure. A wrapper source install alone is not a reusable SDK.
The source-only developer index describes SDK construction.

## Absolute paths and input preparation

Run from the checkout, in an ordinary non-root shell. Use a new WORK for each
independent route. These variables are ordinary caller-owned paths, not harness
inputs. Replace the Lua paths if using a nondefault compatible installation.

```sh
set -eu
SOURCE=$(pwd -P)
WORK=$(mktemp -d "$HOME/lua-libghidra.XXXXXX")
ARCHIVES="$WORK/archives"
INPUTS="$WORK/inputs"
PREFIX="$WORK/prefix"
ROCKS="$WORK/rocks"
GOOD_LUA=/usr/bin/lua5.4
LUA_INCLUDE=/usr/include/lua5.4
for p in "$SOURCE" "$WORK" "$ARCHIVES" "$INPUTS" "$PREFIX" "$ROCKS" "$GOOD_LUA" "$LUA_INCLUDE"; do
  case "$p" in /*) ;; *) echo "expected absolute path: $p" >&2; exit 1;; esac
done
test -f "$SOURCE/CMakeLists.txt"
test -x "$GOOD_LUA"
for h in lua.h luaconf.h lauxlib.h; do test -f "$LUA_INCLUDE/$h"; done
mkdir -p "$ARCHIVES"
cd "$SOURCE"
```

Explicit **online** preparation downloads six locked archives, verifies hashes,
extracts and applies only the approved bfd-sleigh-target-autodetect patch:

```sh
"$GOOD_LUA" scripts/prepare-native.lua --archives "$ARCHIVES" --output "$INPUTS" \
  --profile bfd-sleigh-target-autodetect
```

Alternatively, set ARCHIVES to an absolute existing cache containing all six
locked archives, retain a fresh INPUTS path, and run the same command with
`--offline`. An empty newly-created archive directory cannot satisfy that option.
Online preparation is not offline evidence. Disconnected CMake below means no
configure download, not that preparation was offline. Specs and all native inputs
must already be present; do not override pins or replace the approved profile.

## Source CMake

```sh
cmake -S "$SOURCE" -B "$WORK/cmake-source" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF \
  -DLUA_EXECUTABLE="$GOOD_LUA" -DLLG_LUA_INCLUDE_DIR="$LUA_INCLUDE" \
  -DLIBGHIDRA_USE_SDK=OFF -DNATIVE_INPUT_ROOT="$INPUTS" \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON -DCMAKE_INSTALL_PREFIX="$PREFIX"
cmake --build "$WORK/cmake-source" --parallel 4
cmake --install "$WORK/cmake-source"
export LUA_PATH="$PREFIX/share/lua/5.4/?.lua;$PREFIX/share/lua/5.4/?/init.lua;;"
export LUA_CPATH="$PREFIX/lib/lua/5.4/?.so;;"
"$GOOD_LUA" -e 'assert(require("libghidra")); assert(require("libghidra.lowlevel"))'
```

The module borrows the host Lua VM; it must not link another liblua. The helper
DSO and $ORIGIN layout are part of the installation, not optional files to omit
when moving the module.

## Source LuaRocks

Use the same prepared INPUTS with a fresh WORK/tree for this route. LUA_DIR must
be an absolute compatible host prefix with bin/lua (or selected LuaRocks host)
and include headers; inspect LuaRocks's resolved LUA/LUA_INCDIR before building.
The driver forwards them and checks the ABI even with testing off.

```sh
LUA_DIR=/usr
case "$LUA_DIR" in /*) ;; *) exit 1;; esac
test -d "$LUA_DIR"
luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" config variables.LUA
luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" config variables.LUA_INCDIR
unset LLG_SDK_PREFIX
LLG_BUILD_DIR="$WORK/rock-source-build" LLG_INPUT_ROOT="$INPUTS" \
  luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" --tree="$ROCKS" \
  make --deps-mode=none --no-manifest
unset LUA_PATH LUA_CPATH
eval "$(luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" --tree="$ROCKS" path)"
"$GOOD_LUA" -e 'assert(require("libghidra")); assert(require("libghidra.lowlevel"))'
```

Keep GOOD_LUA equal to the resolved LuaRocks host, with its matching headers;
for a custom host set LUA_DIR to that installation, not the ambient system.

## SDK CMake and SDK LuaRocks

Define SDK to your **existing absolute qualified SDK**, not a download URL:

```sh
SDK=/absolute/path/to/qualified-sdk
case "$SDK" in /*) ;; *) echo 'absolute SDK required' >&2; exit 1;; esac
test -d "$SDK"
test -f "$SDK/lib/cmake/libghidra/libghidraConfig.cmake"
test -f "$SDK/lib/cmake/protobuf/protobuf-config.cmake"
```

If your qualified SDK uses a different libdir, use its actual CONFIG location;
do not silently select an unrelated system package. In a fresh WORK/PREFIX,
configure this **instead of** the source configure (no NATIVE_INPUT_ROOT):

```sh
cmake -S "$SOURCE" -B "$WORK/cmake-sdk" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF \
  -DLUA_EXECUTABLE="$GOOD_LUA" -DLLG_LUA_INCLUDE_DIR="$LUA_INCLUDE" \
  -DLIBGHIDRA_USE_SDK=ON -DCMAKE_PREFIX_PATH="$SDK" \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON -DCMAKE_INSTALL_PREFIX="$PREFIX"
cmake --build "$WORK/cmake-sdk" --parallel 4
cmake --install "$WORK/cmake-sdk"
export LUA_PATH="$PREFIX/share/lua/5.4/?.lua;$PREFIX/share/lua/5.4/?/init.lua;;"
export LUA_CPATH="$PREFIX/lib/lua/5.4/?.so;;"
"$GOOD_LUA" -e 'assert(require("libghidra")); assert(require("libghidra.lowlevel"))'
```

SDK LuaRocks uses a fresh WORK/ROCKS and the same resolved Lua host selection:

```sh
unset LLG_INPUT_ROOT
LLG_BUILD_DIR="$WORK/rock-sdk-build" LLG_SDK_PREFIX="$SDK" \
  luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" --tree="$ROCKS" \
  make --deps-mode=none --no-manifest
unset LUA_PATH LUA_CPATH
eval "$(luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" --tree="$ROCKS" path)"
"$GOOD_LUA" -e 'assert(require("libghidra")); assert(require("libghidra.lowlevel"))'
```

Never set both LLG_INPUT_ROOT and LLG_SDK_PREFIX. SDK consumption does not run
Python. Pins and the authorized shared-BFD/PIC/spec closure remain required.

## Decompile your own input

Use `examples/decompile.lua BINARY ADDRESS LANGUAGE_ID COMPILER_SPEC_ID
[GHIDRA_ROOT]`. The executable interface has no fixture-manifest dependency.
For the source checkout, EXAMPLE is `$SOURCE/examples/decompile.lua`.
The package data location is `share/libghidra/examples/decompile.lua` beneath
the actual package prefix. CMake's prefix is PREFIX; LuaRocks normally uses:

```sh
ROCK_PACKAGE_PREFIX="$ROCKS/lib/luarocks/rocks-5.4/lua-libghidra/scm-1"
# Confirm this equals CMAKE_INSTALL_PREFIX in the rock build's cache/install log.
# Do not assume $ROCKS/share is the package-data prefix.
```

Choose a **known mapped virtual function address**, never a file offset, guessed
integer or arbitrary extreme address. For an unstripped supported ELF,
`nm -n --defined-only /absolute/path/to/binary` helps identify a known function.
`nm` prints hexadecimal without a prefix: `0000000000401106` becomes argument
`0x0000000000401106` (or `0x401106`). Bare all-digit strings are decimal to u64.
Exact parsing is not a mapping/safety proof: native extreme/unmapped address
crashes are known and cannot be recovered by Lua close/error handling.

Example invocation (replace paths/address with your verified supported input):

```sh
EXAMPLE="$SOURCE/examples/decompile.lua"
BINARY=/absolute/path/to/supported.elf
ADDRESS=0x401106
LANGUAGE_ID=x86:LE:64:default
COMPILER_SPEC_ID=gcc
SPECS=/absolute/path/to/ghidra-spec-root
"$GOOD_LUA" "$EXAMPLE" "$BINARY" "$ADDRESS" "$LANGUAGE_ID" "$COMPILER_SPEC_ID" "$SPECS"
# Embedded specs: writable HOME required on cold cache.
"$GOOD_LUA" "$EXAMPLE" "$BINARY" "$ADDRESS" "$LANGUAGE_ID" "$COMPILER_SPEC_ID"
```

Use a real root containing the expected Ghidra processor/spec layout for external
mode. Embedded mode extracts native compiled specs under HOME on a cold cache;
a missing/unwritable cold cache is an error, not proof the binary is unsupported.
Warm-cache use does not establish cold-cache behavior.

The script checks u64 and open results, then decompiles **before** lookup (native
discovery is lazy). It prints completed/is_fallback, error_message and pseudocode.
It exits zero only for complete, nonfallback output without an error message;
a present fallback/incomplete record is different from nil,error. Structured
errors retain code/message/operation/backend. The Lua 5.4 close-scoped function
returns before os.exit, so normal and raised Lua-error paths release the owner.
`check` tests presence only; it is not a shortcut for checking these flags.
Later get_function may still return NOT_FOUND; no eager analysis pass is invented.

## Practical limits and fixture demonstrations

Read [API limits](API.md#ownership-persistence-and-effective-limits) before editing
or saving. One client/process, shared aliases, logical close versus owner release,
no autosave/rollback, ignored protection/deadline fields, bounded ReadBytes,
pages-only families, empty string discovery, partial batch outcomes and limited
category persistence all matter. True-local retyping is unqualified on the
exercised profile. No dependency-internal OOM recovery guarantee is provided.

The analyzed-project regression uses a special no-FileBytes project referring
to external ELF. It does not establish ordinary raw/FileBytes project support.
`first_slice.lua`, `core_mutation.lua` and `fixture_manifest.lua` in the package
example data directory are **source-fixture regression demonstrations**, not
standalone own-input quickstarts. They require the original fixture tree and
LIBGHIDRA_FIXTURE_ROOT pointing to that checkout, plus the example data directory
in LUA_PATH. Do not substitute their special loader route for your own binary.

To replace an old recursively installed documentation dossier, use a clean prefix
for validation. If intentionally upgrading in place, remove only that old
`share/doc/lua-libghidra` subtree after backing up any user additions; installing
new files alone cannot remove stale old files. No automatic whole-prefix cleanup
is implied. Local build success is not distribution clearance; see
[notices](NOTICES.md).
