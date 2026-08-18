# .agents/

The folder that collects assets for LabFox coding agents.
Keep everything here in one place instead of scattering it across tool-specific folders (`.claude/`, `.cursor/`, etc.).

```
.agents/
├── skills/    Procedures per task type (<name>/SKILL.md)
└── docs/      Detailed docs (read only when needed)
```

- Shared rules live in `AGENTS.md` at the repository root.
- `CLAUDE.md` imports `AGENTS.md` and holds only Claude Code specific content.
- `.claude/skills` is a symlink pointing at `.agents/skills`. The real files are here.
  When adding another tool, link it the same way.

## How to add a skill

Create `.agents/skills/<kebab-case-name>/SKILL.md` and fill in the frontmatter.

```markdown
---
name: skill-name
description: One line on when to use this skill. The agent decides based on this sentence alone.
---
```

Write the `description` in terms of **"when it triggers"**, not "what it does".
