# M0 operation/field inventory — structural baseline, semantic review open

`coverage.json` is generated from the actual pinned public headers, LocalClient
overrides and Python AST, not the COVERAGE summary alone. It is **not yet a
completed M0 inventory**, an adapter specification ready for implementation, or
runtime qualification. `unresolved` and per-operation pagination identity/order
slots intentionally expose remaining work. A passing structural check does not
close those gates.

## Reproduce

From the project root, with the locked native input extracted at the default
`.cache/native-inputs/libghidra-d51ca813ae1b6b59519551a9be8c0b1ad74d862d`:

```sh
python3 scripts/inventory-api.py
python3 scripts/inventory-api.py --check
python3 -m unittest discover -s tests -p test_inventory_api.py -v
```

`--source PATH` accepts another extracted source root. No dependency code is
executed, no downloads or native writes occur. Source hashes and declaration/
implementation line references are recorded for independent inspection. This
bounded parser rejects unrecognized local model declarations rather than dropping
fields. It reconciles all service declarations to shared defaults, every local
override to a declaration and every included override to the normative tier table.
HTTP/headless factory option types are excluded from local model extraction;
Python transport/headless/helper operations are separately marked excluded.
StatusOr is described in `error_envelope`, not misrepresented as a model table.

## Current accounting

- 110 native service operations: 70 local overrides, 40 inherited defaults
  excluded from local support. Factory and owner lifecycle are recorded separately.
- 160 local/shared model types, 466 direct fields, with recursively expanded
  request/response field paths; native defaults, optionality and Lua representation.
- 412 Python operation/model rows including the 27 direct LocalClient operations,
  constructor, model annotations and excluded HTTP/async/headless/helper methods.
- Exact source hashes include downstream adapters and decompiler pool; those hashes
  establish provenance, **not** completed branch-by-branch semantic review.

`declaration.arguments` is the native signature. `request.binding_default` is a
proposed binding convention where specified; nested defaults remain native model
defaults. Unspecified arguments are required rather than inventing defaults.
Native integral width is not proof of an effective downstream domain. Only the
documented ReadBytes and compound paging bounds are presently resolved.

## Remaining semantic work (blocks exhaustive acceptance)

Resolve every included operation against the owning downstream adapter, including
identity fields and comparator, actual global order, cursor sequence, filtering,
range normalization and errors propagated by helpers. Replace generic facade
convenience descriptions with exact per-method signatures/extraction and resolve
native enum spellings. Independently reconcile Python bodies and native pybind
conversion/extraction, not only AST signatures. Inspect owner factory/destructor
branches and prove excluded default bodies and HTTP overrides do not expand local
support. Review nested fields for ignored/conditional semantics, not only types.
Add independent source-mutation regression tests: field/operation removal/addition,
ignored-field and cursor drift must be detected rather than merely regenerated.

All positive/negative and Python oracle slots remain **unqualified**. Inventory is
not qualification: native readiness evidence in `docs/NATIVE-READINESS.md` belongs
to its pinned separately authorized engine profile and does not qualify every API
row. No M1 implementation is included. MIT wrapper choice does not resolve the
separate upstream license applicability gate.

Retain defined-string constant-empty fidelity only (no scanner or iterator),
signatures pages-only (candidate offsets; empty output is not exhaustion), ignored
mutation arguments, range-end zero sentinels, signed-int4 ReadBytes bound, logical
program closure versus binding owner release, and mutation/lifecycle generation
invalidation across both public views. Structural tests pin these exceptions.
