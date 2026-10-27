{
  local.nvim.plugins.devicons = {
    package = "nvim-web-devicons";
    lua =
      # lua
      ''
        { "nvim-web-devicons", on_require = "nvim-web-devicons" }
      '';
  };
}
