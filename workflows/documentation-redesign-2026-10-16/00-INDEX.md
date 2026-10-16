# Documentation redesign — working index

Scope and owner conditions: [requirements](00-REQUIREMENTS.md). Baseline `4dffcb1`.
All files here are working documents, excluded from main docs/package/site.

## Workflow

- [x] Confirm clean stable baseline and stopped runtime; resolve Astra model.
- [x] Record owner conditions and subsystem/issue map.
- [x] Astra author: current-state analysis, design alternatives and selected design.
- [x] Separate Astra analyst: bounded example-origin assessment for the designer.
- [x] Fresh independent Astra design/analysis review and bounded corrections.
- [x] Astra author: self-contained sequenced replacement plan and planner handoff.
- [x] Fresh independent Astra plan/handoff review and bounded corrections.
- [x] Commit accepted artifacts and notify the main planner through Analyst.
- [x] After accepted design/plan and planner notice, use operator-authorized Run.
- [x] Verify fresh owning-chain execution and report adoption/resume receipts.

Use up to two correction rounds per reviewed document group. Unresolved required
changes are explicit blockers, not implicit approval. Do not implement during
planning, push, publish, alter deployment/config/prompts or change runtime files.

The operator explicitly authorized resume after the new design and plan are
accepted and the main planner has been told about the changes. The earlier Stop
remains effective until those conditions hold; no additional Run permission is
needed at that point. This does not authorize push or website publication.

## Issues and dimensions

| ID | Issue/condition | Importance | Transversality |
| --- | --- | --- | --- |
| [R01](R01-reading-path-and-reference.md) | Reader journey, domain API navigation, supported records | High | User/reference/generation/site |
| [R02](R02-authority-and-working-documents.md) | Current guides versus history and working documents | High | Docs/package/operator handoff |
| [R03](R03-independent-examples.md) | Independent task-first Lua examples | High | Examples/guides/tests/site |
| [R04](R04-artifact-and-stage-integration.md) | One content authority, artifact closure and pending website integration | High | Manifests/checks/site/planning |

These are redesign dimensions, not a new claim that each current component is
broken. They form one coherent design with an ordered plan, not four independent
implementations of overlapping document trees.

## Current artifacts

- [Analysis](01-ANALYSIS.md) and [design](02-DESIGN.md): independently approved;
  [final design review](reviews/DESIGN-REVIEW-r2.md).
- [Plan](04-PLAN.md) and [owning-planner handoff](05-PLANNER-HANDOFF.md): independently
  approved; [final plan review](reviews/PLAN-REVIEW-r2.md). The readiness gate is
  satisfied; notification and resume succeeded. Durable root adoption, explicit
  replacement direction to `card-h` and fresh stage execution are verified;
  website remains stopped/gated until E2. [Evidence](06-ADOPTION-RESUME.md). Approval of
  future tests is not a claim they have been implemented or passed.
- [Example assessment](03-EXAMPLE-ASSESSMENT.md): no distinctive upstream adaptation
  established, composition origin unknown; public fixture-demo selection must be
  addressed separately from correctness of ordinary API syntax.
