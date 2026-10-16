# Native source coverage and retained runtime evidence

`coverage.json` is generated **only from pinned C++ input and migrated Lua reviews**.
Its 110 operation rows include 70 local implementations and 40 excluded defaults.
All generated runtime slots are unqualified. Surface calls distinguish the ten
original approved first-slice grammars from sixty historical inventory proposals;
this classification grants no new syntax and does not revoke subsequent SPEC or
COVERAGE acceptance. Iterator qualification is not generated from source order.

Reproduce, without Python or upstream Python research sources:

```
lua5.4 scripts/inventory-api.lua "$PINNED_LIBGHIDRA_SOURCE" "$FRESH_JSON" --coverage
lua5.4 scripts/check-tooling.lua "$PINNED_LIBGHIDRA_SOURCE" "$FRESH_WORK_DIRECTORY"
cmp "$FRESH_JSON" api/coverage.json
```

The CLI refuses to overwrite an existing output. To update the committed ledger,
generate a fresh file, review its semantic diff, then replace the committed file.
Two-argument CLI mode emits raw native reviews for source fingerprint regression.

`history/coverage-m3.json` preserves the exact pre-cutover ledger, including all M3
manual/runtime annotations and Python development research. It is immutable
historical evidence, **not a generation input**. `runtime-evidence-m3.json` indexes
its per-operation runtime evidence without manufacturing newer qualification and
pins the full historical file's SHA256. Historical tests may compare old native
fingerprints/defaults, never execute Python or require upstream Python binding.
`coverage.md` remains chronological research history, not regeneration directions.
Current requirements and real Lua/native evidence remain authoritative. No runtime
acceptance is gained or lost by source-ledger format migration.

M4 implemented call grammar and request/response/dispatch disposition is maintained
in [M4-FULL](../docs/M4-FULL.md), supplementing the source-generated field facts.
Do not infer full qualification from the generated proposal names or from method
availability alone; service/runtime evidence and limitations remain separate.
