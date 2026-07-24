-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Ctrl+B: ファイルツリー開閉
map("n", "<C-b>", "<cmd>Neotree toggle<CR>", { desc = "Toggle file tree" })

-- F3: 現在のバッファを整形
map({ "n", "v" }, "<F3>", function()
  require("conform").format({ async = false, lsp_format = "fallback" })
end, { desc = "Format buffer" })

local function set_mypy_strict(enabled)
  vim.g.python_mypy_strict = enabled

  local ok, lint = pcall(require, "lint")
  if ok and lint.linters and lint.linters.mypy then
    local args = lint.linters.mypy.args or {}
    local strict_index = nil

    for index, arg in ipairs(args) do
      if arg == "--strict" then
        strict_index = index
        break
      end
    end

    if enabled and not strict_index then
      table.insert(args, 6, "--strict")
    elseif not enabled and strict_index then
      table.remove(args, strict_index)
    end

    lint.linters.mypy.args = args
    lint.try_lint("mypy")
  end

  vim.notify("mypy --strict: " .. (enabled and "on" or "off"))
end

map("n", "<F4>", function()
  if vim.g.python_mypy_strict == nil then
    vim.g.python_mypy_strict = true
  end

  set_mypy_strict(not vim.g.python_mypy_strict)
end, { desc = "Toggle mypy strict" })
