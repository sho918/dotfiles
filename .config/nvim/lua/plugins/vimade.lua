---@type NvPluginSpec
return {
  {
    "TaDaa/vimade",
    event = "VeryLazy",
    opts = {
      tint = {
        bg = { rgb = { 0, 0, 0 }, intensity = 0.05 },
      },
      blocklist = {
        codediff = {
          buf_name = "codediff://",
          buf_opts = { ft = { "codediff-explorer", "codediff-history" } },
        },
      },
    },
  },
}
