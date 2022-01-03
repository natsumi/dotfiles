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
        -- [[<cmd>lua require('telescope.builtin').find_files({find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<CR>]],
        -- [[<cmd>Telescope find_files<cr>]],
        [[<cmd>Telescope find_files find_command=rg,--hidden,--files<CR>]],
        opt
    )
    map("n", "<leader>q", ":q <CR>", opt)

    -- DAP
    map("n", "<leader>dct", '<cmd>lua require"dap".continue()<CR>')
    map("n", "<leader>dsv", '<cmd>lua require"dap".step_over()<CR>')
    map("n", "<leader>dsi", '<cmd>lua require"dap".step_into()<CR>')
    map("n", "<leader>dso", '<cmd>lua require"dap".step_out()<CR>')
    map("n", "<leader>dtb", '<cmd>lua require"dap".toggle_breakpoint()<CR>')

    map("n", "<leader>dsc", '<cmd>lua require"dap.ui.variables".scopes()<CR>')
    map("n", "<leader>dhh", '<cmd>lua require"dap.ui.variables".hover()<CR>')
    map("v", "<leader>dhv", '<cmd>lua require"dap.ui.variables".visual_hover()<CR>')

    map("n", "<leader>duh", '<cmd>lua require"dap.ui.widgets".hover()<CR>')
    map("n", "<leader>duf", "<cmd>lua local widgets=require'dap.ui.widgets';widgets.centered_float(widgets.scopes)<CR>")

    map("n", "<leader>dsbr", '<cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
    map("n", "<leader>dsbm", '<cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>')
    map("n", "<leader>dro", '<cmd>lua require"dap".repl.open()<CR>')
    map("n", "<leader>drl", '<cmd>lua require"dap".repl.run_last()<CR>')
    -- DAP Telescope
    map("n", "<leader>dcc", '<cmd>lua require"telescope".extensions.dap.commands{}<CR>')
    map("n", "<leader>dco", '<cmd>lua require"telescope".extensions.dap.configurations{}<CR>')
    map("n", "<leader>dlb", '<cmd>lua require"telescope".extensions.dap.list_breakpoints{}<CR>')
    map("n", "<leader>dv", '<cmd>lua require"telescope".extensions.dap.variables{}<CR>')
    map("n", "<leader>df", '<cmd>lua require"telescope".extensions.dap.frames{}<CR>')
    -- DAP UI
    map("n", "<leader>dui", '<cmd>lua require"dapui".toggle()<CR>')
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

    -- Show lint errors in a diagnostic window
    use({
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup({})
        end,
    })

    --
    -- Utils
    --
    use({
        "easymotion/vim-easymotion",
    })
    use({
        "tpope/vim-repeat",
    })
    use({
        "tpope/vim-surround",
    })
    use({
        "wakatime/vim-wakatime",
    })

    --
    -- Debuggers
    --
    use({
        "mfussenegger/nvim-dap",
        requires = {
            {
                "suketa/nvim-dap-ruby",
                after = "nvim-dap",
                config = function()
                    require("dap-ruby").setup()
                end,
            },
            {
                "rcarriga/nvim-dap-ui", -- Nice UI for debugging
                after = "nvim-dap",
                config = function()
                    local dap, dapui = require("dap"), require("dapui")
                    dap.listeners.after.event_initialized["dapui_config"] = function()
                        dapui.open()
                    end
                    dap.listeners.before.event_terminated["dapui_config"] = function()
                        dapui.close()
                    end
                    dap.listeners.before.event_exited["dapui_config"] = function()
                        dapui.close()
                    end
                    require("dapui").setup()
                end,
            },
        },
    })

    use({
        "nvim-telescope/telescope-dap.nvim", -- Show project dependant history
        after = "telescope.nvim",
        config = function()
            require("telescope").load_extension("dap")
        end,
    })
end)

-- NOTE: we heavily suggest using Packer's lazy loading (with the 'event' field)
-- see: https://github.com/wbthomason/packer.nvim
-- https://nvchad.github.io/config/walkthrough

-- Stop sourcing filetype.vim
vim.g.did_load_filetypes = 1
