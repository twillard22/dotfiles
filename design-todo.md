# Design To-Do

Tasks that require Claude.ai (design) to generate output files before wiring up in code.

---

## Claude Code custom themes

Generate `neon-sign.json` and `neon-sign-muted.json` for Claude Code's theme system.

**Prompt for claude.ai:**

> I want to create two Claude Code custom themes. Claude Code themes are JSON files saved to `~/.claude/themes/<slug>.json` with this format:
>
> ```json
> {
>   "name": "Display Name",
>   "base": "dark",
>   "overrides": {
>     "token": "#hexcolor"
>   }
> }
> ```
>
> Available color tokens: `claude`, `text`, `inverseText`, `inactive`, `subtle`, `suggestion`, `permission`, `remember`, `success`, `error`, `warning`, `merged`, `promptBorder`, `planMode`, `autoAccept`, `bashBorder`, `ide`, `fastMode`, `diffAdded`, `diffRemoved`, `diffAddedDimmed`, `diffRemovedDimmed`, `diffAddedWord`, `diffRemovedWord`, `userMessageBackground`, `userMessageBackgroundHover`, `messageActionsBackground`, `bashMessageBackgroundColor`, `memoryBackgroundColor`, `selectionBg`, `rate_limit_fill`, `rate_limit_empty`, `briefLabelYou`, `briefLabelClaude`
>
> The palettes are in `~/.dotfiles/ghostty/themes/neon-sign` and `~/.dotfiles/ghostty/themes/neon-sign-muted`.
> Map each palette to the token list semantically (green → success/diff added, red → error/diff removed,
> magenta → claude accent, yellow → warning/permission, purple → planMode/remember, etc.).
> Fill all tokens. Output two complete JSON files: `neon-sign.json` and `neon-sign-muted.json`.

**Once you have the files, hand them to Claude Code to:**
1. Place in `~/.dotfiles/claude/themes/neon-sign.json` and `neon-sign-muted.json`
2. Add symlinks to `setup.sh` (under the Claude section):
   ```bash
   mkdir -p "$HOME/.claude/themes"
   symlink "$DOTFILES/claude/themes/neon-sign.json" "$HOME/.claude/themes/neon-sign.json"
   symlink "$DOTFILES/claude/themes/neon-sign-muted.json" "$HOME/.claude/themes/neon-sign-muted.json"
   ```
3. Copy `~/.claude/settings.json` to `~/.dotfiles/claude/settings.json` and add its symlink to `setup.sh`
4. Add `claude/settings.local.json` to `.gitignore`
5. Run `setup.sh` to activate, then set theme with `/theme` in Claude Code
