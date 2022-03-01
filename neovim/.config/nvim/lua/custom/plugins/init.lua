return {
    --
    -- Look & Feel
    --

    { "rebelot/kanagawa.nvim" },
    {
        "karb94/neoscroll.nvim",
        opt = true,
        config = function()
            require("neoscroll").setup()
        end,
        -- lazy loading
        setup = function()
            require("core.utils").packer_lazy_load("neoscroll.nvim")
        end,
    },
    {
        "luukvbaal/stabilize.nvim",
        config = function()
            require("stabilize").setup()
        end,
    },
    --
    -- file managing , picker etc
    --
    {
        "nathom/filetype.nvim",
    },
    --
    -- Formatting / Linting
    --
    {
        "jose-elias-alvarez/null-ls.nvim",
        after = "nvim-lspconfig",
        config = function()
            require("custom.plugins.null-ls").setup()
        end,
    },
    -- load it after nvim-lspconfig , since we'll  some lspconfig stuff in the null-ls config!

    -- Show lint errors in a diagnostic window
    {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup({})
        end,
    },
    --
    -- Utils
    --
    {
        "easymotion/vim-easymotion",
    },
    {
        "tpope/vim-repeat",
    },
    {
        "tpope/vim-surround",
    },
    {
        "wakatime/vim-wakatime",
    },
    --
    -- Debuggers
    --
    {
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
    },
    {
        "nvim-telescope/telescope-dap.nvim", -- Show project dependant history
        after = "telescope.nvim",
        config = function()
            require("telescope").load_extension("dap")
        end,
    },
}
