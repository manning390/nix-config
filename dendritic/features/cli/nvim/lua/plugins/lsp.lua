return {
	{
		"nvim-lspconfig",
		lazy = false, -- Register servers before the initial buffer's FileType event.
		priority = 60,
		after = function()
			require("config.lsp")
		end,
	},
	{
		"lazydev.nvim",
		ft = "lua",
		after = function()
			require("lazydev").setup({})
		end,
	},
	{
		"typescript-tools.nvim",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		after = function()
			require("typescript-tools").setup({})
		end,
	},
	{
		"phpactor-nvim",
		ft = { "php", "blade" },
		cmd = "PhpActor",
		after = function()
			require("phpactor").setup({
				install = {
					-- The PHP application is a Nix package, not a mutable Git checkout.
					bin = "phpactor",
					php_bin = "", -- Run Nix's executable wrapper directly, not via PHP.
					check_on_startup = "none",
				},
				lspconfig = { enabled = false },
			})
		end,
	},
	{
		"conform.nvim",
		on_require = "conform", -- Also covers formatexpr and :Format.
		after = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					typescript = { "prettierd", "prettier", stop_after_first = true },
					typescriptreact = { "prettierd", "prettier", stop_after_first = true },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					javascriptreact = { "prettierd", "prettier", stop_after_first = true },
					html = { "prettierd", "prettier", stop_after_first = true },
					svelte = { "prettierd", "prettier", stop_after_first = true },
					php = { "pint" },
					nix = { "alejandra" },
					json = { "fixjson", "jq" },
					json5 = { "fixjson" },
					cs = { "csharpier" },
					["_"] = { "codespell" },
					["*"] = { "trim_whitespace" },
				},
				default_format_opts = { lsp_format = "fallback" },
			})
		end,
	},
}
