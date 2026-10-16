# Installation

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


## Installed paths and use

CMake module destinations are LUA_SOURCE_DIR and LUA_MODULE_DIR in the producing
cache. Relative values resolve beneath the actual install prefix, including a
`cmake --install --prefix` override; absolute values are used unchanged. The
conventional defaults shown above are not a rule for custom destinations.
For LuaRocks keep the actual expanded PREFIX/LUADIR/LIBDIR/LUA from its build
and cache. PREFIX is versioned package data, not necessarily the deployed module
root. Query deploy_lua_dir and deploy_lib_dir using the same tree, Lua version
and host prefix; verify installed files and the rock install record. Do not
append CMake's conventional module paths to a versioned rock PREFIX.

The two runnable scripts are under `share/libghidra/examples` in the actual
package data prefix. Exact manual copies live under
`share/doc/lua-libghidra/examples`. Start with the [tutorial](TUTORIAL.md), then
consult [task arguments and outcomes](EXAMPLES.md). Preserve the helper DSO next
to `_native.so` and its $ORIGIN lookup: moving just the module is insufficient.
No installed fixture/helper Lua scripts or source build kit are provided.

Use a clean prefix to avoid stale manual files. When upgrading in place, back up
user additions and remove only the old `share/doc/lua-libghidra` subtree if needed;
installing new files cannot remove obsolete members. No whole-prefix cleanup is
implied. Local build success is not distribution permission; see [NOTICES](NOTICES.md).
