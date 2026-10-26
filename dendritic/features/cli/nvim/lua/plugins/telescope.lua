local specs = {
	{
		"telescope.nvim",
		cmd = "Telescope",
		on_require = "telescope",
		after = function()
			require("config.telescope").setup()
		end,
	},
	{
		"browser-bookmarks",
		dep_of = "telescope.nvim",
		after = function()
			require("browser_bookmarks").setup({
				selected_browser = "firefox",
				config_dir = vim.env.BROWSER_CONFIG_DIR,
			})
		end,
	},
}

for _, name in ipairs({
	"telescope-live-grep-args.nvim",
	"telescope-fzf-native.nvim",
	"telescope-emoji.nvim",
	"telescope-heading",
	"tailiscope",
	"github-coauthors",
	"git-worktree.nvim",
}) do
	table.insert(specs, { name, dep_of = "telescope.nvim" })
end

return specs
