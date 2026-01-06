---@type NvPluginSpec
return {
  {
    "coder/claudecode.nvim",
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSelectModel",
      "ClaudeCodeAdd",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
    },
    dependencies = { "folke/snacks.nvim" },
    config = true,
  },
}
