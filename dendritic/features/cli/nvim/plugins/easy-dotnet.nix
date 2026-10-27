# .NET project, test, package, and execution tools.
# Load for C# buffers or :Dotnet; package completion also initializes cmp.
{
  local.nvim.plugins.easy-dotnet = {
    package = "easy-dotnet-nvim";
    lua =
      # lua
      ''
        {
          "easy-dotnet.nvim",
          ft = "cs",
          cmd = "Dotnet",
          main = "easy-dotnet",
          opts = {},
          after = function()
            require("cmp").register_source("easy-dotnet", require("easy-dotnet").package_completion_source)
          end,
        }
      '';
  };
}
