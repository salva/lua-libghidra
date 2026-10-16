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

Owning-stage adoption/current direction and new child execution will be recorded
once observed. Root reads alone do not certify adopted dependencies or completed
restructuring. Website release remains dependent on E2 under the new plan.

## Evidence and boundaries

API receipts are host-local mode 0600 under
`/home/salva/g/ml/tmp/lua-libghidra-documentation-redesign-2026-10-16/`:
`notification-receipt.json` and `run-receipt.json`.

No coordinator implementation, push, Pages publication/dispatch/settings changes,
deployment/config/model/prompt changes or new dependency patches. Plans and this
record are workflow working material, not final docs. Preserve completed work and
all Git/runtime history; final documentation is not required to retain a development
evidence dossier.
