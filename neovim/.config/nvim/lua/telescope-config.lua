local opt = {noremap = true, silent = true}

vim.api.nvim_set_keymap(
    "n",
    "<Leader>ff",
    [[<cmd>lua require('telescope.builtin').find_files()<CR>]],
    opt
)

vim.api.nvim_set_keymap(
    "n",
    "<Leader>fg",
    [[<cmd>lua require('telescope.builtin').live_grep()<CR>]],
    opt
)
vim.api.nvim_set_keymap(
    "n",
    "<Leader>fb",
    [[<leader>fb <cmd>lua require('telescope.builtin').buffers()<CR>]],
    opt
)
vim.api.nvim_set_keymap(
    "n",
    "<Leader>fh",
    [[<cmd>lua require('telescope.builtin').help_tags()<CR>]],
    opt
)