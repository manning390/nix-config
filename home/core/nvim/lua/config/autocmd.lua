local au = vim.api.nvim_create_autocmd
local ag = vim.api.nvim_create_augroup

local numbertoggle = ag('numbertoggle', { clear = true })
au({ 'BufEnter', 'FocusGained', 'InsertLeave' }, {
    group = numbertoggle,
    command = 'set relativenumber'
})
au({ 'BufLeave', 'FocusLost', 'InsertEnter' }, {
    group = numbertoggle,
    command = 'set norelativenumber'
})

au({ 'BufEnter', 'BufNew', 'BufNewFile', 'BufWinEnter' }, {
    group = ag('treesitter_fold_workaround', {}),
    callback = function()
        vim.opt.foldmethod = 'expr'
        vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    end
})
au({ 'FileType' }, {
    group = ag('treesitter_highlight', {}),
    pattern = '*',
    callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype

        local ignore_ft = { "TelescopePrompt", "TelescopeResults", "notify", "help", "fugitive",
            "cmp_menu", "cmp_docs",
            "lazy", "lazy_backdrop",
            "bash", "sh"
        }
        if vim.tbl_contains(ignore_ft, ft) then return end

        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
            -- vim.notify("No treesitter lang for filetype: " .. ft, vim.log.levels.WARN)
            return
        end

        local ok, err = pcall(vim.treesitter.start, buf, lang)
        if not ok then
            vim.notify("Treesitter start failed: "..tostring(err), vim.log.levels.ERROR)
        end
    end,
})
-- au({'BufReadPost', 'FileReadPost', 'BufEnter'}, {
--     group = ag('openfolds', {clear = true}),
--     command = 'normal zR'
-- })
au('TextYankPost', {
    group = ag('yank_highlight', { clear = true }),
    pattern = '*',
    callback = function()
        vim.hl.on_yank { higroup = 'IncSearch', timeout = 300 }
    end,
})
-- Show line diagnostics automatically in hover window
au({ 'CursorHold', 'CursorHoldI' }, {
    pattern = { '*' },
    group = ag('diagnostic', { clear = true }),
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end
})
-- au({ 'BufEnter' }, {
--     group = ag('blade', { clear = true }),
--     pattern = '*.blade.php',
--     command = 'set filetype=blade.php',
-- })
