-- Just an example, supposed to be placed in /lua/custom/

local M = {}
local override = require "custom.plugins.override"
local userPlugins = require "custom.plugins"

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

M.ui = {
    theme = "kanagawa"
}

-- /lua/custom/chadrc.lualocal
-- userPlugins = require("custom.plugins")

-- M.plugins = {
--     default_plugin_config_replace = {
--         nvim_treesitter = "custom.plugins.treesitter",
--     },
--     options = {
--         lspconfig = {
--             setup_lspconf = "custom.plugins.lspconfig",
--         },
--     },
--     status = {
--         colorizer = true,
--         dashboard = true,
--     },
--     install = userPlugins,
-- }

M.plugins = {
options = {
      lspconfig = {
         setup_lspconf = "custom.plugins.lspconfig",
      },
   },
    override = {
        ["nvim-treesitter/nvim-treesitter"] = override.treesitter
    },
    user = userPlugins
}

M.mappings = require "custom.mappings"

return M
