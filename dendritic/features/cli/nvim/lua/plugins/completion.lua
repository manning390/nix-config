-- cmp sources use after/plugin scripts. packadd alone does not source those
-- when loaded after startup, so explicitly source each source's after directory.
local function load_source(name)
	vim.cmd.packadd(name)
	vim.cmd.packadd(name .. "/after")
end

local specs = {
	{
		"luasnip",
		on_require = "luasnip",
		dep_of = "nvim-cmp",
		after = function()
			require("config.snippets")
		end,
	},
	{
		"nvim-cmp",
		event = "InsertEnter",
		on_require = "cmp",
		before = function()
			require("lze").trigger_load("nvim-autopairs")
		end,
		after = function()
			require("config.cmp")
		end,
	},
	{ "lspkind.nvim", on_require = "lspkind" },
}

for _, name in ipairs({
	"cmp-buffer",
	"cmp-calc",
	"cmp-spell",
	"cmp-nvim-lua",
	"cmp-path",
	"cmp-async-path",
	"cmp_luasnip",
	"cmp-nvim-lsp-signature-help",
}) do
	table.insert(specs, {
		name,
		on_plugin = "nvim-cmp",
		load = load_source,
	})
end

return specs
