return {
	{ "vim-fugitive", cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gedit", "Gread", "Gwrite", "GBrowse" } },
	{ "vim-rhubarb", lazy = false }, -- Registers GitHub handlers for Fugitive.
	{
		"gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		after = function()
			require("gitsigns").setup({})
		end,
	},
	{
		"refactoring.nvim",
		cmd = "Refactor",
		on_require = "refactoring",
		after = function()
			require("refactoring").setup({})
		end,
	},
	{
		"overseer.nvim",
		on_require = "overseer",
		cmd = { "OverseerRun", "OverseerToggle", "OverseerOpen", "OverseerClose" },
		dep_of = "compiler.nvim",
		after = function()
			require("overseer").setup({
				task_list = {
					direction = "bottom",
					min_height = 25,
					max_height = 25,
					default_detail = 1,
				},
			})
		end,
	},
	{
		"compiler.nvim",
		cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
		before = function()
			require("lze").trigger_load("telescope.nvim")
		end,
		after = function()
			require("compiler").setup({})
		end,
	},
	{ "nvim-dap", on_require = "dap" },
	{
		"easy-dotnet.nvim",
		ft = "cs",
		cmd = "Dotnet",
		after = function()
			require("easy-dotnet").setup({})
			require("cmp").register_source("easy-dotnet", require("easy-dotnet").package_completion_source)
		end,
	},
	{
		"markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = "markdown",
		beforeAll = function()
			vim.g.mkdp_theme = "dark"
			vim.g.mkdp_markdown_css = ""
		end,
	},
	{
		"auto-save.nvim",
		cmd = "ASToggle",
		after = function()
			require("auto-save").setup({})
		end,
	},
	{
		"zen-mode.nvim",
		cmd = "ZenMode",
		after = function()
			require("zen-mode").setup({
				window = {
					width = 80,
					options = {
						wrap = true,
						linebreak = true,
						breakindent = false,
						breakindentopt = "",
						sidescroll = 0,
						showbreak = "",
						list = false,
						number = false,
						relativenumber = false,
						colorcolumn = "",
					},
				},
				gitsigns = { enabled = true },
				tmux = { enabled = true },
				kitty = { enabled = true },
				wezterm = { enabled = true },
			})
		end,
	},
	{
		"thesaurus_query.vim",
		cmd = { "ThesaurusQueryReplace", "ThesaurusQueryReplaceCurrentWord" },
		beforeAll = function()
			vim.g.tq_openoffice_en_file = "~/Documents/MyThes-1.0/th_en_US_new"
			vim.g.tq_enabled_backends = { "openoffice_en", "datamuse_com" }
		end,
	},
	{
		"codecompanion.nvim",
		cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
		on_require = "codecompanion",
		after = function()
			require("codecompanion").setup({
				interactions = { chat = { adapter = "copilot_acp" } },
			})
		end,
	},
}
