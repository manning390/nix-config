local function test()
	require("telescope")
	local ini = require("browser_bookmarks.parser.ini")
	local path = vim.fn.tempname()
	local fixture = "[Profile0]\nName=default-release\nIsRelative=1\nPath=Profiles/example.default-release\nDefault=1\n"
	local function parse(contents)
		local file = assert(io.open(path, "wb"))
		file:write(contents)
		file:close()
		local ok, result = pcall(ini.load, path)
		os.remove(path)
		assert(ok, result)
		return result
	end
	local unix = parse(fixture)
	local windows = parse((fixture:gsub("\n", "\r\n")))
	assert(vim.deep_equal(unix, windows), "Windows and Unix profiles must parse identically")
	assert(windows.Profile0.Name == "default-release", "profile names must not retain CR")
	assert(windows.Profile0.Path == "Profiles/example.default-release", "paths must not retain CR")
	assert(windows.Profile0.IsRelative == 1 and windows.Profile0.Default == 1)
end

local ok, err = xpcall(test, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd.cquit()
else
	print("bookmark tests passed")
	vim.cmd.qa({ bang = true })
end
