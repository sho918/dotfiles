---@type NvPluginSpec
return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = vim.fn.has "win32" ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    cmd = {
      "AvanteAsk",
      "AvanteBuild",
      "AvanteChat",
      "AvanteChatNew",
      "AvanteEdit",
      "AvanteFocus",
      "AvanteHistory",
      "AvanteRefresh",
      "AvanteStop",
      "AvanteSwitchProvider",
      "AvanteToggle",
      "AvanteModels",
    },
    opts = {
      provider = "claude",
      behaviour = {
        auto_suggestions = false,
      },
      providers = {
        claude = {
          auth_type = "max",
        },
      },
      selector = {
        provider = "snacks",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "folke/snacks.nvim",
      "nvim-tree/nvim-web-devicons",
    },
  },
}
