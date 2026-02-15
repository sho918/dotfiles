---@type NvPluginSpec
return {
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.cursorword").setup()
      require("mini.indentscope").setup()
      require("mini.trailspace").setup()
      require("mini.extra").setup()

      local function set_zenkaku_hl()
        vim.api.nvim_set_hl(0, "MiniTrailspaceZenkaku", { default = true, link = "MiniTrailspace" })
      end

      local function has_match(match_id)
        for _, match in ipairs(vim.fn.getmatches()) do
          if match.id == match_id then
            return true
          end
        end
        return false
      end

      local function del_zenkaku_match()
        local match_id = vim.w.mini_trailspace_zenkaku_match_id
        if match_id == nil then
          return
        end
        pcall(vim.fn.matchdelete, match_id)
        vim.w.mini_trailspace_zenkaku_match_id = nil
      end

      local function add_zenkaku_match()
        if vim.fn.mode() ~= "n" then
          del_zenkaku_match()
          return
        end
        if vim.bo.buftype ~= "" then
          del_zenkaku_match()
          return
        end

        local match_id = vim.w.mini_trailspace_zenkaku_match_id
        if match_id ~= nil and has_match(match_id) then
          return
        end

        vim.w.mini_trailspace_zenkaku_match_id = vim.fn.matchadd("MiniTrailspaceZenkaku", [[\%u3000\+\s*$]])
      end

      set_zenkaku_hl()

      local zenkaku_group = vim.api.nvim_create_augroup("MiniTrailspaceZenkaku", { clear = true })

      vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "InsertLeave" }, {
        group = zenkaku_group,
        callback = add_zenkaku_match,
        desc = "Highlight trailing full-width spaces",
      })
      vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "InsertEnter" }, {
        group = zenkaku_group,
        callback = del_zenkaku_match,
        desc = "Unhighlight trailing full-width spaces",
      })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = zenkaku_group,
        callback = set_zenkaku_hl,
        desc = "Ensure full-width trailspace highlight",
      })
    end,
  },
}
