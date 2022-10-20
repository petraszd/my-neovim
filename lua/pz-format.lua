_G.pz_format = function()
  local has_tsserver = false

  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  for i = 1, #clients do
    local c = clients[i]
    -- Not sure if checking just for tsserver is good enough
    if c.name == "tsserver" then
      has_tsserver = true
      break
    end
  end

  if has_tsserver then
    vim.api.nvim_command("Prettier")
  else
    vim.lsp.buf.format()
  end
end
