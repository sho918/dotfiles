---@type NvPluginSpec
local function render(props)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
  if filename == "" then
    filename = "[No Name]"
  end

  local modified = vim.bo[props.buf].modified and " *" or ""

  return filename .. modified
end

return {
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    opts = {
      render = render,
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}
