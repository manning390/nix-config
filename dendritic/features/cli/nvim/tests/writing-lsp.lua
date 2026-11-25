-- Optional integration test: requires ltex-ls-plus on PATH.
-- nvim --headless -u NONE --cmd 'set rtp^=.' '+luafile tests/writing-lsp.lua'
local root
local function test()
	assert(vim.fn.executable("ltex-ls-plus") == 1, "ltex-ls-plus must be on PATH")
	root = vim.fn.tempname()
	vim.fn.mkdir(root, "p")
	vim.fn.writefile({ "This is a sentense." }, root .. "/chapter.txt")
	vim.cmd("filetype on")
	vim.cmd.edit(root .. "/chapter.txt")
	local buf = vim.api.nvim_get_current_buf()
	local writing = require("config.writing")
	writing.setup()
	writing.enable({ root = root })
	local function diagnostics()
		return vim.diagnostic.get(buf)
	end
	assert(
		vim.wait(90000, function()
			return #diagnostics() > 0
		end, 100),
		"No LTeX diagnostics received"
	)
	local client = assert(vim.lsp.get_clients({ name = "writing-ltex" })[1])
	vim.fn.writefile({ "This is a diffrent chapter." }, root .. "/second.txt")
	vim.cmd.edit(root .. "/second.txt")
	local second = vim.api.nvim_get_current_buf()
	assert(
		vim.wait(30000, function()
			return #vim.diagnostic.get(second) > 0
		end, 100),
		"Second chapter received no diagnostics"
	)
	assert(#vim.lsp.get_clients({ name = "writing-ltex" }) == 1, "Chapters must share one LTeX process")
	vim.cmd.buffer(buf)
	local diagnostic = diagnostics()[1]
	local response = client:request_sync("textDocument/codeAction", {
		textDocument = { uri = vim.uri_from_bufnr(buf) },
		range = {
			start = { line = diagnostic.lnum, character = diagnostic.col },
			["end"] = { line = diagnostic.end_lnum, character = diagnostic.end_col },
		},
		context = { diagnostics = { diagnostic.user_data.lsp } },
	}, 10000, buf)
	assert(response and not response.err, vim.inspect(response))
	local actions = assert(response.result)
	local dictionary, ignore, disable, fix, buffer_quickfix
	for _, action in ipairs(actions) do
		local command = action.command
		if type(command) == "table" then
			if command.command == "_ltex.addToDictionary" then
				dictionary = command
			end
			if command.command == "_ltex.hideFalsePositives" then
				ignore = command
			end
			if command.command == "_ltex.disableRules" then
				disable = command
			end
			if command.command == "_writing.bufferQuickfix" then
				buffer_quickfix = action
			end
		end
		if action.edit then
			fix = action
		end
	end
	assert(dictionary and ignore and disable and fix, "Missing expected LTeX code actions: " .. vim.inspect(actions))
	assert(buffer_quickfix, "Missing buffer quickfix code action")
	-- Exercise the native code-action menu, as used by the existing 'ca mapping.
	local original_select, selected = vim.ui.select, false
	vim.ui.select = function(items, _, choose)
		for _, item in ipairs(items) do
			if item.action and item.action.title == buffer_quickfix.title then
				selected = true
				choose(item)
				return
			end
		end
		error("Buffer quickfix action missing from native code-action menu")
	end
	vim.lsp.buf.code_action()
	assert(
		vim.wait(10000, function()
			return selected
		end, 100),
		"Code-action menu not shown"
	)
	vim.ui.select = original_select
	local items = vim.fn.getqflist()
	assert(#items > 0 and items[1].bufnr == buf, "Native code action did not populate buffer quickfix")
	for _, item in ipairs(items) do
		assert(item.bufnr == buf, "Buffer code action included a different chapter")
	end
	vim.cmd.cclose()
	vim.cmd.buffer(buf)
	assert(client.commands[dictionary.command], "Code action handler not registered")
	client.commands[dictionary.command](dictionary, { client_id = client.id, bufnr = buf })
	assert(vim.fn.filereadable(root .. "/.writing/ltex.json") == 1)
	assert(
		vim.wait(30000, function()
			return #diagnostics() == 0
		end, 100),
		"Dictionary change did not clear spelling issue"
	)
	vim.lsp.util.apply_workspace_edit(fix.edit, client.offset_encoding)
	assert(
		vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= "This is a sentense.",
		"Suggested replacement not applied"
	)
	writing.disable()
	vim.fn.delete(root, "rf")
end

local ok, err = xpcall(test, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd.cquit()
else
	print("writing LSP integration tests passed")
	vim.cmd.qa({ bang = true })
end
