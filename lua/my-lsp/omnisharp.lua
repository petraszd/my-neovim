local lsp_cfg = require('lspconfig')
local lsp_util = require('lspconfig.util')

lsp_cfg.omnisharp.setup({
  cmd = { "/usr/local/bin/omnisharp", "--languageserver" , "--hostPID", tostring(vim.fn.getpid()) },
  root_dir = function(fname)
    return lsp_util.root_pattern("*.csproj", "*.sln")(fname)
  end,
})
