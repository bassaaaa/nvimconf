-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Markdownのスペルチェック（波下線）を無効化
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

local function refresh_snacks_explorer_git()
  local snacks = rawget(_G, "Snacks")
  local git_ok, git = pcall(require, "snacks.explorer.git")
  local tree_ok, tree = pcall(require, "snacks.explorer.tree")

  if not snacks or not snacks.picker or not git_ok or not tree_ok then
    return
  end

  local explorers = snacks.picker.get({
    source = "explorer",
    tab = false,
  })

  for _, picker in ipairs(explorers) do
    if not picker.closed then
      local explorer = picker
      local root = tree:find(explorer:cwd())

      -- Snacks does not clear a directory status after Git stops
      -- reporting that directory as untracked.
      tree:walk(root, function(node)
        node.dir_status = nil
      end, { all = true })

      -- Redraw even when only the rendered Git status is stale.
      root.status = "__refresh__"

      git.update(explorer:cwd(), {
        force = true,
        untracked = explorer.opts.git_untracked,
        on_update = function()
          if explorer.closed then
            return
          end

          explorer.list:set_target()
          explorer:find()
        end,
      })
    end
  end
end

local snacks_explorer_git_refresh_group = vim.api.nvim_create_augroup(
  "snacks_explorer_git_refresh",
  { clear = true }
)

vim.api.nvim_create_autocmd(
  {
    "BufWritePost",
    "FocusGained",
    "TermClose",
    "TermLeave",
    "ShellCmdPost",
  },
  {
    group = snacks_explorer_git_refresh_group,
    callback = refresh_snacks_explorer_git,
  }
)

vim.schedule(refresh_snacks_explorer_git)
