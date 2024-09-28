vim.g.mapleader = "'"
vim.g.maplocalleader = "'"

local startMsg = 'Leader is '.. vim.g.mapleader

if vim.env.COLEMAK == '1' then
	startMsg = startMsg .. ' Colemak layout'
	vim.g.keymaps = {
		h = 'm',
		j = 'n',
		k = 'e',
		l = 'i',
		n = 'h',
		N = 'H',
		f = 't',
	}
else
	vim.g.keymaps = {
		h = 'h',
		j = 'j',
		k = 'k',
		l = 'l',
		n = 'n',
		N = 'N',
		f = 'f',
	}
end

require'config.lazy'
require'config.notify'
require'config.options'
require'config.keymaps'
require'config.commands'
require'config.autocmd'
require'config.telescope'

local ok, _ = pcall(dofile, './nvim/init.lua')

print(startMsg)
