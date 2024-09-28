local au = vim.api.nvim_create_autocmd
local ag = vim.api.nvim_create_augroup

local numbertoggle = ag('numbertoggle', { clear = true })
au({'BufEnter', 'FocusGained', 'InsertLeave'}, {
    group = numbertoggle,
    command = 'set relativenumber'
})
au({'BufLeave', 'FocusLost', 'InsertEnter'}, {
    group = numbertoggle,
    command = 'set norelativenumber'
})

au({'BufEnter', 'BufNew', 'BufNewFile', 'BufWinEnter'}, {
    group = ag('treesitter_fold_workaround', {}),
    callback = function()
        vim.opt.foldmethod = 'expr'
        vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    end
})
-- au({'BufReadPost', 'FileReadPost', 'BufEnter'}, {
--     group = ag('openfolds', {clear = true}),
--     command = 'normal zR'
-- })
au('TextYankPost', {
  group = ag('yank_highlight', {clear = true}),
  pattern = '*',
  callback = function()
    vim.highlight.on_yank { higroup='IncSearch', timeout=300 }
  end,
})
-- Show line diagnostics automatically in hover window
au({'CursorHold', 'CursorHoldI'}, {
    pattern = {'*'},
    group = ag('diagnostic', {clear = true}),
    callback = function()
      vim.diagnostic.open_float(nil, {focus=false})
    end
})
au({'BufEnter'}, {
    group = ag('blade', {clear = true}),
    pattern = '*.blade.php',
    command = 'set filetype=blade.php',
})
