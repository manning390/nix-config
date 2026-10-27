{
  local.nvim.plugins.devicons = {
    package = "nvim-web-devicons";
    lua =
      # lua
      ''
        { "nvim-web-devicons", priority = 100 }
      '';
  };
}
