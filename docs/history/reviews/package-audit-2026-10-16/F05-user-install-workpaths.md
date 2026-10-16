# F05 — User installation recipe depends on harness environment

Severity: medium. Category: unusable recipe. Transversality: user docs.

With `SAIVAGE_CARD_WORK_ROOT` absent, documented LuaRocks paths expand to
`/my-rock-build` and `/my-rock-tree`. Expansion was reproduced, not an attempted
installation. Ordinary users should not need an autonomous card environment.
Evidence: [recipe](../../../PACKAGE-FOUNDATION.md#L12).

Define caller-owned writable absolute paths or fail clearly on absent inputs.
Verify from a non-root shell without Saivage variables. Coordinate installation
guide changes with F06 and full-suite workpath changes with F08, without conflating
the two defects. See [packaging report](03-PACKAGING.md).
