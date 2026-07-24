local function find_python(root_dir)
  local virtual_env = os.getenv("VIRTUAL_ENV")
  if virtual_env and virtual_env ~= "" then
    local python = virtual_env .. "/bin/python"
    if vim.fn.executable(python) == 1 then
      return python
    end
  end

  local path = root_dir or vim.fn.expand("%:p:h")
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
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = {
          spacing = 2,
          source = "if_many",
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      },
      servers = {
        pyright = {
          before_init = function(_, config)
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = find_python(config.root_dir)
          end,
        },
      },
    },
  },
}
