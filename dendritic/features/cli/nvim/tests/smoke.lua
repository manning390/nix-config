local function test()
	local lze = require("lze")
	assert(not package.loaded.lazy, "lazy.nvim must not be loaded")
	assert(vim.g.colors_name == "nord", "theme must load at startup")
	assert(package.loaded["config.lsp"], "LSP configuration must run at startup")
	assert(package.loaded["config.treesitter"], "Treesitter configuration must run at startup")
	assert(not package.loaded.telescope, "keymaps must not eagerly load Telescope")
	assert(not package.loaded.cmp, "completion must wait until InsertEnter")
	assert(not package.loaded.dap, "debugger must remain deferred")
	assert(lze.state("conform.nvim") == true, "formatting must remain deferred")

	-- Every spec must correspond to an installed optional package.
	local seen = {}
	for _, group in ipairs({ "ui", "editing", "lsp", "completion", "telescope", "tools" }) do
		for _, spec in ipairs(require("plugins." .. group)) do
			local name = spec.name or spec[1] -- lze normalizes specs in place.
			assert(not seen[name], "duplicate spec: " .. name)
			seen[name] = true
			assert(
				#vim.fn.globpath(vim.o.packpath, "pack/*/opt/" .. name, false, true) > 0,
				"missing package: " .. name
			)
		end
	end

	local telescope = require("telescope")
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
	assert(pcall(vim.treesitter.language.add, "lua"), "Nix must supply the Lua parser")
	assert(pcall(vim.treesitter.language.add, "svelte"), "Nix must supply the Svelte parser")
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
