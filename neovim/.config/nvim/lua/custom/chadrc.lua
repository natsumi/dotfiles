-- This is an example chadrc file , its supposed to be placed in /lua/custom dir
-- lua/custom/chadrc.lua

local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

M.ui = {
    theme = "catppuccin",
}

-- /lua/custom/chadrc.lualocal
userPlugins = require("custom.plugins")

M.plugins = {
    default_plugin_config_replace = {
        nvim_treesitter = "custom.plugins.treesitter",
    },
    options = {
        lspconfig = {
            setup_lspconf = "custom.plugins.lspconfig",
        },
    },
    status = {
        colorizer = true,
        dashboard = true,
    },
    install = userPlugins,
}

return M
