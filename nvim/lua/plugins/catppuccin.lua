-- Prefer COLOR_MODE env; else on macOS follow system appearance; else default dark (macchiato).
local function catppuccin_flavour()
  local mode = os.getenv("COLOR_MODE")
  if mode == "light" then
    return "latte"
  end
  if mode == "dark" then
    return "macchiato"
  end
  if vim.fn.has("mac") == 1 then
    local ok, out = pcall(function()
      return vim.fn.trim(vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }))
    end)
    if ok and out == "Dark" then
      return "macchiato"
    end
    return "latte"
  end
  return "macchiato"
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = function()
      return {
        flavour = catppuccin_flavour(),
        transparent_background = false,
      }
    end,
    config = function(_, opts)
      vim.g.catppuccin_flavour = opts.flavour
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
      -- Toggle light/dark and reload (optional in-session switch)
      vim.api.nvim_create_user_command("CatppuccinToggle", function()
        local current = vim.g.catppuccin_flavour or "macchiato"
        local next_flavour = (current == "macchiato") and "latte" or "macchiato"
        vim.g.catppuccin_flavour = next_flavour
        require("catppuccin").setup(vim.tbl_extend("force", opts, { flavour = next_flavour }))
        vim.cmd.colorscheme("catppuccin")
        vim.notify("Catppuccin: " .. next_flavour, vim.log.levels.INFO)
      end, {})
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
}
