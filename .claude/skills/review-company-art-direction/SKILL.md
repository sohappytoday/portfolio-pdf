---
name: review-company-art-direction
description: Independently audit a company art-direction extraction for evidence traceability, synthesis quality, font and brand safety, and readiness for the portfolio theme contract. Use after extract-company-art-direction, when reviewing a company's research package, or when deciding whether an extraction meets the 90/100 handoff threshold. Reviewers are strictly read-only and never fix the artifact they score.
---

# Review company art direction

The full definition of this skill lives in `.agents/skills/review-company-art-direction/` so that Codex and Claude Code
share one source of truth. Do not duplicate it here.

Read `.agents/skills/review-company-art-direction/SKILL.md` in full and follow it literally, including every file it lists
under its required reading. Its `references/` and `scripts/` directories are part of the skill.

Those files use Codex's `$skill-name` invocation syntax. In Claude Code the equivalent is the
`/skill-name` slash command or the matching subagent in `.claude/agents/`. The names are identical.
