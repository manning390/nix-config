{
  local.nvim.plugins.lualine = {
    package = "lualine-nvim";
    lua =
      # lua
      ''
        {
          "lualine.nvim",
          after = function()
            require("config.lualine")
          end,
        }
      '';
  };
}
