# lua-libghidra

Decompile functions and inspect binaries from Lua with
[libghidra](https://github.com/0xeb/libghidra).
lua-libghidra runs the native library in your Lua process, without starting the
Ghidra application or a separate service.

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

The supported environment is Ubuntu 24.04/Linux x86-64 with ordinary PUC Lua 5.4:
signed 64-bit integers and eight-byte double numbers. The tested runtime is
5.4.6. Building requires C++20 and CMake; LuaRocks is also supported as an install
route. Lua 5.3 and custom numeric hosts have not been validated.

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

Pins: libghidra `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`, engine
`2035b8153afaf7ce2edde24a2c80b62bbcf5127f`, selected
`bfd-sleigh-target-autodetect` profile. Native SOURCE builds alone run the unchanged
upstream `cpp/embed_specs.py` through `cpp/cmake/EmbedSpecs.cmake`. This step needs
Python >=3.10 with standard-library zlib/XML support. There are no Python bindings
or project-owned Python tools or tests, and no SDK-consumer or runtime Python
requirement.

Original wrapper and documentation: Copyright 2026 Salvador Fandiño,
[MIT License](LICENSE). Dependencies retain their own licenses, including
libghidra's Human-Origin Source License v1.0. MIT does not replace applicable
upstream conditions for wrappers. No upstream endorsement is implied.
Read the [notices](docs/NOTICES.md) before distributing linked artifacts:
a successful local build is not legal or distribution clearance, a finding of
combined-license compatibility, or proof that all required source is included.

Source contributors: `docs/development/README.md` is the source-only developer
index, not part of the installed manual.
