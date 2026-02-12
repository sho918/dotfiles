-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/mappings.lua
require "nvchad.mappings"

local map = vim.keymap.set

-- Helpers
local function module_call(mod, method, ...)
  local args = { ... }
  return function()
    local target = require(mod)
    for key in string.gmatch(method, "[^%.]+") do
      target = target[key]
    end
    target(unpack(args))
  end
end

local function multicursor_call(method, ...)
  local args = { ... }
  return function()
    local ok, mc = pcall(require, "multicursor-nvim")
    if not ok then
      return
    end
    mc[method](unpack(args))
  end
end

-- Basics
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Insert mode cursor moves
map("i", "<C-p>", "<Up>", { desc = "Move cursor up" })
map("i", "<C-n>", "<Down>", { desc = "Move cursor down" })
map("i", "<C-b>", "<Left>", { desc = "Move cursor left" })
map("i", "<C-f>", "<Right>", { desc = "Move cursor right" })

-- Save
map("n", "<leader>ww", "<cmd>w<cr>", { desc = "Save" })

-- Window splits / move
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split Below" })
map("n", "<leader>\\", "<cmd>vsplit<cr>", { desc = "Split Right" })
map("n", "<C-h>", module_call("smart-splits", "move_cursor_left"), { desc = "Go to left window" })
map("n", "<C-j>", module_call("smart-splits", "move_cursor_down"), { desc = "Go to lower window" })
map("n", "<C-k>", module_call("smart-splits", "move_cursor_up"), { desc = "Go to upper window" })
map("n", "<C-l>", module_call("smart-splits", "move_cursor_right"), { desc = "Go to right window" })

-- Move lines/blocks
map("v", "<C-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<C-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Git
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
map("n", "<leader>gl", "<cmd>LazyGitLog<cr>", { desc = "LazyGit Log" })
map("n", "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", { desc = "LazyGit: Current File" })
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git Diff (Working Tree)" })
map("n", "<leader>gD", "<cmd>DiffviewOpen HEAD~1<cr>", { desc = "Git Diff (Prev Commit)" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git File History" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Git Branch History" })
map("n", "<leader>gs", "<cmd>DiffviewOpen --cached<cr>", { desc = "Git Diff (Staged)" })
map("n", "<leader>gm", "<cmd>DiffviewOpen main...HEAD<cr>", { desc = "Git Diff (main)" })
map("n", "<leader>gM", "<cmd>DiffviewOpen master...HEAD<cr>", { desc = "Git Diff (master)" })
map("n", "<leader>gr", "<cmd>PR<cr>", { desc = "PR Review Menu" })
map("v", "<leader>gr", ":<C-u>'<,'>PRSuggestChange<CR>", { desc = "PR Suggest Change" })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Git: Close Diffview" })
map("n", "<leader>gt", "<cmd>DiffviewToggleFiles<cr>", { desc = "Git: Toggle File Panel" })
map("n", "<leader>gp", module_call("gitsigns", "preview_hunk"), { desc = "Git: Preview Hunk" })
map("n", "<leader>gb", module_call("snacks", "git.blame_line"), { desc = "Git: Blame Line" })
map("n", "<leader>ga", "<cmd>BlameColumnToggle<cr>", { desc = "Git: Blame Column" })
map("n", "<leader>hr", module_call("gitsigns", "reset_hunk"), { desc = "Git: Reset Hunk" })
map("n", "<leader>hs", module_call("gitsigns", "stage_hunk"), { desc = "Git: Stage Hunk" })
map("n", "<leader>hu", module_call("gitsigns", "undo_stage_hunk"), { desc = "Git: Undo Stage Hunk" })
map("n", "]c", function()
  if vim.wo.diff then
    return "]c"
  end
  require("gitsigns").next_hunk()
  return "<Ignore>"
end, { desc = "Git: Next Hunk", expr = true })
map("n", "[c", function()
  if vim.wo.diff then
    return "[c"
  end
  require("gitsigns").prev_hunk()
  return "<Ignore>"
end, { desc = "Git: Prev Hunk", expr = true })

-- Snacks picker
map("n", "<leader><leader>", module_call("snacks", "picker.smart", { hidden = true }), { desc = "Smart Find Files" })
map("n", "<leader>ff", module_call("snacks", "picker.files", { hidden = true }), { desc = "Find Files" })
map("n", "<leader>fg", module_call("snacks", "picker.git_files"), { desc = "Find Git Files" })
map("n", "<leader>fw", module_call("snacks", "picker.grep"), { desc = "Grep" })
map("n", "<leader>fb", module_call("snacks", "picker.buffers"), { desc = "Buffers" })
map("n", "<leader>fr", module_call("snacks", "picker.recent"), { desc = "Recent" })
map("n", "<leader>fh", module_call("snacks", "picker.help"), { desc = "Help Pages" })
map("n", "<leader>fo", module_call("snacks", "picker.recent"), { desc = "Recent Files" })
map("n", "<leader>fl", module_call("snacks", "picker.lines"), { desc = "Buffer Lines" })
map("n", "<leader>fz", module_call("snacks", "picker.grep_buffers"), { desc = "Grep Buffers" })
map("n", "<leader>ma", module_call("snacks", "picker.marks"), { desc = "Marks" })
map(
  "n",
  "<leader>fa",
  module_call("snacks", "picker.files", { hidden = true, ignored = true, follow = true }),
  { desc = "Find All Files" }
)

-- Oil
map("n", "<leader>e", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.w[win].is_oil_win then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  local ok, oil = pcall(require, "oil")
  if ok then
    oil.open_float()
  else
    vim.cmd "Oil --float"
  end
end, { desc = "Oil (Float)" })

-- Flash
map({ "n", "x", "o" }, "s", module_call("flash", "jump"), { desc = "Flash" })
map({ "n", "x", "o" }, "S", module_call("flash", "treesitter"), { desc = "Flash Treesitter" })
map("o", "r", module_call("flash", "remote"), { desc = "Remote Flash" })
map({ "o", "x" }, "R", module_call("flash", "treesitter_search"), { desc = "Treesitter Search" })
map("c", "<C-s>", module_call("flash", "toggle"), { desc = "Toggle Flash Search" })

-- Multi-cursor (multicursor.nvim)
map("n", "<C-g>", multicursor_call("matchAddCursor", 1), { desc = "MultiCursor: Add next match" })
map("x", "<C-g>", multicursor_call("matchAddCursor", 1), { desc = "MultiCursor: Add next match (visual)" })

-- Lasterisk
map("n", "*", module_call("lasterisk", "search"), { desc = "Search word (Lasterisk)" })
map("n", "g*", module_call("lasterisk", "search", { is_whole = false }), { desc = "Search word (partial)" })
map("x", "g*", module_call("lasterisk", "search", { is_whole = false }), { desc = "Search selection (partial)" })

-- Folds
map("n", "zR", module_call("ufo", "openAllFolds"), { desc = "Open all folds (UFO)" })
map("n", "zM", module_call("ufo", "closeAllFolds"), { desc = "Close all folds (UFO)" })

-- Precognition
map("n", "<leader>up", module_call("precognition", "toggle"), { desc = "Toggle Precognition" })

-- Trouble
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
map(
  "n",
  "<leader>cl",
  "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
  { desc = "LSP Definitions / References (Trouble)" }
)
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })

-- LSP
map("n", "gd", module_call("snacks", "picker.lsp_definitions"), { desc = "LSP Definitions" })
map("n", "gD", module_call("snacks", "picker.lsp_declarations"), { desc = "LSP Declarations" })
map("n", "gI", module_call("snacks", "picker.lsp_implementations"), { desc = "LSP Implementations" })
map("n", "gy", module_call("snacks", "picker.lsp_type_definitions"), { desc = "LSP Type Definitions" })
map("n", "gR", module_call("snacks", "picker.lsp_references"), { desc = "LSP References" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
map("n", "<leader>o", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
map("n", "<leader>r", function()
  return ":IncRename " .. vim.fn.expand "<cword>"
end, { expr = true, desc = "LSP Rename" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "<leader>ls", module_call("snacks", "picker.lsp_symbols"), { desc = "LSP Symbols" })
map("n", "<leader>lS", module_call("snacks", "picker.lsp_workspace_symbols"), { desc = "LSP Workspace Symbols" })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, desc = "LSP Hover" }
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "gh", vim.lsp.buf.hover, opts)
  end,
})

-- Treesitter textobjects
map(
  { "x", "o" },
  "af",
  module_call("nvim-treesitter.textobjects.select", "select_textobject", "@function.outer"),
  { desc = "TS Function outer" }
)
map(
  { "x", "o" },
  "if",
  module_call("nvim-treesitter.textobjects.select", "select_textobject", "@function.inner"),
  { desc = "TS Function inner" }
)
map(
  { "x", "o" },
  "ac",
  module_call("nvim-treesitter.textobjects.select", "select_textobject", "@class.outer"),
  { desc = "TS Class outer" }
)
map(
  { "x", "o" },
  "ic",
  module_call("nvim-treesitter.textobjects.select", "select_textobject", "@class.inner"),
  { desc = "TS Class inner" }
)
map(
  { "x", "o" },
  "aa",
  module_call("nvim-treesitter.textobjects.select", "select_textobject", "@parameter.outer"),
  { desc = "TS Parameter outer" }
)
map(
  { "x", "o" },
  "ia",
  module_call("nvim-treesitter.textobjects.select", "select_textobject", "@parameter.inner"),
  { desc = "TS Parameter inner" }
)

-- Overlook
map("n", "<leader>pd", module_call("overlook.api", "peek_definition"), { desc = "Overlook: Peek Definition" })
map("n", "<leader>pp", module_call("overlook.api", "peek_cursor"), { desc = "Overlook: Peek Cursor" })
map("n", "<leader>pu", module_call("overlook.api", "restore_popup"), { desc = "Overlook: Restore Popup" })
map("n", "<leader>pU", module_call("overlook.api", "restore_all_popups"), { desc = "Overlook: Restore All Popups" })
map("n", "<leader>pc", module_call("overlook.api", "close_all"), { desc = "Overlook: Close All" })
map("n", "<leader>pf", module_call("overlook.api", "switch_focus"), { desc = "Overlook: Switch Focus" })
map("n", "<leader>ps", module_call("overlook.api", "open_in_split"), { desc = "Overlook: Open In Split" })
map("n", "<leader>pv", module_call("overlook.api", "open_in_vsplit"), { desc = "Overlook: Open In VSplit" })

-- Substitute
map("n", "gr", module_call("substitute", "operator"), { desc = "Replace with register" })
map("n", "grr", module_call("substitute", "line"), { desc = "Replace line with register" })
map("x", "gr", module_call("substitute", "visual"), { desc = "Replace with register" })

-- CopilotChat
map("n", "<leader>ag", "<cmd>CopilotChat<cr>", { desc = "Copilot Chat" })

-- Claude Code
map("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Claude Code" })
map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Claude Code Focus" })
map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Claude Code Resume" })
map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Claude Code Continue" })
map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Claude Code Select Model" })
map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Claude Code Add Buffer" })
map("n", "<leader>aB", "<cmd>ClaudeCodeTreeAdd<cr>", { desc = "Claude Code Add File (Tree)" })
map("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Claude Code Send Selection" })
map("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Claude Code Diff Accept" })
map("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Claude Code Diff Deny" })
