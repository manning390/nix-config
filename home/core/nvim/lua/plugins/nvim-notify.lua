return {
	{
	"rcarriga/nvim-notify",
	main = "notify",
	priority = 70,
	config = function()
		local notify = require("notify")
		notify.setup({})
		vim.notify = notify
	end,
},
}
