-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
map("n", "-", "<cmd>Neotree<CR>", { desc = "Start Neotree" })
map("n", "<leader>rm", "<cmd>RemoteStart<CR>", { desc = "Start Remote" })
-- map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
-- map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
map("n", "<M-x>", "<cmd>tabclose<CR>")
map("n", "<M-c>", "<cmd>tabnew<CR>")
map("n", "<M-p>", "<cmd>tabprevious<CR>")
map("n", "<M-n>", "<cmd>tabnext<CR>")
map("n", "<M-w>x", "<cmd>tabonly<CR>")
map('n', '<C-b>', '<C-i>', { noremap = true, silent = true })
