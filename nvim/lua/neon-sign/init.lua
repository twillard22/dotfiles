-- Neon Sign — Neovim / LazyVim colorscheme engine
-- ---------------------------------------------------------------------------
-- One engine, two palettes. The palette files in `colors/` build a color
-- table and call `require("neon-sign").load(palette)`. All semantic decisions
-- (which palette color maps to which syntax role, what is italic, etc.) live
-- here so `neon-sign` and `neon-sign-muted` behave identically.
--
-- Semantic decisions (matches the sibling VS Code / Ghostty / zsh themes):
--   • Comments .......... italic
--   • Keywords .......... NOT italic
--   • Functions/Types ... NOT bold
--   • Parameters ........ italic (the one extra italic the family uses)
--   • Current line ...... subtle background, no underline
--
-- Color → role (conventional, taken from the VS Code theme):
--   keyword  hot pink  → keywords, control flow, storage, operators*, tags
--   func     green     → functions, methods
--   type     violet    → types, classes, interfaces, namespaces, enums
--   variable cyan      → variables, properties, fields
--   string   amber     → strings, parameters(italic)
--   number   orange    → numbers, booleans, constants, enum members
--   special  magenta   → decorators, macros, regex, escapes, this/self, labels
--   comment  dim       → comments (italic)
-- ---------------------------------------------------------------------------

local M = {}

-- Per-user overrides: `vim.g.neon_sign = { italic_comments = false, ... }`
local defaults = {
  italic_comments = true,
  italic_parameters = true,
  italic_keywords = false,
  bold = false,            -- master switch — keep the theme flat & minimal
  transparent = false,     -- let the terminal background show through
  cursorline = true,       -- subtle highlight on the current line
  dim_inactive = false,    -- dim windows that don't have focus
}

local function opts()
  local o = vim.tbl_deep_extend("force", {}, defaults, vim.g.neon_sign or {})
  return o
end

-- Convenience: bold only fires when the master `bold` switch is on.
local function build_styles(c, o)
  local I = o.italic_comments and { italic = true } or {}
  local IP = o.italic_parameters and { italic = true } or {}
  local IK = o.italic_keywords and { italic = true } or {}
  local B = o.bold and { bold = true } or {}
  return I, IP, IK, B
end

function M.highlights(c, o)
  local I, IP, IK, B = build_styles(c, o)
  local bg = o.transparent and "NONE" or c.bg_main
  local bg_sidebar = o.transparent and "NONE" or c.bg_darkest
  local bg_float = o.transparent and "NONE" or c.bg_raised
  local cline = o.cursorline and c.bg_subtle or "NONE"

  local hl = {
    ----------------------------------------------------------------- editor UI
    Normal = { fg = c.fg, bg = bg },
    NormalNC = { fg = c.fg, bg = o.dim_inactive and c.bg_darkest or bg },
    NormalFloat = { fg = c.fg, bg = bg_float },
    FloatBorder = { fg = c.border, bg = bg_float },
    FloatTitle = { fg = c.keyword, bg = bg_float },
    ColorColumn = { bg = c.bg_subtle },
    Conceal = { fg = c.fg_dim },
    Cursor = { fg = c.bg_main, bg = c.special },
    lCursor = { fg = c.bg_main, bg = c.special },
    CursorIM = { fg = c.bg_main, bg = c.special },
    CursorColumn = { bg = cline },
    CursorLine = { bg = cline },
    Directory = { fg = c.variable },
    EndOfBuffer = { fg = c.bg_main },
    ErrorMsg = { fg = c.error },
    VertSplit = { fg = c.border },
    WinSeparator = { fg = c.border, bold = false },
    Folded = { fg = c.fg_dim, bg = c.bg_raised },
    FoldColumn = { fg = c.line_nums, bg = bg },
    SignColumn = { fg = c.line_nums, bg = bg },
    LineNr = { fg = c.line_nums },
    LineNrAbove = { fg = c.line_nums },
    LineNrBelow = { fg = c.line_nums },
    CursorLineNr = { fg = c.keyword },          -- bright pink, no bold
    CursorLineSign = { bg = cline },
    CursorLineFold = { bg = cline },
    MatchParen = { fg = c.special, bg = c.bg_highlight },
    ModeMsg = { fg = c.fg_mid },
    MsgArea = { fg = c.fg_mid },
    MoreMsg = { fg = c.func },
    NonText = { fg = c.line_nums },
    Pmenu = { fg = c.fg, bg = c.bg_raised },
    PmenuSel = { fg = c.fg, bg = c.bg_highlight },
    PmenuSbar = { bg = c.bg_raised },
    PmenuThumb = { bg = c.bg_highlight },
    Question = { fg = c.func },
    QuickFixLine = { bg = c.bg_highlight },
    Search = { fg = c.bg_main, bg = c.keyword },
    IncSearch = { fg = c.bg_main, bg = c.special },
    CurSearch = { fg = c.bg_main, bg = c.special },
    SpecialKey = { fg = c.line_nums },
    SpellBad = { sp = c.error, undercurl = true },
    SpellCap = { sp = c.warning, undercurl = true },
    SpellLocal = { sp = c.info, undercurl = true },
    SpellRare = { sp = c.special, undercurl = true },
    StatusLine = { fg = c.fg_mid, bg = c.bg_darkest },
    StatusLineNC = { fg = c.fg_dim, bg = c.bg_darkest },
    TabLine = { fg = c.fg_dim, bg = c.bg_darkest },
    TabLineFill = { bg = c.bg_darkest },
    TabLineSel = { fg = c.fg, bg = c.bg_main },
    Title = { fg = c.keyword },
    Visual = { bg = c.bg_highlight },
    VisualNOS = { bg = c.bg_highlight },
    WarningMsg = { fg = c.warning },
    Whitespace = { fg = c.line_nums },
    WildMenu = { bg = c.bg_highlight },
    Winbar = { fg = c.fg_dim, bg = bg },
    WinbarNC = { fg = c.fg_dim, bg = bg },

    ----------------------------------------------------------------- syntax (legacy)
    Comment = vim.tbl_extend("force", { fg = c.fg_dim }, I),
    Constant = { fg = c.number },
    String = { fg = c.string },
    Character = { fg = c.string },
    Number = { fg = c.number },
    Float = { fg = c.number },
    Boolean = { fg = c.number },
    Identifier = { fg = c.variable },
    Function = vim.tbl_extend("force", { fg = c.func }, B),
    Statement = vim.tbl_extend("force", { fg = c.keyword }, IK),
    Conditional = vim.tbl_extend("force", { fg = c.keyword }, IK),
    Repeat = vim.tbl_extend("force", { fg = c.keyword }, IK),
    Label = { fg = c.special },
    Operator = { fg = c.special },
    Keyword = vim.tbl_extend("force", { fg = c.keyword }, IK),
    Exception = vim.tbl_extend("force", { fg = c.keyword }, IK),
    PreProc = { fg = c.special },
    Include = vim.tbl_extend("force", { fg = c.keyword }, IK),
    Define = { fg = c.special },
    Macro = { fg = c.special },
    PreCondit = { fg = c.special },
    Type = vim.tbl_extend("force", { fg = c.type }, B),
    StorageClass = vim.tbl_extend("force", { fg = c.keyword }, IK),
    Structure = vim.tbl_extend("force", { fg = c.type }, B),
    Typedef = vim.tbl_extend("force", { fg = c.type }, B),
    Special = { fg = c.special },
    SpecialChar = { fg = c.special },
    Tag = { fg = c.keyword },
    Delimiter = { fg = c.fg_mid },
    SpecialComment = vim.tbl_extend("force", { fg = c.fg_dim }, I),
    Debug = { fg = c.number },
    Underlined = { underline = true },
    Bold = { bold = o.bold },
    Italic = { italic = true },
    Ignore = { fg = c.fg_dim },
    Error = { fg = c.error },
    Todo = vim.tbl_extend("force", { fg = c.special, bg = c.bg_raised }, B),

    ----------------------------------------------------------------- diagnostics
    DiagnosticError = { fg = c.error },
    DiagnosticWarn = { fg = c.warning },
    DiagnosticInfo = { fg = c.info },
    DiagnosticHint = { fg = c.hint },
    DiagnosticOk = { fg = c.success },
    DiagnosticVirtualTextError = { fg = c.error, bg = c.bg_subtle },
    DiagnosticVirtualTextWarn = { fg = c.warning, bg = c.bg_subtle },
    DiagnosticVirtualTextInfo = { fg = c.info, bg = c.bg_subtle },
    DiagnosticVirtualTextHint = { fg = c.hint, bg = c.bg_subtle },
    DiagnosticUnderlineError = { sp = c.error, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.warning, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.info, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.hint, undercurl = true },
    DiagnosticUnnecessary = { fg = c.fg_dim },
    DiagnosticDeprecated = { fg = c.fg_dim, strikethrough = true },

    ----------------------------------------------------------------- LSP
    LspReferenceText = { bg = c.bg_highlight },
    LspReferenceRead = { bg = c.bg_highlight },
    LspReferenceWrite = { bg = c.bg_highlight },
    LspCodeLens = { fg = c.fg_dim },
    LspInlayHint = { fg = c.line_nums, bg = c.bg_subtle },
    LspSignatureActiveParameter = { fg = c.string, bg = c.bg_highlight },

    ----------------------------------------------------------------- diff / git
    DiffAdd = { bg = c.diff_add },
    DiffChange = { bg = c.diff_change },
    DiffDelete = { bg = c.diff_delete },
    DiffText = { bg = c.diff_text },
    Added = { fg = c.success },
    Changed = { fg = c.info },
    Removed = { fg = c.error },
    diffAdded = { fg = c.success },
    diffRemoved = { fg = c.error },
    diffChanged = { fg = c.info },
    diffOldFile = { fg = c.warning },
    diffNewFile = { fg = c.number },
    diffFile = { fg = c.variable },
    diffLine = { fg = c.fg_dim },
    diffIndexLine = { fg = c.special },
  }

  ---------------------------------------------------------------- Treesitter
  local ts = {
    ["@comment"] = vim.tbl_extend("force", { fg = c.fg_dim }, I),
    ["@comment.documentation"] = vim.tbl_extend("force", { fg = c.fg_dim }, I),
    ["@comment.error"] = { fg = c.error },
    ["@comment.warning"] = { fg = c.warning },
    ["@comment.todo"] = vim.tbl_extend("force", { fg = c.special, bg = c.bg_raised }, B),
    ["@comment.note"] = vim.tbl_extend("force", { fg = c.info, bg = c.bg_raised }, B),

    ["@constant"] = { fg = c.number },
    ["@constant.builtin"] = { fg = c.number },
    ["@constant.macro"] = { fg = c.special },
    ["@number"] = { fg = c.number },
    ["@number.float"] = { fg = c.number },
    ["@boolean"] = { fg = c.number },
    ["@character"] = { fg = c.string },
    ["@character.special"] = { fg = c.special },
    ["@string"] = { fg = c.string },
    ["@string.documentation"] = { fg = c.string },
    ["@string.regexp"] = { fg = c.special },
    ["@string.escape"] = { fg = c.special },
    ["@string.special"] = { fg = c.special },
    ["@string.special.url"] = { fg = c.variable, underline = true },

    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = vim.tbl_extend("force", { fg = c.special }, I),
    ["@variable.parameter"] = vim.tbl_extend("force", { fg = c.string }, IP),
    ["@variable.member"] = { fg = c.variable },
    ["@property"] = { fg = c.variable },
    ["@field"] = { fg = c.variable },

    ["@function"] = vim.tbl_extend("force", { fg = c.func }, B),
    ["@function.builtin"] = vim.tbl_extend("force", { fg = c.func }, B),
    ["@function.call"] = { fg = c.func },
    ["@function.macro"] = { fg = c.special },
    ["@function.method"] = vim.tbl_extend("force", { fg = c.func }, B),
    ["@function.method.call"] = { fg = c.func },
    ["@constructor"] = { fg = c.type },

    ["@keyword"] = vim.tbl_extend("force", { fg = c.keyword }, IK),
    ["@keyword.function"] = vim.tbl_extend("force", { fg = c.keyword }, IK),
    ["@keyword.operator"] = { fg = c.special },
    ["@keyword.return"] = vim.tbl_extend("force", { fg = c.keyword }, IK),
    ["@keyword.import"] = vim.tbl_extend("force", { fg = c.keyword }, IK),
    ["@keyword.export"] = vim.tbl_extend("force", { fg = c.keyword }, IK),
    ["@keyword.conditional"] = vim.tbl_extend("force", { fg = c.keyword }, IK),
    ["@keyword.repeat"] = vim.tbl_extend("force", { fg = c.keyword }, IK),
    ["@keyword.exception"] = vim.tbl_extend("force", { fg = c.keyword }, IK),
    ["@keyword.directive"] = { fg = c.special },
    ["@keyword.directive.define"] = { fg = c.special },
    ["@keyword.coroutine"] = vim.tbl_extend("force", { fg = c.keyword }, IK),

    ["@operator"] = { fg = c.special },
    ["@label"] = { fg = c.special },
    ["@punctuation.delimiter"] = { fg = c.fg_mid },
    ["@punctuation.bracket"] = { fg = c.fg_mid },
    ["@punctuation.special"] = { fg = c.special },

    ["@type"] = vim.tbl_extend("force", { fg = c.type }, B),
    ["@type.builtin"] = vim.tbl_extend("force", { fg = c.type }, I),
    ["@type.definition"] = vim.tbl_extend("force", { fg = c.type }, B),
    ["@type.qualifier"] = vim.tbl_extend("force", { fg = c.keyword }, IK),
    ["@attribute"] = vim.tbl_extend("force", { fg = c.special }, I),
    ["@attribute.builtin"] = vim.tbl_extend("force", { fg = c.special }, I),
    ["@namespace"] = { fg = c.type },
    ["@module"] = { fg = c.type },
    ["@module.builtin"] = vim.tbl_extend("force", { fg = c.type }, I),

    ["@decorator"] = vim.tbl_extend("force", { fg = c.special }, I),

    -- markup (markdown, help, etc.)
    ["@markup.heading"] = { fg = c.keyword },
    ["@markup.heading.1"] = { fg = c.keyword },
    ["@markup.heading.2"] = { fg = c.type },
    ["@markup.heading.3"] = { fg = c.func },
    ["@markup.heading.4"] = { fg = c.variable },
    ["@markup.heading.5"] = { fg = c.string },
    ["@markup.heading.6"] = { fg = c.special },
    ["@markup.strong"] = { fg = c.string, bold = o.bold },
    ["@markup.italic"] = { fg = c.type, italic = true },
    ["@markup.strikethrough"] = { fg = c.fg_dim, strikethrough = true },
    ["@markup.underline"] = { underline = true },
    ["@markup.quote"] = vim.tbl_extend("force", { fg = c.fg_dim }, I),
    ["@markup.math"] = { fg = c.number },
    ["@markup.link"] = { fg = c.variable },
    ["@markup.link.label"] = { fg = c.special },
    ["@markup.link.url"] = { fg = c.variable, underline = true },
    ["@markup.raw"] = { fg = c.func },
    ["@markup.raw.block"] = { fg = c.func },
    ["@markup.list"] = { fg = c.special },
    ["@markup.list.checked"] = { fg = c.success },
    ["@markup.list.unchecked"] = { fg = c.fg_dim },

    -- html / jsx / xml
    ["@tag"] = { fg = c.keyword },
    ["@tag.builtin"] = { fg = c.keyword },
    ["@tag.attribute"] = vim.tbl_extend("force", { fg = c.func }, I),
    ["@tag.delimiter"] = { fg = c.fg_mid },

    -- diff
    ["@diff.plus"] = { fg = c.success },
    ["@diff.minus"] = { fg = c.error },
    ["@diff.delta"] = { fg = c.info },

    ["@text.literal"] = { fg = c.func },
    ["@text.reference"] = { fg = c.variable },
    ["@text.uri"] = { fg = c.variable, underline = true },
  }
  for k, v in pairs(ts) do hl[k] = v end

  ---------------------------------------------------- LSP semantic tokens
  local sem = {
    ["@lsp.type.namespace"] = hl["@module"],
    ["@lsp.type.type"] = hl["@type"],
    ["@lsp.type.class"] = hl["@type"],
    ["@lsp.type.enum"] = hl["@type"],
    ["@lsp.type.interface"] = hl["@type"],
    ["@lsp.type.struct"] = hl["@type"],
    ["@lsp.type.typeParameter"] = hl["@type"],
    ["@lsp.type.parameter"] = hl["@variable.parameter"],
    ["@lsp.type.variable"] = hl["@variable"],
    ["@lsp.type.property"] = hl["@property"],
    ["@lsp.type.enumMember"] = { fg = c.number },
    ["@lsp.type.function"] = hl["@function"],
    ["@lsp.type.method"] = hl["@function.method"],
    ["@lsp.type.macro"] = { fg = c.special },
    ["@lsp.type.decorator"] = hl["@decorator"],
    ["@lsp.type.keyword"] = hl["@keyword"],
    ["@lsp.type.comment"] = hl["@comment"],
    ["@lsp.type.string"] = hl["@string"],
    ["@lsp.type.number"] = { fg = c.number },
    ["@lsp.type.operator"] = { fg = c.special },
    ["@lsp.typemod.variable.readonly"] = { fg = c.number },
    ["@lsp.typemod.variable.defaultLibrary"] = vim.tbl_extend("force", { fg = c.special }, I),
    ["@lsp.typemod.function.defaultLibrary"] = hl["@function"],
    ["@lsp.typemod.method.defaultLibrary"] = hl["@function"],
    ["@lsp.typemod.keyword.documentation"] = hl["@keyword"],
  }
  for k, v in pairs(sem) do hl[k] = v end

  ---------------------------------------------------- plugins (LazyVim defaults)
  local plugins = {
    -- gitsigns
    GitSignsAdd = { fg = c.success },
    GitSignsChange = { fg = c.info },
    GitSignsDelete = { fg = c.error },
    GitSignsAddNr = { fg = c.success },
    GitSignsChangeNr = { fg = c.info },
    GitSignsDeleteNr = { fg = c.error },
    GitSignsCurrentLineBlame = { fg = c.fg_dim },

    -- Telescope
    TelescopeNormal = { fg = c.fg, bg = c.bg_raised },
    TelescopeBorder = { fg = c.border, bg = c.bg_raised },
    TelescopePromptNormal = { fg = c.fg, bg = c.bg_highlight },
    TelescopePromptBorder = { fg = c.bg_highlight, bg = c.bg_highlight },
    TelescopePromptTitle = { fg = c.bg_main, bg = c.keyword },
    TelescopePreviewTitle = { fg = c.bg_main, bg = c.func },
    TelescopeResultsTitle = { fg = c.bg_raised, bg = c.bg_raised },
    TelescopePromptPrefix = { fg = c.keyword },
    TelescopeSelection = { bg = c.bg_highlight },
    TelescopeSelectionCaret = { fg = c.keyword, bg = c.bg_highlight },
    TelescopeMatching = { fg = c.special, bold = o.bold },

    -- Neo-tree / NvimTree
    NeoTreeNormal = { fg = c.fg_mid, bg = c.bg_darkest },
    NeoTreeNormalNC = { fg = c.fg_mid, bg = c.bg_darkest },
    NeoTreeDirectoryName = { fg = c.fg_mid },
    NeoTreeDirectoryIcon = { fg = c.keyword },
    NeoTreeRootName = { fg = c.keyword },
    NeoTreeFileName = { fg = c.fg_mid },
    NeoTreeGitAdded = { fg = c.success },
    NeoTreeGitModified = { fg = c.info },
    NeoTreeGitDeleted = { fg = c.error },
    NeoTreeGitUntracked = { fg = c.warning },
    NeoTreeGitConflict = { fg = c.special },
    NeoTreeGitIgnored = { fg = c.fg_dim },
    NeoTreeIndentMarker = { fg = c.border },
    NeoTreeExpander = { fg = c.fg_dim },
    NeoTreeTabActive = { fg = c.fg, bg = c.bg_main },
    NeoTreeTabInactive = { fg = c.fg_dim, bg = c.bg_darkest },
    NvimTreeNormal = { fg = c.fg_mid, bg = c.bg_darkest },
    NvimTreeFolderIcon = { fg = c.keyword },
    NvimTreeRootFolder = { fg = c.keyword },
    NvimTreeGitDirty = { fg = c.info },
    NvimTreeGitNew = { fg = c.success },
    NvimTreeGitDeleted = { fg = c.error },
    NvimTreeSpecialFile = { fg = c.special },
    NvimTreeIndentMarker = { fg = c.border },

    -- which-key
    WhichKey = { fg = c.special },
    WhichKeyGroup = { fg = c.variable },
    WhichKeyDesc = { fg = c.fg },
    WhichKeySeparator = { fg = c.fg_dim },
    WhichKeyFloat = { bg = c.bg_raised },
    WhichKeyBorder = { fg = c.border, bg = c.bg_raised },
    WhichKeyValue = { fg = c.fg_dim },

    -- bufferline
    BufferLineFill = { bg = c.bg_darkest },
    BufferLineBackground = { fg = c.fg_dim, bg = c.bg_darkest },
    BufferLineBufferSelected = { fg = c.fg, bg = c.bg_main, italic = false },
    BufferLineBufferVisible = { fg = c.fg_mid, bg = c.bg_darkest },
    BufferLineIndicatorSelected = { fg = c.keyword },
    BufferLineModified = { fg = c.special },
    BufferLineModifiedSelected = { fg = c.special },

    -- lualine handled by its own theme below, but a few fallbacks:
    -- noice / notify / cmp
    NoiceCmdlinePopupBorder = { fg = c.keyword },
    NoiceCmdlineIcon = { fg = c.keyword },
    NotifyERRORBorder = { fg = c.error },
    NotifyWARNBorder = { fg = c.warning },
    NotifyINFOBorder = { fg = c.info },
    NotifyDEBUGBorder = { fg = c.fg_dim },
    NotifyTRACEBorder = { fg = c.special },
    NotifyERRORIcon = { fg = c.error },
    NotifyWARNIcon = { fg = c.warning },
    NotifyINFOIcon = { fg = c.info },
    NotifyERRORTitle = { fg = c.error },
    NotifyWARNTitle = { fg = c.warning },
    NotifyINFOTitle = { fg = c.info },

    CmpItemAbbr = { fg = c.fg_mid },
    CmpItemAbbrDeprecated = { fg = c.fg_dim, strikethrough = true },
    CmpItemAbbrMatch = { fg = c.keyword, bold = o.bold },
    CmpItemAbbrMatchFuzzy = { fg = c.keyword, bold = o.bold },
    CmpItemKindFunction = { fg = c.func },
    CmpItemKindMethod = { fg = c.func },
    CmpItemKindVariable = { fg = c.variable },
    CmpItemKindKeyword = { fg = c.keyword },
    CmpItemKindClass = { fg = c.type },
    CmpItemKindInterface = { fg = c.type },
    CmpItemKindText = { fg = c.fg_mid },
    CmpItemKindSnippet = { fg = c.string },
    CmpItemKindConstant = { fg = c.number },
    CmpItemKindProperty = { fg = c.variable },
    CmpItemMenu = { fg = c.fg_dim },

    BlinkCmpLabelMatch = { fg = c.keyword, bold = o.bold },
    BlinkCmpKindFunction = { fg = c.func },
    BlinkCmpKindVariable = { fg = c.variable },
    BlinkCmpKindKeyword = { fg = c.keyword },
    BlinkCmpKindClass = { fg = c.type },

    -- indent-blankline v3
    IblIndent = { fg = c.bg_subtle },
    IblScope = { fg = c.border },

    -- mini.nvim
    MiniIndentscopeSymbol = { fg = c.special },
    MiniStatuslineModeNormal = { fg = c.bg_main, bg = c.keyword, bold = o.bold },
    MiniStatuslineModeInsert = { fg = c.bg_main, bg = c.func, bold = o.bold },
    MiniStatuslineModeVisual = { fg = c.bg_main, bg = c.type, bold = o.bold },
    MiniStatuslineFilename = { fg = c.fg_mid, bg = c.bg_raised },
    MiniIconsAzure = { fg = c.variable },
    MiniIconsBlue = { fg = c.info },
    MiniIconsCyan = { fg = c.variable },
    MiniIconsGreen = { fg = c.func },
    MiniIconsGrey = { fg = c.fg_mid },
    MiniIconsOrange = { fg = c.number },
    MiniIconsPurple = { fg = c.type },
    MiniIconsRed = { fg = c.error },
    MiniIconsYellow = { fg = c.string },

    -- flash / leap labels
    FlashLabel = { fg = c.bg_main, bg = c.keyword, bold = o.bold },
    FlashMatch = { fg = c.special, bg = c.bg_highlight },

    -- dashboard / snacks
    SnacksDashboardHeader = { fg = c.keyword },
    SnacksDashboardFooter = { fg = c.fg_dim },
    SnacksDashboardKey = { fg = c.special },
    SnacksDashboardDesc = { fg = c.fg_mid },
    SnacksDashboardIcon = { fg = c.func },
    SnacksDashboardTitle = { fg = c.keyword },
    SnacksIndent = { fg = c.bg_subtle },
    SnacksIndentScope = { fg = c.border },

    -- trouble
    TroubleNormal = { fg = c.fg_mid, bg = c.bg_darkest },
    TroubleText = { fg = c.fg_mid },
    TroubleCount = { fg = c.special, bg = c.bg_highlight },

    -- headlines / render-markdown
    RenderMarkdownCode = { bg = c.bg_raised },
    RenderMarkdownH1Bg = { bg = c.bg_subtle },
    RenderMarkdownH2Bg = { bg = c.bg_subtle },
  }
  for k, v in pairs(plugins) do hl[k] = v end

  return hl
end

-- A lualine theme table built from the palette.
function M.lualine(c)
  local function seg(fg, bg) return { fg = fg, bg = bg } end
  return {
    normal = {
      a = seg(c.bg_main, c.keyword),
      b = seg(c.fg, c.bg_highlight),
      c = seg(c.fg_mid, c.bg_darkest),
    },
    insert = { a = seg(c.bg_main, c.func) },
    visual = { a = seg(c.bg_main, c.type) },
    replace = { a = seg(c.bg_main, c.error) },
    command = { a = seg(c.bg_main, c.string) },
    inactive = {
      a = seg(c.fg_dim, c.bg_darkest),
      b = seg(c.fg_dim, c.bg_darkest),
      c = seg(c.fg_dim, c.bg_darkest),
    },
  }
end

local function set_terminal(c)
  vim.g.terminal_color_0 = c.term0
  vim.g.terminal_color_1 = c.term1
  vim.g.terminal_color_2 = c.term2
  vim.g.terminal_color_3 = c.term3
  vim.g.terminal_color_4 = c.term4
  vim.g.terminal_color_5 = c.term5
  vim.g.terminal_color_6 = c.term6
  vim.g.terminal_color_7 = c.term7
  vim.g.terminal_color_8 = c.term8
  vim.g.terminal_color_9 = c.term9
  vim.g.terminal_color_10 = c.term10
  vim.g.terminal_color_11 = c.term11
  vim.g.terminal_color_12 = c.term12
  vim.g.terminal_color_13 = c.term13
  vim.g.terminal_color_14 = c.term14
  vim.g.terminal_color_15 = c.term15
end

-- Entry point used by the files in colors/.
function M.load(palette)
  if vim.g.colors_name then vim.cmd("hi clear") end
  if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = palette.name

  local o = opts()
  local hl = M.highlights(palette, o)
  local set = vim.api.nvim_set_hl
  for group, spec in pairs(hl) do
    set(0, group, spec)
  end
  set_terminal(palette)

  -- expose the lualine theme so a statusline plugin can pick it up
  M._lualine = M.lualine(palette)
end

return M
