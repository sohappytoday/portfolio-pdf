---
name: review-portfolio-system
description: Independently verify the common portfolio workflow or a rendered portfolio against explicit 100-point gates, deterministic checks, and hard blockers. Use when auditing portfolio-system/, validating Codex skills/agents/hooks for this project, reviewing rendered PDF/PNG quality, or deciding whether the work meets the 90/100 acceptance threshold. This workflow is review-only; reviewers never edit the artifact they score.
---

# Review portfolio system

Run an evidence-first, independent acceptance review. A score of 90 is an operational gate, not a probability.

## Choose the review mode

- `workflow-readiness`: review `AGENTS.md`, project memory, both skills, custom agents, hooks, validator, and system contracts using `references/workflow-readiness-rubric.md`.
- `rendered-design`: review actual PDF and page PNG files using `portfolio-system/QUALITY_GATE.md`.

If the user does not specify a mode, infer it from the changed artifacts and state the choice.

## Procedure

1. On Windows, run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/build-common-portfolio-system/scripts/validate-portfolio-system.ps1 -RepoRoot <git-root>`. Any failure is a hard blocker.
2. In rendered-design mode, inspect the complete PDF/PNG set before reading source CSS. Then inspect source, fonts, licensing notes, manifests, and preflight evidence.
3. Run two independent read-only reviewers. Prefer `portfolio_system_verifier` for system/contracts and `portfolio_visual_qa` for rendered output. Give both the same artifact snapshot and rubric.
4. Each reviewer must cite files and, for visuals, page numbers. Missing evidence receives no credit.
5. If total scores differ by more than 2 points or any category differs by more than 1 point, run a third read-only adjudication focused only on disputed items.
6. Final score is the lower accepted reviewer score. Pass only when deterministic checks pass, hard blockers equal zero, each reviewer scores at least 90, and category floors are met.
7. Return failures to the architect. Reviewers must not edit. Repeat against a newly rendered or newly validated snapshot.

## Output

Return scope and snapshot, deterministic results, hard blockers, category tables from both reviewers,
disagreements/adjudication, the lower final score, PASS/FAIL, and evidence-backed fixes. Do not round up.
