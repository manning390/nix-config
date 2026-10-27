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
