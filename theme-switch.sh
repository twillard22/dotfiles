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
ln -sf "$DOTFILES/themes/$THEME" "$DOTFILES/themes/active"
echo "  zsh theme  →  themes/$THEME"

# Starship
rm -f "$DOTFILES/starship/starship.toml"
ln -sf "$DOTFILES/starship/$THEME.toml" "$DOTFILES/starship/starship.toml"
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

echo ""
echo "Done. Open a new shell for zsh changes. Restart Ghostty for terminal changes."
