-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.relativenumber = false
vim.cmd("syntax off")
vim.cmd("set termguicolors")
opt.guifont = "Hasklug Nerd Font:h11"
opt.titlestring = "%{substitute(getcwd(), $HOME, '~', '')}"
opt.title = true
opt.titlelen = 70

vim.g.neovide_cursor_vfx_mode = "pixiedust"
