# Installation

## Supported environment and route selection

Build from a source checkout, then choose one of these routes:

- **Source with CMake:** build the native dependencies and wrapper, and install
  into a directory of your choice. Start here unless you already have an SDK.
- **Source with LuaRocks:** use the same prepared dependencies, with LuaRocks
  managing the wrapper installation.
- **Local SDK with CMake or LuaRocks:** reuse an existing compatible native SDK
  instead of rebuilding those dependencies. No public prebuilt SDK download is
  provided.

The supported environment is Ubuntu 24.04 amd64/Linux x86-64 with ordinary PUC
Lua 5.4, using signed 64-bit integers and eight-byte double numbers. The tested
runtime is Lua 5.4.6; Lua 5.3 and custom numeric hosts have not been validated.
You need GCC 13.3.0 with C++20 support, CMake >=3.26, Ninja, pkg-config, and both
the Lua executable and its matching development headers. LuaRocks routes also
need LuaRocks 3.x. For a nondefault Lua installation, explicitly select its
executable and the directory containing `lua.h`, `luaconf.h` and `lauxlib.h`.

Native builds also need the shared BFD, sframe, zstd and zlib libraries and
development files listed in the [system lock](../native-system.lock.json), plus
GNU tar, unzip, sha256sum, patch, realpath and core utilities. The exact locked
package versions may no longer be available in your package repositories.
Static system BFD archives are not a supported substitute.

Source builds run the unchanged upstream `cpp/embed_specs.py` through
`cpp/cmake/EmbedSpecs.cmake` to embed processor specifications. This step requires
Python >=3.10 with standard-library zlib/XML support. The wrapper does not use
upstream Python bindings or project-owned Python tools or tests. Neither SDK
builds nor the installed Lua module need Python. Installed execution also needs
no Java, Ghidra application or network. Downloads use curl only during the
explicit preparation step below.

For an SDK route, supply a local SDK validated for this binding. It must include
compatible libghidra CMake CONFIG files, exact Protobuf **29.3.0 CONFIG** files,
and all required Protobuf and Abseil libraries built as position-independent code
(PIC). Installing the wrapper from source does not itself produce a reusable
SDK. SDK construction is described in the source-only developer index.

## Absolute paths and input preparation

Run the following setup from the checkout root in a non-root shell. It creates
`WORK` for build files and installation output, sets `PREFIX` for CMake installs
and `ROCKS` for LuaRocks installs, and selects the Lua executable and headers.
Replace the Lua paths if yours differ. Use a new `WORK` for each independent
installation route. The installed manual alone is not a source build kit.

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

For either source route, prepare the dependencies next. This **online** command
downloads six archives at their locked versions, verifies their hashes, extracts
them and applies the `bfd-sleigh-target-autodetect` patch:

```sh
"$GOOD_LUA" scripts/prepare-native.lua --archives "$ARCHIVES" --output "$INPUTS" \
  --profile bfd-sleigh-target-autodetect
```

If you already have all six locked archives, set `ARCHIVES` to that cache's
absolute path and run the same command with `--offline`, keeping `INPUTS` fresh.
An empty cache will not work. The CMake commands below disable downloads during
configuration, so all native sources and specifications must be prepared first.
That does not make the earlier download step offline. Keep the locked versions
and selected patch profile.

## Source CMake

After preparing `INPUTS`, configure, build and install. The last three commands
set Lua's search paths and check that both public modules can be loaded:

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

The module uses the running Lua VM and must not link a second `liblua`. Its helper
shared library must remain beside `_native.so`; `$ORIGIN` lets the module find
that library relative to its own location. If you move the installation, keep
this layout intact.

## Source LuaRocks

Use the prepared `INPUTS` with a fresh `WORK` and LuaRocks tree. Set `LUA_DIR` to
the absolute prefix of your compatible Lua installation, containing its executable
(`bin/lua`, or the host selected by LuaRocks) and headers. The first two LuaRocks
queries below show which executable and header directory it will use. Check them
before building: the driver forwards those selections and checks Lua's binary
interface even when tests are disabled.

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

`GOOD_LUA` must be the executable selected by LuaRocks, with matching headers.
For a custom Lua installation, point `LUA_DIR` at that installation rather than
the system prefix.

## SDK CMake and SDK LuaRocks

Set `SDK` to the absolute directory of your existing compatible SDK:

```sh
SDK=/absolute/path/to/qualified-sdk
case "$SDK" in /*) ;; *) echo 'absolute SDK required' >&2; exit 1;; esac
test -d "$SDK"
test -f "$SDK/lib/cmake/libghidra/libghidraConfig.cmake"
test -f "$SDK/lib/cmake/protobuf/protobuf-config.cmake"
```

If the SDK uses a different library directory, check its actual CONFIG locations
instead. Ensure CMake selects this SDK rather than an unrelated system package.
With fresh `WORK` and `PREFIX` paths, use this configuration **instead of** the
source configuration; it does not use `NATIVE_INPUT_ROOT`:

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

For SDK LuaRocks, use fresh `WORK` and `ROCKS` paths and select `LUA_DIR` and the
matching Lua host as in the source LuaRocks route:

```sh
unset LLG_INPUT_ROOT
LLG_BUILD_DIR="$WORK/rock-sdk-build" LLG_SDK_PREFIX="$SDK" \
  luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" --tree="$ROCKS" \
  make --deps-mode=none --no-manifest
unset LUA_PATH LUA_CPATH
eval "$(luarocks --lua-version=5.4 --lua-dir="$LUA_DIR" --tree="$ROCKS" path)"
"$GOOD_LUA" -e 'assert(require("libghidra")); assert(require("libghidra.lowlevel"))'
```

Set only one of `LLG_INPUT_ROOT` and `LLG_SDK_PREFIX`. SDK builds do not run Python,
but still require the locked versions, shared BFD libraries, PIC archives and
processor specifications described above.


## Installed paths and use

Once the module-load check succeeds, continue with the [tutorial](TUTORIAL.md).
The runnable scripts are in `share/libghidra/examples` under your package data
prefix; identical copies accompany the manual in
`share/doc/lua-libghidra/examples`. The installation does not include test fixtures,
fixture-helper scripts or a source build kit.

**Custom CMake paths.** Check `LUA_SOURCE_DIR` and `LUA_MODULE_DIR` in the build's
CMake cache. Relative destinations are beneath the actual install prefix,
including a `cmake --install --prefix` override. Absolute destinations stay as
written. Adjust the search paths above if you chose nondefault destinations.

**LuaRocks paths.** Package data and deployed modules can live in different
directories. Keep the expanded `PREFIX`, `LUADIR`, `LIBDIR` and `LUA` values from
the build and cache. `PREFIX` locates versioned package data. To find deployed
modules, query `deploy_lua_dir` and `deploy_lib_dir` with the same tree, Lua version
and host prefix, then confirm the files against the rock's install record. Do not
append CMake's default module paths to the versioned rock prefix. Wherever the
modules are installed, retain the helper shared library beside `_native.so` and
its `$ORIGIN` lookup.

**Upgrades.** A clean prefix avoids obsolete manual files. For an in-place upgrade,
back up any additions you made and, if needed, remove only the old
`share/doc/lua-libghidra` subtree before installing. Installation adds or replaces
files but cannot remove obsolete ones; do not clear the whole prefix.

Before distributing what you built, read [NOTICES](NOTICES.md). A successful local
build does not grant distribution permission.
