# Native source accounting and generated fields

`coverage.json` is generated from pinned C++ source and Lua source reviews. Its
110 operation rows include 70 local implementations and 40 excluded defaults.
Generated runtime slots remain unqualified. The historical ten-surface grammar
classification and sixty proposal slots are source metadata, not current syntax.
[API](../docs/API.md) is the sole call/default/envelope authority;
[contributor coverage](../docs/development/COVERAGE.md) supplies operation categories.

From the checkout, select existing verified libghidra source at
`d51ca813ae1b6b59519551a9be8c0b1ad74d862d`. Outputs/work must be fresh:

```sh
lua5.4 scripts/inventory-api.lua "$PINNED_SOURCE" "$FRESH_JSON" --coverage
lua5.4 scripts/check-tooling.lua "$PINNED_SOURCE" "$FRESH_WORK"
# Inspect the semantic diff before replacing api/coverage.json.
lua5.4 scripts/render-fields.lua
lua5.4 scripts/render-fields.lua --check
lua5.4 tests/tooling_fields.lua
```

The CLI refuses to overwrite an existing candidate. Two-argument inventory mode
emits raw native source reviews. No Python oracle or upstream Python binding is
required. Never regenerate `history/coverage-m3.json` or `runtime-evidence-m3.json`:
these are immutable test-consumed data, not generation input or manual pages.

`coverage.json` → `scripts/render-fields.lua` → [FIELDS](FIELDS.md) is the only
field pipeline. Scope-first exhaustive partitions put supported result values,
input/options, envelopes and enums before native-only appendix models/enums.
HealthStatus and Capability are result values; BytePatch is an input item.
Unknown/unassigned/duplicate models fail. Model anchors and nested links remain
stable. Request model defaults never imply optional Lua positional arguments.

Recursive included reachability establishes conversion availability, not populated
producers, stable iteration, persistence or runtime qualification. Enum spellings
follow actual converters with unknown numeric-response fallback. Native-only
schemas retain source facts without supported conversion claims. Current
[contributor testing](../docs/development/TESTING.md) documents real validation
scope, prerequisites and full/reduced integration commands.
