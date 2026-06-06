-- Neon Sign Muted — Neovim colorscheme (muted)
-- Activate with:  :colorscheme neon-sign-muted
-- Same role mapping as neon-sign, lower saturation for long sessions.

require("neon-sign").load({
  name = "neon-sign-muted",

  -- backgrounds & UI
  bg_darkest  = "#161025",
  bg_main     = "#1e1830",
  bg_raised   = "#28203f",
  bg_highlight= "#3a2f55",
  bg_subtle   = "#2a2245",
  border      = "#3d3360",

  fg          = "#d8cee8",
  fg_mid      = "#b8a8d0",
  fg_dim      = "#8a7ba8",
  line_nums   = "#4d4275",

  -- syntax roles
  keyword     = "#e87aa8", -- rose       — keywords, control flow, storage, tags
  func        = "#8de0a5", -- sage green — functions, methods
  type        = "#b896d8", -- lilac      — types, classes, namespaces
  variable    = "#8fcde0", -- sky        — variables, properties, fields
  string      = "#e8c074", -- wheat      — strings, parameters
  number      = "#e89870", -- clay       — numbers, booleans, constants
  special     = "#d090c8", -- orchid     — operators, decorators, regex, this/self

  -- diagnostics
  error       = "#e87a8a",
  warning     = "#e8c074",
  info        = "#8fcde0",
  success     = "#8de0a5",
  hint        = "#8de0a5",

  -- diff backgrounds
  diff_add    = "#22382b",
  diff_change = "#23304a",
  diff_delete = "#382226",
  diff_text   = "#2e4a3a",

  -- terminal ANSI (0-15)
  term0  = "#161025", term1  = "#e87a8a", term2  = "#8de0a5", term3  = "#e8c074",
  term4  = "#8fcde0", term5  = "#d090c8", term6  = "#b896d8", term7  = "#b8a8d0",
  term8  = "#4d4275", term9  = "#f08fa0", term10 = "#a8e8bc", term11 = "#f0cf90",
  term12 = "#a8d8e8", term13 = "#dca8d4", term14 = "#cab0e0", term15 = "#f0e8fa",
})
