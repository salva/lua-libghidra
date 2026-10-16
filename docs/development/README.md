# Contributor guide

The maintained user manual starts at [README](../../README.md), with
[installation](../INSTALL.md) and [tutorial](../TUTORIAL.md), [API](../API.md), generated
[fields](../../api/FIELDS.md) and [notices](../NOTICES.md).

- [SPEC](SPEC.md): binding invariants and supported platform/scope.
- [DESIGN](DESIGN.md): direct-C-API phases, ownership and conversion architecture.
- [COVERAGE](COVERAGE.md): operation classification and source/runtime distinctions.
- [TESTING](TESTING.md): build, fixture and current validation commands.

## Source layout

`lua/libghidra/` contains the facade, lowlevel exports and iterator engine.
`src/` contains the direct C API adapter and converters. `cmake/` selects native
inputs, host ABI, package installation and the sole document inventory.
`scripts/` contains Lua source-fact tooling and build helpers; `tests/` contains
Lua/native boundary and real-engine qualification, authored fixtures and package
checks. `api/coverage.json` is generated source accounting, not a runtime pass
ledger. API owns signatures; FIELDS owns generated model fields. Do not duplicate
those authorities in contributor pages.

These contributor pages are source-only and are not selected into the installed
user manual. Current tooling commands must describe executable behavior, with
full/reduced scope stated explicitly rather than inferred from a helper pass.
