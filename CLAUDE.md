# Portfolio PDF workspace

The durable project rules are shared with Codex and live in AGENTS.md.

@AGENTS.md

## Claude Code specifics

This project's workflow definitions have a single source of truth under `.agents/` and `.codex/`.
The `.claude/` directory mirrors them into the shapes Claude Code reads:

- **Skills** — `.claude/skills/<name>/SKILL.md` are thin wrappers. The real instructions,
  `references/`, and `scripts/` stay in `.agents/skills/<name>/`. Always read the `.agents/` copy in full.
- **Subagents** — `.claude/agents/*.md` mirror `.codex/agents/*.toml`. Keep both in sync when either changes.
- **Hooks** — `.claude/settings.json` runs the same `.codex/hooks/*.ps1` validators that Codex runs.
- **Project memory** — `.agents/memory/portfolio-system-strategy.md`, as AGENTS.md requires.

### Invocation syntax

AGENTS.md and the `.agents/skills/` files use Codex's `$skill-name` syntax. In Claude Code the
equivalent is the `/skill-name` slash command, or delegating to the matching subagent. The names are
identical; only the sigil differs.

### Read-only reviewers

Codex enforced reviewer read-only status with `sandbox_mode = "read-only"`. Claude Code has no
equivalent sandbox, so the mirrored reviewer agents are restricted by omitting Write and Edit from
their `tools:` list and by an explicit read-only instruction. They still have Bash for non-mutating
validation — a reviewer must never use it to modify the artifact it scores.
