# lua-libghidra

Proposed local Lua bindings for [libghidra by Elias Bachaalany](https://github.com/0xeb/libghidra).
These AI-assisted design documents are informed by upstream API, documentation
and source review; no binding implementation or runtime qualification exists yet.
Upstream is not represented as endorsing this project.

- [Specification](docs/SPEC.md): two public surfaces, values and behavior.
- [Design](docs/DESIGN.md): ownership, pagination and reproducible native build.
- [Coverage](docs/COVERAGE.md): named native operations and release tiers.
- [Proposed examples](docs/EXAMPLES.md): first-slice calls and shared ownership.
- [Plan](docs/PLAN.md): readiness and release qualification gates.
- [Review index](docs/reviews/00-INDEX.md): dispositions and pending review.
- [Operations](workflows/OPERATIONS.md): automation policy.

Baseline: Linux x86-64, Lua 5.4, C++20, native local engine, CMake/LuaRocks.
sol2 is provisional pending ownership validation. HTTP is deferred; SWIG excluded.
The SDK proposes faithful `libghidra.lowlevel` responses and a small `libghidra`
Session facade sharing one owner. Source builds require Python >=3.10 with zlib
for upstream spec embedding; Python also serves as a qualification oracle.
Installed runtime requires neither Python nor Java/network access.

Upstream pin: `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.
Its [Human-Origin Source License v1.0](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/LICENSE)
permits unchanged dependency use and conditionally restricts derivative wrappers.
This wrapper's original code and documentation are licensed under the
[MIT License](LICENSE), as selected by the operator. This does not relicense
libghidra or other third-party components. Upstream applicability remains an M0
check; see SPEC for the distinction and distribution obligations.
