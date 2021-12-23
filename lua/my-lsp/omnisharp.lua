local lsp_cfg = require('lspconfig')

lsp_cfg.omnisharp.setup({
  cmd = { "/usr/local/bin/omnisharp", "--languageserver" , "--hostPID", tostring(vim.fn.getpid()) };
})
