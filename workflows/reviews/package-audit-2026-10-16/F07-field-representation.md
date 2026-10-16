# F07 — Generated field wording misstates Lua scalar/enum representation

Severity: low. Category: generated reference defect. Transversality: tooling/reference.

`RevisionResponse.file_version` is described as int32 table/enum even though its
converter emits a Lua integer; enum entries likewise use ambiguous table/enum
wording rather than lowercase-string/numeric-fallback semantics. Evidence:
[rendered field](../../../../api/FIELDS.md#L963),
[converter](../../../../src/owner.cpp#L173).

Fix presentation in its generating source, regenerate current outputs and test
representative integers/enums. Preserve historical source/evidence artifacts and
unsupported-model distinctions. Do not hand-edit generated files or promote
source accounting into runtime qualification. See [documentation report](04-DOCUMENTATION.md).
