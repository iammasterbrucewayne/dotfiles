-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle Catppuccin light/dark (latte/Macchiato)
vim.keymap.set("n", "<leader>ut", "<cmd>CatppuccinToggle<cr>", { desc = "Toggle light/dark theme" })

-- C++: compile current file (g++) or build (make)
vim.keymap.set("n", "<leader>cc", function()
  local file = vim.fn.expand("%")
  if file:match("%.cpp$") then
    -- Run from file's directory so the binary is found; use absolute path to run it
    vim.cmd("terminal g++ -o %:p:r % && %:p:r")
  end
end, { desc = "Compile and run current C++ file" })
vim.keymap.set("n", "<leader>cb", "<cmd>make<cr>", { desc = "Build (make)" })
