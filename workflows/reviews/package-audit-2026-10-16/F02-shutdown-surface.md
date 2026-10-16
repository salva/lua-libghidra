# F02 — Shutdown surface and persistence policy disagree

Severity: low. Category: surface/contract inconsistency. Transversality: API/docs.

Session exports `shutdown` although the current specialist disposition assigns
Shutdown to `native()`. This alias also lacks the stricter facade close/save
state-path policy. Method exposure was reproduced; no data-loss experiment or
new native failure is claimed. Evidence: [export](../../../../lua/libghidra/init.lua#L8),
[native-only claim](../../../M4-FULL.md#L139).

Design must select the intended facade surface explicitly, not silently change it
as an editorial correction. Preserve lowlevel Shutdown. See [API report](02-API-SEMANTICS.md).
