-- Setup lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Plugins themselves
require('lazy').setup({
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Snippets
    'L3MON4D3/LuaSnip',
    config = function()
      local snippets_path = vim.fn.stdpath("config") .. "/snippets"
      require("luasnip.loaders.from_lua").load({ paths = snippets_path })
    end,
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
    },
  },

  {
    -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim', opts = {}
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'tokyonight',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { { 'filename', path = 1 } },
        lualine_c = {
          {
            'diagnostics',
            sections = { 'error', 'warn' },
            sources = { 'nvim_diagnostic' },
          },
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
    },
  },

  {
    -- "gc" to comment visual regions/lines
    'numToStr/Comment.nvim', opts = {}
  },

  {
    -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ":TSUpdate",
  },

  {
    'nvim-treesitter/playground',
  },

  {
    -- Colorscheme
    'folke/tokyonight.nvim',
    config = function()
      require('tokyonight').setup({
        style = 'moon',
        on_highlights = function(highlights, colors)
          local util = require('tokyonight.util')
          highlights['DiagnosticUnnecessary'] = {
            bg = util.blend(colors['fg'], colors['bg'], 0.2),
            underline = true,
          }
        end,
      })
      vim.cmd.colorscheme('tokyonight-moon')
    end,
  },
}, {
  git = {
    url_format = 'git@github.com:%s.git',
  }
})


-- [[ Telescope ]]
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<esc>'] = require('telescope.actions').close,
      },
    },
  },
}
pcall(require('telescope').load_extension, 'fzf')


-- [[ Treesitter ]]
require('nvim-treesitter.configs').setup({
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'lua', 'python', 'tsx', 'typescript', 'query' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  indent = {
    enable = true
  },

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

