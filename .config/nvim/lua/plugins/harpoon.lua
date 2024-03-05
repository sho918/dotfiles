return {
  "ThePrimeagen/harpoon",
  lazy = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    vim.keymap.set(
      "n",
      "<leader>hh",
      "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>",
      { desc = "Toggle harpoon quick menu" }
    )
    vim.keymap.set(
      "n",
      "<leader>hm",
      "<cmd>lua require('harpoon.mark').add_file()<CR>",
      { desc = "Mark file with harpoon" }
    )
    vim.keymap.set(
      "n",
      "<leader>hn",
      "<cmd>lua require('harpoon.ui').nav_next()<CR>",
      { desc = "Go to next harpoon mark" }
    )
    vim.keymap.set(
      "n",
      "<leader>hp",
      "<cmd>lua require('harpoon.ui').nav_prev()<CR>",
      { desc = "Go to previous harpoon mark" }
    )
  end,
}
