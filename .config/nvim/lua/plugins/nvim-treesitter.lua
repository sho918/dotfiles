---@type NvPluginSpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
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
      highlight = { enable = true },
      indent = { enable = true },
      matchup = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
        },
      },
    },
  },
}
