{
  local.nvim.plugins.cmp-async-path = {
    package = "cmp-async-path";
    lua =
      # lua
      ''
        { "cmp-async-path", on_plugin = "nvim-cmp", load = require("config.loader").with_after }
      '';
  };
}
