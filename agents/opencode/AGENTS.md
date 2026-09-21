# OpenCode notes

Rules live in `~/.claude/rules` (loaded via `instructions`), not here.
"Make a note" means edit the owning rules file: `~/.dotfiles/agents/rules/00-engineering.md`
for generic rules, `~/.work-agents/agents/rules/50-later.md` for work rules,
`<layer>/agents/repos/<name>/rules.md` for private notes, or `<repo>/AGENTS.md`
for team-visible rules.
OpenCode-only: `omo.jsonc` controls routing; `tui.json` is plugin-managed. Restart
OpenCode after config changes.
Ignore a repo's one-line `.claude/rules/*.local.md` `@~/...` stub; its content arrives via `.opencode/rules/*.local.md`.
