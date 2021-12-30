local lsp_cfg = require('lspconfig')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lsp_cfg.cssls.setup({
  capabilities = capabilities,
})
