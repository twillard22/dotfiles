# Dotfiles Audit

Ten-step accuracy audit. Each step documents the finding and the fix applied.

---

## Step 1 — `.gitignore` pattern validation

Test every pattern with `git check-ignore` to confirm actual coverage.

| Pattern | Covers | Gap |
|---------|--------|-----|
| `.DS_Store` | `.DS_Store` everywhere in the tree ✓ | — |
| `*.local` | `foo.local`, `gitconfig.local` ✓ | `settings.local.json` not covered, but Claude Code writes it to `~/.claude/` not `~/.dotfiles/claude/` — no real gap |
| `.env` | `.env` ✓ | — |
| `.env.*` | `.env.local`, `.env.production` ✓ | — |
| `*.secret` | `foo.secret` ✓ | — |

**Status:** All patterns correct. `claude/settings.local.json` was added then removed after
cross-referencing with symlinks — Claude Code writes that file to `~/.claude/` (the config dir),
not alongside the resolved symlink target in `~/.dotfiles/claude/`.

---

## Step 2 — Tracked binary/generated artifacts

`.vsix` files are committed to the repo (`vscode-themes/*/tw-*.vsix`).
README documents this as intentional: VSIXs are the distribution artifact and
can't be scripted away. No action needed.

**Status:** OK (intentional, documented).

---

## Step 3 — Repo symlinks: absolute vs relative

Both symlinks committed to git use hardcoded absolute paths that embed the
current machine's username. They will silently break on any machine where the
home directory path differs.

| Symlink | Current target | Required |
|---------|---------------|---------|
| `starship/starship.toml` | `/Users/trenton.willard/.dotfiles/starship/neon-sign-muted.toml` | `neon-sign-muted.toml` (relative) |
| `themes/active` | `/Users/trenton.willard/.dotfiles/themes/neon-sign-muted` | `neon-sign-muted` (relative) |

**Fix:** Recreate both as relative symlinks.

---

## Step 4 — On-disk symlinks: resolve check

Every symlink that `setup.sh` creates, verified on disk.

| Path | Status |
|------|--------|
| `~/.zshrc` | OK |
| `~/.gitconfig` | OK |
| `~/.gitignore_global` | OK |
| `~/.config/mise/config.toml` | OK |
| `~/Library/Application Support/Code/User/settings.json` | OK |
| `~/.config/ghostty/config` | OK |
| `~/.config/ghostty/themes/neon-sign` | OK |
| `~/.config/ghostty/themes/neon-sign-muted` | OK |
| `~/.config/aerospace/aerospace.toml` | OK |
| `~/.config/starship.toml` | OK |
| `~/.claude/CLAUDE.md` | OK |
| `~/.claude/settings.json` | **NOT A SYMLINK** — plain file, not wired to dotfiles |

**Fix:** Copy `~/.claude/settings.json` to `dotfiles/claude/settings.json`, add symlink
to `setup.sh`, replace the plain file with the symlink.

---

## Step 5 — `setup.sh` completeness

Files in dotfiles that should be symlinked but are missing from `setup.sh`:

- `claude/settings.json` — no symlink entry, no `mkdir -p ~/.claude/themes`
- `claude/themes/` — directory and per-theme symlinks not yet in script
  (blocked on design-todo.md; stub the `mkdir` now)

**Fix:** Add `settings.json` symlink. Add `mkdir -p "$HOME/.claude/themes"` as a
forward-compatible stub. Theme symlinks land when design-todo is resolved.

---

## Step 6 — `setup.sh` accuracy

Every symlink target path listed in `setup.sh` was verified to exist in dotfiles.
All present. No stale paths.

**Status:** OK.

---

## Step 7 — `theme-switch.sh` correctness

- No stale theme references — catppuccin-mocha and tokyodark cases were already
  removed in the last pull. ✓
- All current themes (neon-sign, neon-sign-muted) have Ghostty and VS Code entries. ✓
- **Missing:** No Claude Code theme step. When `claude/themes/` lands, switching
  theme won't update Claude Code.

**Fix:** Add a Claude case block that updates the `theme` key in
`claude/settings.json` via `sed`.

---

## Step 8 — Submodule health

`git submodule status` shows `-` prefix for `claude/guidelines/karpathy`, meaning
the submodule is listed in `.gitmodules` but not initialized in `.git/config`.
Root cause: `.git/config` has it registered under the old path
`claude/skills/karpathy` (stale from a previous location), not the current
`claude/guidelines/karpathy`.

The directory has content (cloned with `--recurse-submodules`), so it works now,
but `git submodule update --remote` will not work correctly until fixed.

**Fix:** Run `git submodule sync && git submodule init` to re-register from
`.gitmodules`.

---

## Step 9 — README accuracy

Structure tree in README matches current files on disk with two omissions:

- `claude/settings.json` — not listed under `claude/`
- `design-todo.md` — not listed at repo root

**Fix:** Add both entries to the README structure section.

---

## Step 10 — Untracked files

`design-todo.md` is untracked. All fixes from steps 1–9 should be committed
together in a single hardening commit.

**Fix:** Stage and commit everything.
