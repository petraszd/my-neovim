vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_bufsettings = "noma nomod number nowrap ro nobl"

vim.opt.textwidth = 119
vim.opt.number = true
vim.opt.secure = true
vim.opt.hlsearch = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
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
vim.opt.showmode = false
vim.opt.scrolloff = 10
vim.opt.laststatus = 3

-- Special filetype cases for 2 space indent
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "lua",
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
    "less",
    "html",
    "htmldjango",
    "xml",
    "sql",
  },
  callback = function()
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
  end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Removes leading whitespaces on save.
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = "*",
  command = [[ %s/\s\+$//e ]],
})

vim.opt.clipboard:append({ "unnamedplus" })
vim.opt.completeopt = { "menu", "menuone", "noselect" }


----------
-- PLUGINS
----------

-- Built-in

vim.cmd([[packadd cfilter]])

-- Lazy Plugins

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
      require("luasnip.loaders.from_vscode").lazy_load()
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
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      picker = {},
    }
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
        style = "storm",
        on_colors = function() end,
        on_highlights = function(highlights, colors)
          local util = require("tokyonight.util")
          highlights["DiagnosticUnnecessary"] = {
            bg = util.blend(colors["fg"], 0.2, colors["bg"]),
            underline = true,
          }
          local current_line_fg = highlights["LineNr"].fg
          highlights["LineNr"] = {
            fg = util.lighten(current_line_fg, 0.7),
          }
          highlights["CursorLineNr"] = {
            fg = util.lighten(current_line_fg, 0.7),
          }
          highlights["LineNrAbove"] = {
            fg = util.lighten(current_line_fg, 0.9),
          }
          highlights["LineNrBelow"] = {
            fg = util.lighten(current_line_fg, 0.9),
          }
          local current_separator_fg = highlights["WinSeparator"].fg
          highlights["WinSeparator"] = {
            bold = true,
            fg = util.lighten(current_separator_fg, 0.6),
          }
        end,
      })
      vim.cmd.colorscheme("tokyonight-storm")
    end,
  },

  -- file_colors_plugin_item,
}, {
  git = {
    url_format = "git@github.com:%s.git",
  }
})

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
    "rust",
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


-----------------
-- Random keymaps
-----------------
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

vim.keymap.set("n", "<leader>;", ":cn<CR>", { desc = "Next Buffer in Quickfix" })
vim.keymap.set("n", "<leader>,", ":cp<CR>", { desc = "Prev Buffer in Quickfix" })

vim.keymap.set("n", "<leader>fb", Snacks.picker.buffers, { desc = "Pick [B]uffer" })
vim.keymap.set("n", "<leader>ff", Snacks.picker.files, { desc = "Pick [F]ile" })
vim.keymap.set("n", "<leader>fg", Snacks.picker.grep, { desc = "Grep in the project" })
vim.keymap.set("n", "<leader>f/", Snacks.picker.lines, { desc = "Grep in the current buffer" })
vim.keymap.set("n", "<leader>fw", Snacks.picker.grep_word, { desc = "Grep files by current [W]ord" })
vim.keymap.set("n", "<leader>fd", Snacks.picker.diagnostics_buffer, { desc = "[D]iagnostics in the current buffer" })
vim.keymap.set("n", "<leader>r", function()
  require("pz/format").pz_format(vim.api.nvim_get_current_buf())
end, { desc = "Fo[r]mat" })

-- On LSP connects to a particular buffer.
local on_attach = function(_ --[[ client ]], bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  -- TODO: stupid: remove it in favor of `K`
  nmap("<leader>h", require("pz/hover").pz_hover, "[H]over")
  vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("gr", function () Snacks.picker.lsp_references({ include_current = true }) end, "[G]oto [R]eferences")
  nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmap("<leader>ds", Snacks.picker.lsp_symbols, "[D]ocument [S]ymbols")

  -- Lesser used LSP functionality
  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
end

-- Should be called before any LSP config
require("neodev").setup({})

local servers = {
  clangd = {},
  eslint = {},
  ts_ls = {},
  zls = {},
  pyright = {
    python = {
      disableOrganizeImports = true,
      analysis = {
        typeCheckingMode = "off",
      }
    }
  },
  ruff = {},
  cssls = {},
  gopls = {},
  gdscript = {},
  omnisharp = {},
  rust_analyzer = {
    ["rust-analyzer"] = {
      cargo = {
        features = "all",
        -- extraArgs = { "+nightly", },
      },
    },
  },
  lua_ls = {
    Lua = {
      semantic = { enable = false },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { globals = { "vim" } },
      completion = {
        callSnippet = "Replace"
      }
    },
  },
  helm_ls = {},
  terraformls = {},
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
    -- Mason registry does not have info about gdscript
    return x ~= "gdscript"
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
  vim.lsp.enable(server_name)
  vim.lsp.config(server_name, config)
end

for server_name in pairs(servers) do
  setup_lsp_server(server_name)
end


-- luasnip
local luasnip = require("luasnip")

luasnip.config.setup({})
vim.keymap.set({ "i", "s" }, "<C-L>", function()
  if luasnip.jumpable() then
    luasnip.jump(1)
  end
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-J>", function()
  if luasnip.jumpable() then
    luasnip.jump(-1)
  end
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-E>", function()
  if luasnip.choice_active() then
    luasnip.change_choice(1)
  end
end, { silent = true })

-- nvim-cmp setup
local cmp = require("cmp")

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
      elseif luasnip.expandable() then
        luasnip.expand()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
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
