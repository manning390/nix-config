if not pcall(require, 'nvim-treesitter') then
	return
end

require('nvim-treesitter.configs').setup {
	ensure_installed      = { },
	highlight             = { enable = true },
	indent                = { enable = true, disable = { 'python' } },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection    = '<c-space>',
			node_incremental  = '<c-space>',
			scope_incremental = '<c-s>',
			node_decremental  = '<c-backspace>',
		},
	},
	sync_install          = true,
	auto_install          = true,
	textobjects           = {
		select = {
			enable = true,
			lookahead = true, -- Automatically jump forward to textobj, similiar to targets.vim,
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				['ac'] = '@class.outer',
				['ic'] = '@class.inner',
				['if'] = '@function.inner',
				['af'] = '@function.outer',
				['ia'] = '@parameter.inner',
				['aa'] = '@parameter.outer',
			}
		}
	},
	move                  = {
		enable = true,
		set_jumps = true, -- whether to set jumps in the jumplist
		goto_next_start = {
			[']m'] = '@function.outer',
			[']]'] = '@class.outer',
		},
		goto_next_end = {
			[']M'] = '@function.outer',
			[']['] = '@class.outer',
		},
		goto_previous_start = {
			['[m'] = '@function.outer',
			['[['] = '@class.outer',
		},
		goto_previous_end = {
			['[M'] = '@function.outer',
			['[]'] = '@class.outer',
		},
	},
	tree_docs             = { enable = true }
}
require('ts_context_commentstring').setup {}
vim.g.skip_ts_context_commentstring_module = true

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.blade = {
  install_info = {
    url = "https://github.com/EmranMR/tree-sitter-blade",
    files = {"src/parser.c"},
    branch = "main",
  },
  filetype = "blade"
}
