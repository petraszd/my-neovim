vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.textwidth = 119
vim.opt.number = true
vim.opt.secure = true
vim.opt.hlsearch = false
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.mouse = "a"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.wo.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.relativenumber = true


-- TODO: remove
vim.keymap.set("n", "<F3>", function()
  print("Reloading pz_format")
  package.loaded["pz/format"] = nil
  require("pz/format")
  vim.cmd("messages clear")
end, {})

-- Special filetype cases for 2 space indent
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "lua",
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
    "less",
  },
  callback = function()
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
  end,
})

-- Removes leading whitespaces on save.
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = "*",
  command = [[ %s/\s\+$//e ]],
})

vim.opt.clipboard:append({ "unnamedplus" })
vim.opt.completeopt = { "menu", "menuone", "noselect" }


----------------------
-- PLUGINS (lazy.nvim)
----------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "git@github.com:folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Plugins themselves
require("lazy").setup({
  {
    -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      {
        "williamboman/mason.nvim",
        config = true
      },
      "williamboman/mason-lspconfig.nvim",
      -- Additional lua configuration, makes nvim stuff amazing!
      "folke/neodev.nvim",
    },
  },

  {
    -- Snippets
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local snippets_path = vim.fn.stdpath("config") .. "/snippets"
      require("luasnip.loaders.from_lua").load({ paths = { snippets_path } })
    end,
  },

  {
    -- Autocompletion
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  {
    -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    opts = {}
  },

  {
    -- Set lualine as statusline
    "nvim-lualine/lualine.nvim",
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = "tokyonight",
        component_separators = "|",
        section_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { { "filename", path = 1 } },
        lualine_c = {
          {
            "diagnostics",
            sections = { "error", "warn" },
            sources = { "nvim_diagnostic" },
          },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" }
      },
    },
  },

  {
    -- "gc" to comment visual regions/lines
    "numToStr/Comment.nvim",
    opts = {}
  },

  {
    -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = { "nvim-lua/plenary.nvim", },
  },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = "make",
    cond = function()
      return vim.fn.executable "make" == 1
    end,
  },

  {
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
  },

  {
    "nvim-treesitter/playground",
  },

  {
    -- Colorscheme
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        style = "moon",
        on_colors = function() end,
        on_highlights = function(highlights, colors)
          local util = require("tokyonight.util")
          highlights["DiagnosticUnnecessary"] = {
            bg = util.blend(colors["fg"], colors["bg"], 0.2),
            underline = true,
          }
          highlights["LineNr"] = {
            fg = util.lighten(highlights["LineNr"].fg, 0.9)
          }
        end,
      })
      vim.cmd.colorscheme("tokyonight-moon")
    end,
  },
}, {
  git = {
    url_format = "git@github.com:%s.git",
  }
})

-------------------------
-- Telescope Plugin Setup
-------------------------
require("telescope").setup {
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
        ["<esc>"] = require("telescope.actions").close,
      },
    },
  },
}
pcall(require("telescope").load_extension, "fzf")

-------------
-- Treesitter
-------------
require("nvim-treesitter.configs").setup({
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    "c",
    "lua",
    "python",
    "tsx",
    "typescript",
    "javascript",
    "query",
    "gdscript",
    "vimdoc",
  },

  auto_install = false,
  indent = { enable = true },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  modules = {},
  sync_install = false,
  ignore_install = {},
})
vim.keymap.set("n", "<leader>w", "<C-w>w", { desc = "Next [W]indow" })
vim.keymap.set("n", "<leader>v", "<C-w>v", { desc = "Split [V]ertical" })
vim.keymap.set("n", "<leader>c", "<C-w>c", { desc = "[C]lose window" })
vim.keymap.set("n", "<leader>o", "<C-w>o", { desc = "[O]nly window" })

vim.keymap.set("n", "<leader>s", ":wa<CR>", { desc = "[S]ave All" })
vim.keymap.set("n", "<leader>e", ":Ex<CR>", { desc = "[E]xplore" })

vim.keymap.set("n", "<leader>th", function()
  vim.o.hlsearch = not vim.o.hlsearch
end, { desc = "[T]oggle [H]ighlight" })

vim.keymap.set("i", "kk", "<C-p>")
vim.keymap.set("i", "jj", "<C-n>")

local telescope_builtin = require("telescope.builtin")
local telescope_themes = require("telescope.themes")

vim.keymap.set("n", "<leader>b", function()
  telescope_builtin.buffers({
    sort_lastused = true,
    sort_mru = true,
  })
end, { desc = "Find existing [B]uffers" })
vim.keymap.set("n", "<leader>/", function()
  telescope_builtin.current_buffer_fuzzy_find(
    telescope_themes.get_dropdown({
      winblend = 10,
      previewer = false,
    })
  )
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>p", telescope_builtin.find_files, { desc = "[P] Search Files" })
vim.keymap.set("n", "<leader>f", telescope_builtin.live_grep, { desc = "[F] Search by Grep" })
vim.keymap.set("n", "<leader>m", telescope_builtin.marks, { desc = "[M] Search by Marks" })

vim.keymap.set("n", "<leader>d", vim.diagnostic.goto_next, { desc = "[D] Go to next diagnostic message" })

-- On LSP connects to a particular buffer.
local on_attach = function(_ --[[ client ]], bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  nmap("<leader>h", require("pz/hover").pz_hover, "[H]over")
  nmap("<leader>r", function()
    require("pz/format").pz_format(bufnr)
  end, "Fo[r]mat")

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

  -- Lesser used LSP functionality
  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
end

-- Should be called before any LSP config
require("neodev").setup({})

local servers = {
  clangd = {},
  eslint = {},
  tsserver = {},
  zls = {},
  pylsp = {}, -- TODO: find a better Python LSP
  cssls = {},
  sqlls = {},
  gdscript = {},
  omnisharp = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- diagnostics = { globals = { "vim" } },
      completion = {
        callSnippet = "Replace"
      }
    },
  },
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
local default_capabilities = require("cmp_nvim_lsp").default_capabilities(lsp_capabilities)

local config_overrides = {
  sqlls = function(config)
    config.root_dir = function(fname)
      local util = require("lspconfig.util")
      return util.find_git_ancestor(fname) or util.path.dirname(fname)
    end
    config.on_init = function(client)
      client.handlers["textDocument/publishDiagnostics"] = function()
        -- Empty
      end
    end
    return config
  end,

  cssls = function(config)
    local capabilities = require("cmp_nvim_lsp").default_capabilities(lsp_capabilities)
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    config.capabilities = capabilities
    return config
  end,

  omnisharp = function(config)
    local brew_prefix = string.gsub(vim.fn.system("brew --prefix"), "\n", "")
    local omnisharp_exe = brew_prefix .. "/bin/omnisharp/OmniSharp.exe"
    config.cmd = { "mono", omnisharp_exe }
    return config
  end,
}

-- Untracked custom local configs (Example: OS specific config; Work VS personal; etc.)
local has_custom_configs, local_config_overrides = pcall(require, "pz/custom_lsp_configs")
if not has_custom_configs then
  local_config_overrides = {}
end

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
  ensure_installed = vim.tbl_filter(function(x)
    return x ~= "gdscript" -- Mason registry does not have info about gdscript
  end, vim.tbl_keys(servers)),
})

local function setup_lsp_server(server_name)
  local settings = servers[server_name]
  local config = {
    capabilities = default_capabilities,
    on_attach = on_attach,
    settings = settings,
  }
  if config_overrides[server_name] ~= nil then
    config = config_overrides[server_name](config)
  end
  if local_config_overrides[server_name] ~= nil then
    config = local_config_overrides[server_name](config)
  end
  require("lspconfig")[server_name].setup(config)
end

-- Setup gdscript manually
setup_lsp_server("gdscript")

mason_lspconfig.setup_handlers({ setup_lsp_server })

-- nvim-cmp setup
local cmp = require("cmp")
local luasnip = require("luasnip")

luasnip.config.setup({})

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete({}),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
  },
})
