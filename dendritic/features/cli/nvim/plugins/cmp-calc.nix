{
  local.nvim.plugins.cmp-calc = {
    package = "cmp-calc";
    lua =
      # lua
      ''
        { "cmp-calc", on_plugin = "nvim-cmp", load = require("config.loader").with_after }
      '';
  };
}
