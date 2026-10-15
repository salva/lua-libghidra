# lua-libghidra

Proposed local Lua bindings for [libghidra by Elias Bachaalany](https://github.com/0xeb/libghidra).
These AI-assisted design documents are informed by upstream API, documentation
and source review; no binding implementation or runtime qualification exists yet.
Upstream is not represented as endorsing this project.

- [Specification](docs/SPEC.md): two public surfaces, values and behavior.
- [Design](docs/DESIGN.md): ownership, pagination and reproducible native build.
- [Coverage](docs/COVERAGE.md): named native operations and release tiers.
- [Plan](docs/PLAN.md): readiness and release qualification gates.
- [Review index](docs/reviews/00-INDEX.md): dispositions and pending review.
- [Operations](workflows/OPERATIONS.md): automation policy.

Baseline: Linux x86-64, Lua 5.4, C++20, native local engine, CMake/LuaRocks.
sol2 is provisional pending ownership validation. HTTP is deferred; SWIG excluded.
The SDK proposes faithful `libghidra.lowlevel` responses and a small `libghidra`
Session facade sharing one owner. Python is a qualification oracle, not a runtime
dependency.

Upstream pin: `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.
Its [Human-Origin Source License v1.0](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/LICENSE)
permits unchanged dependency use and conditionally restricts derivative wrappers.
Applicability and binding licensing remain M0 decisions before implementation;
see SPEC for the distinction and distribution obligations.
