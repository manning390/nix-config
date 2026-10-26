return {
	{
		"nvim-ts-context-commentstring",
		dep_of = "comment.nvim",
	},
	{
		"nvim-treesitter-textobjects",
		lazy = false,
		after = function()
			require("config.treesitter")
		end,
		before = function()
			require("lze").trigger_load("nvim-ts-context-commentstring")
		end,
	},
	{
		"comment.nvim",
		lazy = false,
		after = function()
			require("Comment").setup({})
		end,
	},
	{
		"treesj",
		on_require = "treesj",
		cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
		after = function()
			require("config.treesj")
		end,
	},
	{
		"nvim-surround",
		event = "DeferredUIEnter",
		after = function()
			require("nvim-surround").setup({})
		end,
	},
	{
		"nvim-autopairs",
		event = "InsertEnter",
		on_require = "nvim-autopairs",
		after = function()
			require("nvim-autopairs").setup({ fast_wrap = {} })
		end,
	},
	{ "leap.nvim", lazy = false }, -- <Plug> mappings are defined by the plugin.
	{ "vim-tmux-navigator", lazy = false },
	{ "vim-speeddating", lazy = false },
	{ "vim-abolish", lazy = false },
	{ "vim-eunuch", lazy = false },
	{ "vim-repeat", lazy = false },
	{ "vim-sleuth", lazy = false },
	{ "vim-unimpaired", lazy = false },
	{ "align.nvim", on_require = "align" },
	{ "mkdir.nvim", lazy = false },
	{
		"vim-pasta",
		lazy = false,
		beforeAll = function()
			vim.g.pasta_disabled_filetypes = { "fugitive" }
		end,
	},
	{
		"todo-comments.nvim",
		event = { "BufReadPost", "BufNewFile" },
		after = function()
			require("todo-comments").setup({})
		end,
	},
}
