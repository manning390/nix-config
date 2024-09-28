vim.api.nvim_create_user_command('W', ':w', {}) -- Fat finger save
vim.api.nvim_create_user_command('Es', ':EslintFixAll', {}) -- Fast alias

-- Leverages tpope/abolish.vim :Subvert to create commands to swap the pairs in the list below
-- ie, :'<,'>WH => var_width -> var_height
-- let Width = mything.box.width()
for from,to in pairs({
		x = 'y',
		y = 'x',
		width = 'height',
		height = 'width',
	})
do
	local cmd = string.upper(string.sub(from,1,1))..string.upper(string.sub(to,1,1))
	vim.api.nvim_create_user_command(cmd, function(opt)
		local reg = vim.fn.getreg('/')
		vim.cmd(opt.line1..','..opt.line2..'Subvert/'..from..'/'..to..'/igew')
		vim.cmd('let @/="'..reg.. '"')
		end,
	{range = true})
end

