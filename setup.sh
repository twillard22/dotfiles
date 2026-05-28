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

# ── Starship ──────────────────────────────────────────────────────────────────
echo "==> Linking Starship config..."
mkdir -p "$HOME/.config"
symlink "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

# ── Claude ────────────────────────────────────────────────────────────────────
echo "==> Linking Claude config..."
mkdir -p "$HOME/.claude/skills"
mkdir -p "$HOME/.claude/themes"
symlink "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
symlink "$DOTFILES/claude/themes/neon-sign.json" "$HOME/.claude/themes/neon-sign.json"
symlink "$DOTFILES/claude/themes/neon-sign-muted.json" "$HOME/.claude/themes/neon-sign-muted.json"

# Invokable skills — add one line per skill in claude/skills/
# symlink "$DOTFILES/claude/skills/tanstack-start-setup" "$HOME/.claude/skills/tanstack-start-setup"

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
echo "  2. Claude Code plugins (run once inside Claude Code):"
echo "       /plugin install supabase@claude-plugins-official"
echo "       /plugin install figma@claude-plugins-official"
echo ""
echo "  3. Android dev (if needed):"
echo "       Install Android Studio manually from https://developer.android.com/studio"
echo "       Install Zulu 17 JDK:  brew install --cask zulu@17"
echo "       Open Android Studio → SDK Manager to install the SDK"
echo ""
echo "  4. App-specific secrets (.env files, API keys) — set up per project"
