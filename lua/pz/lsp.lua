--  This function gets run when an LSP connects to a particular buffer.

local on_attach = function(_--[[ client ]], bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>h', require('pz/hover').pz_hover, '[H]over')
  nmap('<leader>r', function()
    require('pz/format').pz_format(bufnr)
  end, 'Fo[r]mat')

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
end

-- Should be called before any LSP config
require('neodev').setup({})

local servers = {
  clangd = {},
  eslint = {},
  tsserver = {},
  zls = {},
  pylsp = {}, -- TODO: find a better Python LSP
  cssls = {},
  sqlls = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- diagnostics = { globals = { 'vim' } },
      completion = {
        callSnippet = "Replace"
      }
    },
  },
}

require('neodev').setup({})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
local default_capabilities = require('cmp_nvim_lsp').default_capabilities(lsp_capabilities)

local config_overrides = {
  sqlls = function(config)
    config.root_dir = function(fname)
      local util = require('lspconfig.util')
      return util.find_git_ancestor(fname) or util.path.dirname(fname)
    end
    config.on_init = function(client)
      client.handlers["textDocument/publishDiagnostics"] = function()
        --[[ Empty ]]
      end
    end
    return config
  end,

  cssls = function(config)
    local capabilities = require('cmp_nvim_lsp').default_capabilities(lsp_capabilities)
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    config.capabilities = capabilities
    return config
  end
}

-- Untracked custom local configs (Example: OS specific config; Work VS personal; etc.)
local has_custom_configs, local_config_overrides = pcall(require, 'pz/custom_lsp_configs')
if not has_custom_configs then
  local_config_overrides = {}
end

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
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
    require('lspconfig')[server_name].setup(config)
  end,
}

-- nvim-cmp setup
local cmp = require('cmp')
local luasnip = require('luasnip')

luasnip.config.setup({})

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete({}),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
  },
}
