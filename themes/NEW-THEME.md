# New Theme Generation Brief

Use this template to generate a new theme for the full dev environment.
Paste the whole file into claude.ai. Two modes:

**From scratch** — fill in the Theme Name and Vibe sections only. Leave the Palette table empty.
Claude will design the full color palette and generate all 5 files.

**From a palette** — fill in the Theme Name and the Palette table with your hex values.
Claude will map the palette to all 5 files.

---

## Theme Name

**Name:** `neon-sign`
**Display name:** `Neon Sign`

---

## Vibe (from-scratch mode only)

Describe the aesthetic. Examples:
- "Warm and earthy — muted oranges, browns, deep forest greens on a dark brown background"
- "High contrast neon cyberpunk — electric blues and magentas on near-black"
- "Muted pastel, inspired by a rainy afternoon — desaturated colors, nothing too bright"
- "Inspired by a Tokyo night skyline — deep navy, neon pink and cyan accents"

**Vibe:** `Neon sign / cyberpunk bar — near-black background with deep violet undertones, vivid neon syntax colors that genuinely pop: hot pink keywords, electric green functions, violet types, cyan variables, amber strings, orange numbers, magenta specials. Think the glow of neon tubes against dark glass. High contrast but not fatiguing — colors should be saturated and punchy, not screaming max-brightness. Each syntax role should be instantly visually distinct at a glance.`

If designing from scratch, pick colors that:
- Have sufficient contrast (WCAG AA minimum) between foreground and background
- Use distinct enough hues that keywords, strings, functions, and types are visually separable at a glance
- Feel cohesive — accent colors should feel like they belong to the same palette
- Follow the dark theme convention: backgrounds #0d–#2a range, foreground #90–#d0 range

---

## Palette

**Name:** `<theme-name>` (lowercase-hyphenated, e.g. `nord`, `gruvbox-dark`, `rose-pine`)
**Display name:** `<Display Name>` (how it appears in VS Code picker, e.g. `Nord`, `Gruvbox Dark`)

---

## Palette

Define all colors with their semantic role. Every theme needs at least these:

| Token         | Hex     | Role                                              |
|---------------|---------|---------------------------------------------------|
| `bg_darkest`  |         | Deepest bg — terminal black, title bar            |
| `bg_main`     |         | Main editor background                            |
| `bg_raised`   |         | Sidebar, inactive tabs, activity bar              |
| `bg_highlight`|         | Line highlight, active selection                  |
| `bg_subtle`   |         | Word highlight, indent guides                     |
| `border`      |         | Borders, separators, line numbers (inactive)      |
| `fg`          |         | Default text                                      |
| `fg_dim`      |         | Comments, placeholder text, inactive items        |
| `keyword`     |         | Keywords, control flow, operators                 |
| `function`    |         | Function and method names                         |
| `type`        |         | Types, classes, interfaces                        |
| `variable`    |         | Variables, parameters, properties                 |
| `string`      |         | Strings                                           |
| `number`      |         | Numbers, booleans, constants                      |
| `special`     |         | Macros, decorators, built-ins, labels             |
| `accent`      |         | Active tab border, panel title border, badges     |
| `error`       |         | Errors, deleted git                               |
| `warning`     |         | Warnings                                          |
| `info`        |         | Info diagnostics, modified git                    |
| `success`     |         | Added git                                         |

---

## Syntax Intent (fill in or adjust)

If the palette colors above map cleanly to syntax roles, describe any non-obvious choices here.
Example: "strings use `success` rather than a dedicated color because the green reads better at this saturation."

---

## Output Required

Generate all five of the following files. Use the palette tokens above — no hardcoded colors in
explanations, only in the actual file content.

---

### 1. VS Code theme JSON
**File:** `vscode-themes/<theme-name>/themes/<theme-name>.json`

Full VS Code color theme. Match the structure of the existing themes exactly:
- Top-level: `name`, `type: "dark"`, `semanticHighlighting: true`, `colors`, `tokenColors`, `semanticTokenColors`
- `colors`: all workbench UI keys (editor, tabs, sidebar, activity bar, status bar, title bar, terminal ANSI,
  panel, widgets, input, lists, scrollbar, buttons, badges, focus, notifications, peek view, diff, git decorations)
- `tokenColors`: one entry per syntax concept with named `scope` arrays
- `semanticTokenColors`: flat object with semantic token type keys

Reference the catppuccin-mocha theme for the full list of required keys.

---

### 2. Ghostty theme file
**File:** `ghostty/themes/<theme-name>`

Format:
```
# <Display Name> — Ghostty theme

background = <bg_main>
foreground = <fg>

cursor-color = <fg>
cursor-text  = <bg_main>

selection-background = <bg_highlight>
selection-foreground = <fg>

palette = 0=<bg_darkest>
palette = 1=<error>
palette = 2=<success>
palette = 3=<warning>
palette = 4=<info>
palette = 5=<special>
palette = 6=<type or teal-equivalent>
palette = 7=<fg_dim or subtext>
palette = 8=<bg_subtle>
palette = 9=<error>
palette = 10=<success>
palette = 11=<warning>
palette = 12=<info>
palette = 13=<special>
palette = 14=<type or teal-equivalent>
palette = 15=<fg>
```

---

### 3. Starship config
**File:** `starship/<theme-name>.toml`

Full Starship config: copy the icon/symbol blocks verbatim from the reference below, then add
`style` settings to the modules listed. Use hex color values directly (no palette variables).

**Modules that need style:**
- `[character]` — `success_symbol`, `error_symbol`
- `[directory]` — `style`, `read_only_style`
- `[git_branch]` — `style`
- `[git_commit]` — `style`
- `[git_status]` — `style`
- `[git_state]` — `style`
- `[cmd_duration]` — `style`
- `[username]` — `style_user`, `style_root`
- `[hostname]` — `style`
- `[nodejs]`, `[python]`, `[rust]`, `[golang]`, `[package]`, `[time]` — `style`
- `[[battery.display]]` charging/warning/critical — `style`

**Icon/symbol reference** (copy verbatim, do not change):
```toml
[aws]
symbol = " "
[azure]
symbol = " "
[battery]
full_symbol = "󰁹 "
charging_symbol = "󰂄 "
discharging_symbol = "󰂃 "
unknown_symbol = "󰂑 "
empty_symbol = "󰂎 "
[buf]
symbol = " "
[bun]
symbol = " "
[c]
symbol = " "
[cpp]
symbol = " "
[cmake]
symbol = " "
[cobol]
symbol = " "
[conda]
symbol = " "
[container]
symbol = " "
[crystal]
symbol = " "
[dart]
symbol = " "
[deno]
symbol = " "
[direnv]
symbol = " "
[directory]
read_only = " 󰌾"
[docker_context]
symbol = " "
[dotnet]
symbol = " "
[elixir]
symbol = " "
[elm]
symbol = " "
[erlang]
symbol = " "
[fennel]
symbol = " "
[fortran]
symbol = " "
[fossil_branch]
symbol = " "
[gcloud]
symbol = "󱇶 "
[gleam]
symbol = " "
[git_branch]
symbol = " "
[git_commit]
tag_symbol = '  '
[golang]
symbol = " "
[gradle]
symbol = " "
[guix_shell]
symbol = " "
[haskell]
symbol = " "
[haxe]
symbol = " "
[helm]
symbol = " "
[hg_branch]
symbol = " "
[hostname]
ssh_symbol = " "
[java]
symbol = " "
[julia]
symbol = " "
[kotlin]
symbol = " "
[kubernetes]
symbol = "󱃾 "
[lua]
symbol = " "
[maven]
symbol = " "
[memory_usage]
symbol = "󰍛 "
[meson]
symbol = "󰔷 "
[mojo]
symbol = "󰈸 "
[nats]
symbol = " "
[netns]
symbol = "󰛳 "
[nim]
symbol = " "
[nix_shell]
symbol = " "
[nodejs]
symbol = " "
[ocaml]
symbol = " "
[odin]
symbol = "󰟢 "
[opa]
symbol = " "
[openstack]
symbol = " "
[os.symbols]
AIX = " "
AlmaLinux = " "
Alpaquita = " "
Alpine = " "
ALTLinux = " "
Amazon = " "
Android = " "
AOSC = " "
Arch = " "
Artix = " "
Bluefin = " "
CachyOS = " "
CentOS = " "
Debian = " "
DragonFly = " "
Elementary = " "
Emscripten = " "
EndeavourOS = " "
Fedora = " "
FreeBSD = " "
Garuda = " "
Gentoo = " "
HardenedBSD = "󰞌 "
Illumos = " "
InstantOS = " "
Ios = "󰀷 "
Kali = " "
Linux = " "
Mabox = " "
Macos = " "
Manjaro = " "
Mariner = " "
MidnightBSD = " "
Mint = " "
NetBSD = " "
NixOS = " "
Nobara = " "
OpenBSD = " "
OpenCloudOS = " "
openEuler = " "
openSUSE = " "
OracleLinux = "󰺡 "
PikaOS = " "
Pop = " "
Raspbian = " "
Redhat = "󱄛 "
RedHatEnterprise = "󱄛 "
Redox = "󰀘 "
RockyLinux = " "
Solus = " "
SUSE = " "
Ubuntu = " "
Ultramarine = " "
Unknown = " "
Uos = " "
Void = " "
Windows = "󰍲 "
Zorin = " "
[package]
symbol = "󰏗 "
[perl]
symbol = " "
[php]
symbol = " "
[pijul_channel]
symbol = " "
[pixi]
symbol = "󰏗 "
[pulumi]
symbol = " "
[purescript]
symbol = " "
[python]
symbol = " "
[raku]
symbol = "󱖊 "
[red]
symbol = "󱍼 "
[rlang]
symbol = "󰟔 "
[ruby]
symbol = " "
[rust]
symbol = "󱘗 "
[scala]
symbol = " "
[shlvl]
symbol = "󰹍 "
[singularity]
symbol = " "
[solidity]
symbol = " "
[spack]
symbol = " "
[status]
symbol = " "
[sudo]
symbol = " "
[swift]
symbol = " "
[terraform]
symbol = " "
[vlang]
symbol = " "
[typst]
symbol = " "
[vagrant]
symbol = " "
[xmake]
symbol = " "
[zig]
symbol = " "
```

---

### 4. zsh-syntax-highlighting
**File:** `themes/<theme-name>/zsh-highlights.zsh`

Format:
```zsh
# <Display Name> — zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[comment]='fg=<fg_dim>'
ZSH_HIGHLIGHT_STYLES[alias]='fg=<function>'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=<function>'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=<function>'
ZSH_HIGHLIGHT_STYLES[function]='fg=<function>'
ZSH_HIGHLIGHT_STYLES[command]='fg=<function>'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=<special>,italic'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=<variable>,italic'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=<variable>'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=<variable>'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=<special>'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=<type>'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=<keyword>'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=<function>'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=<keyword>'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=<fg>'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=<fg>'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=<fg>'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=<keyword>'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=<keyword>'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=<keyword>'
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='fg=<string>'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=<string>'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=<string>'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=<variable>'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=<string>'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=<variable>'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=<string>'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=<fg>'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=<variable>'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=<fg>'
ZSH_HIGHLIGHT_STYLES[assign]='fg=<fg>'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=<type>'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=<type>'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=<variable>'
ZSH_HIGHLIGHT_STYLES[path]='fg=<fg>,underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=<keyword>,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=<fg>,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=<keyword>,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=<variable>'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=<special>'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=<variable>'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=<keyword>'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=<fg>'
ZSH_HIGHLIGHT_STYLES[default]='fg=<fg>'
ZSH_HIGHLIGHT_STYLES[cursor]='fg=<fg>'
```

---

### 5. zsh-autosuggestions
**File:** `themes/<theme-name>/zsh-autosuggest.zsh`

One line — use `fg_dim` or the dimmest non-background color:
```zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=<fg_dim>'
```

---

### 6. theme-switch.sh additions

Two new case entries to add to `~/dotfiles/theme-switch.sh` — one for the Ghostty block, one for VS Code:

```bash
# In the Ghostty case block:
<theme-name>) GHOSTTY_THEME="<theme-name>" ;;

# In the VS Code case block:
<theme-name>) VSCODE_THEME="<Display Name>" ;;
```

---

## Adding to dotfiles after generation

The easiest path: hand all the generated files to Claude Code and say "add the `<theme-name>` theme" — it knows the full structure and will do every step below.

To do it manually:

```bash
# 1. Place the generated files
mkdir -p ~/dotfiles/vscode-themes/<name>/themes
mkdir -p ~/dotfiles/themes/<name>

cp <name>-vscode.json      ~/dotfiles/vscode-themes/<name>/themes/<name>.json
cp <name>-ghostty          ~/dotfiles/ghostty/themes/<name>
cp <name>-starship.toml    ~/dotfiles/starship/<name>.toml
cp <name>-zsh-highlights.zsh  ~/dotfiles/themes/<name>/zsh-highlights.zsh
cp <name>-zsh-autosuggest.zsh ~/dotfiles/themes/<name>/zsh-autosuggest.zsh

# 2. Create the VS Code extension package.json
cat > ~/dotfiles/vscode-themes/<name>/package.json <<EOF
{
  "name": "tw-<name>",
  "displayName": "<Display Name>",
  "description": "<Description>. Part of the twillard22 dotfiles theme system.",
  "publisher": "twillard22",
  "version": "1.0.0",
  "engines": { "vscode": "^1.60.0" },
  "categories": ["Themes"],
  "contributes": {
    "themes": [
      {
        "label": "<Display Name>",
        "uiTheme": "vs-dark",
        "path": "./themes/<name>.json"
      }
    ]
  }
}
EOF

# 3. Package and install the VS Code extension
cd ~/dotfiles/vscode-themes/<name>
vsce package --allow-missing-repository
code --install-extension tw-<name>-1.0.0.vsix

# 4. Symlink the Ghostty theme
ln -sf ~/dotfiles/ghostty/themes/<name> ~/.config/ghostty/themes/<name>

# 5. Add two case entries to theme-switch.sh
#    In the Ghostty block:  <name>) GHOSTTY_THEME="<name>" ;;
#    In the VS Code block:  <name>) VSCODE_THEME="<Display Name>" ;;

# 6. Add to setup.sh VS Code install block:
#    code --install-extension "$DOTFILES/vscode-themes/<name>/tw-<name>-1.0.0.vsix"

# 7. Switch to it
theme-switch <name>
```
