_G.pz_search_using_grepper = function()
  local search_str = vim.fn.getreg("/")
  local _, _, _, var_str,_ = string.find(search_str, "^(\\<)(.*)(\\>)$")
  if var_str ~= nil then
    search_str = var_str
  end
  vim.api.nvim_command("GrepperRg " .. search_str)
end


vim.api.nvim_set_keymap("n", "<F5>", "<CMD>lua pz_search_using_grepper()<CR>", {})
vim.api.nvim_set_keymap("v", "<F5>", "<CMD>lua pz_search_using_grepper()<CR>", {})
