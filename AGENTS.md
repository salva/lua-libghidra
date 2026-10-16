# lua-libghidra working guidance

- Scope is the native local libghidra functionality only; HTTP support is deferred.
  Do not use SWIG, including for prototypes, generators or fallback bindings.

- Read `docs/SPEC.md`, `docs/DESIGN.md`, `docs/COVERAGE.md` and `docs/PLAN.md`.
  The operator authorized implementation of the reviewed baseline; see
  `workflows/LAUNCH.md` for the objective and `workflows/OPERATIONS.md` for deployment.
- Keep product requirements and design separate from automation configuration.
  Saivage deployment and launch policy belongs in `workflows/OPERATIONS.md`.
- Verify the exact upstream libghidra project, revision, API and licensing before
  choosing an integration or redistribution strategy. Do not assume a Ghidra CLI
  or another similarly named library is the requested dependency.
- Validate against the real supported upstream library and Lua runtimes; mocks
  alone do not demonstrate a working native binding. Cover ownership, lifetimes,
  errors and boundary conversions explicitly in design and tests.
- Deliver the Lua wrapper, not an upstream repair campaign. Document upstream
  bugs with existing evidence and limitations, then move on. Small, understood,
  tested wrapper-side workarounds are allowed when useful for delivery; upstream
  debugging, fixes and speculative workarounds are not the priority. Preserve
  wrapper safety and honest capability claims; dependency patches still require
  their existing separate authorization.
- Keep credentials, generated runtime state and build output out of Git.
  Keep Saivage state project-local in `.saivage/` and `.saivage-work/`.
- Do not modify sibling projects or start autonomous work without operator approval.
- Commit implemented changes promptly. Do not push without operator permission.
- Follow the project skills in `.github/skills/` when their task matches:
  guidance-adoption for Saivage prompt changes, validation for binding/build
  checks, lxc-operations for this deployment and skill-authoring for skill edits.
  These host-side skills do not grant Saivage Executors deployment authority.
- Use Salvador Fandiño <sfandino@yahoo.com> as both Git author and committer,
  including automated commits; do not override this with a Saivage identity.
  The operator authorized the initial public GitHub publication only, not ongoing
  autonomous pushes.
