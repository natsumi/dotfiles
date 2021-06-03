


return require("packer").startup(function()
	-- Packer can manage itself
        use "wbthomason/packer.nvim"

        -- Themes
        use 'shaunsingh/solarized.nvim'
        use 'shaunsingh/moonlight.nvim'
        use 'shaunsingh/nord.nvim'

        --
        -- Look & Feel
        --
        -- Syntax coloring
        use "norcalli/nvim-colorizer.lua"

        -- Top status bar
        use "akinsho/nvim-bufferline.lua"

        use {
          'glepnir/galaxyline.nvim',
            branch = 'main',
            -- your statusline
            config = function() require'my_statusline' end,
            -- some optional icons
            requires = {'kyazdani42/nvim-web-devicons', opt = true}
        }


        -- Show tab indicators
        use {"lukas-reineke/indent-blankline.nvim", branch = "lua"}
        use {
          'lewis6991/gitsigns.nvim',
          requires = {
            'nvim-lua/plenary.nvim'
          }
        }

        --
        -- Language Specific
        --

        -- Auto add closing pair
        use "windwp/nvim-autopairs"

        -- snippet support

        -- file managing , picker etc
        use {
          'nvim-telescope/telescope.nvim',
          requires = {
            {'nvim-lua/popup.nvim'},
            {'nvim-lua/plenary.nvim'}
          }
        }

        use "kyazdani42/nvim-tree.lua"

        -- utils
        use 'tomtom/tcomment_vim'
        use 'tpope/vim-repeat'
        use 'tpope/vim-surround'
        use 'machakann/vim-highlightedyank'
        use "folke/which-key.nvim"
end)
