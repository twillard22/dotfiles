#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
THEME="${1:-}"

if [ -z "$THEME" ]; then
  THEME=$(ls "$DOTFILES/themes/" | grep -v active | grep -v '\.' | fzf \
    --prompt="  Theme: " \
    --height=~10 \
    --layout=reverse \
    --border=rounded \
    --border-label=" theme-switch " \
    --no-info \
    --color="border:#7199EE,label:#7199EE,prompt:#95C561,pointer:#EE6D85,hl:#EE6D85,hl+:#EE6D85")
  [ -z "$THEME" ] && exit 0
fi

if [ ! -d "$DOTFILES/themes/$THEME" ]; then
  echo "Unknown theme: $THEME"
  echo "Available: $(ls "$DOTFILES/themes/" | grep -v active | grep -v '\.md' | tr '\n' ' ')"
  exit 1
fi

echo "==> Switching to $THEME"

# Reinstall VS Code extension if VSIX exists (picks up any theme JSON changes)
VSIX=$(ls "$DOTFILES/vscode-themes/$THEME/"*.vsix 2>/dev/null | head -1)
if [ -n "$VSIX" ]; then
  code --install-extension "$VSIX" 2>/dev/null
  echo "  vscode ext →  tw-$THEME (reinstalled)"
fi

# zsh theme files
rm -f "$DOTFILES/themes/active"
ln -sf "$THEME" "$DOTFILES/themes/active"
echo "  zsh theme  →  themes/$THEME"

# Starship
rm -f "$DOTFILES/starship/starship.toml"
ln -sf "$THEME.toml" "$DOTFILES/starship/starship.toml"
echo "  starship   →  starship/$THEME.toml"

# Ghostty
case "$THEME" in
  neon-sign)        GHOSTTY_THEME="neon-sign" ;;
  neon-sign-muted)  GHOSTTY_THEME="neon-sign-muted" ;;
  *) echo "  WARNING: no Ghostty mapping for $THEME — skipping"; GHOSTTY_THEME="" ;;
esac
if [ -n "$GHOSTTY_THEME" ]; then
  sed -i '' "s|^theme = .*|theme = $GHOSTTY_THEME|" "$DOTFILES/ghostty/config"
  echo "  ghostty    →  $GHOSTTY_THEME"
fi

# VS Code
case "$THEME" in
  neon-sign)        VSCODE_THEME="Neon Sign" ;;
  neon-sign-muted)  VSCODE_THEME="Neon Sign Muted" ;;
  *) echo "  WARNING: no VS Code mapping for $THEME — skipping"; VSCODE_THEME="" ;;
esac
if [ -n "$VSCODE_THEME" ]; then
  sed -i '' "s|\"workbench.colorTheme\": \".*\"|\"workbench.colorTheme\": \"$VSCODE_THEME\"|" "$DOTFILES/vscode/settings.json"
  echo "  vscode     →  $VSCODE_THEME"
fi

# Claude Code (writes active theme into the tracked agents/claude/settings.json, which is
# symlinked to ~/.claude/settings.json — edit the repo file so the symlink stays intact)
case "$THEME" in
  neon-sign)        CLAUDE_THEME="neon-sign" ;;
  neon-sign-muted)  CLAUDE_THEME="neon-sign-muted" ;;
  *) echo "  WARNING: no Claude Code mapping for $THEME — skipping"; CLAUDE_THEME="" ;;
esac
if [ -n "$CLAUDE_THEME" ]; then
  CLAUDE_SETTINGS="$DOTFILES/agents/claude/settings.json"
  if [ -f "$CLAUDE_SETTINGS" ]; then
    sed -i '' "s|\"theme\": \".*\"|\"theme\": \"custom:$CLAUDE_THEME\"|" "$CLAUDE_SETTINGS"
    echo "  claude     →  $CLAUDE_THEME"
  else
    echo "  WARNING: $CLAUDE_SETTINGS not found — skipping Claude theme"
  fi
fi

# OpenCode (~/.config/opencode/tui.json is a plugin-managed copy, not a symlink — see
# setup.sh — so write both it and the tracked template agents/opencode/tui.json; theme
# names match the files in agents/opencode/themes/; OpenCode picks the change up on next launch)
case "$THEME" in
  neon-sign)        OPENCODE_THEME="neon-sign" ;;
  neon-sign-muted)  OPENCODE_THEME="neon-sign-muted" ;;
  *) echo "  WARNING: no OpenCode mapping for $THEME — skipping"; OPENCODE_THEME="" ;;
esac
if [ -n "$OPENCODE_THEME" ]; then
  # the live file is plugin-managed (not a symlink); update it and the tracked template
  for OPENCODE_TUI in "$HOME/.config/opencode/tui.json" "$DOTFILES/agents/opencode/tui.json"; do
    if [ -f "$OPENCODE_TUI" ]; then
      if grep -q '"theme":' "$OPENCODE_TUI"; then
        sed -i '' "s|\"theme\": \".*\"|\"theme\": \"$OPENCODE_THEME\"|" "$OPENCODE_TUI"
      else
        sed -i '' "s|^{|{\n  \"theme\": \"$OPENCODE_THEME\",|" "$OPENCODE_TUI"
      fi
    fi
  done
  echo "  opencode   →  $OPENCODE_THEME"
fi

# Neovim (writes state file; running instances pick it up on next open)
case "$THEME" in
  neon-sign)        NVIM_THEME="neon-sign" ;;
  neon-sign-muted)  NVIM_THEME="neon-sign-muted" ;;
  *) echo "  WARNING: no Neovim mapping for $THEME — skipping"; NVIM_THEME="" ;;
esac
if [ -n "$NVIM_THEME" ]; then
  mkdir -p "$HOME/.local/state/nvim"
  echo "$NVIM_THEME" > "$HOME/.local/state/nvim/theme"
  echo "  nvim       →  $NVIM_THEME"
fi

# Borders
case "$THEME" in
  neon-sign)        BORDERS_THEME="neon-sign" ;;
  neon-sign-muted)  BORDERS_THEME="neon-sign-muted" ;;
  *) echo "  WARNING: no borders mapping for $THEME — skipping"; BORDERS_THEME="" ;;
esac
if [ -n "$BORDERS_THEME" ]; then
  rm -f "$DOTFILES/borders/active"
  ln -sf "$BORDERS_THEME" "$DOTFILES/borders/active"
  pkill borders 2>/dev/null || true
  borders &
  echo "  borders    →  $BORDERS_THEME"
fi

echo ""
echo "Done. Open a new shell for zsh changes. Restart Ghostty for terminal changes."
