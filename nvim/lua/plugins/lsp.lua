return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason.nvim" },
    opts = function(_, opts)
      local function extend_on_attach(server_opts, fn)
        local prev = server_opts.on_attach
        server_opts.on_attach = function(client, bufnr)
          if prev then
            prev(client, bufnr)
          end
          fn(client, bufnr)
        end
      end

      -- Mason installs binaries to this path
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/alejandra"

      opts.servers = opts.servers or {}

      -- Web stack
      opts.servers.html = opts.servers.html or {}
      extend_on_attach(opts.servers.html, function(client)
        -- html-lsp can forward documentHighlight for embedded JS to tsls and
        -- sometimes returns -32603; disable just this capability to avoid spam.
        client.server_capabilities.documentHighlightProvider = false
      end)
      opts.servers.emmet_language_server = opts.servers.emmet_language_server or {
        filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
      }

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
