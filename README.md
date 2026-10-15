# lua-libghidra

Lua bindings for [0xeb/libghidra](https://github.com/0xeb/libghidra), designed
around its C++ SDK and inspired by its Python API. Specification and design are
drafted for review; no binding implementation or Saivage deployment exists yet.

## Project documents

- [Specification](docs/SPEC.md): proposed scope, Lua API and acceptance criteria.
- [Design](docs/DESIGN.md): integration architecture and binding-tool comparison.
- [Plan](docs/PLAN.md): sequenced implementation work and validation gates.
- [Automation operations](workflows/OPERATIONS.md): Saivage setup and launch policy.

The proposed baseline is Lua 5.4 on Linux x86-64, C++20 with sol2, local and HTTP
backends, CMake and LuaRocks. The plan records decisions to confirm before
implementation. Python supplies API inspiration, not a runtime dependency.
