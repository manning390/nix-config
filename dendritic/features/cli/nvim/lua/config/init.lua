vim.g.mapleader = "'"
vim.g.maplocalleader = "'"

local startMsg = "Leader is " .. vim.g.mapleader

if vim.env.COLEMAK == "1" then
	startMsg = startMsg .. " Colemak layout"
	vim.g.keymaps = {
		h = "m",
		j = "n",
		k = "e",
		l = "i",
		n = "h",
		N = "H",
		f = "t",
	}
else
	vim.g.keymaps = {
		h = "h",
		j = "j",
		k = "k",
		l = "l",
		n = "n",
		N = "N",
		f = "f",
	}
end

require("config.clipboard")
require("config.options")
require("plugins")
require("config.notify")
require("config.keymaps")
require("config.commands")
require("config.autocmd")

print(startMsg)
