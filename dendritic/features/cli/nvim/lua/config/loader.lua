local M = {}

-- cmp sources register themselves in after/plugin. Plain packadd does not source
-- those scripts when loading a source after startup.
function M.with_after(name)
	vim.cmd.packadd(name)
	vim.cmd.packadd(name .. "/after")
end

-- A deliberately small extension to lze: explicit module names, no guessing.
-- opts runs setup before an optional user-supplied after hook.
function M.normalize(spec)
	local normalized = vim.tbl_extend("force", {}, spec)
	if spec.opts ~= nil then
		assert(type(spec.main) == "string", "a plugin with opts must declare main")
		assert(type(spec.opts) == "table", "plugin opts must be a Lua table")
		local main, opts, after = spec.main, spec.opts, spec.after
		normalized.after = function(plugin)
			require(main).setup(opts)
			if after then
				after(plugin)
			end
		end
	end
	-- These are adapter fields, not part of lze's spec.
	normalized.main = nil
	normalized.opts = nil
	return normalized
end

function M.load(specs)
	require("lze").load(vim.tbl_map(M.normalize, specs))
end

return M
