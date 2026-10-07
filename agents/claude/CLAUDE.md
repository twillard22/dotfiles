# Claude Code global rules
# Rules live in ~/.claude/rules/*.md, linked by setup.sh. Claude Code reads that
# directory natively. This file holds Claude-only notes.

## Claude Code only

- No memory system is in use (`autoMemoryEnabled: false`). Persist rules in the owning
  layer's file — `~/.dotfiles/agents/rules/00-engineering.md` (generic), `~/.work-agents/agents/rules/50-later.md`
  (work), `<layer>/agents/repos/<name>/rules.md` (private per-repo), or `<repo>/AGENTS.md`
  (team-visible) — never in `~/.claude/` memories.
- `.claude/settings.local.json` is in the global gitignore (`git/gitignore_global`,
  symlinked to `~/.gitignore_global`), so it is ignored in every repo including this one.
  Do not re-raise it as untracked.
- Themes: `theme-switch.sh` writes `"theme": "custom:<slug>"` into
  `agents/claude/settings.json`;
  the `custom:` prefix is required for user-defined themes. To add a theme follow
  `themes/NEW-THEME.md` and README.md -> Themes; never generate palette files yourself.
- Per-repo private notes arrive through `<repo>/.claude/rules/<layer>.local.md` stubs
  importing `@~/...`. Claude asks once per repo, "Allow external CLAUDE.md file
  imports?" Answer Yes; the approval is stored in `~/.claude.json`. Never use
  `CLAUDE.local.md`; it suppresses `AGENTS.md`.
- `brew doctor`'s "unlinked kegs: ruby" warning is inconsequential. The keg is a
  dependency-only install (`installed_on_request: false`) pulled in by `cocoapods`, whose
  `pod` wrapper invokes Ruby by absolute Cellar path and works fine unlinked. Your actual
  Ruby toolchain is mise's, which precedes `/opt/homebrew/bin` on PATH, so linking the keg
  would neither help nor shadow anything. Leave it as-is; do not re-raise it.
