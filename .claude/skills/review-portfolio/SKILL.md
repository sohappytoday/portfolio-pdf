---
name: review-portfolio
description: >
  Score and critique the user's own portfolio content under content/ against a rubric,
  targeting a specific job role (default: DevOps Engineer). Use when the user asks to
  review, grade, critique, or check whether their portfolio content is well-written. This
  is read-only feedback — it never edits content/ itself, and it never touches
  portfolio-example/ (that's a different, reference-only concern).
---

# /review-portfolio

Entry point for scoring the user's own `content/` against the portfolio-quality rubric.

## What to do

1. Determine the target role for this review: default to **DevOps Engineer** (the user's
   current stated application goal). If the user names a different role/company for this
   particular run, pass that instead.
2. Delegate to the **portfolio-reviewer** subagent (`.claude/agents/portfolio-reviewer.md`)
   via the Agent tool, passing the target role. Run in the foreground
   (`run_in_background: false`) — the next step depends on its result.
3. Relay the agent's scored review to the user as-is (per-item tables, overall score, top
   3 priority fixes, what's already strong).

## Scope

- Reviews `content/` only — the user's own content. Never `portfolio-example/`.
- Read-only: this skill critiques, it doesn't rewrite. If the user wants the fixes
  actually applied, that's a separate follow-up step, not part of this skill.
- If `content/` doesn't exist yet or is empty, expect the agent to say so rather than
  produce a fabricated review — relay that plainly instead of treating it as an error.
