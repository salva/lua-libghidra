# Automation operations

## Batched qualification guidance — 2026-10-16

Operator-requested same-release adoption: source `2b31f57`, editorial approval
by independent Astra (final edition confirmed). Maintained overrides are under
`workflows/prompts/`; host-side adapted skills are in `.github/skills/` and loaded
through project OpenCode configuration. They cover prompt adoption, validation,
this LXC instance and skill authoring, not new Executor tools or permissions.

The common/Planner guidance and test add-coverage/verify prompts now request
coherent related batches, a concise current finish list/status, applicable evidence
reuse and meaningful regression boundaries. Existing graph/outcomes, required
safety acceptance and independent review remain unchanged; no fixed batch size,
extra report/card or waived gate. This changes execution granularity, not the M1
product contract or permission to implement a later node's work.

Exact release `39ffe231` compiled **28 role bindings and 75 process prompts**;
effective settings and generated node-result contracts were unchanged. Supported
Project Stop reported contained and zero managed processes; service exclusion
then verified no service-user processes or runtime lock. Complete independent
stopped backup/candidate retained all project files, including ignored state/work.
Actual release consumers validated both trees: **10 cards, 57 card-history rows,
127 accepted records, 15 sessions, 26 segments, 6,859 messages, 1,700 provider
rows**, no images or missing work/record references. Two historical unmatched
calls were preserved, not reinterpreted as successful effects.

Whole-tree comparison checked **149,717 regular files, 5,717,844,976 bytes per
tree and seven symlinks**, namespace/mode/ownership and no writable aliases.
No sockets/FIFOs were present. Only the four allowlisted prompt files differed;
YAML, models/providers/tools/compaction/identities, credentials, product files and
history were unchanged. No migration or reset. The complete candidate prompt tree
was published under exclusion with displaced originals retained; no saved-state
root was replaced. Service restarted at 00:16 UTC, PID 22945; readiness passed and
execution remained stopped until ordinary Run.

Current-instructions API verified batching policy in all four inspected bindings
(root Planner, M1 Planner, qualification Executor, Analyst), with current record
and historical conversation/catalog access intact. Three normal notices to
`project`, `card-b` and `card-b-c` reported `interruption: not_requested`.
Supported `start_project` succeeded at 00:17 UTC. Root recovery activated the same
M1 owner at 00:18:26 with explicit batching direction. At 00:19:08 that Planner
activated the same `card-b-c`, consolidating the remaining qualification groups
and explicitly leaving tactics/batch size to Executor without weakening gates.
The Executor's **current compacted segment, version 4**, contains fresh returned
read, run_command and wait_process calls through 00:19:30 and the new direction.
Historical version 1 alone would miss that execution. This verifies child resume
and guidance delivery, not sustained batching compliance or complete M1 acceptance.

Evidence and full backup/candidate/displaced prompts:
`/home/salva/g/ml/tmp/lua-libghidra-batched-guidance-2026-10-16/`.
Key files: `source-check/guidance-validation.json`, `source-validation.json`,
`candidate-validation.json`, `tree-validation.json`, `publication.json`,
`live-bindings-and-history.json`, `stop-receipt.json`, `notify-resume-receipt.json`,
`verified-child-resume.json`, `verified-executor-resume.json`, `editorial-review.md`.
These secret-bearing full copies stay outside Git. Rollback is prompt-only under
fresh exclusion; do not restore historical state over new execution. No push.

## Deployment — 2026-10-15

The operator authorized a new container and autonomous launch after review
convergence. [LAUNCH.md](LAUNCH.md) records the accepted objective.

| Item | Value |
| --- | --- |
| Container | `saivage-lua-libghidra`, classic privileged LXC, Ubuntu 24.04 amd64 |
| Control room | `http://10.0.3.233:8080/` (DHCP; verify before operations) |
| Guest identity | `salva`, UID/GID 1000, matching target owner; guest-local passwordless sudo |
| Target | Host `/home/salva/g/ml/lua-libghidra` → guest `/work/lua-libghidra`, writable |
| Runtime | Dedicated copy of PM release `39ffe231`, guest `/opt/saivage`, read-only |
| Runtime host path | `/home/salva/g/ml/tmp/lua-libghidra-container-setup/release-39ffe231` — active mount source; retain while deployed |
| Service | `saivage.service`, Node 24.16.0, npm 11.13.0 |
| Workflow | Fresh bundled `classic-typed`; no PM cards/history or gameplay extensions |
| Routes | Planner `gpt-6-astra`; Analyst, Oversight, Reviewer, Executor and compaction `gpt-6.1-sol` |
| Credentials | Selected PM Codex profile copied to ignored project-local auth store, mode 0600; no secret in tracked configuration |
| Operator access | Tokenless; nftables accepts port 8080 only from loopback or host `10.0.3.1`; no SSH server |

Reviewed configuration snapshot: [saivage.yaml](saivage.yaml). Active configuration
and generated prompts are in ignored `.saivage/`; changes to the snapshot do not
automatically reconfigure the service. State is newly initialized and project-local.
The initial root-specific agent identity change was rejected at startup; it was
reverted to the initialized topology while stopped, with no generated-state
repair/reset. Planning routes were changed without changing session identities.

Installed baseline: GCC/G++ 13, CMake 3.28.3, Ninja, Lua 5.4.6/development headers,
LuaRocks (configured for 5.4), Python 3.12/venv/development headers, Java 21,
binutils/BFD/iberty and zlib/zstd development libraries. Exact libghidra/Ghidra/spec
qualification remains M0 work, not a passed implementation gate.

## Verification and launch evidence

- Compiled prompt-composition and static-serving smoke checks passed using the
  installed release. No Saivage source rebuild or code modification was needed.
- Service and nftables survived an actual LXC stop/start. Host and guest health,
  readiness, UI and headerless Analyst API probes passed afterward.
- HTTP access from the sibling PM container was rejected before and after restart.
- DHCP assigned `.231` initially and `.233` after reboot. The current NIC MAC
  `5a:2d:93:d5:37:5f` is now persisted; the IP remains DHCP-managed.
- Analyst launch request through supported `POST /api/chat` accepted root brief
  revision 2 and called `start_project` successfully at 19:32:39 UTC (PID 198).
  Root planner activated `card-a`, “Establish M0 legal, native dependency, fixture
  and inventory readiness,” at 19:33:38 UTC. Its independent planner session
  executed `get_card` and multiple `read` calls with successful returned results
  through 19:34 UTC. This establishes real child execution, not merely a running
  status; binding implementation/qualification is not yet claimed.
- Compared 1,662 installed bin/dist/web runtime files byte-for-byte against the
  pinned PM release copy; all matched. Evidence: `release-verification.json`.

Setup scripts and non-secret launch/probe evidence are under
`/home/salva/g/ml/tmp/lua-libghidra-container-setup/`. That directory also contains
the active runtime mount source, so it is not disposable while deployed.

## Operations

```bash
sudo lxc-info -n saivage-lua-libghidra
sudo lxc-attach -n saivage-lua-libghidra -- systemctl status saivage.service --no-pager
curl -fsS http://10.0.3.233:8080/health/ready
```

Use the Analyst/normal Run/Stop controls for project execution. A systemd restart
starts the web service with project execution stopped; it is not an automatic Run.
Keep existing credentials and generated history intact during later operations.

## Setup policy

Use sibling `../pm` as an operational reference for its current Saivage v3
deployment pattern, not as a source of product-specific prompts or live state.
Verify its current configuration at deployment time; workspace-level historic
container addresses and v2 instructions may be stale.

1. Agree on `docs/development/SPEC.md` and `docs/development/DESIGN.md` and
   prepare the current delivery plan under `workflows/`.
2. Select the Saivage release, general software-development workflow and model
   routing. Do not copy PM reconstruction/observation workflows by default.
3. Provision an isolated environment with this project mounted as its target.
   Preserve other projects and services. Keep state and credentials project-local
   and ignored by Git; never copy another project's cards, sessions or history.
4. Verify configuration, native build dependencies, upstream access and health.
5. Record the actual deployment details here and obtain operator approval before
   Run. A healthy web service is not evidence that implementation has started.

The operator's explicit launch request authorizes this deployment and initial Run;
the text of this document alone does not authorize future resets or publication.
