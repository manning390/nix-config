-- Run from the nvim directory:
-- nvim --headless -u NONE --cmd 'set rtp^=.' '+luafile tests/writing.lua'
local function test()
	local root = vim.fn.tempname()
	local other = vim.fn.tempname()
	vim.fn.mkdir(root .. "/chapters", "p")
	vim.fn.mkdir(other, "p")
	vim.fn.writefile({ "This are a chapter." }, root .. "/chapters/one.txt")
	vim.fn.writefile({ "Another chaptr." }, root .. "/chapters/two.txt")
	vim.fn.writefile({ "# Notes" }, root .. "/notes.md")
	vim.fn.writefile({ "local x = 1" }, root .. "/code.lua")
	vim.fn.writefile({ "Other project" }, other .. "/three.txt")
	local clients, next_id = {}, 0
	-- Initialize Neovim's diagnostic module before installing the fake clients.
	assert(vim.lsp.diagnostic.get_namespace)
	local original_start, original_clients, original_executable = vim.lsp.start, vim.lsp.get_clients, vim.fn.executable
	vim.fn.executable = function(name)
		return name == "ltex-ls-plus" and 1 or original_executable(name)
	end
	vim.lsp.get_clients = function(filter)
		local result = {}
		for _, client in pairs(clients) do
			if not filter or not filter.name or client.name == filter.name then
				table.insert(result, client)
			end
		end
		return result
	end
	vim.lsp.start = function(config, opts)
		local client
		for _, candidate in pairs(clients) do
			if candidate.config.root_dir == config.root_dir then
				client = candidate
			end
		end
		if not client then
			next_id = next_id + 1
			client = {
				id = next_id,
				name = config.name,
				config = config,
				settings = config.settings,
				attached_buffers = {},
				notify = function() end,
				stop = function(self)
					clients[self.id] = nil
				end,
			}
			clients[client.id] = client
		end
		client.attached_buffers[opts.bufnr] = true
		config.on_attach(client, opts.bufnr)
		return client.id
	end
	vim.cmd("filetype on")
	local writing = require("config.writing")
	writing.setup()
	writing.setup() -- Commands/autocommands are idempotent.
	assert(vim.fn.exists(":Write") == 2 and vim.fn.exists(":WritingMode") == 0)
	vim.cmd.edit(root .. "/chapters/one.txt")
	local first = vim.api.nvim_get_current_buf()
	vim.bo.textwidth = 73
	vim.wo.number = true
	vim.keymap.set("n", "j", "G", { buffer = true })
	-- Exercise root discovery from the actual project rc source.
	vim.fn.writefile({ 'require("config.writing").enable()' }, root .. "/.nvim.lua")
	dofile(root .. "/.nvim.lua")
	assert(vim.b.writing_mode and vim.bo.textwidth == 0 and not vim.wo.number)
	assert(clients[1].config.root_dir == root)
	assert(clients[1].config.get_language_id(first, "text") == "plaintext")
	assert(vim.fn.maparg("j", "n", false, true).expr == 1)
	vim.cmd.edit(root .. "/chapters/two.txt")
	local second = vim.api.nvim_get_current_buf()
	assert(vim.b.writing_mode and clients[1].attached_buffers[second])
	assert(next_id == 1, "chapters must share a server")
	vim.cmd.edit(root .. "/notes.md")
	assert(vim.b.writing_mode)
	vim.cmd.edit(root .. "/code.lua")
	assert(not vim.b.writing_mode and vim.wo.number, "code buffer must retain normal settings")
	vim.cmd.edit(other .. "/three.txt")
	assert(not vim.b.writing_mode)
	writing.enable({ root = other, language = "en-GB" })
	assert(next_id == 2 and clients[2].settings.ltex.language == "en-GB")
	local commands = clients[1].config.commands
	commands["_ltex.addToDictionary"]({ arguments = { { words = { ["en-US"] = { "Kaladin", "Kaladin" } } } } })
	commands["_ltex.disableRules"]({ arguments = { { ruleIds = { ["en-US"] = { "PASSIVE_VOICE" } } } } })
	commands["_ltex.hideFalsePositives"]({
		arguments = { { falsePositives = { ["en-US"] = { '{"sentence":"Intentional."}' } } } },
	})
	local data = vim.json.decode(table.concat(vim.fn.readfile(root .. "/.writing/ltex.json"), "\n"))
	assert(#data.dictionary["en-US"] == 1 and data.dictionary["en-US"][1] == "Kaladin")
	assert(data.disabledRules["en-US"][1] == "PASSIVE_VOICE")
	assert(#data.hiddenFalsePositives["en-US"] == 1)
	assert(not clients[2].settings.ltex.dictionary, "project dictionaries must be isolated")
	vim.cmd.buffer(first)
	local ns = vim.lsp.diagnostic.get_namespace(1, false)
	local other_ns = vim.lsp.diagnostic.get_namespace(2, false)
	local issue = { lnum = 0, col = 0, message = "Test spelling", severity = vim.diagnostic.severity.WARN }
	vim.diagnostic.set(ns, first, { vim.deepcopy(issue) })
	vim.diagnostic.set(ns, second, { vim.deepcopy(issue) })
	vim.diagnostic.set(other_ns, vim.fn.bufnr(other .. "/three.txt"), { vim.deepcopy(issue) })
	writing.quickfix()
	assert(#vim.fn.getqflist() == 2, "quickfix must include only the current project's open chapters")
	vim.cmd.cclose()
	vim.cmd.buffer(first)
	commands["_writing.bufferQuickfix"]({
		arguments = { vim.uri_from_bufnr(first) },
	})
	local items = vim.fn.getqflist()
	assert(#items == 1 and items[1].bufnr == first, "buffer action must exclude other chapters: " .. vim.inspect(items))
	vim.cmd.cclose()
	vim.cmd.buffer(first)
	writing.focus()
	assert(not vim.diagnostic.is_enabled({ bufnr = first, ns_id = ns }))
	writing.focus()
	assert(vim.diagnostic.is_enabled({ bufnr = first, ns_id = ns }))
	vim.cmd("Write off")
	assert(not vim.b.writing_mode and vim.bo.textwidth == 73 and vim.wo.number)
	assert(vim.fn.maparg("j", "n", false, true).rhs == "G", "restore prior buffer mappings")
	assert(not clients[1] and clients[2], "disabling one project must leave the other running")
	assert(#vim.diagnostic.get(first, { namespace = ns }) == 0)
	writing.enable({ root = root })
	assert(clients[3].settings.ltex.dictionary["en-US"][1] == "Kaladin", "reload persisted dictionary")
	writing.disable()
	vim.lsp.start, vim.lsp.get_clients, vim.fn.executable = original_start, original_clients, original_executable
	vim.fn.delete(root, "rf")
	vim.fn.delete(other, "rf")
end

local ok, err = xpcall(test, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd.cquit()
else
	print("writing tests passed")
	vim.cmd.qa({ bang = true })
end
