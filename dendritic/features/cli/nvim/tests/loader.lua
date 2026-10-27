local function test()
	local loader = require("config.loader")
	local calls = {}
	local options = { enabled = true }
	package.loaded["loader-test-plugin"] = {
		setup = function(opts)
			assert(opts == options, "opts must be passed to setup unchanged")
			table.insert(calls, "setup")
		end,
	}
	local spec = {
		"loader-test-plugin",
		main = "loader-test-plugin",
		opts = options,
		cmd = "TestCommand",
		after = function(plugin)
			assert(plugin.name == "loader-test-plugin", "after must receive the lze plugin")
			table.insert(calls, "after")
		end,
	}
	local normalized = loader.normalize(spec)
	assert(normalized ~= spec, "normalization must not mutate the generated spec")
	assert(spec.opts == options and spec.main == "loader-test-plugin")
	assert(normalized.opts == nil and normalized.main == nil, "adapter fields must not reach lze")
	assert(normalized.cmd == "TestCommand", "lze fields must be preserved")
	normalized.after({ name = "loader-test-plugin" })
	assert(table.concat(calls, ",") == "setup,after", "setup must run before after")

	local hook = function() end
	assert(loader.normalize({ "plain-plugin", after = hook }).after == hook)
	assert(loader.normalize({ "plain-plugin", main = "plain-plugin" }).after == nil, "omitted opts must not call setup")
	assert(not pcall(loader.normalize, { "missing-main", opts = {} }))
	assert(not pcall(loader.normalize, { "invalid-opts", main = "test", opts = true }))

	local batches = {}
	package.loaded.lze = {
		load = function(specs)
			table.insert(batches, specs)
		end,
	}
	loader.load({ spec, { "plain-plugin", lazy = false } })
	assert(#batches == 1 and #batches[1] == 2, "all specs must reach lze in one batch")
	assert(batches[1][1].opts == nil and batches[1][2].lazy == false)
end

local ok, err = xpcall(test, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd.cquit()
else
	print("lze adapter tests passed")
	vim.cmd.qa({ bang = true })
end
