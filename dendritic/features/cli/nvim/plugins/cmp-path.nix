{
  local.nvim.plugins.cmp-path = {
    package = "cmp-path";
    lua =
      # lua
      ''
        { "cmp-path", on_plugin = "nvim-cmp", load = require("config.loader").with_after }
      '';
  };
}
