local ts_config = require("nvim-treesitter.configs")

ts_config.setup {
  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {
    "bash",
    "css",
    "dockerfile",
    "elixir",
    "go",
    "html",
    "javascript",
    "json",
    "lua",
    "python",
    "ruby",
    "scss",
    "typescript",
    "yaml",
  },
  highlight = {
    enable = true, -- false will disable the whole extension
    use_languagetree = true
  },
  indent = {
    enable = true
  }
}

-- Enable TreeSitter folding
vim.wo.foldmethod = 'expr'
vim.wo.foldlevel = 99
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
