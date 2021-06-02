-- bootstrap snippet from: https://github.com/wbthomason/packer.nvim/issues/198#issuecomment-808927939
local fn = vim.fn

-- Auto install packer.nvim
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.isdirectory(install_path) == 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
--   require('plugin_specification')
--   vim.cmd 'autocmd User PackerComplete ++once lua require("my_config")'
  require('packer').sync()
-- else
--   require('my_config')
end


return require("packer").startup(function()
	-- Packer can manage itself
        use "wbthomason/packer.nvim"

        -- Themes
        use 'shaunsingh/solarized.nvim'
        use 'shaunsingh/moonlight.nvim'
        use 'shaunsingh/nord.nvim'
	--
        -- lang stuff

        -- snippet support

        -- file managing , picker etc
        use {
  'nvim-telescope/telescope.nvim',
  requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
}

        -- misc
end)
