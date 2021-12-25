local M = {}

M.setup_lsp = function(attach, capabilities)
    local lspconfig = require("lspconfig")

    -- lspservers with default config
    local servers = {
        "bashls",
        "cssls",
        "dockerls",
        "elixirls",
        "gopls",
        "html",
        "jsonls",
        "pyright",
        "solargraph",
        "sumneko_lua",
        "tailwindcss",
        "tsserver",
        "vuels",
        "yamlls",
    }

    for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
            on_attach = attach,
            capabilities = capabilities,
            flags = {
                debounce_text_changes = 150,
            },
        })
    end

    -- Elixir
    lspconfig.elixirls.setup({
        cmd = { "/Users/natsumi/dev/elixirls/language_server.sh" },
    })

    -- ruby - Use null-ls / standardrb for formatting instead
    lspconfig.solargraph.setup({
        on_attach = function(client, bufnr)
            client.resolved_capabilities.document_formatting = false
            client.resolved_capabilities.document_range_formatting = false
            vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>fm", "<cmd>lua vim.lsp.buf.formatting()<CR>", {})
        end,
    })

    -- typescript
    lspconfig.tsserver.setup({
        on_attach = function(client, bufnr)
            client.resolved_capabilities.document_formatting = false
            client.resolved_capabilities.document_range_formatting = false
            vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>fm", "<cmd>lua vim.lsp.buf.formatting()<CR>", {})
        end,
    })

    -- the above tsserver config will remvoe the tsserver's inbuilt formatting
    -- since I use null-ls with denofmt for formatting ts/js stuff.
end

return M
