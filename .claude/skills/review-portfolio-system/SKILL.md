---
name: review-portfolio-system
description: Independently verify the common portfolio workflow or a rendered portfolio against explicit 100-point gates, deterministic checks, and hard blockers. Use when auditing portfolio-system/, validating Codex skills/agents/hooks for this project, reviewing rendered PDF/PNG quality, or deciding whether the work meets the 90/100 acceptance threshold. This workflow is review-only; reviewers never edit the artifact they score.
---

# Review portfolio system

The full definition of this skill lives in `.agents/skills/review-portfolio-system/` so that Codex and Claude Code
share one source of truth. Do not duplicate it here.

Read `.agents/skills/review-portfolio-system/SKILL.md` in full and follow it literally, including every file it lists
under its required reading. Its `references/` and `scripts/` directories are part of the skill.

Those files use Codex's `$skill-name` invocation syntax. In Claude Code the equivalent is the
`/skill-name` slash command or the matching subagent in `.claude/agents/`. The names are identical.
