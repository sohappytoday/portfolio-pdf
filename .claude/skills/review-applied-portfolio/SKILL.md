---
name: review-applied-portfolio
description: Independently review an applied company-theme build against its input lock, deterministic preflight, rendered PNG/PDF evidence, brand-safety constraints, and the 90-point quality gate. Use after apply-company-art-direction creates an immutable build. Reviewers are read-only and never repair the build they score.
---

# Review applied portfolio

The full definition of this skill lives in `.agents/skills/review-applied-portfolio/` so that Codex and Claude Code
share one source of truth. Do not duplicate it here.

Read `.agents/skills/review-applied-portfolio/SKILL.md` in full and follow it literally, including every file it lists
under its required reading. Its `references/` and `scripts/` directories are part of the skill.

Those files use Codex's `$skill-name` invocation syntax. In Claude Code the equivalent is the
`/skill-name` slash command or the matching subagent in `.claude/agents/`. The names are identical.
