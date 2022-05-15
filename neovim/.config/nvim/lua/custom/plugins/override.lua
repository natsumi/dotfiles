-- overriding default plugin configs!

local M = {}
-- one of "all", "maintained" (parsers with maintainers), or a list of languages
M.treesitter = {
    ensure_installed = {
        "bash",
        "css",
        "dockerfile",
        "elixir",
        "go",
        "heex",
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
        use_languagetree = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
    indent = {
        enable = true,
    },
}

return M

-- Enable TreeSitter folding
-- vim.wo.foldmethod = "expr"
-- vim.wo.foldlevel = 99
-- vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
