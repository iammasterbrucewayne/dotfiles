-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function err(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "Keymap" })
end

local function as_string(v)
  if type(v) == "string" then
    return v
  end
  return nil
end

-- Toggle Catppuccin light/dark (latte/Macchiato)
vim.keymap.set("n", "<leader>ut", "<cmd>CatppuccinToggle<cr>", { desc = "Toggle light/dark theme" })

-- C++: quick compile/run, dev compile (clang++ + ASan), or build (make). Fail safely.
vim.keymap.set("n", "<leader>cc", function()
  local ok, raw_file = pcall(vim.fn.expand, "%")
  local file = ok and as_string(raw_file) or nil
  if not file or file == "" then
    err("No file path (unsaved or invalid buffer). Save the file or open a .cpp file.")
    return
  end
  if file:find("%s") or file:find("%(recovery%)") then
    err("Buffer is in recovery or has an unusual name. Recover or open the file normally.")
    return
  end
  if not file:match("%.cpp$") then
    err("Not a .cpp file. Current buffer: " .. (file == "" and "(unnamed)" or file))
    return
  end
  pcall(function()
    vim.cmd("terminal g++ -o %:p:r % && %:p:r")
  end)
end, { desc = "Compile and run current C++ file" })

vim.keymap.set("n", "<leader>cC", function()
  local ok, raw_file = pcall(vim.fn.expand, "%:p")
  local file = ok and as_string(raw_file) or nil
  if not file or file == "" then
    err("No file path (unsaved or invalid buffer). Save the file or open a .cpp file.")
    return
  end
  if file:find("%s") or file:find("%(recovery%)") then
    err("Buffer is in recovery or has an unusual name. Recover or open the file normally.")
    return
  end
  if not file:match("%.cpp$") then
    err("Not a .cpp file. Current buffer: " .. (file == "" and "(unnamed)" or file))
    return
  end

  local dir = as_string(vim.fn.fnamemodify(file, ":h"))
  local name = as_string(vim.fn.fnamemodify(file, ":t"))
  local out = as_string(vim.fn.fnamemodify(file, ":t:r"))
  if not dir or dir == "" or not name or name == "" then
    err("Could not derive compile inputs from path.")
    return
  end
  if not out or out == "" then
    err("Could not derive output name from path.")
    return
  end

  local cmd = table.concat({
    "cd " .. vim.fn.shellescape(dir),
    "&& clang++ -std=c++20 -Wall -Wextra -Wpedantic -g -fsanitize=address "
      .. vim.fn.shellescape(name)
      .. " -o "
      .. vim.fn.shellescape(out),
    "&& " .. vim.fn.shellescape("./" .. out),
  }, " ")

  local ran = pcall(function()
    vim.cmd("terminal " .. cmd)
  end)
  if not ran then
    err("Failed to run terminal command.")
  end
end, { desc = "Dev build (clang++/ASan) + run" })

vim.keymap.set("n", "<leader>cb", function()
  local ran = pcall(function()
    vim.cmd("make")
  end)
  if not ran then
    err("Failed to run make.")
  end
end, { desc = "Build (make)" })
