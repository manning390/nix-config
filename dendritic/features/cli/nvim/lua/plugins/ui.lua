return {
	{ "nvim-web-devicons", lazy = false, priority = 100 },
	{
		"nord.nvim",
		lazy = false,
		priority = 1000,
		after = function()
			vim.o.background = "dark"
			vim.cmd.colorscheme("nord")
		end,
	},
	{
		"notifier.nvim",
		lazy = false,
		priority = 70,
		beforeAll = function()
			-- Compatibility with recent Neovim nightlies.
			vim.tbl_islist = vim.tbl_islist or vim.islist
		end,
		after = function()
			require("notifier").setup({})
		end,
	},
	{
		"harpoon2",
		lazy = false,
		priority = 60, -- The statusline reads Harpoon's list.
		after = function()
			require("harpoon"):setup({ settings = { save_on_toggle = true, sync_on_ui_close = true } })
		end,
	},
	{
		"lualine.nvim",
		lazy = false,
		after = function()
			require("config.lualine")
		end,
	},
	{
		"indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		after = function()
			require("ibl").setup({ scope = { enabled = false } })
		end,
	},
	{
		"neoscroll.nvim",
		event = "DeferredUIEnter",
		after = function()
			require("neoscroll").setup({})
		end,
	},
	{
		"dressing.nvim",
		on_require = "dressing",
		event = "DeferredUIEnter",
		after = function()
			require("dressing").setup({})
		end,
	},
}
