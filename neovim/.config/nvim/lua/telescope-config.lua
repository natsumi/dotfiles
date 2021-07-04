require("telescope").setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--hidden",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case"
    },
    prompt_prefix = " ",
    selection_caret = " ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        mirror = false,
      },
      vertical = {
        mirror = false
      },
    },
    scroll_strategy = "cycle",
    border = {},
    file_sorter = require "telescope.sorters".get_fuzzy_file,
    file_ignore_patterns = {},
    generic_sorter = require "telescope.sorters".get_generic_fuzzy_sorter,
    shorten_path = true,
    winblend = 0,
    borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
    color_devicons = true,
    use_less = true,
    set_env = {["COLORTERM"] = "truecolor"}, -- default = nil,
    grep_previewer = require "telescope.previewers".vim_buffer_vimgrep.new,
    qflist_previewer = require "telescope.previewers".vim_buffer_qflist.new,
    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require "telescope.previewers".buffer_previewer_maker
  },
  extensions = {
    media_files = {
      filetypes = {"png", "webp", "jpg", "jpeg"},
      find_cmd = "rg" -- find command (defaults to `fd`)
    }
  }
}

require("telescope").load_extension("media_files")

local opt = {noremap = true, silent = true}

vim.api.nvim_set_keymap(
  "n",
  "<Leader>fp",
  [[<Cmd>lua require('telescope').extensions.media_files.media_files()<CR>]],
  opt
)

vim.api.nvim_set_keymap(
  "n",
  "<C-p>",
  [[<cmd>lua require('telescope.builtin').find_files({ previewer = false, find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<CR>]],
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
