# Instance prompt overrides

These four maintained files overlay the existing classic-typed prompt tree.
They are automation policy, not product requirements. Do not replace the entire
instance configuration with a template or edit generated state to deploy them.

The batching/concise-status/evidence-reuse policy is adapted from PM's reviewed
Saivage guidance (`pm` source `a64a1e0`, release `39ffe231`), particularly
`fragments/_shared/engineering-simplicity.md` and project guidance. Test-node
wording is adapted to this instance's existing graph; outcomes are unchanged.

Use the project `lua-libghidra-guidance-adoption` skill for deployment. Compile the
complete effective tree with the exact installed release, preserve live settings
and history, review the rendered role/node closure, then use supported Stop,
stopped backup/candidate validation, restart and ordinary Run. Publish only the
reviewed overlay within a preserved complete prompt tree. See OPERATIONS.md.

Host-side skills live in `.github/skills/`, with project-unique IDs to avoid
shadowing the workspace's reusable skills. They are not installed into Saivage's
Executor catalog: host deployment control is not an Executor permission.

Skill provenance: guidance-adoption comes from the workspace's reviewed adoption
skill; validation and LXC operations adapt the sibling/workspace Saivage skills;
skill-authoring adapts `saivage-v3/.github/skills/opencode-skill-authoring` at
`9d4f16e5`, corrected to current OpenCode V2 discovery. These are deliberately
project-specific adaptations, not copies of sibling reset/migration procedures.

Composition check (Node is required by the actual Saivage compiler, not by the
Lua binding):

```sh
node workflows/check-guidance.mjs <installed-release-root> <instance-root> <fresh-scratch-root>
```

The checker overlays these four files in a scratch config, compiles deployed
settings and all affected role/node bindings, checks contracts/settings unchanged,
and validates skill metadata. It does not validate saved history or prove runtime
adoption; those are separate deployment checks.
