# lua-libghidra

Native-local Lua/C++ bindings for [libghidra by Elias Bachaalany](https://github.com/0xeb/libghidra).
The faithful `libghidra.lowlevel` client and small `libghidra` Session facade
share one native owner; neither starts a second Lua VM. No upstream endorsement
is implied. Both native-local adapter surfaces are implemented; availability is
not a guarantee that the pinned engine supports every input or persists every edit.

## Start here

- [Install and decompile your own input](docs/EXAMPLES.md)
- [Current API, exact values and limitations](docs/API.md)
- [Generated native field reference](api/FIELDS.md)
- [Dependency notices and conveyance obligations](docs/NOTICES.md)

Supported profile: Ubuntu 24.04/Linux x86-64, ordinary PUC Lua 5.4 with signed
64-bit integers and eight-byte double numbers (qualified runtime 5.4.6), C++20,
CMake or LuaRocks. Lua 5.3 and custom numeric hosts are not qualified.
Native-local only: no HTTP, SWIG or upstream Python-binding dependency.
Installed execution requires no Python, Java, Ghidra application or network.
An embedded-spec cold cache needs writable HOME; external specs are an alternative.

Pins: libghidra `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`, engine
`2035b8153afaf7ce2edde24a2c80b62bbcf5127f`, approved
`bfd-sleigh-target-autodetect` profile. Native SOURCE builds alone use unchanged
upstream `cpp/embed_specs.py` via `cpp/cmake/EmbedSpecs.cmake`, Python >=3.10
standard-library zlib/XML. This narrow build exception does not permit Python
bindings, project-owned Python tooling/tests, SDK-consumer or runtime Python.

Original wrapper and documentation: Copyright 2026 Salvador Fandiño,
[MIT License](LICENSE). This wrapper was informed by upstream API, documentation
and source review. MIT does not relicense dependencies or exempt wrappers from
applicable upstream conditions. Upstream uses Human-Origin Source License v1.0;
see [notices](docs/NOTICES.md) before conveying linked artifacts. No legal,
combined-license, corresponding-source completeness or distribution clearance is
implied by a successful local build.

Source contributors: `docs/development/README.md` is the source-only developer
index, not part of the installed manual.
