---@type NvPluginSpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        opts = {
          select = {
            lookahead = true,
          },
        },
      },
      { "windwp/nvim-ts-autotag", opts = {} },
      { "JoosepAlviste/nvim-ts-context-commentstring", opts = {} },
    },
    opts = {
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "python",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "html",
        "css",
        "markdown",
        "markdown_inline",
      },
    },
  },
}
