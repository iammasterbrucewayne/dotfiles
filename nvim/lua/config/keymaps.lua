-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle Catppuccin light/dark (latte/Macchiato)
vim.keymap.set("n", "<leader>ut", "<cmd>CatppuccinToggle<cr>", { desc = "Toggle light/dark theme" })
