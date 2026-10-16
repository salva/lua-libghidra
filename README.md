# lua-libghidra

Native local Lua bindings for [libghidra by Elias Bachaalany](https://github.com/0xeb/libghidra).
This original wrapper and its AI-assisted documentation are informed by upstream
API, documentation and source review. Both Lua surfaces and full native-local
adapters are implemented. Local installed qualification and artifact applicability
are in [full qualification](docs/INSTALLED-FULL.md) and the
[operation/field crosswalk](docs/FULL-CROSSWALK.md); historical core evidence is
retained separately. M5 independent acceptance and publication are not approved.
Upstream is not represented as endorsing this project.

- [Core API reference](docs/API.md), [field manifest](api/FIELDS.md), and
  [local notices/source obligations](docs/NOTICES.md).
- [Specification](docs/SPEC.md): two public surfaces, values and behavior.
- [Design](docs/DESIGN.md): ownership, pagination and reproducible native build.
- [Coverage](docs/COVERAGE.md): named native operations and release tiers.
- [Installed examples](docs/EXAMPLES.md): first-slice calls and shared ownership.
- [Plan](docs/PLAN.md): readiness and release qualification gates.
- [Review index](docs/reviews/00-INDEX.md): dispositions and pending review.
- [Operations](workflows/OPERATIONS.md): automation policy.

Baseline: Linux x86-64, Lua 5.4, C++20, native local engine, CMake/LuaRocks.
The adapter uses the protected direct Lua C API (no sol2). HTTP is deferred; SWIG excluded.
The SDK provides faithful `libghidra.lowlevel` responses and a small `libghidra`
Session facade sharing one owner. Source builds require Python >=3.10 with zlib
for upstream spec embedding in the current dependency profile. Python is allowed
during development, but upstream Python bindings are not a build/runtime/test
dependency. Release tooling/tests should be Lua-based; retained Python requires
a documented compelling reason and operator acceptance. Installed runtime requires
neither Python nor Java/network access.

Upstream pin: `d51ca813ae1b6b59519551a9be8c0b1ad74d862d`.
Its [Human-Origin Source License v1.0](https://github.com/0xeb/libghidra/blob/d51ca813ae1b6b59519551a9be8c0b1ad74d862d/LICENSE)
permits unchanged dependency use and conditionally restricts derivative wrappers.
This wrapper's original code and documentation are licensed under the
[MIT License](LICENSE), as selected by the operator. This does not relicense
libghidra or other third-party components. The operator accepted the existing
upstream license for project planning and closed licensing research on that
basis; this is not legal clearance or publication authorization. See
[the disposition and retained research](docs/M0-LICENSE.md) for qualifications
and third-party distribution obligations.
