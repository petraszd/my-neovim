vim.keymap.set('n', '<leader>w', '<C-w>w', { desc = 'Next [W]indow' })
vim.keymap.set('n', '<leader>v', '<C-w>v', { desc = 'Split [V]ertical' })
vim.keymap.set('n', '<leader>c', '<C-w>c', { desc = '[C]lose window' })
vim.keymap.set('n', '<leader>o', '<C-w>o', { desc = '[O]nly window' })

vim.keymap.set('n', '<leader>s', ':wa<CR>', { desc = '[S]ave All' })
vim.keymap.set('n', '<leader>e', ':Ex<CR>', { desc = '[E]xplore' })

vim.keymap.set('i', 'kk', '<C-p>')
vim.keymap.set('i', 'jj', '<C-n>')

-- [[ Telescope ]]
local telescope_builtin = require('telescope.builtin')
local telescope_themes = require('telescope.themes')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>b', function()
  telescope_builtin.buffers({
    sort_lastused = true,
    sort_mru = true,
  })
end, { desc = 'Find existing [B]uffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  telescope_builtin.current_buffer_fuzzy_find(
    telescope_themes.get_dropdown({
      winblend = 10,
      previewer = false,
    })
  )
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>p', telescope_builtin.find_files, { desc = '[P] Search Files' })
vim.keymap.set('n', '<leader>f', telescope_builtin.live_grep, { desc = '[F] Search by Grep' })
vim.keymap.set('n', '<leader>m', telescope_builtin.marks, { desc = '[M] Search by Marks' })

vim.keymap.set('n', '<leader>d', vim.diagnostic.goto_next, { desc = '[D] Go to next diagnostic message' })
