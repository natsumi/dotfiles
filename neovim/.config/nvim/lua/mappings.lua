local function map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local opt = {}

-- Change leader key to space
vim.g.mapleader = ' ' -- set leader to space

-- Remap keys to navigate windows use Ctrl+key
map('n', '<C-h>', [[<C-w>h]], opt)
map('n', '<C-j>', [[<C-w>j]], opt)
map('n', '<C-k>', [[<C-w>k]], opt)
map('n', '<C-l>', [[<C-w>l]], opt)