-- Please check NvChad docs if you're totally new to nvchad + dont know lua!!
-- This is an example init file in /lua/custom/
-- this init.lua can load stuffs etc too so treat it like your ~/.config/nvim/

require("custom.mappings")
-- Stop sourcing filetype.vim
vim.g.did_load_filetypes = 1
