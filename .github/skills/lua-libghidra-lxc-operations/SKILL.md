---
name: lua-libghidra-lxc-operations
description: 'Inspect or operate the dedicated saivage-lua-libghidra LXC deployment. Use for health, service identity, supported Stop/Run, bind mounts, restart or prompt deployment on this project only.'
---

# Dedicated instance operations

Adapted from sibling/workspace Saivage LXC operations, restricted to this project.
Read workspace handoff and workflows/OPERATIONS.md; verify facts before changing
anything. Do not operate the similarly named sibling containers.

Known deployment (verify): classic LXC `saivage-lua-libghidra`, service
`saivage.service`, host project mounted at `/work/lua-libghidra`; read-only
`/opt/saivage` comes from workspace tmp/lua-libghidra-container-setup/release-39ffe231.
Retain that active mount source. No guest SSH is configured here.

```sh
sudo lxc-info -n saivage-lua-libghidra
sudo lxc-attach -n saivage-lua-libghidra -- systemctl cat saivage.service
sudo lxc-attach -n saivage-lua-libghidra -- systemctl status saivage.service --no-pager
```

Use the verified IP for health/readiness and supported Analyst controls. Stop
project execution before an authorized deployment, then verify managed-process
settlement and service exclusion. A restart leaves execution stopped; ordinary Run
is a separate supported action. Do not edit cards/runtime JSON, erase locks,
reset history or restart sibling services. Restart and Run need operator authority.

For prompts, follow the guidance-adoption skill's complete stopped backup,
candidate validation and allowlisted publication. Preserve credentials without
printing them. Keep temporary evidence under workspace tmp and state project-local.
After restart check exact release/unit, health, bindings and history access;
after Run verify fresh child execution, not only running flags. No autonomous push.
