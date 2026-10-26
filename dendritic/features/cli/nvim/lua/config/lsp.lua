-- vim.lsp.set_log_level('debug')
-- local efm_languages = {
--     lua = { require('efml-configs.formatters.stylua') }
-- }
-- Configure completion capabilities before enabling any servers.
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("clangd", {
	init_options = {
		compilationDatabaseDirectory = "build",
	},
})
vim.lsp.config("emmet_language_server", {
	filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte", "vue" },
})
vim.lsp.config("nixd", {
	settings = {
		nixd = {
			formatting = {
				command = { "alejandra" },
			},
		},
	},
})
vim.lsp.config("cssls", {
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
})
local eslint_on_attach = vim.lsp.config.eslint.on_attach
vim.lsp.config("eslint", {
	filetypes = { "javascriptreact", "typescriptreact", "javascript", "svelte" },
	on_attach = function(client, bufnr)
		if eslint_on_attach then
			eslint_on_attach(client, bufnr)
		end
		vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
			require("conform").format({ async = false })
			vim.cmd("LspEslintFixAll")
		end, { desc = "Format current buffer with LSP" })
	end,
})
vim.lsp.config("lua_ls", {
	on_init = function(client)
		local workspace = client.workspace_folders and client.workspace_folders[1]
		local path = workspace and workspace.name
		if path and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) then
			return true
		end
		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
			runtime = {
				-- Tell the language server which version of Lua you're using
				-- (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},
			telemetry = { enable = false },
			diagnostics = { globals = { "vim", "require" } },
			completion = {
				callSnippet = "Replace",
			},
		})
		client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
		return true
	end,
})
vim.lsp.enable({
	"clangd",
	"emmet_language_server",
	"tailwindcss",
	"nixd",
	"svelte",
	"vimls",
	"cssls",
	"eslint",
	"lua_ls",
	"jsonls",
})
-- vim.lsp.enable('roslyn_ls')

-- vim.lsp.config.intelephense.init_options = {}
local servers = {
	-- tsserver = {
	--     on_attach = function(client)
	--         client.server_capabilities.documentFormattingProvider = false
	--         client.server_capabilities.documentRangeFormattingProvider = false
	--     end,
	-- },
	-- phpactor = {},
	-- intelephense = {
	--     init_options = {
	--         -- licenceKey = (function()
	--         --     local f = assert(io.open(os.getenv("HOME") .. "/intelephense/license.txt", "rb"))
	--         --     local content = f:read("*line")
	--         --     f:close()
	--         --     return content
	--         -- end)()
	--     }
	-- },
	-- cssls = {
	--     on_attach = function(client)
	--         client.server_capabilities.documentFormattingProvider = false
	--         client.server_capabilities.documentRangeFormattingProvider = false
	--     end,
	-- },
	-- eslint = {
	--     filetypes = {'javascriptreact', 'typescriptreact', 'javascript', 'svelte'},
	--     on_attach = function(_, bufnr)
	--         vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
	--             vim.lsp.buf.format()
	--             vim.cmd('EslintFixAll')
	--         end, { desc = 'Format current buffer with LSP' })
	--     end,
	-- },
	-- lua_ls = {
	--     on_init = function(client)
	--         local path = client.workspace_folders[1].name
	--         if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
	--             client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
	--                 Lua = {
	--                     runtime = {
	--                         -- Tell the language server which version of Lua you're using
	--                         -- (most likely LuaJIT in the case of Neovim)
	--                         version = 'LuaJIT'
	--                     },
	--                     -- Make the server aware of Neovim runtime files
	--                     workspace = {
	--                         checkThirdParty = false,
	--                         library = {
	--                             vim.env.VIMRUNTIME
	--
	--                             -- "${3rd}/luv/library"
	--                             -- "${3rd}/busted/library",
	--                         }
	--                         -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
	--                         -- library = vim.api.nvim_get_runtime_file("", true)
	--                     },
	--                     telemetry = { enable = false },
	--                     diagnostics = { globals = { 'vim', 'require' } },
	--                     completion = {
	--                         callSnippet = "Replace"
	--                     }
	--                 }
	--             })
	--             client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
	--         end
	--         return true
	--     end,
	-- },
	-- efm = {
	--    filetypes = vim.tbl_keys(efm_languages),
	--    settings = {
	--        rootMarkers = { ".git/" },
	--        languages = vim.tbl_extend('force',
	--            require 'efmls-configs.defaults'.languages(), efm_languages
	--        )
	--   },
	--   init_options = {
	--     documentFormatting = true,
	--     documentRangeFormatting = true,
	--   },
	-- },
	-- ltex = {
	--     filetypes = { 'markdown' },
	--     filter_notifications = {
	--         'checking document'
	--     },
	--     -- on_init = function(client)
	--     --     client.server_capabilities
	--     -- end
	-- },
	-- nixd = {},
	-- svelte = {},
	-- godot = (os.getenv("GODOT") and {} or nil)
}

vim.diagnostic.config({
	virtual_text = false,
	float = {
		source = true,
	},
})
