return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>ee", ":Neotree filesystem reveal left<CR>", desc = "Open neotree filesystem", silent = true },
    { "<leader>eb", ":Neotree buffers<CR>", desc = "Open neotree buffers", silent = true },
    { "<leader>es", ":Neotree float git_status<CR>", desc = "Open neotree git status", silent = true },
  },
  config = function()
    require("neo-tree").setup({
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
      },
    })
  end,
}
