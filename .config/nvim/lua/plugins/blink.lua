---@type NvPluginSpec
return {
  { import = "nvchad.blink.lazyspec" },
  {
    "saghen/blink.cmp",
    dependencies = {
      { "fang2hou/blink-copilot" },
    },
    opts = function(_, opts)
      opts = opts or {}
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or {}
      if not vim.tbl_contains(opts.sources.default, "copilot") then
        table.insert(opts.sources.default, "copilot")
      end

      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.copilot = vim.tbl_deep_extend("force", opts.sources.providers.copilot or {}, {
        name = "Copilot",
        module = "blink-copilot",
        score_offset = 100,
        async = true,
      })

      opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
        ["<Tab>"] = { "select_and_accept", "fallback" },
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
      })

      opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, {
        keymap = {
          preset = "cmdline",
          ["<Tab>"] = { "show", "accept" },
        },
        completion = {
          menu = {
            auto_show = true,
          },
        },
      })

      opts.fuzzy = vim.tbl_deep_extend("force", opts.fuzzy or {}, {
        implementation = "lua",
      })

      return opts
    end,
  },
}
