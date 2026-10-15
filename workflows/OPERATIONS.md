# Automation operations

## Status

Repository preparation only. No container, service, model routing, credentials,
cards or autonomous run have been created for this project.

## Setup policy

Use sibling `../pm` as an operational reference for its current Saivage v3
deployment pattern, not as a source of product-specific prompts or live state.
Verify its current configuration at deployment time; workspace-level historic
container addresses and v2 instructions may be stale.

1. Agree on `docs/SPEC.md` and `docs/DESIGN.md` and prepare `docs/PLAN.md`.
2. Select the Saivage release, general software-development workflow and model
   routing. Do not copy PM reconstruction/observation workflows by default.
3. Provision an isolated environment with this project mounted as its target.
   Preserve other projects and services. Keep state and credentials project-local
   and ignored by Git; never copy another project's cards, sessions or history.
4. Verify configuration, native build dependencies, upstream access and health.
5. Record the actual deployment details here and obtain operator approval before
   Run. A healthy web service is not evidence that implementation has started.

No deployment or Run is authorized merely by the existence of this document.
