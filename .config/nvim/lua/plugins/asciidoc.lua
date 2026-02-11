---@type NvPluginSpec
return {
  {
    "habamax/vim-asciidoctor",
    ft = { "asciidoc", "asciidoctor", "adoc" },
    init = function()
      vim.g.asciidoctor_folding = 1
      vim.g.asciidoctor_fold_options = 1
      vim.g.asciidoctor_fenced_languages = {
        "lua",
        "python",
        "bash",
        "javascript",
        "typescript",
        "json",
        "yaml",
      }

      local group = vim.api.nvim_create_augroup("AsciidocLocalOptions", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "asciidoc", "asciidoctor", "adoc" },
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.spell = true
          vim.opt_local.spelllang:append "cjk"
        end,
      })
    end,
  },
  {
    "brianhuster/live-preview.nvim",
    ft = { "asciidoc", "asciidoctor", "adoc" },
    dependencies = { "folke/snacks.nvim" },
    config = function()
      require("livepreview.config").set {
        picker = "snacks",
        auto_start = false,
      }
    end,
  },
}
