local dap = require("dap")

for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
	dap.adapters[adapter] = {
		type = "server",
		host = "127.0.0.1",
		port = "${port}",
		executable = {
			command = "js-debug",
			args = { "${port}", "127.0.0.1" },
		},
	}
end

for _, filetype in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" }) do
	dap.configurations[filetype] = {
		{
			name = "Node: launch current file (JavaScript or compiled output)",
			type = "pwa-node",
			request = "launch",
			program = "${file}",
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			skipFiles = { "<node_internals>/**", "**/node_modules/**" },
		},
		{
			name = "Node: attach (start app with --inspect)",
			type = "pwa-node",
			request = "attach",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			skipFiles = { "<node_internals>/**", "**/node_modules/**" },
		},
		{
			name = "Chrome: debug dev server (TypeScript / Svelte)",
			type = "pwa-chrome",
			request = "launch",
			url = function()
				return vim.fn.input("Dev server URL: ", "http://localhost:5173")
			end,
			webRoot = "${workspaceFolder}",
			cwd = "${workspaceFolder}",
			sourceMaps = true,
		},
	}
end

dap.adapters.coreclr = {
	type = "executable",
	command = "netcoredbg",
	args = { "--interpreter=vscode" },
}
dap.configurations.cs = {
	{
		name = ".NET: launch built DLL",
		type = "coreclr",
		request = "launch",
		program = function()
			return vim.fn.input("DLL path (run dotnet build first): ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopAtEntry = false,
	},
	{
		name = ".NET: attach",
		type = "coreclr",
		request = "attach",
		processId = require("dap.utils").pick_process,
	},
}

dap.adapters.php = {
	type = "executable",
	command = "php-debug",
}
dap.configurations.php = {
	{
		name = "PHP: listen for Xdebug on port 9003",
		type = "php",
		request = "launch",
		port = 9003,
	},
}

-- Project launch.json configurations are read on demand by nvim-dap.
local vscode = require("dap.ext.vscode")
vscode.type_to_filetypes = vim.tbl_extend("force", vscode.type_to_filetypes, {
	["pwa-node"] = { "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" },
	["pwa-chrome"] = { "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" },
	coreclr = { "cs" },
	php = { "php" },
})
