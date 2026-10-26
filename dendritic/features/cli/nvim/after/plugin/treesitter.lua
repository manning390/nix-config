-- Nix supplies parsers and queries; highlighting and folding use Neovim's API.
local group = vim.api.nvim_create_augroup("config_treesitter", { clear = true })
local ignored_filetypes = {
	"TelescopePrompt",
	"TelescopeResults",
	"notify",
	"help",
	"fugitive",
	"cmp_menu",
	"cmp_docs",
	"harpoon",
	"lazy",
	"lazy_backdrop",
	"bash",
	"sh",
	"text",
}

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
	group = group,
	callback = function(args)
		local buf = args.buf
		local ft = vim.bo[buf].filetype
		if vim.bo[buf].buftype ~= "" or vim.tbl_contains(ignored_filetypes, ft) then
			return
		end
		local lang = vim.treesitter.language.get_lang(ft)
		if not lang or not pcall(vim.treesitter.start, buf, lang) then
			return -- Some filetypes have no installed parser.
		end

		-- Folding options belong to windows, not buffers.
		if vim.api.nvim_get_current_buf() == buf then
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		end
		if ft ~= "python" then
			vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

require("ts_context_commentstring").setup({})

-- Keep the existing textobjects, using the standalone main-branch API.
-- Examples: `vaf` selects a function, `dif` deletes its contents, `]m` moves to the next one.
require("nvim-treesitter-textobjects").setup({
	select = { lookahead = true },
	move = { set_jumps = true },
})

for lhs, capture in pairs({
	ac = "@class.outer",
	ic = "@class.inner",
	af = "@function.outer",
	["if"] = "@function.inner",
	aa = "@parameter.outer",
	ia = "@parameter.inner",
}) do
	vim.keymap.set({ "x", "o" }, lhs, function()
		require("nvim-treesitter-textobjects.select").select_textobject(capture, "textobjects")
	end, { desc = "Treesitter: select " .. capture })
end

for method, mappings in pairs({
	goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
	goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
	goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
	goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
}) do
	for lhs, capture in pairs(mappings) do
		vim.keymap.set({ "n", "x", "o" }, lhs, function()
			require("nvim-treesitter-textobjects.move")[method](capture, "textobjects")
		end, { desc = "Treesitter: " .. method .. " " .. capture })
	end
end
