---@type NvPluginSpec
return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()

      local servers = {
        "lua_ls",
        "pyright",
        "vtsls",
        "eslint",
        "jsonls",
        "html",
        "cssls",
      }
      vim.lsp.enable(servers)
    end,
  },
}
