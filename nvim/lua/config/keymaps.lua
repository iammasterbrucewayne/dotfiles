-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle Catppuccin light/dark (latte/Macchiato)
vim.keymap.set("n", "<leader>ut", "<cmd>CatppuccinToggle<cr>", { desc = "Toggle light/dark theme" })

-- C++: quick compile/run, dev compile (clang++ + ASan), or build (make)
vim.keymap.set("n", "<leader>cc", function()
  local file = vim.fn.expand("%")
  if file:match("%.cpp$") then
    -- Run from file's directory so the binary is found; use absolute path to run it
    vim.cmd("terminal g++ -o %:p:r % && %:p:r")
  end
end, { desc = "Compile and run current C++ file" })

vim.keymap.set("n", "<leader>cC", function()
  local file = vim.fn.expand("%:p")
  if not file:match("%.cpp$") then
    return
  end

  local dir = vim.fn.fnamemodify(file, ":h")
  local name = vim.fn.fnamemodify(file, ":t")
  local out = vim.fn.fnamemodify(file, ":t:r")

  local cmd = table.concat({
    "cd " .. vim.fn.shellescape(dir),
    "&& clang++ -std=c++20 -Wall -Wextra -Wpedantic -g -fsanitize=address "
      .. vim.fn.shellescape(name)
      .. " -o "
      .. vim.fn.shellescape(out),
    "&& " .. vim.fn.shellescape("./" .. out),
  }, " ")

  vim.cmd("terminal " .. cmd)
end, { desc = "Dev build (clang++/ASan) + run" })
vim.keymap.set("n", "<leader>cb", "<cmd>make<cr>", { desc = "Build (make)" })
