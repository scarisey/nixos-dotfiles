-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.relativenumber = false
vim.cmd("syntax on")
vim.cmd("set termguicolors")
-- opt.guifont = "MesloLGL Nerd Font Mono:h11"
opt.titlestring = "%{substitute(getcwd(), $HOME, '~', '')}"
opt.title = true
opt.titlelen = 70

vim.g.neovide_cursor_vfx_mode = "pixiedust"
vim.g.neovide_hide_mouse_when_typing = false
