-- Global settings
require "mappings"
require "settings"

-- bootstrap snippet from: https://github.com/wbthomason/packer.nvim/issues/198#issuecomment-808927939
local fn = vim.fn

-- Auto install packer.nvim
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.isdirectory(install_path) == 0 then
  fn.system({"git", "clone", "https://github.com/wbthomason/packer.nvim", install_path})
  require("plugin_specification")
  vim.cmd 'autocmd User PackerComplete ++once lua require("plugins")'
  require("packer").sync()
else
  require("plugins")
end

require "themes"

-- Plugin Configuration
require "file-icons" -- Icons for nvimTree
