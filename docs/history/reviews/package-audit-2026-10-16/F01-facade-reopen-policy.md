# F01 — Facade reopen bypasses option restrictions

Severity: medium. Category: contract inconsistency. Transversality: local API.

`Session:open_program` forwards native options, accepting ineffective `read_only`
and `project_name` fields that the facade factory rejects. This makes the implied
read-only policy misleading. Reproduced with a real owner; no upstream repair is
requested. Evidence: [facade forwarding](../../../../lua/libghidra/init.lua#L8),
[factory restriction](../../../../lua/libghidra/init.lua#L105).

Design must choose consistent facade validation versus removing the undocumented
convenience, retain the explicit native escape hatch and test rejected inputs
without generation changes. See [dimension report](02-API-SEMANTICS.md#api-01--medium-session-reopen-bypasses-the-facades-rejected-option-policy).
