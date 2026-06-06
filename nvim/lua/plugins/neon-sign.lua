-- Reads the active theme from a state file written by theme-switch.sh.
-- Falls back to neon-sign-muted if the file doesn't exist.
local function active_theme()
  local path = vim.fn.stdpath("state") .. "/theme"
  local f = io.open(path)
  if f then
    local name = vim.trim(f:read("*a"))
    f:close()
    if name ~= "" then return name end
  end
  return "neon-sign-muted"
end

return {
  {
    "neon-sign",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    name = "neon-sign",
  },

  {
    "LazyVim/LazyVim",
    opts = { colorscheme = active_theme() },
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      local ok, ns = pcall(require, "neon-sign")
      if ok and ns._lualine then
        opts.options = opts.options or {}
        opts.options.theme = ns._lualine
      end
    end,
  },
}
