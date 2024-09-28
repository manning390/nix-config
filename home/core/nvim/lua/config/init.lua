require'config.options'
require'config.notify'
require'config.keymaps'
require'config.commands'
require'config.autocmd'
require'config.telescope'

local ok, _ = pcall(dofile, './nvim/init.lua')
