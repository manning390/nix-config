local fn = require("config.functions")

-- Resolve plugin functions when invoked, not while defining mappings. lze's
-- on_require handlers then load and configure the relevant optional plugin.
local function deferred(module)
	return setmetatable({}, {
		__index = function(_, method)
			return function(...)
				return require(module)[method](...)
			end
		end,
	})
end

local function extension(name, method)
	return function(...)
		return require("telescope").extensions[name][method](...)
	end
end

local function bind(op, outer_opts)
	outer_opts = outer_opts or { noremap = true }
	return function(lhs, rhs, opts)
		opts = vim.tbl_extend("force", outer_opts, opts or {})
		vim.keymap.set(op, lhs, rhs, opts)
	end
end

local map = bind("")
local nmap = bind("n", { noremap = false })
local nnoremap = bind("n")
local vnoremap = bind("v")
local xnoremap = bind("x")
local inoremap = bind("i")

nnoremap("<enter>", ':let @/=""<cr>', { silent = true }) -- Clear search buffer

nnoremap("Q", "<nop>", { silent = true })
vim.keymap.set({ "n", "v" }, "<Space>", "<nop>", { silent = true })

-- nnoremap('<leader><cr>', function() require('reload') end)

-- Setting local variables for qwerty <-> colemak for downsteam mappings
local sf = string.format
local h, j, k, l, n, N, f = "h", "j", "k", "l", "n", "N", "f"
if vim.env.COLEMAK == "1" then
	h, j, k, l, n, N, f = "m", "n", "e", "i", "h", "H", "t"
	map("m", "h") -- left
	map("n", "j") -- down
	map("e", "k") -- up
	map("i", "l") -- right
	map("l", "i") -- insert
	nnoremap("j", "e") -- end word
	nnoremap("J", "E") -- end WORD
	nmap("h", "n") -- next
	nmap("H", "N") -- previous
	nmap("k", "m") -- mark
	nmap("N", "J") -- join
	nmap("M", "H") -- top screen
	nmap("I", "L") -- bottom screen
	nmap("E", "M") -- middle screen
end
-- nnoremap(k, "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- nnoremap(j, "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

nnoremap(sf("<C-%s>", h), ":TmuxNavigateLeft<cr>", { silent = true }) -- change window left
nnoremap(sf("<C-%s>", j), ":TmuxNavigateDown<cr>", { silent = true }) -- change window down
nnoremap(sf("<C-%s>", k), ":TmuxNavigateUp<cr>", { silent = true }) -- change window up
nnoremap(sf("<C-%s>", l), ":TmuxNavigateRight<cr>", { silent = true }) -- change window right
nnoremap("<C-\\>", ":TmuxNavigatePrevious<cr>", { silent = true })

inoremap("<S-Tab>", "<C-V><Tab>")

-- Harpoon
local harpoon = require("harpoon")
nnoremap("<leader>a", function()
	harpoon:list():add()
end)
nnoremap("<leader>`", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)
for i = 1, 9 do
	nnoremap("<leader>" .. i, function()
		harpoon:list():select(i)
	end)
end
-- nnoremap('<leader>t`', require 'harpoon.cmd-ui'.toggle_quick_menu)
-- nnoremap('<leader>tt', function() require 'harpoon.term'.gotoTerminal(1) end)
-- nnoremap('<leader>ts', function() require 'harpoon.term'.gotoTerminal(0) end)

-- Telescope
local mtel = require("config.telescope")
local tel = deferred("telescope.builtin")
nnoremap("<C-p>", mtel.project_files, { desc = "Search [P]roject" })
nnoremap("<leader><space>", tel.buffers, { desc = "[ ] Find existing buffers" })
nnoremap("<leader>pr", tel.oldfiles, { desc = "Find [R]ecently opened files" })
nnoremap("<leader>pf", function()
	tel.find_files({ no_ignore = true })
end, { desc = "Search [F]iles" })
nnoremap("<leader>ph", tel.help_tags, { desc = "Search [H]elp" })
nnoremap("<leader>pd", tel.diagnostics, { desc = "Search [D]iagnostics" })
nnoremap("<leader>pg", extension("live_grep_args", "live_grep_args"), { desc = "Search by [G]rep" })
nnoremap("<leader>p/", tel.grep_string, { desc = "Search current [W]ord" })
nnoremap("<leader>pb", extension("bookmarks", "bookmarks"), { desc = "Search browser [B]ookmarks" })
-- nnoremap('<leader>pg', function()
-- 	tel.grep_string{ search = vim.fn.input("Grep For > ")} end)
-- nnoremap('<leader>pw', function()
-- 	tel.grep_string{ search = vim.fn.expand("<cword>")} end)
nnoremap("<leader>pt", extension("git_worktree", "git_worktrees"), { desc = "Search Work[T]rees" })
--nnoremap('<leader>pv', mtel.search_dotfiles, { desc = 'Search [V]im Configs' })
nnoremap("<leader>px", mtel.search_nixconfig, { desc = "Search Ni[X] Configs" })
nnoremap("<leader>p<space>", mtel.related_files, { desc = "[p ] Search related files" })
nnoremap("<leader>/", mtel.fuzzy_buffer, { desc = "[/] Fuzzily search in current buffer" })
nnoremap("z?", tel.spell_suggest, { desc = "Suggest Spelling Correction" })

-- Lsp
nnoremap("gd", vim.lsp.buf.definition, { silent = true, desc = "LSP: [G]oto [D]efinition" })
nnoremap("gD", vim.lsp.buf.declaration, { silent = true })
-- nnoremap('gr', vim.lsp.buf.references, {silent = true, desc = 'LSP: [G]oto [R]eferences'})
nnoremap("gr", tel.lsp_references, { silent = true, desc = "LSP: [G]oto [R]eferences" })
nnoremap("gi", tel.lsp_implementations, { silent = true, desc = "LSP: [G]oto [I]mplementations" })
nnoremap("gt", vim.lsp.buf.type_definition, { desc = "LSP: [G]oto [T]ype Definition" })
nnoremap("g?", vim.diagnostic.open_float, { silent = true })
nnoremap("<leader>cn", vim.lsp.buf.rename, { desc = "LSP: [R]e[n]ame" })
nnoremap("<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: [C]ode [A]ction" })
-- nnoremap('<leader>cc', require 'color-converter'.cycle, { desc = '[C]olor [C]onverter' })
-- nnoremap('<leader>ct', ':ClorizerToggle', { desc = '[C]olor Display [T]oggle' })
nnoremap("]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic " })
nnoremap("[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
nnoremap("]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next Error" })
nnoremap("[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous Error" })
--nnoremap(']t', require'todo-comments'.jump_next, { desc = "Next todo comment"})
--nnoremap('[t', require'todo-comments'.jump_prev, { desc = "Previous todo comment"})
nnoremap("<leader>q", vim.diagnostic.setloclist)
-- Neovim maps K to hover buffer-locally when an attached LSP supports it.
nnoremap("<leader>f", ":Format<CR>", { desc = "LSP+Conform: [F]ormat" })
-- nnoremap("<leader>d", ":OverseerRun<CR>", { desc = "[D]ispatch Overseer action" })
-- nnoremap(sf('<C-%s>', h), vim.lsp.buf.signature_help, { desc = 'LSP: Signature Documentation'}) -- Needs colemak rebind
-- nmap('<leader>'..n, function() vim.lsp.diagnostic.goto_next() end, {silent = true})
-- nmap('<leader>'..N, function()
-- 	vim.lsp.diagnostic.show_line_diagnostics()
-- 	vim.lsp.util.show_line_diagnostics()
-- end, {silent = true})

-- Refactoring
-- Spaces at end are intentional
xnoremap("<leader>re", ":Refactor extract ")
xnoremap("<leader>rf", ":Refactor extract_to_file ")
xnoremap("<leader>rv", ":Refactor extract_var ")
vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var")
nnoremap("<leader>rI", ":Refactor inline_func")
nnoremap("<leader>rb", ":Refactor extract_block")
nnoremap("<leader>rbf", ":Refactor extract_block_to_file")
vim.keymap.set({ "n", "x" }, "<leader>rr", function()
	require("refactoring")
	require("telescope").extensions.refactoring.refactors()
end)

-- Run tests
nnoremap("<leader>tq", ":TestNearest<CR>", { desc = "Tests: [T]est Nearest [Q]" })
nnoremap("<leader>ta", ":TestFile<CR>", { desc = "Tests: [T]est [A]ll in File" })
nnoremap("<leader>tz", ":TestSuite<CR>", { desc = "Tests: [T]est Suite [Z]" })
-- nnoremap('<leader>tq', require'neotest'.run.run, { desc = 'Tests: [T]est Nearest [Q]' })
-- nnoremap('<leader>ta', function() require'neotest'.run.run(vim.fn.expand('%')) end, { desc = 'Tests: [T]est [A]ll in File' })
-- nnoremap('<leader>ts',  require'neotest'.summary.toggle, { desc = 'Tests: [T]est Toggle [S]ummary' })
-- nnoremap('<leader>tl',  require'neotest'.run.run_last, { desc = 'Tests: [T]est [L]ast' })
-- nnoremap('<leader>tz', require('neotest').run, { desc = 'Tests: [T]est Suite [Z]' })

-- Snippets
local ls = deferred("luasnip")
vim.keymap.set({ "i", "s" }, "<C-k>", function()
	return ls.expand_or_locally_jumpable() and "<Plug>luasnip-expand-or-jump" or "<C-k>"
end, { expr = true, silent = true, desc = "Snippet: expand or jump forward" })
vim.keymap.set({ "i", "s" }, "<C-j>", function()
	return ls.locally_jumpable(-1) and "<Plug>luasnip-jump-prev" or "<C-j>"
end, { expr = true, silent = true, desc = "Snippet: jump backward" })
inoremap("<C-i>", function()
	return ls.choice_active() and "<Plug>luasnip-next-choice" or "<C-i>"
end, { expr = true, silent = true, desc = "Snippet: next choice, otherwise Tab" })
-- nnoremap('<leader>s', '<cmd>source ~/.config/nvim/lua/manning390/luasnip.lua<cr>')

-- Fugitive
nnoremap("<leader>gs", ":G<cr>")
nnoremap("<leader>gC", ":G ci<cr>")
nnoremap("<leader>gp", ":G push<cr>")
nnoremap("<leader>g" .. j, ":diffget //3<cr>")
nnoremap("<leader>g" .. f, ":diffget //2<cr>")
nnoremap("<leader>gb", ":GBrowse<cr>", { desc = "Fugitive GBrowse to default" })
vnoremap("<leader>gb", ":'<,'>GBrowse<cr>")
nnoremap("<leader>ga", extension("githubcoauthors", "coauthors"), { desc = "Add github co-author from git history" })
nnoremap("<leader>gm", function()
	local branch = fn.getDefaultBranch()
	vim.cmd(string.format("GBrowse origin/%s:%%", branch))
end, { desc = "Fugitive GBrowse to default branch" })
vnoremap("<leader>gm", function()
	local branch = fn.getDefaultBranch()
	vim.cmd(string.format("'<,'>GBrowse origin/%s:%%", branch))
end, { desc = "Fugitive GBrowse to default branch" })

nnoremap("<leader>gw", extension("git_worktree", "create_git_worktree"))

-- Leap's recommended jump bindings: s is bidirectional; S targets another window.
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Leap: jump in current window" })
vim.keymap.set("n", "S", "<Plug>(leap-from-window)", { desc = "Leap: jump to another window" })

-- Quick fix lists
nnoremap("g" .. n, ":cnext<cr>", { silent = true })
nnoremap("g" .. N, ":cprevious<cr>", { silent = true })
nnoremap("gq", fn.toggleQuickfix, { silent = true, desc = "Toggle Quickfix Window" })

-- Edit file path under cursor
nnoremap("gf", ":edit <cfile><cr>")

-- Split and join lines syntactically
local tsj = deferred("treesj")
nnoremap("gm", tsj.toggle)
nnoremap("gs", tsj.split)
nnoremap("gJ", tsj.join)

-- Jump to EOL
inoremap(";;", "<ESC>A;<ESC>")
inoremap(",,", "<ESC>A,<ESC>")

-- Visual Shifting
vnoremap("<", "<gv")
vnoremap(">", ">gv")

nnoremap("<leader>ss", ":setlocal spell!<cr>", { silent = true })
-- nnoremap('<leader>sq', fn.spellToQF)
vnoremap(".", ":normal .<cr>")
nnoremap("<leader>%", ":let @+=expand('%')<cr>") -- Yank filepath into copy buffer
nnoremap("Y", "y$") -- Add missing yank
nnoremap("0", function()
	fn.toggleMovement("^", "0")
end)
nnoremap("~", fn.customCaseToggle)

nnoremap("<leader>pm", ":PhpActor context_menu<cr>")

-- Debugger dap
local dap = deferred("dap")
nnoremap("<F5>", dap.continue, { desc = "Start/continue debugging" })
nnoremap("<F10>", dap.step_over, { desc = "Step over" })
nnoremap("<F11>", dap.step_into, { desc = "Step into" })
nnoremap("<F12>", dap.step_out, { desc = "Step out" })
nnoremap("<leader>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
nnoremap("<leader>dO", dap.step_over, { desc = "Step over (alt)" })
nnoremap("<leader>dc", dap.run_to_cursor, { desc = "Run to cursor" })
nnoremap("<leader>dt", dap.terminate, { desc = "Terminate debugging" })
nnoremap("<leader>ds", function()
	require("dap.ui.widgets").sidebar(require("dap.ui.widgets").scopes).open()
end, { desc = "Show debug scopes" })
nnoremap("<leader>dh", function()
	require("dap.ui.widgets").hover()
end, { desc = "Inspect value under cursor" })
nnoremap("<leader>dr", function()
	require("dap").repl.toggle()
end, { desc = "Toggle DAP REPL" })
nnoremap("<leader>d" .. j, dap.down, { desc = "Go down stack frame" })
nnoremap("<leader>d" .. k, dap.up, { desc = "Go up stack frame" })

-- nnoremap('z/', ':ThesaurusQueryReplaceCurrentWord<cr>')
-- vnoremap('z/', 'y:ThesaurusQueryReplace <C-r>"<cr>')
nnoremap("z/", ":Wrd<cr>")

nnoremap("z ", ":set invlist!<cr>", { silent = true })
