-- Load plugins with packer
require "settings"

-- bootstrap snippet from: https://github.com/wbthomason/packer.nvim/issues/198#issuecomment-808927939
local fn = vim.fn

-- Auto install packer.nvim
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.isdirectory(install_path) == 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  require('plugin_specification')
  vim.cmd 'autocmd User PackerComplete ++once lua require("plugins")'
  require('packer').sync()
else
  require('plugins')
end

-- require "plugins"
require "themes"

-- key bindings
vim.g.mapleader = ' ' -- set leader to space

-- Plugin Configuration
require 'nvimTree'
require 'file-icons' -- Icons for nvimTree
require "bufferline-config"
-- require "galaxy-line-config"
require "telescope-config"
require 'indent-blankline-config'
require 'gitsigns-config'
require "whichkey-config"

require 'nvim-autopairs'.setup()
require 'colorizer'.setup()