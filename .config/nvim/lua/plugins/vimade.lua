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
        diffview = {
          buf_name = "diffview://",
          buf_opts = { ft = { "DiffviewFiles", "DiffviewFileHistory" } },
        },
      },
    },
  },
}
