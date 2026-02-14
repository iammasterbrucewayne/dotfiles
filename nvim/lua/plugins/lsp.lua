return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason.nvim" },
    opts = function(_, opts)
      -- Mason installs binaries to this path
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/alejandra"

      opts.servers = opts.servers or {}
      opts.servers.lua_ls = opts.servers.lua_ls or {}
      opts.servers.lua_ls.settings = vim.tbl_deep_extend("force", opts.servers.lua_ls.settings or {}, {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      })
      opts.servers.nil_ls = {
        settings = {
          ["nil"] = {
            formatting = {
              command = { mason_bin },
            },
          },
        },
      }
    end,
  },
}
