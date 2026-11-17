---@type NvPluginSpec
return {
  {
    "esmuellert/codediff.nvim",
    version = "^4.0.0",
    cmd = "CodeDiff",
    opts = {
      keymaps = {
        view = {
          quit = { "q", "<leader>gq" },
          toggle_explorer = { "<leader>b", "<leader>gt" },
        },
      },
    },
  },
}
