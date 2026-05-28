# Always-loaded guidelines
# Add one @path line per guideline to have it loaded in every conversation.
@guidelines/karpathy/skills/karpathy-guidelines/SKILL.md

# Engineering Principles

Universal guidelines that apply to every project.

## Testing

TDD — tests before implementation. Every line of production code has a test.
- Write a failing test first, then make it pass.
- "Fix the bug" → write a test that reproduces it, then make it pass.
- "Add validation" → write tests for invalid inputs, then make them pass.

## Functional Programming

Pure functions for all business logic. Side effects (DB writes, network calls) isolated to
route handlers and top-level entry points. Business logic never triggers side effects directly.

## Type Safety

Never use `as` to assert a data shape — use a schema library (Zod, Valibot, etc.) to parse
and validate it first. `as` is only acceptable for non-shape assertions (`undefined as unknown`,
type-narrowing within already-validated data).

## Comments

Default to no comments. Only add one when the WHY is non-obvious: a hidden constraint, a subtle
invariant, a workaround for a specific bug, behavior that would surprise a reader. Never explain
WHAT the code does — well-named identifiers already do that.

## Security

Never introduce command injection, XSS, SQL injection, or other OWASP top 10 vulnerabilities.
Only validate at system boundaries (user input, external APIs) — trust internal code and
framework guarantees.

---

# Dotfiles Setup

This file lives at `~/.dotfiles/claude/CLAUDE.md` and is symlinked to `~/.claude/CLAUDE.md`.
Claude Code loads it automatically for every project on this machine.

## New machine setup

```bash
git clone --recurse-submodules https://github.com/twillard22/dotfiles ~/.dotfiles
cd ~/.dotfiles && ./setup.sh
```

Then on each machine, create `~/.gitconfig.local` with this machine's GPG signing
key and email (the shared `gitconfig` `[include]`s it, so without this file commits
will fail to sign):

```bash
cp ~/.dotfiles/git/gitconfig.local.example ~/.gitconfig.local
# edit to fill in this machine's email + signingkey
```

Then reinstall Claude Code plugins (can't be scripted — run once in Claude Code):
```
/plugin install supabase@claude-plugins-official
/plugin install figma@claude-plugins-official
```

## Adding a new always-loaded guideline

Always-loaded guidelines are `@path` included at the top of this file — Claude reads them
at the start of every conversation without being asked.

**From an external repo (recommended for third-party guidelines):**
1. Add it as a submodule: `cd ~/.dotfiles && git submodule add <url> claude/guidelines/<name>`
2. Add an `@path` line at the top of this file: `@guidelines/<name>/path/to/SKILL.md`
3. Commit: `git add -A && git commit -m "add <name> guideline"`

**As a plain file (for your own guidelines):**
1. Create `claude/guidelines/<name>.md` with your content
2. Add an `@path` line at the top of this file: `@guidelines/<name>.md`
3. Commit

## Adding a new invokable skill

Invokable skills are callable mid-conversation (e.g. `/tanstack-start-setup`). They live in
`claude/skills/` and are symlinked into `~/.claude/skills/` by `setup.sh`.

1. Create `claude/skills/<name>/SKILL.md` with your skill content
2. Add one line to `setup.sh`: `symlink "$DOTFILES/claude/skills/<name>" "$HOME/.claude/skills/<name>"`
3. Run `setup.sh` to activate: `cd ~/.dotfiles && ./setup.sh`
4. Commit: `git add -A && git commit -m "add <name> skill"`

## Updating guideline submodules

```bash
cd ~/.dotfiles && git submodule update --remote && git commit -am "update guidelines"
```

## Git commits

Never include a `Co-Authored-By: Claude` (or any Claude/Anthropic co-author) trailer in git commit messages.

## Memory vs. repo documentation

Prefer documenting context in the dotfiles repo (comments in config files, or this CLAUDE.md)
over Claude's local memory system. Local memories live in `~/.claude/` and are not synced
across machines — anything worth remembering should live in the repo instead.

## Known non-issues — do not re-raise

**`settings.local.json` in gitignore:** Do not suggest adding `settings.local.json` or
`**/.claude/settings.local.json` to any gitignore. Claude Code writes this file into project
`.claude/` dirs, but those dirs are never inside this dotfiles repo. Adding the rule is
defensive theater for a scenario that cannot occur. This has been raised and rejected multiple
times (see commits `1761f09`, `5ba93ac`).

## Creating a new theme

**Do NOT generate theme files yourself — Claude Code's role is only to fill in the brief and wire up results.**
The correct process:

1. Fill in `~/.dotfiles/themes/NEW-THEME.md` — set the `Name`, `Display name`, and `Vibe` fields only. Leave the Palette table empty.
2. Hand the filled-in file to the user and tell them to paste the whole thing into claude.ai — it will design the palette and generate all 5 output files.
3. Once the user returns with the generated files, wire everything up:
   - Place files into `vscode-themes/<name>/themes/<name>.json`, `ghostty/themes/<name>`, `starship/<name>.toml`, `themes/<name>/zsh-highlights.zsh`, `themes/<name>/zsh-autosuggest.zsh`
   - Create `vscode-themes/<name>/package.json` (copy structure from an existing one)
   - Add two case entries to `theme-switch.sh` (Ghostty block + VS Code block)
   - Package and install the VS Code extension: `cd vscode-themes/<name> && vsce package --allow-missing-repository && code --install-extension tw-<name>-1.0.0.vsix`
   - Symlink the Ghostty theme: `ln -sf ~/.dotfiles/ghostty/themes/<name> ~/.config/ghostty/themes/<name>`
   - Run `theme-switch <name>` to activate
