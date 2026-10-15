# lua-libghidra working guidance

- Scope is the native local libghidra functionality only; HTTP support is deferred.
  Do not use SWIG, including for prototypes, generators or fallback bindings.

- Read `docs/SPEC.md`, `docs/DESIGN.md` and `docs/PLAN.md` when available.
  Until requirements are agreed, do not invent a binding API or start implementation.
- Keep product requirements and design separate from automation configuration.
  Saivage deployment and launch policy belongs in `workflows/OPERATIONS.md`.
- Verify the exact upstream libghidra project, revision, API and licensing before
  choosing an integration or redistribution strategy. Do not assume a Ghidra CLI
  or another similarly named library is the requested dependency.
- Validate against the real supported upstream library and Lua runtimes; mocks
  alone do not demonstrate a working native binding. Cover ownership, lifetimes,
  errors and boundary conversions explicitly in design and tests.
- Keep credentials, generated runtime state and build output out of Git.
  Keep Saivage state project-local in `.saivage/` and `.saivage-work/`.
- Do not modify sibling projects or start autonomous work without operator approval.
- Commit implemented changes promptly. Do not push without operator permission.
