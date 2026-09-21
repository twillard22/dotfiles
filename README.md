# dotfiles

Personal dev environment — shell, git, mise, Homebrew packages, VSCode, Neovim, and agent config
for OpenCode (primary) and Claude Code (secondary).

## Structure

```
.dotfiles/
  Brewfile               ← all Homebrew formulae and casks
  setup.sh               ← run this on a new machine
  theme-switch.sh        ← switch all tools to a theme at once
  zsh/
    zshrc                ← symlinked to ~/.zshrc
  git/
    gitconfig            ← symlinked to ~/.gitconfig (includes ~/.gitconfig.local for per-machine identity)
    gitconfig.local.example  ← template — copy to ~/.gitconfig.local on each machine, NOT symlinked
  mise/
    config.toml          ← symlinked to ~/.config/mise/config.toml (node, bun, pnpm)
  ghostty/
    config               ← symlinked to ~/.config/ghostty/config
    themes/              ← custom Ghostty theme files, each symlinked to ~/.config/ghostty/themes/
  starship/
    starship.toml        ← symlink → active theme (managed by theme-switch.sh)
    neon-sign.toml
    neon-sign-muted.toml
  nvim/                  ← symlinked to ~/.config/nvim (LazyVim + neon-sign colorscheme)
    init.lua             ← LazyVim entry point
    lua/
      config/lazy.lua    ← lazy.nvim bootstrap
      neon-sign/         ← theme engine (shared by both colorscheme variants)
      plugins/
        neon-sign.lua    ← LazyVim spec; reads ~/.local/state/nvim/theme for active variant
    colors/
      neon-sign.lua      ← vivid palette entry point
      neon-sign-muted.lua ← muted palette entry point
  vscode/
    settings.json        ← symlinked to ~/Library/Application Support/Code/User/settings.json
  vscode-themes/         ← custom VS Code theme extensions, each symlinked to ~/.vscode/extensions/
    neon-sign/           ← copied from github.com/twillard22/neon-sign (see note in Themes section)
    neon-sign-muted/
  Neon Sign Preview.html ← combined theme preview (VS Code · Neovim · Ghostty/zsh · Claude)
  themes/                ← zsh theme files, sourced at shell startup
    active/              ← symlink → active theme dir (managed by theme-switch.sh)
    neon-sign/
      zsh-highlights.zsh
      zsh-autosuggest.zsh
    neon-sign-muted/
      zsh-highlights.zsh
      zsh-autosuggest.zsh
    NEW-THEME.md         ← template: paste into claude.ai to generate a new theme
  agents/                ← tool-neutral agent config (OpenCode is primary, Claude Code secondary)
    lib.sh               ← shared shell helpers, sourced by this repo's setup.sh and ~/.work-agents/setup.sh
    rules/
      00-engineering.md  ← generic rules, symlinked to ~/.claude/rules/00-engineering.md
    guidelines/          ← submodules linked into ~/.claude/rules/ under a numbered name
      karpathy/          ← submodule: github.com/multica-ai/andrej-karpathy-skills → ~/.claude/rules/10-karpathy.md
    skills/              ← invokable skills; every dir is symlinked to ~/.claude/skills/ (both tools read it)
    repos/               ← per-repo private notes; see agents/repos/README.md
    claude/
      CLAUDE.md          ← symlinked to ~/.claude/CLAUDE.md (Claude Code only)
      settings.json      ← symlinked to ~/.claude/settings.json (Claude Code only)
      themes/            ← Claude Code theme JSONs, symlinked to ~/.claude/themes/
    opencode/            ← see agents/opencode/README.md for the full how-to
      opencode.jsonc     ← symlinked to ~/.config/opencode/opencode.jsonc (providers, instructions, permissions)
      tui.json           ← template, copied once to ~/.config/opencode/tui.json (plugin rewrites it, so not a link)
      AGENTS.md          ← thin file, symlinked to ~/.config/opencode/AGENTS.md — rules live in ~/.claude/rules
      omo.jsonc          ← symlinked to ~/.omo/omo.jsonc (oh-my-openagent model routing)
      themes/            ← OpenCode theme JSONs, symlinked to ~/.config/opencode/themes/
      skill-template/    ← copy to start a new skill
  tests/
    setup-profiles.test.sh ← profile-gated setup.sh behaviour, run against a scratch HOME
```

## New machine setup

### 1. Xcode Command Line Tools

Git isn't available on a fresh Mac. Install the CLI tools first:

```bash
xcode-select --install
```

Wait for the installer to finish before continuing.

### 2. Clone this repo

Use HTTPS for the initial clone — no SSH key needed yet:

```bash
git clone --recurse-submodules https://github.com/twillard22/dotfiles ~/.dotfiles
```

### 3. Run setup.sh

```bash
cd ~/.dotfiles && ./setup.sh --profile personal
# or: ./setup.sh --profile work
```

After the first run, the `dotfiles` alias is available in your shell, and the profile is saved —
run `dotfiles` (bare, no flag) from anywhere to re-run setup with the same profile. See
`## Profiles` below for what each profile does.

This will:
- Install Homebrew (if not present)
- Install all packages from `Brewfile` (`brew bundle`) including starship, zsh plugins, neovim, lazygit, and Fira Code Nerd Font
- Run `git lfs install`
- Symlink `.zshrc`, `.gitconfig`, `mise/config.toml`, `starship.toml`, `ghostty/config`, `nvim/`, VSCode `settings.json`, and Claude config
- Link `~/.claude/rules/` (`00-engineering.md`, `10-karpathy.md`, and — on the work profile —
  `50-later.md`) and wire per-repo private-notes stubs via `agents/repos/`
- Seed `~/.local/state/nvim/theme` with `neon-sign-muted` (nvim reads this on startup to pick the active colorscheme)
- Configure `~/.gnupg/gpg-agent.conf` to use `pinentry-mac`
- Run `mise install` (node, bun, pnpm, ruby, yarn)
- Install custom theme VSIXs (neon-sign, neon-sign-muted) and Marketplace extensions (ESLint, Prettier)

### 4. Per-machine git identity

The shared `gitconfig` in this repo does NOT contain a signing key or email — those
are per-machine. The repo's `gitconfig` does `[include] path = ~/.gitconfig.local`,
so create that file on each machine:

```bash
cp ~/.dotfiles/git/gitconfig.local.example ~/.gitconfig.local
# then edit ~/.gitconfig.local and fill in this machine's email + signingkey
```

The signing key ID is whatever GPG key lives on this machine. To see it:

```bash
gpg --list-secret-keys --keyid-format=long
```

Register every machine's public GPG key on github.com → Settings → SSH and GPG keys
so commits from any machine show as Verified.

### 5. SSH key (optional)

If you want SSH instead of HTTPS for git remotes, generate a new key for this machine
and authorize it with GitHub:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
pbcopy < ~/.ssh/id_ed25519.pub
```

Then: github.com → Settings → SSH Keys → New SSH key → paste.

Switch the dotfiles remote to SSH:

```bash
git -C ~/.dotfiles remote set-url origin git@github.com:twillard22/dotfiles.git
```

### 6. OpenCode providers

API keys are stored by OpenCode outside the repo (`~/.local/share/opencode/auth.json`):

```
opencode auth login          # Anthropic platform key
opencode auth login          # OpenAI platform key
opencode models anthropic    # confirm the model IDs used in agents/opencode/*.jsonc
opencode models openai
```

Full details, first-run checklist, and the artifact smoke test: `agents/opencode/README.md`.

### 7. Manual steps

- **GPG key** — each machine has its own key. If you want to reuse an existing
  key, export it from the old machine and import on the new one:
  ```bash
  # On old machine (replace KEY_ID with that machine's key)
  gpg --export-secret-keys --armor KEY_ID > key.asc
  # On new machine
  gpg --import key.asc && shred -u key.asc
  ```
  Otherwise generate a fresh key with `gpg --full-generate-key` and register the
  public half on GitHub. Either way, put the resulting key ID into
  `~/.gitconfig.local` (see step 4). `gpg-agent.conf` is already configured by
  `setup.sh` — no extra step needed.

- **Android dev** (if needed):
  ```bash
  brew install --cask zulu@17
  brew install --cask android-studio
  # Then open Android Studio → SDK Manager to install the SDK
  ```

- **Default terminal** — set Ghostty as default: System Settings → Desktop & Dock → Default terminal app → Ghostty.

- **App-specific secrets** — `.env` files, API keys, etc. Set up per project.

---

## Profiles

`setup.sh` is profile-gated. The chosen profile is saved to `~/.config/agents/profile`, so a
bare `./setup.sh` (or the `dotfiles` alias) reuses it — it exits 1 if no profile has been saved
yet.

- **`--profile personal`** — links only this repo's rules, skills, and themes. It is a hard
  gate: even if `~/.work-agents` is present on disk, personal setup ignores it, purges
  `~/.config/agents/manifest.work` (see below), prunes any existing symlink under
  `~/.claude/rules`, `~/.claude/skills`, or `~/Documents` that resolves into `~/.work-agents`,
  prints a warning if `~/.work-agents` exists, and exits 0.
- **`--profile work`** — requires `~/.work-agents/setup.sh` to exist and be executable; exits 1
  naming the clone command otherwise. On success it calls that script, which links the Later
  rules, skills, per-repo stubs, and Documents symlinks described in
  `~/.work-agents/README.md`.

**The manifest.** Everything `~/.work-agents/setup.sh` creates that is not a plain symlink
resolving into `~/.work-agents` — the real one-line per-repo stub files, their paired OpenCode
symlinks, and any org skill (copied, not symlinked, by the `skills`
CLI) — gets recorded, one absolute path per line, in `~/.config/agents/manifest.work`.
Switching to `--profile personal` reads that manifest and removes every path it lists, then
deletes the manifest itself. That's how the copied org skill and the per-repo stubs — which
`prune_links_into` can't find because they aren't symlinks into `~/.work-agents` — get cleaned
up on a personal machine.

`DOTFILES_SKIP_INSTALL=1 ./setup.sh --profile personal` skips Homebrew, mise, GPG, `code`, and
Raycast — the tests use this to run setup against a scratch `HOME` without touching real
machine state.

## How rules load

Both tools read the same merged rules directory, `~/.claude/rules/`: Claude Code natively,
OpenCode via the `instructions` globs in `agents/opencode/opencode.jsonc`.

| File | Claude Code | OpenCode | Owner |
|---|---|---|---|
| `<repo>/AGENTS.md` | reads it walking up from cwd | reads it walking up from cwd | the repo (team-visible) |
| `<repo>/.claude/rules/*.md` | reads it | reads via `.claude/rules/*.md` glob | the repo |
| `~/.claude/rules/00-engineering.md` | reads the directory natively | reads via `~/.claude/rules/*.md` glob | dotfiles (`agents/rules/`) |
| `~/.claude/rules/10-karpathy.md` | same | same | dotfiles (`agents/guidelines/karpathy/` submodule) |
| `~/.claude/rules/50-later.md` | same (work profile only) | same (work profile only) | work-agents |
| `<repo>/.claude/rules/<layer>.local.md` + `<repo>/.opencode/rules/<layer>.local.md` | follows the `@~/...` import in the `.claude` stub | reads the `.opencode` copy directly | per-repo private notes (see below) |

## Per-repo private notes

A note that's true for one repo but not worth committing to that repo lives at
`agents/repos/<name>/{location,rules.md}` in the owning layer — personal notes here, work notes
in `~/.work-agents/agents/repos/<name>/`. `location` is a single `~/`-relative path to the
repo; `rules.md` is the note itself.

`setup.sh` turns each entry into two files inside the target repo: `.claude/rules/<layer>.local.md`,
a real file containing exactly one line, `@~/<layer-repo>/agents/repos/<name>/rules.md`, which
Claude Code follows as an import; and `.opencode/rules/<layer>.local.md`, a symlink to the same
`rules.md`, which OpenCode reads directly. Both are matched by the global gitignore, so they
never show up as untracked in the repo. The first time Claude Code sees the import line in a
given repo it asks "Allow external CLAUDE.md file imports?" — answer Yes.

Promote a private note by moving its content into `<repo>/AGENTS.md` and deleting the
`agents/repos/<name>` entry, then delete the two stubs by hand
(`rm <repo>/.claude/rules/<layer>.local.md <repo>/.opencode/rules/<layer>.local.md`);
`setup.sh` only creates stubs, it never removes one for an entry that no longer exists.
Restart OpenCode and Claude Code after any rules change so they pick up the new files.

---

## Themes

Themes cover all six tools simultaneously: VS Code, Ghostty, Starship, zsh-syntax-highlighting,
zsh-autosuggestions, and Claude Code. All theme files live in `.dotfiles` — no third-party extensions required.

### Switching themes

```bash
theme-switch neon-sign
theme-switch neon-sign-muted
```

### neon-sign and neon-sign-muted

These themes live in their own public repo: **[twillard22/neon-sign](https://github.com/twillard22/neon-sign)**

The theme files are **intentionally copied** into dotfiles rather than referenced as a submodule. Reasons:
- The VSIX files need to be built and committed here anyway — a submodule wouldn't eliminate the manual step
- Themes are stable once set; sync with the upstream repo is deliberate, not automatic
- Keeps setup.sh and theme-switch.sh path logic simple and flat

To sync after updating neon-sign:
```bash
# Copy updated files from the neon-sign repo, rebuild the VSIX, commit
cp ~/Development/neon-sign/ghostty/neon-sign ~/.dotfiles/ghostty/themes/neon-sign
cp ~/Development/neon-sign/ghostty/neon-sign-muted ~/.dotfiles/ghostty/themes/neon-sign-muted
cp ~/Development/neon-sign/starship/neon-sign.toml ~/.dotfiles/starship/
cp ~/Development/neon-sign/starship/neon-sign-muted.toml ~/.dotfiles/starship/
cp ~/Development/neon-sign/zsh/zsh-highlights.zsh ~/.dotfiles/themes/neon-sign/
cp ~/Development/neon-sign/zsh/zsh-autosuggest.zsh ~/.dotfiles/themes/neon-sign/
cp ~/Development/neon-sign/zsh/neon-sign-muted-highlights.zsh ~/.dotfiles/themes/neon-sign-muted/zsh-highlights.zsh
cp ~/Development/neon-sign/zsh/neon-sign-muted-autosuggest.zsh ~/.dotfiles/themes/neon-sign-muted/zsh-autosuggest.zsh
cp ~/Development/neon-sign/themes/neon-sign.json ~/.dotfiles/vscode-themes/neon-sign/themes/
cp ~/Development/neon-sign/themes/neon-sign-muted.json ~/.dotfiles/vscode-themes/neon-sign-muted/themes/
cp ~/Development/neon-sign/claude/neon-sign.json ~/.dotfiles/agents/claude/themes/neon-sign.json
cp ~/Development/neon-sign/claude/neon-sign-muted.json ~/.dotfiles/agents/claude/themes/neon-sign-muted.json
# Then rebuild VSIXs and commit
```

### Adding a new theme

1. Fill in `themes/NEW-THEME.md` with the theme name and color palette
2. Paste the filled-in file into claude.ai — it will generate all 5 config files
3. Drop the generated files into this repo and run (or ask Claude Code to do it):

```bash
# Place files, create package.json, package as VSIX, and install
# Full step-by-step in themes/NEW-THEME.md

# Short version:
cd vscode-themes/<name> && vsce package --allow-missing-repository
code --install-extension tw-<name>-1.0.0.vsix
ln -sf ~/.dotfiles/ghostty/themes/<name> ~/.config/ghostty/themes/<name>
theme-switch <name>
```

`themes/NEW-THEME.md` covers the VS Code, Ghostty, Starship, and zsh files. The agent
tools need three more steps it does not mention:

- `agents/claude/themes/<name>.json` for Claude Code (`{ "name", "base": "dark", "overrides": {…} }`)
  and `agents/opencode/themes/<name>.json` in OpenCode's `defs` + `theme` schema (copy an
  existing one; the two shapes differ).
- Add `<name>` case entries to the Claude Code and OpenCode blocks in `theme-switch.sh`.
  Claude Code needs the `custom:` prefix, which the script adds.
- Drop the file into `agents/claude/themes/` and run `setup.sh` — the themes loop links every
  file in that directory automatically (same for OpenCode themes) — then `theme-switch <name>`.

Or hand the generated files to an agent and say "add the `<name>` theme".

### VS Code extension packaging

Themes are distributed as `.vsix` files (publisher: `twillard22`) installed via
`code --install-extension`. The `.vsix` for each theme lives alongside its source in
`vscode-themes/<name>/`. To rebuild after editing a theme JSON:

```bash
cd ~/.dotfiles/vscode-themes/<name>
vsce package --allow-missing-repository
code --install-extension tw-<name>-1.0.0.vsix
```

### How it works

- **theme-switch.sh** updates six things atomically: `themes/active` symlink (zsh),
  `starship/starship.toml` symlink, `ghostty/config` theme line, `vscode/settings.json` colorTheme,
  `agents/claude/settings.json` theme (written as `custom:<slug>`, linked to
  `~/.claude/settings.json`), and `~/.local/state/nvim/theme`
  (nvim reads this state file on startup — running instances pick it up on next open)
- **zshrc** sources `themes/active/zsh-autosuggest.zsh` and `themes/active/zsh-highlights.zsh`
  before the plugin sources, so the active theme's colors are always loaded
- **Ghostty** reads `~/.config/ghostty/themes/<name>`, which is symlinked from `ghostty/themes/<name>`
- **VS Code** loads extensions from `~/.vscode/extensions/`, which are symlinked from `vscode-themes/`

---

## Maintaining the dotfiles

### Adding a Homebrew package

```bash
brew install <package>
# Add it to Brewfile manually, then commit
```

### Adding an always-loaded rule

Both tools read `~/.claude/rules/` (Claude Code natively, OpenCode via the `instructions`
globs in `agents/opencode/opencode.jsonc`), so there's one place to add a rule, not two.

**As a plain file:**
```bash
# Create agents/rules/NN-name.md (NN keeps load order predictable; 00-engineering.md is generic)
# Add one line to setup.sh's Claude section:
#   symlink "$DOTFILES/agents/rules/NN-name.md" "$HOME/.claude/rules/NN-name.md"
git add -A && git commit -m "add NN-name rule"
```

**From an external repo (submodule):** add it under `agents/guidelines/<name>/` and link its
`SKILL.md` (or equivalent) into `~/.claude/rules/NN-name.md` the same way — see how
`agents/guidelines/karpathy/` is wired to `10-karpathy.md` in `setup.sh`.

### Adding an invokable skill

Full walkthrough and the public-safe checklist: `agents/opencode/README.md`.

```bash
cp -R agents/opencode/skill-template agents/skills/<name>   # name: lowercase, hyphens
# edit agents/skills/<name>/SKILL.md — frontmatter `name` must equal the directory name
cd ~/.dotfiles && ./setup.sh                                 # links every dir automatically
git add -A && git commit -m "add <name> skill"
```

Later-specific skills go in `~/.work-agents/agents/skills/` instead (private repo).

### Updating guideline submodules

```bash
cd ~/.dotfiles && git submodule update --remote && git commit -am "update guidelines"
```

## Testing

```bash
bash tests/setup-profiles.test.sh
```

Runs `setup.sh` repeatedly against a scratch `HOME` (`DOTFILES_SKIP_INSTALL=1`, real machine
state untouched) covering both profiles, the personal hard gate, idempotency, and — when
`~/.work-agents` exists on this machine — the real work `setup.sh`. Prints `PASS <name>` per
scenario and `ALL PASS` at the end; any failure exits 1 with `FAIL <name>: <reason>`.
