---@type NvPluginSpec
return {
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    dependencies = {
      "nvim-neorg/lua-utils.nvim",
      "nvim-neotest/nvim-nio",
      "MunifTanjim/nui.nvim",
      "pysan3/pathlib.nvim",
      "nvim-neorg/tree-sitter-norg",
      "nvim-neorg/tree-sitter-norg-meta",
    },
    config = function()
      local function add_lazy_rock_cpath(rock_name)
        local extension = jit.os:find "Windows" and "dll" or "so"
        local root = vim.fn.stdpath "data" .. "/lazy-rocks/" .. rock_name
        package.cpath = package.cpath .. ";" .. root .. "/lib/lua/5.1/?." .. extension
        package.cpath = package.cpath .. ";" .. root .. "/lib64/lua/5.1/?." .. extension
      end

      add_lazy_rock_cpath "tree-sitter-norg"
      add_lazy_rock_cpath "tree-sitter-norg-meta"

      require("neorg").setup {
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {},
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/neorg",
              },
              default_workspace = "notes",
              index = "index.norg",
              open_last_workspace = false,
            },
          },
          ["core.journal"] = {
            config = {
              workspace = "notes",
              journal_folder = "journal",
              strategy = "nested",
            },
          },
          ["core.qol.todo_items"] = {},
        },
      }
    end,
  },
}
