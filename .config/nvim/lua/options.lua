require "nvchad.options"

local opt = vim.opt

-- Display
opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.cursorlineopt = "number,line"
opt.signcolumn = "yes"
opt.termguicolors = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", extends = "»", precedes = "«", nbsp = "␣" }
opt.colorcolumn = "120"

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Split
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.confirm = true
opt.clipboard:append "unnamedplus"
opt.mouse = "a"

-- Context
opt.scrolloff = 4
opt.sidescrolloff = 8

-- Responsiveness
opt.updatetime = 200
opt.timeoutlen = 400

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Substitute
opt.inccommand = "split"

-- UI
opt.showmode = false

-- Persistent undo
opt.undofile = true
