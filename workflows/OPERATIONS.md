# Automation operations

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
- Analyst launch request submitted through supported `POST /api/chat`; execution
  confirmation is recorded below after its tools and child work are observed.

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

1. Agree on `docs/SPEC.md` and `docs/DESIGN.md` and prepare `docs/PLAN.md`.
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
