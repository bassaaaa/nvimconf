local function find_python()
  local virtual_env = os.getenv("VIRTUAL_ENV")
  if virtual_env and virtual_env ~= "" then
    return virtual_env .. "/bin/python"
  end

  local path = vim.fn.expand("%:p:h")
  while path and path ~= "" do
    for _, name in ipairs({ ".venv", "venv", "env", "matrix_env" }) do
      local python = path .. "/" .. name .. "/bin/python"
      if vim.fn.executable(python) == 1 then
        return python
      end
    end

    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then
      break
    end
    path = parent
  end

  return "python3"
end

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "flake8", "mypy" },
      },
      linters = {
        flake8 = {
          cmd = vim.fn.expand("~/.local/bin/flake8"),
        },
        mypy = {
          cmd = "/opt/homebrew/bin/uv",
          args = {
            "run",
            "--active",
            "--with",
            "mypy",
            "mypy",
            "--strict",
            "--python-executable",
            find_python,
            "--show-column-numbers",
            "--show-error-end",
            "--hide-error-context",
            "--no-color-output",
            "--no-error-summary",
            "--no-pretty",
          },
        },
      },
    },
  },
}
