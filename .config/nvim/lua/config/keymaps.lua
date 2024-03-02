-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap

keymap.set("n", "x", '"_x', { desc = "Delete word without yanking" })

-- Save and quit
keymap.set("n", "<leader>w", ":update<CR>", { desc = "Save" })
keymap.set("n", "<leader>q", ":quit<CR>", { desc = "Quit" })
keymap.set("n", "<leader>Q", ":qa<CR>", { desc = "Quit all" })

-- Split window
keymap.set("n", "<leader>ss", ":vsplit<CR>", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", ":vsplit<CR>", { desc = "Split window horizontally" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })

-- Tab
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Move cursor
keymap.set("i", "<C-p>", "<Up>", { desc = "Move up" })
keymap.set("i", "<C-n>", "<Down>", { desc = "Move down" })
keymap.set("i", "<C-b>", "<Left>", { desc = "Move left" })
keymap.set("i", "<C-f>", "<Right>", { desc = "Move right" })

-- Move line
keymap.set("n", "<C-k>", "<cmd>m .-2<CR>", { desc = "Move line up" })
keymap.set("n", "<C-j>", "<cmd>m .+1<CR>", { desc = "Move line down" })
keymap.set("v", "<C-k>", "<cmd>m '>+1<CR>", { desc = "Move line up (visual mode)" })
keymap.set("v", "<C-j>", "<cmd>m '<-2<CR>", { desc = "Move line down (visual mode)" })

-- Search
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
