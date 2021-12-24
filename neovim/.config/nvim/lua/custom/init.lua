-- This is an example init file , its supposed to be placed in /lua/custom dir
-- lua/custom/init.lua

-- This is where your custom modules and plugins go.
-- Please check NvChad docs if you're totally new to nvchad + dont know lua!!

local hooks = require("core.hooks")

-- MAPPINGS
-- To add new plugins, use the "setup_mappings" hook,

hooks.add("setup_mappings", function(map)
    map(
        "n",
        "<C-p>",
        [[<cmd>lua require('telescope.builtin').find_files({find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<CR>]],
        opt
    )
    map("n", "<leader>q", ":q <CR>", opt)
end)

-- NOTE : opt is a variable  there (most likely a table if you want multiple options),
-- you can remove it if you dont have any custom options

-- Install plugins
-- To add new plugins, use the "install_plugin" hook,

-- examples below:

hooks.add("install_plugins", function(use)
    -- use {
    --    "max397574/better-escape.nvim",
    --    event = "InsertEnter",
    -- }

    --
    -- Look & Feel
    --

    use("rebelot/kanagawa.nvim")
    use({
        "karb94/neoscroll.nvim",
        opt = true,
        config = function()
            require("neoscroll").setup()
        end,
        -- lazy loading
        setup = function()
            require("core.utils").packer_lazy_load("neoscroll.nvim")
        end,
    })

    use({
        "luukvbaal/stabilize.nvim",
        config = function()
            require("stabilize").setup()
        end,
    })

    --
    -- file managing , picker etc
    --
    use({
        "nathom/filetype.nvim",
    })

    --
    -- Formatting / Linting
    --
    use({
        "jose-elias-alvarez/null-ls.nvim",
        after = "nvim-lspconfig",
        config = function()
            require("custom.plugins.null-ls").setup()
        end,
    })

    -- load it after nvim-lspconfig , since we'll use some lspconfig stuff in the null-ls config!
end)

-- NOTE: we heavily suggest using Packer's lazy loading (with the 'event' field)
-- see: https://github.com/wbthomason/packer.nvim
-- https://nvchad.github.io/config/walkthrough

-- Stop sourcing filetype.vim
vim.g.did_load_filetypes = 1
