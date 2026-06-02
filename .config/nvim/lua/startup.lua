local M = {}

local function normalized_path(path)
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

local function neorg_notes_root()
  return normalized_path "~/neorg"
end

function M.is_neorg_notes_root(path)
  return normalized_path(path) == neorg_notes_root()
end

-- Treat `nvim <dir>` like an empty startup while still honoring the target cwd.
function M.prepare_dashboard_dir_start()
  if vim.fn.argc(-1) ~= 1 then
    return
  end

  local arg = vim.fn.argv(0)
  if arg == "" then
    return
  end

  local dir = normalized_path(arg)
  if M.is_neorg_notes_root(dir) then
    local index = vim.fs.joinpath(dir, "index.norg")
    vim.cmd("args " .. vim.fn.fnameescape(index))
    vim.cmd.edit(vim.fn.fnameescape(index))
    return
  end

  if vim.fn.isdirectory(arg) ~= 1 then
    return
  end

  vim.fn.chdir(dir)
  vim.cmd "silent! argdelete *"

  local buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_set_name, buf, "")
  end
end

return M
