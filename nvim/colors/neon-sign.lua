-- Neon Sign — Neovim colorscheme (vivid)
-- Activate with:  :colorscheme neon-sign   (or in LazyVim, colorscheme = "neon-sign")
-- The palette below is the single source of truth — same hexes as the
-- VS Code / Ghostty / Starship / zsh members of the theme family.

require("neon-sign").load({
  name = "neon-sign",

  -- backgrounds & UI
  bg_darkest  = "#08040f", -- terminal black, sidebars, statusline
  bg_main     = "#0f0820", -- editor background
  bg_raised   = "#170d2c", -- floats, popups, inactive panels
  bg_highlight= "#2a1a4a", -- visual selection, active pmenu item
  bg_subtle   = "#1c1136", -- current line, indent guides, virtual text
  border      = "#2d1f4d", -- borders, separators

  fg          = "#e0d4f5", -- default text
  fg_mid      = "#9a87b8", -- punctuation, delimiters, muted UI text
  fg_dim      = "#6b5a8a", -- comments, inactive items
  line_nums   = "#3a2960", -- line numbers, whitespace, non-text

  -- syntax roles
  keyword     = "#ff3d8a", -- hot pink   — keywords, control flow, storage, tags
  func        = "#5dff8f", -- green      — functions, methods
  type        = "#b266ff", -- violet     — types, classes, namespaces
  variable    = "#5ee2ff", -- cyan       — variables, properties, fields
  string      = "#ffb547", -- amber      — strings, parameters
  number      = "#ff7a3d", -- orange     — numbers, booleans, constants
  special     = "#ff5edb", -- magenta    — operators, decorators, regex, this/self

  -- diagnostics
  error       = "#ff4d6d",
  warning     = "#ffb547",
  info        = "#5ee2ff",
  success     = "#5dff8f",
  hint        = "#5dff8f",

  -- diff backgrounds (low-alpha equivalents baked to opaque)
  diff_add    = "#13241c",
  diff_change = "#0f1a2e",
  diff_delete = "#2a1218",
  diff_text   = "#1c3a2a",

  -- terminal ANSI (0-15)
  term0  = "#08040f", term1  = "#ff4d6d", term2  = "#5dff8f", term3  = "#ffb547",
  term4  = "#5ee2ff", term5  = "#ff5edb", term6  = "#b266ff", term7  = "#c8b8e0",
  term8  = "#3a2960", term9  = "#ff6b85", term10 = "#7dffa8", term11 = "#ffc870",
  term12 = "#85ebff", term13 = "#ff85e2", term14 = "#c285ff", term15 = "#ffffff",
})
