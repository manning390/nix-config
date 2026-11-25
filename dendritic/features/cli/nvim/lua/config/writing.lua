-- Project-scoped prose editing. Opt in from a trusted .nvim.lua.
local M = {}
local projects, buffers, windows = {}, {}, {}
local group
local buffer_options =
	{ "textwidth", "wrapmargin", "formatoptions", "formatexpr", "indentexpr", "autoindent", "smartindent" }
local window_options =
	{ "wrap", "linebreak", "breakindent", "showbreak", "list", "number", "relativenumber", "colorcolumn", "spell" }

local function normalize(path)
	return vim.fs.normalize(vim.fn.fnamemodify(path, ":p")):gsub("/+$", "")
end

local function contains(root, path)
	return path:sub(1, #root + 1) == root .. "/"
end

local function project_for(buf)
	local path = normalize(vim.api.nvim_buf_get_name(buf))
	local found
	for root, project in pairs(projects) do
		if contains(root, path) and (not found or #root > #found.root) then
			found = project
		end
	end
	return found
end

local function eligible(buf, project)
	return vim.bo[buf].buftype == "" and vim.tbl_contains(project.filetypes, vim.bo[buf].filetype)
end

local function read_data(project)
	local file = io.open(project.path, "r")
	if not file then
		return {}
	end
	local text = file:read("*a")
	file:close()
	-- Invalid configuration must not be silently overwritten by a code action.
	local data = vim.json.decode(text)
	assert(type(data) == "table", "Invalid writing dictionary: " .. project.path)
	return data
end

local function settings(project)
	return vim.tbl_deep_extend("force", {
		language = project.language,
		checkFrequency = "edit",
	}, project.ltex, read_data(project))
end

local function persist(project, command, field, argument)
	local values = assert(command.arguments and command.arguments[1], "Missing LTeX action arguments")[argument]
	assert(type(values) == "table", "Invalid LTeX action arguments")
	local data = read_data(project)
	data[field] = data[field] or {}
	for language, additions in pairs(values) do
		data[field][language] = data[field][language] or {}
		for _, value in ipairs(additions) do
			if not vim.tbl_contains(data[field][language], value) then
				table.insert(data[field][language], value)
			end
		end
	end
	vim.fn.mkdir(vim.fs.dirname(project.path), "p")
	local temporary = project.path .. "." .. vim.fn.getpid() .. ".tmp"
	assert(vim.fn.writefile({ vim.json.encode(data) }, temporary) == 0, "Cannot save writing dictionary")
	assert(vim.uv.fs_rename(temporary, project.path))
	for _, client in ipairs(vim.lsp.get_clients({ name = "writing-ltex" })) do
		if client.config.root_dir == project.root then
			client.settings.ltex = settings(project)
			client:notify("workspace/didChangeConfiguration", { settings = client.settings })
		end
	end
end

local function namespaces(client_id)
	return {
		vim.lsp.diagnostic.get_namespace(client_id, false),
		vim.lsp.diagnostic.get_namespace(client_id, true),
	}
end

local function start_lsp(buf, project)
	if vim.fn.executable("ltex-ls-plus") == 0 then
		if not project.warned then
			vim.notify("Writing mode: ltex-ls-plus is missing; rebuild your Nix configuration.", vim.log.levels.WARN)
			project.warned = true
		end
		return
	end
	local commands = {}
	for name, spec in pairs({
		addToDictionary = { "dictionary", "words" },
		disableRules = { "disabledRules", "ruleIds" },
		hideFalsePositives = { "hiddenFalsePositives", "falsePositives" },
	}) do
		commands["_ltex." .. name] = function(command)
			local ok, err = pcall(persist, project, command, spec[1], spec[2])
			if not ok then
				vim.notify(tostring(err), vim.log.levels.ERROR)
			end
		end
	end
	commands["_writing.bufferQuickfix"] = function(command)
		local uri = command.arguments and command.arguments[1]
		local target = uri and vim.uri.to_buf(uri)
		if target and buffers[target] and buffers[target].project == project then
			M.quickfix({ bufnr = target })
		end
	end
	vim.lsp.start({
		name = "writing-ltex",
		-- Extend this server's responses, not Neovim's global code-action UI:
		-- native code_action() keeps its filtering, resolution and edit handling.
		cmd = function(dispatchers)
			local rpc = vim.lsp.rpc.start({ "ltex-ls-plus" }, dispatchers)
			local request = rpc.request
			rpc.request = function(method, params, callback, ...)
				if method == "textDocument/codeAction" then
					local original_callback = callback
					callback = function(err, result, request_id)
						local target = vim.uri.to_buf(params.textDocument.uri)
						local only = params.context and params.context.only
						local include = not only or #only == 0 or vim.tbl_contains(only, "source")
						if not err and include and buffers[target] and buffers[target].project == project then
							result = result and result ~= vim.NIL and result or {}
							table.insert(result, {
								title = "Writing: list buffer issues in quickfix",
								kind = "source",
								command = {
									title = "List buffer issues",
									command = "_writing.bufferQuickfix",
									arguments = { params.textDocument.uri },
								},
							})
						end
						original_callback(err, result, request_id)
					end
				end
				return request(method, params, callback, ...)
			end
			return rpc
		end,
		root_dir = project.root,
		settings = { ltex = settings(project) },
		commands = commands,
		-- Preserve the buffer's filetype; .txt chapters are checked as plain text.
		get_language_id = function(_, ft)
			return ft == "text" and "plaintext" or ft
		end,
		on_attach = function(client, attached)
			for _, ns in ipairs(namespaces(client.id)) do
				vim.diagnostic.config({ virtual_text = false, underline = true }, ns)
				vim.diagnostic.enable(not project.focus, { bufnr = attached, ns_id = ns })
			end
		end,
	}, { bufnr = buf })
end

local function restore_window(win)
	local saved = windows[win]
	if saved and vim.api.nvim_win_is_valid(win) then
		for key, value in pairs(saved) do
			vim.wo[win][key] = value
		end
	end
	windows[win] = nil
end

local function update_window()
	local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
	if not buffers[buf] then
		restore_window(win)
		return
	end
	if not windows[win] then
		windows[win] = {}
		for _, key in ipairs(window_options) do
			windows[win][key] = vim.wo[win][key]
		end
	end
	for key, value in pairs({
		wrap = true,
		linebreak = true,
		breakindent = true,
		showbreak = "",
		list = false,
		number = false,
		relativenumber = false,
		colorcolumn = "",
		-- LTeX is the single spelling source, including the project dictionary.
		spell = false,
	}) do
		vim.wo[win][key] = value
	end
end

local function attach(buf)
	local project = project_for(buf)
	if buffers[buf] or not project or not eligible(buf, project) then
		return
	end
	local saved = { options = {}, mappings = {}, project = project }
	for _, key in ipairs(buffer_options) do
		saved.options[key] = vim.bo[buf][key]
	end
	buffers[buf] = saved
	vim.b[buf].writing_mode = true
	vim.bo[buf].textwidth = 0
	vim.bo[buf].wrapmargin = 0
	vim.bo[buf].formatoptions = vim.bo[buf].formatoptions:gsub("[atcro]", "")
	vim.bo[buf].formatexpr = ""
	vim.bo[buf].indentexpr = ""
	vim.bo[buf].autoindent = false
	vim.bo[buf].smartindent = false
	local keys = vim.g.keymaps or { j = "j", k = "k" }
	for _, motion in ipairs({ { keys.j, "gj", "j" }, { keys.k, "gk", "k" } }) do
		local lhs, rhs, counted = unpack(motion)
		vim.api.nvim_buf_call(buf, function()
			local old = vim.fn.maparg(lhs, "n", false, true)
			saved.mappings[lhs] = old.buffer == 1 and old or false
		end)
		vim.keymap.set("n", lhs, function()
			return vim.v.count == 0 and rhs or counted
		end, { buffer = buf, expr = true, desc = "Writing: move by display line" })
	end
	start_lsp(buf, project)
end

local function current_project()
	return project_for(vim.api.nvim_get_current_buf()) or projects[normalize(vim.fn.getcwd())]
end

function M.enable(opts)
	opts = opts or {}
	-- During exrc execution, resolve relative to the rc file, not a chapter subdirectory.
	local source = debug.getinfo(2, "S").source
	local caller = source:sub(1, 1) == "@" and source:sub(2) or ""
	local rc_root = vim.fs.basename(caller) == ".nvim.lua" and vim.fs.dirname(caller) or nil
	local root = normalize(opts.root or rc_root or vim.fn.getcwd())
	if projects[root] then
		return
	end
	local project = {
		root = root,
		path = root .. "/.writing/ltex.json",
		language = opts.language or "en-US",
		filetypes = opts.filetypes or { "text", "markdown" },
		ltex = opts.ltex or {},
		focus = false,
	}
	settings(project) -- Validate persisted data before changing editor state.
	projects[root] = project
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			attach(buf)
		end
	end
	update_window()
end

function M.disable()
	local project = current_project()
	if not project then
		return
	end
	projects[project.root] = nil
	for buf, saved in pairs(buffers) do
		if saved.project == project then
			if vim.api.nvim_buf_is_valid(buf) then
				for key, value in pairs(saved.options) do
					vim.bo[buf][key] = value
				end
				for lhs, old in pairs(saved.mappings) do
					vim.keymap.del("n", lhs, { buffer = buf })
					if old then
						vim.api.nvim_buf_call(buf, function()
							vim.fn.mapset("n", false, old)
						end)
					end
				end
				vim.b[buf].writing_mode = nil
			end
			buffers[buf] = nil
		end
	end
	for _, client in ipairs(vim.lsp.get_clients({ name = "writing-ltex" })) do
		if client.config.root_dir == project.root then
			for buf in pairs(client.attached_buffers) do
				for _, ns in ipairs(namespaces(client.id)) do
					vim.diagnostic.reset(ns, buf)
				end
			end
			client:stop()
		end
	end
	for win in pairs(windows) do
		if vim.api.nvim_win_is_valid(win) and not buffers[vim.api.nvim_win_get_buf(win)] then
			restore_window(win)
		end
	end
end

function M.quickfix(opts)
	opts = opts or {}
	local buf = opts.bufnr
	local project = buf and project_for(buf) or current_project()
	if not project then
		return vim.notify("Enable writing mode in this project first.", vim.log.levels.WARN)
	end
	local diagnostics = {}
	for _, client in ipairs(vim.lsp.get_clients({ name = "writing-ltex" })) do
		if client.config.root_dir == project.root then
			for _, ns in ipairs(namespaces(client.id)) do
				vim.list_extend(diagnostics, vim.diagnostic.get(buf, { namespace = ns }))
			end
		end
	end
	local items = vim.diagnostic.toqflist(diagnostics)
	table.sort(items, function(a, b)
		if a.bufnr ~= b.bufnr then
			return vim.api.nvim_buf_get_name(a.bufnr) < vim.api.nvim_buf_get_name(b.bufnr)
		end
		return a.lnum == b.lnum and a.col < b.col or a.lnum < b.lnum
	end)
	local title = buf and vim.api.nvim_buf_get_name(buf) or project.root
	vim.fn.setqflist({}, " ", { title = "Writing: " .. title, items = items })
	vim.cmd.copen()
end

function M.focus()
	local project = current_project()
	if not project then
		return
	end
	project.focus = not project.focus
	for _, client in ipairs(vim.lsp.get_clients({ name = "writing-ltex" })) do
		if client.config.root_dir == project.root then
			for buf in pairs(client.attached_buffers) do
				for _, ns in ipairs(namespaces(client.id)) do
					vim.diagnostic.enable(not project.focus, { bufnr = buf, ns_id = ns })
				end
			end
		end
	end
	vim.notify("Writing diagnostics " .. (project.focus and "hidden" or "visible"))
end

function M.setup()
	if group then
		return
	end
	group = vim.api.nvim_create_augroup("ProjectWriting", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
		group = group,
		callback = function(event)
			attach(event.buf)
			update_window()
		end,
	})
	vim.api.nvim_create_autocmd("BufWipeout", {
		group = group,
		callback = function(event)
			buffers[event.buf] = nil
		end,
	})
	vim.api.nvim_create_user_command("Write", function(args)
		local action = args.args ~= "" and args.args or "toggle"
		if action == "off" or (action == "toggle" and current_project()) then
			M.disable()
		elseif action == "on" or action == "toggle" then
			M.enable()
		else
			error("Usage: Write [on|off|toggle]")
		end
	end, {
		nargs = "?",
		complete = function()
			return { "on", "off", "toggle" }
		end,
	})
	vim.api.nvim_create_user_command(
		"WritingQuickfix",
		M.quickfix,
		{ desc = "List open chapters' grammar and spelling issues" }
	)
	vim.api.nvim_create_user_command("WritingFocus", M.focus, { desc = "Toggle writing diagnostic visibility" })
end

return M
