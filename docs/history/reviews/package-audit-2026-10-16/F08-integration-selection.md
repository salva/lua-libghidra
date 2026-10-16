# F08 — Qualification silently skips integration groups outside harness

Severity: medium. Category: regression selection gap. Transversality: test entry points.

The installed qualification driver gates persistence, conditional CFG, document
mutation checks and profiles/runtime absence on `SAIVAGE_CARD_WORK_ROOT`, without
an explicit reduced-suite report. CTest does not register the omitted full
integration groups. This is static selection evidence, not a demonstrated product
failure or invalidation of historical card-backed runs. Evidence:
[conditional driver](../../../../tests/installed-qualification.sh#L44).

Make inputs explicit and full/reduced selection truthful; preferably provide a
named integration target reusing existing scripts. Missing prerequisites must not
silently count as qualification. No new framework or engine fault campaign.
See [test-quality report](05-TEST-QUALITY.md).
