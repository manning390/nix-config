local tsj_utils = require("treesj.langs.utils")
-- Fallback from javascript statement_block join format_tree
local arrow_body_format_join = function(tsj)
	local parent = tsj:tsnode():parent():type()
	if parent == "arrow_function" and tsj:tsnode():named_child_count() == 1 then
		tsj:remove_child({ "{", "}" })
		tsj:update_preset({ force_insert = "", space_in_brackets = false }, "join")
		local stmt = tsj:child("return_statement") or tsj:child("expression_statement")

		if stmt then
			if stmt:has_to_format() then
				stmt:remove_child({ "return", ";" })
				local obj = stmt:child("object")
				if obj then
					tsj:wrap({ left = "(", right = ")" }, "inline")
				end
			else
				local text = stmt:text():gsub("^return ", ""):gsub(";$", "")
				stmt:update_text(text)
			end
		end
	end
end
local single_line_if = {
	statement_block = {
		join = {
			-- space_separator = false,
			format_tree = function(tsj)
				if tsj:tsnode():parent():type() == "if_statement" then
					tsj:remove_child({ left = "{", right = "}" })
				else
					print("arrow")
					arrow_body_format_join(tsj)
				end
			end,
		},
	},
	expression_statement = {
		join = {
			enable = false,
		},
		split = {
			enable = function(tsn)
				return tsn:parent():type() == "if_statement"
			end,
			format_tree = function(tsj)
				tsj:wrap({ left = "{", right = "}" })
			end,
		},
	},
	-- return_statement = {
	-- 	split = {
	-- 		enable = function(tsn)
	-- 			return tsn:parent():type() == "if_statement"
	-- 		end,
	-- 		format_tree = function(tsj)
	-- 			tsj:wrap({ left = "{", right = "}" })
	-- 		end,
	-- 	},
	-- },
}
require("treesj").setup({
	use_default_keymaps = false,
	langs = {
		javascript = tsj_utils.merge_preset(require("treesj.langs.javascript"), single_line_if),
		typescript = tsj_utils.merge_preset(require("treesj.langs.typescript"), single_line_if),
		tsx = tsj_utils.merge_preset(require("treesj.langs.tsx"), single_line_if),
	},
})
