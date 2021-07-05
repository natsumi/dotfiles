return require("packer").startup(
  function()
    -- Packer can manage itself
    use "wbthomason/packer.nvim"

    -- Themes
    use "shaunsingh/moonlight.nvim"
    use "shaunsingh/nord.nvim"
    use "shaunsingh/solarized.nvim"
    use "folke/tokyonight.nvim"

    --
    -- Look & Feel
    --
    -- Syntax coloring
    use {
      "norcalli/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup()
      end
    }
    use "folke/lsp-colors.nvim" --  Add LSP diagnostics highlight groups

    -- Top status bar
    use {
      "akinsho/nvim-bufferline.lua",
      config = function()
        require "bufferline-config"
      end
    }

    use {
      "glepnir/galaxyline.nvim",
      branch = "main",
      -- your statusline
      config = function()
        require "galaxy-line-config"
      end,
      -- some optional icons
      requires = {"kyazdani42/nvim-web-devicons", opt = true}
    }

    -- Show tab indicators
    use {
      "lukas-reineke/indent-blankline.nvim",
      config = function()
        require "indent-blankline-config"
      end
    }

    use {
      "lewis6991/gitsigns.nvim",
      config = function()
        require "gitsigns-config"
      end,
      requires = {
        "nvim-lua/plenary.nvim"
      }
    }

    --
    -- Language Specific
    --
    -- Syntax highlighting
    use {
      "nvim-treesitter/nvim-treesitter",
      config = function()
        require "treesitter-config"
      end
    }

    -- LSP
    use {
      "neovim/nvim-lspconfig",
      config = function()
        require "nvim-lsp-config"
      end
    }
    use "kabouzeid/nvim-lspinstall" -- adds LspInstall command
    -- LSP auto complete glyphs
    use {
      "onsails/lspkind-nvim",
      config = function()
        require("lspkind").init()
      end
    }
    use {
      "hrsh7th/nvim-compe",
      config = function()
        require "compe-config"
      end
    }
    -- Show diagnostics in a buffer window
    use {
      "folke/trouble.nvim",
      config = function()
        require("trouble").setup()
      end,
      requires = {
        "kyazdani42/nvim-web-devicons"
      }
    }

    -- Auto add closing pair
    use {
      "windwp/nvim-autopairs",
      config = function()
        require("nvim-autopairs").setup()
      end
    }

    -- Language Formatter
    -- use "sbdchd/neoformat"
    use {
      "mhartington/formatter.nvim",
      config = function()
        require "formatter-config"
      end
    }

    --
    -- snippet support
    --
    use {
      "rafamadriz/friendly-snippets",
      requires = {
        {"hrsh7th/vim-vsnip"}
      }
    }

    --
    -- Git
    --
    use {
      "TimUntersberger/neogit",
      config = function()
        require "neogit-config"
      end,
      requires = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim"
      }
    }

    --
    -- file managing , picker etc
    --
    use {
      "nvim-telescope/telescope.nvim",
      config = function()
        require "telescope-config"
      end,
      requires = {
        {"nvim-lua/plenary.nvim"},
        {"nvim-lua/popup.nvim"},
        {"nvim-telescope/telescope-media-files.nvim"}
      }
    }

    use {
      "kyazdani42/nvim-tree.lua",
      config = function()
        require "nvim-tree-config"
      end,
      requires = {"kyazdani42/nvim-web-devicons", opt = true}
    }

    -- utils
    use "tomtom/tcomment_vim"
    use "tpope/vim-repeat"
    use "tpope/vim-surround"
    use "machakann/vim-highlightedyank"
    use {
      "folke/which-key.nvim",
      config = function()
        require "whichkey-config"
      end
    }
  end
)
