-- Installation lives in _plugins.nix. Names here match Nix's pack/*/opt directories.
-- Keep one combined spec so ordering/priority applies across all groups.
local specs = {}
for _, group in ipairs({ "ui", "editing", "lsp", "completion", "telescope", "tools" }) do
	vim.list_extend(specs, require("plugins." .. group))
end
require("lze").load(specs)
