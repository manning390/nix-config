vim.api.nvim_create_user_command('Q', ':q', {})                            -- Fat finger quit
vim.api.nvim_create_user_command('W', ':w', {})                            -- Fat finger save
vim.api.nvim_create_user_command('F', ':Format', {})                       -- Fat finger save
vim.api.nvim_create_user_command('Prit', 'silent !npx prettier --write % && :e && :LspRestart', {})
vim.api.nvim_create_user_command('Snips', 'e ~/.config/nvim/snippets', {}) -- Reload snippets
vim.api.nvim_create_user_command('E', ':e|lua vim.diagnostic.reset()', {})     -- Reset diagnostics

-- Leverages tpope/abolish.vim :Subvert to create commands to swap the pairs in the list below
-- ie, :'<,'>WH => var_width -> var_height
-- let Width = mything.box.width()
for from, to in pairs({
    x = 'y',          -- XY
    y = 'x',          -- YX
    width = 'height', -- WH
    height = 'width'  -- HW
}) do
    -- Cmd is the first character of each swap uppercse
    local cmd = string.upper(string.sub(from, 1, 1)) .. string.upper(string.sub(to, 1, 1))
    vim.api.nvim_create_user_command(cmd, function(opt)
        local reg = vim.fn.getreg('/')                                         -- Save current search buffer
        vim.cmd(opt.line1 .. ',' .. opt.line2 .. 'Subvert/' .. from .. '/' .. to .. '/igew') -- flags, case-insensitive, all occurances in line, no error warnings if not found, whole word match
        vim.cmd('let @/="' .. reg .. '"')                                      -- Return search buffer to original state
    end, { range = true })
end

vim.api.nvim_create_user_command('Tw', ':Telescope tailiscope', {})

-- From https://github.com/stevearc/overseer.nvim/blob/master/doc/recipes.md#make-similar-to-vim-dispatch
vim.api.nvim_create_user_command("Make", function(params)
  -- Insert args at the '$*' in the makeprg
  local cmd, num_subs = vim.o.makeprg:gsub("%$%*", params.args)
  if num_subs == 0 then
    cmd = cmd .. " " .. params.args
  end
  local task = require("overseer").new_task({
    cmd = vim.fn.expandcmd(cmd),
    components = {
      { "on_output_quickfix", open = not params.bang, open_height = 8 },
      "default",
    },
  })
  task:start()
end, {
  desc = "Run your makeprg as an Overseer task",
  nargs = "*",
  bang = true,
})
