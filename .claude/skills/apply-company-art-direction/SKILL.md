---
name: apply-company-art-direction
description: Apply an accepted company art direction as a licensed, company-specific theme adapter, prove it against the common fixtures, and render an immutable portfolio build when company-neutral layouts exist. Use after extract-company-art-direction has a hash-matching PASS. Do not research a company, rewrite content, or modify the common core during application.
---

# Apply company art direction

The full definition of this skill lives in `.agents/skills/apply-company-art-direction/` so that Codex and Claude Code
share one source of truth. Do not duplicate it here.

Read `.agents/skills/apply-company-art-direction/SKILL.md` in full and follow it literally, including every file it lists
under its required reading. Its `references/` and `scripts/` directories are part of the skill.

Those files use Codex's `$skill-name` invocation syntax. In Claude Code the equivalent is the
`/skill-name` slash command or the matching subagent in `.claude/agents/`. The names are identical.
