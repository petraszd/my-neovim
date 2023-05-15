vim.opt.textwidth = 119
vim.opt.number = true
vim.opt.secure = true
vim.opt.hlsearch = true
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.mouse = 'a'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.wo.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'lua' },
  callback = function()
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = '*',
  command = [[ %s/\s\+$//e ]],
})

vim.opt.clipboard:append({ 'unnamedplus' })
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
