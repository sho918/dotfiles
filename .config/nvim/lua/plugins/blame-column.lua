---@type NvPluginSpec
return {
  {
    "Yu-Leo/blame-column.nvim",
    cmd = "BlameColumnToggle",
    opts = {
      datetime_format = "%Y-%m-%d",
      relative_dates = false,
      time_based_bg_opts = {
        hue = 210,
        saturation = 45,
        lightness_min = 35,
        lightness_max = 65,
      },
      colorizer_fn = function(general_info, line_info)
        local hl = require("blame-column.colorizers").time_based_bg(general_info, line_info)
        hl.fg = "#0B1220"
        return hl
      end,
      structurizer_fn = function(general_info, line_info)
        local line = require("blame-column.structurizers").colorized_date_author(general_info, line_info)
        if line_info.is_modified then
          line.hl = "DiagnosticWarn"
        end
        return line
      end,
      commit_info = {
        datetime_format = "%Y-%m-%d %H:%M:%S",
      },
    },
  },
}
