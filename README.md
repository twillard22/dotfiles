# dotfiles

Personal dev environment — shell, git, mise, Homebrew packages, VSCode, Neovim, and Claude Code config.

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
    opencode/            ← see agents/opencode/README.md for the full how-to
      opencode.jsonc     ← symlinked to ~/.config/opencode/opencode.jsonc (providers, instructions, permissions)
      tui.json           ← symlinked to ~/.config/opencode/tui.json (theme)
      AGENTS.md          ← symlinked to ~/.config/opencode/AGENTS.md (global rules)
      omo.jsonc          ← symlinked to ~/.omo/omo.jsonc (oh-my-openagent model routing)
      themes/            ← OpenCode theme JSONs, symlinked to ~/.config/opencode/themes/
      skill-template/    ← copy to start a new skill
    skills/              ← invokable skills; every dir is symlinked to ~/.claude/skills/ (both tools read it)
    guidelines/          ← always-loaded guidelines (OpenCode: `instructions` in opencode.jsonc; Claude: @path)
      karpathy/          ← submodule: github.com/multica-ai/andrej-karpathy-skills
    CLAUDE.md            ← symlinked to ~/.claude/CLAUDE.md (Claude Code only)
    settings.json        ← symlinked to ~/.claude/settings.json (Claude Code only)
    themes/              ← Claude Code theme JSONs, symlinked to ~/.claude/themes/
  design-todo.md         ← tasks requiring claude.ai design credits to complete
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
cd ~/.dotfiles && ./setup.sh
```

After the first run, the `dotfiles` alias is available in your shell — run `dotfiles` from anywhere to re-run setup.

This will:
- Install Homebrew (if not present)
- Install all packages from `Brewfile` (`brew bundle`) including starship, zsh plugins, neovim, lazygit, and Fira Code Nerd Font
- Run `git lfs install`
- Symlink `.zshrc`, `.gitconfig`, `mise/config.toml`, `starship.toml`, `ghostty/config`, `nvim/`, VSCode `settings.json`, and Claude config
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
cp ~/Development/neon-sign/claude/neon-sign.json ~/.dotfiles/agents/themes/neon-sign.json
cp ~/Development/neon-sign/claude/neon-sign-muted.json ~/.dotfiles/agents/themes/neon-sign-muted.json
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

Or hand the generated files to Claude Code and say "add the `<name>` theme" —
it knows the full structure and will handle every step.

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
  `~/.claude/settings.json` theme (written as `custom:<slug>`), and `~/.local/state/nvim/theme`
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

### Adding an always-loaded guideline

OpenCode loads guidelines from the `instructions` array in `agents/opencode/opencode.jsonc`
(absolute paths or globs). Claude Code loads them via `@path` lines at the top of
`agents/CLAUDE.md`. Add to both while both tools are installed.

**From an external repo (submodule):**
```bash
cd ~/.dotfiles
git submodule add <url> agents/guidelines/<name>
# Add the absolute path to `instructions` in agents/opencode/opencode.jsonc
# Add @guidelines/<name>/path/to/SKILL.md to agents/CLAUDE.md
git add -A && git commit -m "add <name> guideline"
```

**As a plain file:**
```bash
# Create agents/guidelines/<name>.md
# Add @guidelines/<name>.md to agents/CLAUDE.md
git add -A && git commit -m "add <name> guideline"
```

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
