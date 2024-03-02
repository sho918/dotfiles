local opt = vim.opt

-- line numbers
opt.number = true
opt.relativenumber = false

-- cursor
opt.cursorline = true

-- indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- split window
opt.splitright = true
opt.splitbelow = true

-- appearance
opt.termguicolors = true
opt.colorcolumn = "119"
opt.signcolumn = "yes"
opt.scrolloff = 10

-- behaviour
opt.encoding = "UTF-8"
opt.errorbells = false
opt.swapfile = false
opt.completeopt = "menuone,noinsert,noselect"
opt.backspace = "indent,eol,start"
opt.mouse:append("a")
opt.clipboard:append("unnamedplus")
