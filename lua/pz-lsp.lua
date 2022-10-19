-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<TAB>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, {'i', 's'}),
    ['<S-TAB>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, {'i', 's'}),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Set up lspconfig.
local lsp_cfg = require('lspconfig')
local lsp_util = require('lspconfig.util')
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
local has_custom_configs, custom_configs = pcall(require, 'pz-custom-lsp-configs')
if not has_custom_configs then
  custom_configs = {}
end

local function setup(lsp_server, options)
  if custom_configs[lsp_server.name] ~= nil then
    lsp_server.setup(custom_configs[lsp_server.name](options))
  else
    lsp_server.setup(options)
  end
end

setup(lsp_cfg.clangd, { capabilities = capabilities })
setup(lsp_cfg.eslint, { capabilities = capabilities })
setup(lsp_cfg.gdscript, { capabilities = capabilities })
setup(lsp_cfg.omnisharp, {
  capabilities = capabilities,
  cmd = { "/usr/local/bin/omnisharp", "--languageserver" , "--hostPID", tostring(vim.fn.getpid()) }, -- TODO: bin is wrong
  root_dir = function(fname)
    return lsp_util.root_pattern("*.csproj", "*.sln")(fname)
  end,
})
setup(lsp_cfg.pylsp, { capabilities = capabilities })
setup(lsp_cfg.tsserver, { capabilities = capabilities })
setup(lsp_cfg.zls, { capabilities = capabilities })

local cssls_capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
cssls_capabilities.textDocument.completion.completionItem = { snippetSupport = true }
setup(lsp_cfg.cssls, { capabilities = cssls_capabilities })
