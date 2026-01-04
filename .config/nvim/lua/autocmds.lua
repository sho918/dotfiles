require "nvchad.autocmds"

-- 補完メニュー表示中は Copilot のインライン提案を隠す
local copilot_group = vim.api.nvim_create_augroup("CopilotBlink", { clear = true })

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuOpen",
  group = copilot_group,
  callback = function()
    vim.b.copilot_suggestion_hidden = true
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuClose",
  group = copilot_group,
  callback = function()
    vim.b.copilot_suggestion_hidden = false
  end,
})

local yank_group = vim.api.nvim_create_augroup("HighlightYank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = yank_group,
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 200 }
  end,
})

-- Nvdash でのカーソル移動時にエラーが出ないようにする
local nvdash_group = vim.api.nvim_create_augroup("NvdashKeymaps", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "nvdash",
  group = nvdash_group,
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "j", "j", opts)
    vim.keymap.set("n", "k", "k", opts)
    vim.keymap.set("n", "<down>", "<down>", opts)
    vim.keymap.set("n", "<up>", "<up>", opts)
  end,
})

-- Oil: Ctrl+n/p で上下移動
local oil_group = vim.api.nvim_create_augroup("OilKeymaps", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  group = oil_group,
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "<C-n>", "j", opts)
    vim.keymap.set("n", "<C-p>", "k", opts)
  end,
})

-- ファイルの保存時に通知を出す
local save_group = vim.api.nvim_create_augroup("NotifySave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  group = save_group,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name == "" then
      return
    end
    local display = vim.fn.fnamemodify(name, ":~:.")
    vim.notify(("Saved %s"):format(display), vim.log.levels.INFO, { title = "Write" })
  end,
})

-- InsertLeave / FocusLost で自動保存する
local autosave_group = vim.api.nvim_create_augroup("AutoSave", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost" }, {
  group = autosave_group,
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= "" then
      return
    end
    if not vim.bo[buf].modifiable or vim.bo[buf].readonly then
      return
    end
    if vim.api.nvim_buf_get_name(buf) == "" then
      return
    end
    vim.api.nvim_buf_call(buf, function()
      vim.cmd "silent! update"
    end)
  end,
})
