return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      {
        "SmiteshP/nvim-navbuddy",
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim",
          "numToStr/Comment.nvim",
          "nvim-telescope/telescope.nvim",
        },
        opts = { lsp = { auto_attach = true } },
      },
    },
    lazy = false,
    config = function()
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "tsserver",
        },
      })
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
          })
        end,
      })

      -- LSP
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover" })
      vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Show references" })
      vim.keymap.set({ "n", "v" }, "<leader>o", vim.lsp.buf.code_action, { desc = "Show code actions" })

      -- Navbuddy
      vim.keymap.set("n", "<leader>nb", vim.cmd.Navbuddy, { desc = "Toggle navbuddy" })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.diagnostics.eslint,
        },
      })

      vim.keymap.set("n", "<leader>p", vim.lsp.buf.format, { desc = "Format" })
    end,
  },
}
