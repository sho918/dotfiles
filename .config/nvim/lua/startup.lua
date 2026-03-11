local M = {}

-- Treat `nvim <dir>` like an empty startup while still honoring the target cwd.
function M.prepare_dashboard_dir_start()
  if vim.fn.argc(-1) ~= 1 then
    return
  end

  local arg = vim.fn.argv(0)
  if arg == "" or vim.fn.isdirectory(arg) ~= 1 then
    return
  end

  local dir = vim.fs.normalize(vim.fn.fnamemodify(arg, ":p"))
  vim.fn.chdir(dir)
  vim.cmd "silent! argdelete *"

  local buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.api.nvim_buf_set_name, buf, "")
  end
end

return M
