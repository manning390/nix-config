# Debug Adapter Protocol client with JavaScript, .NET, and PHP adapters.
# Load when a debugger mapping requires the Lua API.
{
  local.nvim.plugins.dap = {
    package = "nvim-dap";
    extraPackages = pkgs: [
      pkgs.vscode-js-debug
      pkgs.netcoredbg
      (pkgs.writeShellScriptBin "php-debug" ''
        exec ${pkgs.nodejs}/bin/node ${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js "$@"
      '')
    ];
    lua =
      # lua
      ''
        {
          "nvim-dap",
          on_require = "dap",
          after = function()
            require("config.dap")
          end,
        }
      '';
  };
}
