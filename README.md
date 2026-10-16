# lua-libghidra

Decompile functions and inspect binaries from Lua with
[libghidra](https://github.com/0xeb/libghidra).
lua-libghidra runs the native library in your Lua process, without starting the
Ghidra application or a separate service.

Ghidra supplies the decompiler engine; libghidra exposes its native API; this
binding makes that API callable from Lua. Read reconstructed C-like code, inspect
functions and instructions, and annotate the engine's program view.

Start with `libghidra`, which provides a Session for opening a program, reading
results and managing resources. Use `libghidra.lowlevel` when you need the full
native response or additional methods. Both share one native client and use your
existing Lua VM.

## Start here

- [Install with CMake or LuaRocks](docs/INSTALL.md).
- [Decompile your first function](docs/TUTORIAL.md) and understand the result.
- [Inspect function metadata, bytes and instructions](docs/EXAMPLES.md).
- [Look up methods](docs/API.md) and [result fields](api/FIELDS.md).
- [Read the dependency licenses and distribution requirements](docs/NOTICES.md).

## Requirements

The aim is most UNIX/Linux systems at least as broadly as libghidra, and modern
Lua versions. Today's build targets Linux and requires ordinary PUC Lua 5.4:
signed 64-bit integers and eight-byte double numbers. Ubuntu 24.04 x86-64 with
Lua 5.4.6 is the tested configuration. Lua 5.3 is rejected by the current ABI
check; other systems and custom numeric hosts are not validated. Building needs
C++20 and CMake >=3.26. See [installation](docs/INSTALL.md) for prerequisites.

The binding is local only: no HTTP, SWIG or upstream Python-binding dependency.
Once installed, it needs no Python, Java, Ghidra application or network. The first
use of embedded processor specifications extracts a cache and needs writable
HOME. You can instead supply external specifications; see [installation](docs/INSTALL.md).

Use a known, mapped function address for your first call. The
[tutorial](docs/TUTORIAL.md) explains how to choose one and distinguish complete
decompilation from incomplete or fallback output. The engine does not support
every input, and saving does not preserve every kind of edit; the
[API limits](docs/API.md#ownership-persistence-and-effective-limits) describe these cases.

## Dependencies and license

Original wrapper and documentation: Copyright 2026 Salvador Fandiño,
[MIT License](LICENSE). Dependencies retain their own licenses, including
libghidra's Human-Origin Source License v1.0. MIT does not replace applicable
upstream conditions for wrappers. No upstream endorsement is implied.
Read the [notices](docs/NOTICES.md) for pinned dependencies, exact attribution and
distribution obligations before distributing linked artifacts.

Source contributors: `docs/development/README.md` is the source-only developer
index, not part of the installed manual.
