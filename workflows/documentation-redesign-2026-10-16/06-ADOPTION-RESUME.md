# Approved redesign — adoption and resume evidence

Working operations record, excluded from main documentation/package/site.

## Readiness and controls

- Product baseline `4dffcb1`; accepted design/plan/assignment committed before
  controls, final approval commit `01291ea`.
- Fresh independent Astra design review and plan/handoff review approved with no
  required changes. These are specification approvals, not prospective test passes.
- Operator explicitly authorized notify then resume after that readiness gate.
- Verified dedicated classic LXC `saivage-lua-libghidra`, IP `10.0.3.233`, ready
  endpoint and stopped/idle runtime with no active actors. Website `card-h-d` had
  no children; A/B/C completed work was preserved.
- Three normal notifications, no interruption requested:
  - root `project`: `7dc990e7-81a8-4da7-9a59-d5ff7f765271`;
  - owning `card-h`: `340a9bcd-72ca-4671-829e-070e653cdf8c`;
  - pending website `card-h-d`: `41457e5d-252b-4741-a377-97b910c95d1a`.
- Separate supported Analyst `start_project` succeeded, `started:true`, runtime
  running at 11:44:30 UTC on 2026-10-16. No reopen/reset/service restart or runtime
  JSON edits were used.

## Execution verification

Fresh root recovery produced successful returned `read` results for the replacement
handoff at 11:44:35 and plan at 11:44:40 UTC. Initial resumed runtime had only the
root recovery actor; stage and website were stopped. This establishes actual
access to the new assignment, not only a running flag, and shows the obsolete
website was not directly relaunched by Run.

Root published a new accepted `status.md` at 11:45:50 UTC explicitly adopting the
replacement contract, superseding conflicting B/D directions and recording the
E1 → E2 → existing website E3 gate. The write returned success. Root then called
`activate_card` for existing `card-h` at 11:46:09 with explicit replacement
instructions and the rule that website activation waits for E2; completed A/B/C
must remain done. Because the installed tools do not mutate dependencies, the
accepted owner direction enforces this prerequisite by withholding site activation,
not by claiming a fabricated graph edit.

Fresh `card-h` execution returned successful `get_card` at 11:46:15 and `read` at
11:46:19 UTC. Verification at 11:46:21 showed runtime running and `card-h-d` still
stopped with no children. This verifies durable root adoption, explicit current
parent-to-child direction and actual owning-stage execution, not completion of
E1/E2 or the stage's eventual implementation results. Website remains gated.

## Evidence and boundaries

API receipts are host-local mode 0600 under
`/home/salva/g/ml/tmp/lua-libghidra-documentation-redesign-2026-10-16/`:
`notification-receipt.json`, `run-receipt.json`, `owning-execution-evidence.json`
and `adoption-verification.json`.

No coordinator implementation, push, Pages publication/dispatch/settings changes,
deployment/config/model/prompt changes or new dependency patches. Plans and this
record are workflow working material, not final docs. Preserve completed work and
all Git/runtime history; final documentation is not required to retain a development
evidence dossier.
