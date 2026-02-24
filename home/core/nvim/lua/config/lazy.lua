local opts = {
	dev = {
		path = "~/Documents",
	},
}
local plugins = {
	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"folke/neodev.nvim", -- Additional lua information
				-- config = function()
				-- 	require('neodev').setup({
				-- 		library = { plugins = {"neotest"}, types = true},
				-- 	})
				-- end
			},
		},
	},
	{
		"creativenull/efmls-configs-nvim", -- configurations for efm lang
		version = "v1.x.x",          -- tag is optional, but recommended
		dependencies = { "neovim/nvim-lspconfig" },
	},
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {},
	},
	{
		"nvimtools/none-ls.nvim",
		opts = function()
			local nls = require("null-ls")
			return {
				sources = {
					nls.builtins.formatting.prettier,
					nls.builtins.completion.spell,
					-- require("none-ls.diagnostics.eslint"),
					--require("none-ls.diagnostics.php")
				}
			}
		end,
		dependencies = {
			"gbprod/none-ls-php.nvim",
			"nvimtools/none-ls-extras.nvim",
		}
	},
	{
		"Zeioth/compiler.nvim",
		cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
		dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
		opts = {}
	},
	{ -- PHP Actions
		"gbprod/phpactor.nvim",
		tag = "v1.0.1",
		lazy = true,
		ft = "php",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("phpactor").setup({
				install = {
					path = vim.fn.stdpath("data") .. "/lazy/phpactor",
					branch = "2023.09.24.0",
					bin = vim.fn.stdpath("data") .. "/lazy/phpactor/bin/phpactor",
					php_bin = "php",
					composer_bin = "composer2",
					git_bin = "git",
					check_on_startup = "none",
				},
				lspconfig = {
					enabled = false,
					options = {},
				},
			})
		end,
	},
	{
		enabled = false,
		"adalessa/laravel.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"tpope/vim-dotenv",
			"MunifTanjim/nui.nvim",
			"nvimtools/none-ls.nvim",
		},
		cmd = { "Sail", "Artisan", "Composer", "Npm", "Laravel" },
		keys = {
			{ "<leader>la", ":Laravel artisan<cr>" },
			{ "<leader>lr", ":Laravel routes<cr>" },
			{ "<leader>lm", ":Laravel related<cr>" },
		},
		event = { "VeryLazy" },
		config = true,
	},
	{
		"folke/trouble.nvim",
		enabled = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"stevearc/conform.nvim",
		enabled = false,
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				typescript = { { "prettierd", "prettier" } },
				javascript = { { "prettierd", "prettier" } },
				svelte = { { "prettier", lsp_format = "fallback" } },
				php = { "pint" },
				nix = { "alejandra" },
			},
		},
	},
	-- Notifications
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
	-- Snippets
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
	},
	-- Autocomplete
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-calc",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
			{
				"dcampos/cmp-emmet-vim",
				dependencies = {
					{
						"mattn/emmet-vim",
						config = function()
							vim.g.user_emmet_leader_key = "<C-Z>"
						end,
					},
				},
			},
			"saadparwaiz1/cmp_luasnip",
			-- 'hrsh7th/cmp-cmdline',
			'hrsh7th/cmp-nvim-lsp-signature-help',
			'onsails/lspkind.nvim',
		},
	},
	-- Highlight, edit, navigate code
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
	},
	-- Tmux
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
	},
	-- Git
	"tpope/vim-fugitive", -- :G commands
	"tpope/vim-rhubarb", -- :GBrowse
	{                  -- Sidebar signs
		"lewis6991/gitsigns.nvim",
		main = "gitsigns",
		config = true,
	},

	-- Theme
	"nvim-lualine/lualine.nvim",
	{ "nvim-tree/nvim-web-devicons", lazy = false, priority = 100 },
	-- 'haystackandroid/snow'
	{
		"shaunsingh/nord.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme nord]])
		end,
	},
	-- Utils
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = { scope = { enabled = false } },
	},
	{ -- Comment toggling
		"numToStr/Comment.nvim",
		lazy = false,
		opts = {},
	},
	{
		"Wansmer/treesj",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	-- -- Our lord and savior
	"tpope/vim-abolish",    -- Better substitutions and iabbrev
	"tpope/vim-eunuch",     -- :Rename and :SudoWrite
	"tpope/vim-repeat",     -- bracket mappings and dot-repeats
	"tpope/vim-sleuth",     -- Detect tabstop and shiftwidth auto
	{
		"kylechui/nvim-surround", -- Surround operator
		version = "*",
		event = "VeryLazy",
		opts = {},
	},
	"tpope/vim-unimpaired",                        -- bracket mappings
	-- No bindings or cmds by default, make telescope command?
	{ "Vonr/align.nvim",             branch = "v2" }, -- Align things vertically
	{
		"folke/todo-comments.nvim",                -- Highlight todo comments
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{ -- Jump to keypairs via labels
		url = "https://codeberg.org/andyg/leap.nvim.git",
		ops = {}
	},
	-- {"catgoose/nvim-colorizer.lua", opts = {}},
	-- {"NTBBloodbath/color-converter.nvim", opts = {}},
	"jghauser/mkdir.nvim", -- Write non-existing folders with :w :e etc.
	{
		"windwp/nvim-autopairs",
		opts = {
			fast_wrap = {},
		},
	},
	{ "karb94/neoscroll.nvim", opts = {} }, -- Smooth scroll
	{
		"ku1ik/vim-pasta",
		config = function()
			vim.g.pasta_disabled_filetypes = { "fugitive" }
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
	},
	"xiyaowong/telescope-emoji.nvim",
	"danielvolchek/tailiscope.nvim",    -- Tailwind
	"crispgm/telescope-heading.nvim",   -- Markdown headers etc.
	{
		"dhruvmanila/browser-bookmarks.nvim", -- Browser bookmarks
		opts = {
			selected_browser = "firefox",
			config_dir = vim.env.BROWSER_CONFIG_DIR,
		},
		dependencies = { 'kkharji/sqlite.lua' }
	},
	"cwebster2/github-coauthors.nvim", -- Co-authors

	-- Harpoo"n
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		opts = {
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
			},
		},
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	"ThePrimeagen/git-worktree.nvim",
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("refactoring").setup()
		end,
	},

	-- Testing
	{
		enabled = false,
		"klen/nvim-test",
		config = function()
			require("nvim-test.runners.jest"):setup({
				args = { "--config=./src/test/js/jest.config.js", "--coverage=false", "--verbose=false" },
			})
			require("nvim-test").setup({
				silent = true,
				term = "terminal",
				termOpts = {
					direction = "horizontal", -- terminal's direction ("horizontal"|"vertical"|"float")
					-- go_back = true,
					stopinsert = true,
					keep_one = true,
				},
			})
		end,
	},
	-- {
	-- 	"nvim-neotest/neotest",
	-- 	lazy = true,
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	--    		"antoinemadec/FixCursorHold.nvim",
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 		"nvim-neotest/neotest-jest",
	-- 	},
	-- 	config = function()
	-- 		require('neotest').setup({
	-- 			adapters = {
	-- 				require('neotest-jest')({
	-- 					jestConfigFile = "./src/test/js/jest.config.ts"
	-- 				})
	-- 			}
	-- 		})
	-- 	end
	-- },
	{
		enable = false,
		"stevearc/overseer.nvim",
		dependencies = "stevearc/dressing.nvim",
		opts = {
			task_list = {
				direction = "bottom",
				min_height = 25,
				max_height = 25,
				default_detail = 1,
			}
		},
	},
	{
		"stevearc/dressing.nvim",
		opts = {},
	},

	-- Writing related plugins
	{
		"okuuva/auto-save.nvim",
		version = "^1.0.0",
		cmd = "ASToggle",
		opts = {},
	},
	-- Zen Mode
	{
		"folke/zen-mode.nvim",
		cmd = { "ZenMode", "Write" },
		dependencies = { {
			-- Dims paragraphs not working on
			"folke/twilight.nvim",
			enabled = false,
			cmd = "Twilight",
			lazy = true,
		} },
		lazy = true,
		opts = {
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
				}
			},
			gitsigns = { enabled = true },
			tmux = { enabled = true },
			kitty = { enabled = true },
			wezterm = { enabled = true },
		}
	},
	{
		"ron89/thesaurus_query.vim",
		config = function()
			-- vim.g.tq_language={'en'}
			vim.g.tq_openoffice_en_file = "~/Documents/MyThes-1.0/th_en_US_new"
			vim.g.tq_enabled_backends = { "openoffice_en", "datamuse_com" }
		end,
	},
	-- {
	-- 	"epwalsh/obsidian.nvim",
	-- 	ft = "markdown",
	-- 	dependencies = {
	-- 		"nvim-telescope/telescope.nvim",
	-- 		"nvim-lua/plenary.nvim",
	-- 	},
	-- 	opts = {
	-- 		workspaces = {
	-- 			{
	-- 				name = "Personal",
	-- 				path = "~/Documents/obsidian/Personal",
	-- 			},
	-- 			{
	-- 				name = "Work",
	-- 				path = "~/Documents/obsidian/Work",
	-- 			},
	-- 		},
	-- 		follow_url_func = function(url)
	-- 			vim.ui.open(url) -- need Neovim 0.10.0+
	-- 		end,
	-- 	},
	-- },
	{
		"manning390/wrd.nvim",
		-- dir = "~/Code/lua/wrd.nvm",
		branch = "dev",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		opts = {},
	},
}

-- Run --
require("lazy").setup(plugins, opts)
