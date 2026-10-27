local function test()
	local lze = require("lze")
	assert(not package.loaded.lazy, "lazy.nvim must not be loaded")
	for _, name in ipairs({ "wrd-nvim", "nvim-test" }) do
		assert(lze.state(name) == nil, "disabled plugin must not have a lze spec: " .. name)
		assert(
			#vim.fn.globpath(vim.o.packpath, "pack/*/opt/" .. name, false, true) == 0,
			"disabled plugin must not be installed: " .. name
		)
	end
	assert(vim.g.colors_name == "nord", "theme must load at startup")
	assert(package.loaded["config.lsp"], "LSP configuration must run at startup")
	assert(package.loaded["config.treesitter"], "Treesitter configuration must run at startup")
	assert(not package.loaded.telescope, "keymaps must not eagerly load Telescope")
	assert(not package.loaded.harpoon, "keymaps must not eagerly load Harpoon")
	for _, name in ipairs({ "comment.nvim", "vim-pasta", "lualine.nvim", "harpoon2", "nvim-web-devicons" }) do
		assert(lze.state(name) == true, "plugin must wait for its UI/dependency trigger: " .. name)
	end
	assert(not package.loaded.cmp, "completion must wait until InsertEnter")
	assert(not package.loaded.dap, "debugger must remain deferred")
	assert(lze.state("conform.nvim") == true, "formatting must remain deferred")

	-- Plain startup plugins need only a Nix package, not a generated lze spec.
	for _, name in ipairs({
		"vim-abolish",
		"vim-eunuch",
		"vim-repeat",
		"vim-rhubarb",
		"vim-sleuth",
		"vim-speeddating",
		"vim-unimpaired",
		"mkdir.nvim",
		"leap.nvim",
	}) do
		assert(
			#vim.fn.globpath(vim.o.packpath, "pack/*/start/" .. name, false, true) > 0,
			"missing startup package: " .. name
		)
		assert(lze.state(name) == nil, "native startup package must not have a lze spec: " .. name)
	end
	assert(vim.g.loaded_abolish == 1 and vim.g.loaded_eunuch == 1, "native startup scripts must run")
	assert(vim.fn.maparg("<Plug>(leap)", "n") ~= "", "Leap must define its jump target")
	assert(vim.fn.maparg("s", "n") == "<Plug>(leap)", "Leap must preserve the custom jump binding")
	assert(
		vim.fn.maparg("<C-" .. vim.g.keymaps.h .. ">", "n"):find("TmuxNavigateLeft", 1, true),
		"navigation must preserve the configured keyboard layout"
	)
	assert(
		vim.fn.maparg("]m", "n", false, true).desc == "Treesitter: goto_next_start @function.outer",
		"native plugins must preserve Treesitter mappings"
	)

	-- Every spec must correspond to an installed optional package.
	local seen = {}
	for _, spec in ipairs(require("config.plugin-specs")) do
		local name = spec[1]
		assert(not seen[name], "duplicate spec: " .. name)
		seen[name] = true
		assert(#vim.fn.globpath(vim.o.packpath, "pack/*/opt/" .. name, false, true) > 0, "missing package: " .. name)
	end

	local telescope = require("telescope")
	if vim.fn.has("wsl") == 1 then
		assert(require("browser_bookmarks.config").values.url_open_command == "wsl-open")
		assert(vim.fn.executable("wsl-open") == 1, "WSL bookmark opener must be installed")
	end
	assert(lze.state("telescope.nvim") == false, "require must trigger Telescope setup")
	for _, name in ipairs({ "fzf", "emoji", "live_grep_args", "bookmarks", "githubcoauthors", "git_worktree" }) do
		assert(telescope.extensions[name], "missing Telescope extension: " .. name)
	end

	vim.api.nvim_exec_autocmds("InsertEnter", {})
	assert(package.loaded["config.cmp"], "InsertEnter must configure completion")
	assert(package.loaded["config.snippets"], "completion must configure snippets")
	local sources = {}
	for _, source in pairs(require("cmp").get_registered_sources()) do
		sources[source.name] = true
	end
	for _, name in ipairs({ "buffer", "calc", "spell", "nvim_lua", "async_path", "luasnip" }) do
		assert(sources[name], "unregistered cmp source: " .. name)
	end

	require("conform")
	assert(lze.state("conform.nvim") == false, "require must trigger formatting setup")
	require("treesj")
	assert(package.loaded["config.treesj"], "require must configure Treesj")
	require("dap")
	assert(lze.state("nvim-dap") == false, "require must trigger DAP loading")
	assert(package.loaded["config.dap"], "require must configure debugging")
	for _, adapter in ipairs({ "pwa-node", "pwa-chrome", "coreclr", "php" }) do
		assert(require("dap").adapters[adapter], "missing debug adapter: " .. adapter)
	end
	for _, filetype in ipairs({ "typescript", "svelte", "cs", "php" }) do
		assert(#require("dap").configurations[filetype] > 0, "missing debug configurations: " .. filetype)
	end
	for _, executable in ipairs({ "js-debug", "netcoredbg", "php-debug" }) do
		assert(vim.fn.executable(executable) == 1, "missing debug executable: " .. executable)
	end
	assert(pcall(vim.treesitter.language.add, "lua"), "Nix must supply the Lua parser")
	assert(pcall(vim.treesitter.language.add, "svelte"), "Nix must supply the Svelte parser")
	local svelte =
		vim.treesitter.get_string_parser('<button {@attach tooltip(content)} class="test">Hover me</button>', "svelte")
	local svelte_root = svelte:parse()[1]:root()
	assert(not svelte_root:has_error(), "Svelte @attach syntax must parse without errors")
	assert(svelte_root:sexpr():find("(attach_tag", 1, true), "the patched Svelte parser must recognize @attach")
	vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter", modeline = false })
	for _, name in ipairs({ "comment.nvim", "vim-pasta", "lualine.nvim", "harpoon2" }) do
		assert(lze.state(name) == false, "UI startup must load plugin: " .. name)
	end
	assert(package.loaded["config.lualine"], "UI startup must configure the statusline")
	assert(package.loaded.harpoon, "statusline must load its Harpoon dependency")
	assert(vim.fn.maparg("gcc", "n") ~= "", "deferred commenting must install mappings")
	-- Exercise the remaining setup hooks without invoking their commands. Exclude
	-- easy-dotnet because upstream setup can install/start its external backend.
	for name in pairs(seen) do
		if name ~= "easy-dotnet.nvim" and lze.state(name) then
			lze.trigger_load(name)
		end
	end
	assert(vim.fn.exists(":PhpActor") == 2, "PHP actions must expose the upstream command")
	vim.wait(100) -- Flush scheduled hook errors before exiting.
	assert(vim.v.errmsg == "", vim.v.errmsg)
end

local errors = {}
vim.notify = function(message, level)
	if level == vim.log.levels.ERROR then
		table.insert(errors, tostring(message))
	end
end

local ok, err = xpcall(test, debug.traceback)
if not ok or #errors > 0 then
	io.stderr:write((err or "") .. "\n" .. table.concat(errors, "\n") .. "\n")
	vim.cmd.cquit()
else
	print("lze smoke test passed")
	vim.cmd.qa({ bang = true })
end
