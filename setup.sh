#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

symlink() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ]; then
    echo "  already linked: $dst"
  elif [ -e "$dst" ]; then
    echo "  WARNING: $dst exists and is not a symlink — skipping (move it manually)"
  else
    ln -s "$src" "$dst"
    echo "  linked: $dst → $src"
  fi
}

echo "==> Setting up dotfiles from $DOTFILES"

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "==> Installing Homebrew packages..."
brew bundle --file="$DOTFILES/Brewfile"
git lfs install

# ── Shell ─────────────────────────────────────────────────────────────────────
echo "==> Linking shell config..."
symlink "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"

# ── Git ───────────────────────────────────────────────────────────────────────
echo "==> Linking git config..."
symlink "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
symlink "$DOTFILES/git/gitignore_global" "$HOME/.gitignore_global"

# ── mise ──────────────────────────────────────────────────────────────────────
echo "==> Linking mise config..."
mkdir -p "$HOME/.config/mise"
symlink "$DOTFILES/mise/config.toml" "$HOME/.config/mise/config.toml"

echo "==> Installing mise tools (node, bun, pnpm, ruby, yarn)..."
mise trust "$DOTFILES/mise/config.toml"
mise install

# ── GPG ───────────────────────────────────────────────────────────────────────
echo "==> Configuring GPG agent..."
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"
PINENTRY="$(brew --prefix)/bin/pinentry-mac"
AGENT_CONF="$HOME/.gnupg/gpg-agent.conf"
if ! grep -q "pinentry-program" "$AGENT_CONF" 2>/dev/null; then
  # If the file exists without a trailing newline, `>>` merges the appended
  # line onto the previous one and gpg-agent silently ignores the directive.
  if [ -s "$AGENT_CONF" ] && [ -n "$(tail -c1 "$AGENT_CONF")" ]; then
    printf '\n' >> "$AGENT_CONF"
  fi
  echo "pinentry-program $PINENTRY" >> "$AGENT_CONF"
  echo "  wrote pinentry-program to $AGENT_CONF"
else
  echo "  gpg-agent.conf already configured"
fi

# ── VSCode ────────────────────────────────────────────────────────────────────
echo "==> Linking VSCode settings..."
mkdir -p "$HOME/Library/Application Support/Code/User"
symlink "$DOTFILES/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"

echo "==> Installing custom VSCode themes..."
code --install-extension "$DOTFILES/vscode-themes/neon-sign/tw-neon-sign-1.0.0.vsix"
code --install-extension "$DOTFILES/vscode-themes/neon-sign-muted/tw-neon-sign-muted-1.0.0.vsix"

echo "==> Installing VSCode extensions..."
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode

# ── Ghostty ───────────────────────────────────────────────────────────────────
echo "==> Linking Ghostty config..."
mkdir -p "$HOME/.config/ghostty/themes"
symlink "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
symlink "$DOTFILES/ghostty/themes/neon-sign" "$HOME/.config/ghostty/themes/neon-sign"
symlink "$DOTFILES/ghostty/themes/neon-sign-muted" "$HOME/.config/ghostty/themes/neon-sign-muted"

# ── Aerospace ─────────────────────────────────────────────────────────────────
echo "==> Linking Aerospace config..."
mkdir -p "$HOME/.config/aerospace"
symlink "$DOTFILES/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"

# ── Borders ───────────────────────────────────────────────────────────────────
echo "==> Linking Borders config..."
mkdir -p "$HOME/.config/borders"
if [ ! -e "$DOTFILES/borders/active" ]; then
  ln -sf "neon-sign-muted" "$DOTFILES/borders/active"
  echo "  borders/active → neon-sign-muted (default)"
fi
symlink "$DOTFILES/borders/active" "$HOME/.config/borders/bordersrc"

# ── Neovim ────────────────────────────────────────────────────────────────────
echo "==> Linking Neovim config..."
mkdir -p "$HOME/.config"
symlink "$DOTFILES/nvim" "$HOME/.config/nvim"
# Seed the theme state file if it doesn't exist yet
mkdir -p "$HOME/.local/state/nvim"
if [ ! -f "$HOME/.local/state/nvim/theme" ]; then
  echo "neon-sign-muted" > "$HOME/.local/state/nvim/theme"
  echo "  nvim theme state → neon-sign-muted (default)"
fi

# ── Starship ──────────────────────────────────────────────────────────────────
echo "==> Linking Starship config..."
mkdir -p "$HOME/.config"
symlink "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

# ── Claude ────────────────────────────────────────────────────────────────────
echo "==> Linking Claude config..."
mkdir -p "$HOME/.claude/skills"
mkdir -p "$HOME/.claude/themes"
symlink "$DOTFILES/agents/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
symlink "$DOTFILES/agents/themes/neon-sign.json" "$HOME/.claude/themes/neon-sign.json"
symlink "$DOTFILES/agents/themes/neon-sign-muted.json" "$HOME/.claude/themes/neon-sign-muted.json"

# Work-specific agent config (Later rules + skills) lives in a separate private repo, cloned to ~/.work-agents.
[ -x "$HOME/.work-agents/setup.sh" ] && "$HOME/.work-agents/setup.sh"

# Invokable skills: every directory under agents/skills/ is linked automatically.
# Both Claude Code and OpenCode read ~/.claude/skills, so one link serves both.
for skill in "$DOTFILES"/agents/skills/*/; do
  [ -d "$skill" ] || continue
  symlink "${skill%/}" "$HOME/.claude/skills/$(basename "$skill")"
done

# Global Claude settings (model, plugins, effort, tui, auto-memory, theme).
# Tracked + symlinked so it's shared across machines; per-machine overrides
# (permissions, etc.) live in the gitignored ~/.claude/settings.local.json.
symlink "$DOTFILES/agents/settings.json" "$HOME/.claude/settings.json"

# ── OpenCode ──────────────────────────────────────────────────────────────────
# Config, global AGENTS.md, themes, and oh-my-openagent routing are tracked in
# agents/opencode/ and linked file-by-file: the plugin installer writes node_modules
# and package.json into ~/.config/opencode, so the directory itself is never a link.
# Credentials never live here: `opencode auth login` stores them in
# ~/.local/share/opencode/auth.json. See agents/opencode/README.md.
echo "==> Linking OpenCode config..."
mkdir -p "$HOME/.config/opencode/themes" "$HOME/.omo"
symlink "$DOTFILES/agents/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
# tui.json is NOT linked: oh-my-openagent rewrites it in place (it adds itself to a
# `plugin` array), which replaces a symlink with a real file. Seed it from the tracked
# template once; theme-switch.sh keeps the theme key in sync afterwards.
if [ ! -e "$HOME/.config/opencode/tui.json" ]; then
  cp "$DOTFILES/agents/opencode/tui.json" "$HOME/.config/opencode/tui.json"
  echo "  seeded: ~/.config/opencode/tui.json from template"
fi
symlink "$DOTFILES/agents/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
symlink "$DOTFILES/agents/opencode/omo.jsonc" "$HOME/.omo/omo.jsonc"
for theme in "$DOTFILES"/agents/opencode/themes/*.json; do
  [ -f "$theme" ] || continue
  symlink "$theme" "$HOME/.config/opencode/themes/$(basename "$theme")"
done

# ── Themes ────────────────────────────────────────────────────────────────────
echo "==> Setting up themes..."
chmod +x "$DOTFILES/theme-switch.sh"
# Create themes/active symlink if it doesn't exist
if [ ! -e "$DOTFILES/themes/active" ]; then
  ln -sf "$DOTFILES/themes/neon-sign-muted" "$DOTFILES/themes/active"
  echo "  themes/active → neon-sign-muted (default)"
fi

# ── Raycast ───────────────────────────────────────────────────────────────────
echo "==> Importing Raycast settings..."
open -a Raycast "$DOTFILES/raycast/settings.rayconfig" 2>/dev/null || echo "  Raycast not installed — skipping"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "Done. Manual steps remaining:"
echo ""
echo "  1. GPG key — each machine has its own key. Generate a fresh one:"
echo "       gpg --full-generate-key"
echo "       Then add the key ID to ~/.gitconfig.local (see git/gitconfig.local.example)"
echo "       Or import from another machine: gpg --export-secret-keys --armor KEY_ID > key.asc"
echo "       then: gpg --import key.asc && shred -u key.asc"
echo ""
echo "  2. OpenCode providers (API keys are stored outside the repo):"
echo "       opencode auth login    # Anthropic, then again for OpenAI"
echo "       opencode models anthropic && opencode models openai   # verify the IDs in agents/opencode/*.jsonc"
echo ""
echo "  3. Android dev (if needed):"
echo "       Install Android Studio manually from https://developer.android.com/studio"
echo "       Install Zulu 17 JDK:  brew install --cask zulu@17"
echo "       Open Android Studio → SDK Manager to install the SDK"
echo ""
echo "  4. App-specific secrets (.env files, API keys) — set up per project"
