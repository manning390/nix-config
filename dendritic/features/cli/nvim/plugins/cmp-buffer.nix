{
  local.nvim.plugins.cmp-buffer = {
    package = "cmp-buffer";
    lua =
      # lua
      ''
        { "cmp-buffer", on_plugin = "nvim-cmp", load = require("config.loader").with_after }
      '';
  };
}
