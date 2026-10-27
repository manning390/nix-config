# File-type icons for statuslines and pickers; load when a consumer requires them.
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
