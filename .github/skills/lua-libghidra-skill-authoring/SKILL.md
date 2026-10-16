---
name: lua-libghidra-skill-authoring
description: 'Create or adapt project skills and their discovery configuration. Use for .github/skills, SKILL.md frontmatter, copying sibling skills or editing OpenCode skill sources.'
---

# Project skill authoring

Adapted from saivage-v3's opencode-skill-authoring skill. Follow current OpenCode
V2 documentation at https://opencode.ai/v2/docs/skills, not older V1 schema shapes.

- Maintain one directory per skill under `.github/skills/`; the project OpenCode
  config adds that directory as an explicit source. Use project-unique IDs to
  avoid unintentionally overriding workspace-global skills.
- Start SKILL.md with YAML frontmatter: name matching its directory and a concrete
  trigger-focused description. Prefer portable lowercase kebab-case IDs, 1–64
  characters. Keep operational steps short and supporting files beside the skill.
- Record source/provenance when copying. Adapt paths, runtime versions, tools and
  project scope; do not blindly copy sibling resets, gameplay, HTTP product work,
  unavailable Task roles or mandatory review ceremonies into Executor workflows.
- Distinguish host-side OpenCode skills from Saivage's separate role-filtered
  `.saivage/skills/index.json` catalog. Copying a skill does not grant tools or
  deployment authority; no host operations skill should silently empower Executor.
- Verify frontmatter, references, discovery and applicable composition. For V2,
  explicit config uses a skills array (for example `["./.github/skills"]`), not
  the older skills.paths shape. Preserve unrelated config and permissions.
- Explain activation/reload limits honestly. Commit source promptly with the
  operator identity; do not publish runtime state or push without permission.
