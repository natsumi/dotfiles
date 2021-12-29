local present, ts_config = pcall(require, "nvim-treesitter.configs")

if not present then
    return
end

ts_config.setup({
    -- one of "all", "maintained" (parsers with maintainers), or a list of languages
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
})

-- Enable TreeSitter folding
vim.wo.foldmethod = "expr"
vim.wo.foldlevel = 99
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
