local ls = require("luasnip")
local types = require("luasnip.util.types")

ls.config.set_config({
	history = true,
	updateevents = "TextChanged,TextChangedI",
	enable_autosnippets = true,
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "<-", "Error" } },
			},
		},
	},
	region_check_events = "InsertEnter",
	delete_check_events = "InsertLeave",
})

require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
