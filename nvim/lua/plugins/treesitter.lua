-- Override tree-sitter: disable C++ parser/highlight to avoid crashes on invalid or edge-case input.
-- Remove this file once upstream is fixed or you are on a version that does not crash.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.highlight = opts.highlight or {}
      opts.highlight.disable = opts.highlight.disable or {}
      vim.list_extend(opts.highlight.disable, { "cpp" })
      if type(opts.ensure_installed) == "table" then
        opts.ensure_installed = vim.tbl_filter(function(lang)
          return lang ~= "cpp"
        end, opts.ensure_installed)
      end
      return opts
    end,
  },
}
