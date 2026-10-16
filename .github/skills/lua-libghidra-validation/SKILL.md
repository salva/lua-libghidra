---
name: lua-libghidra-validation
description: 'Validate lua-libghidra native C++/Lua code, tests, build profiles or Saivage guidance. Use after binding, ownership, exact-value, CMake or workflows/prompts changes.'
---

# Project validation

Adapted from sibling Saivage development-validation: select checks by changed
surface and report evidence honestly, rather than copying TypeScript/UI commands.

- Read SPEC, DESIGN, PLAN, COVERAGE and relevant M1/readiness evidence. Use the
  supported real upstream pin and approved engine profile, ordinary C-built Lua,
  and both public surfaces. Mocks and Python-binding comparisons are not gates.
- Batch related assertions and fixtures within the current node's authority.
  Use fast focused tests while editing; build and run relevant broader tests at
  a coherent boundary. Reuse only applicable unchanged evidence; a new session
  is not by itself a reason to repeat a suite. Do not waive required gates.
- For an existing configured native build, run `cmake --build build -j4` and
  `ctest --test-dir build --output-on-failure`. Select focused tests by actual
  registered names; do not invent profiles, targets or claim unrun sanitizers.
- Qualify installed/source SDK and embedded/static/shared VM paths as required
  by the accepted task. Exercise real ownership, closure, UInt64 boundaries,
  failure cleanup and detached conversions. Attribute wrapper-only versus
  dependency/Lua sanitizer coverage explicitly. Never allocate huge buffers
  merely to test preallocation rejection.
- Prompt changes use the guidance-adoption skill and exact installed compiler.
  Automation compiler checks use Node because Saivage's actual compiler is
  JavaScript; this is not Python product tooling or a product runtime dependency.
- Keep status a current concise outcome/evidence/gaps/blockers/next-actions
  summary. Cite full retained output when inline output is incomplete. Distinguish
  a successful tool call from successful commands and bounded tests from complete
  milestone qualification. Preserve failures and unknown effects.
- Commit scoped passing work as Salvador Fandiño <sfandino@yahoo.com> (both
  identities); no push without operator permission. HTTP and SWIG remain excluded.
