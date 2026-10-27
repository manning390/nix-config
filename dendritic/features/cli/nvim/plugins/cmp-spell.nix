{
  local.nvim.plugins.cmp-spell = {
    package = "cmp-spell";
    lua =
      # lua
      ''
        { "cmp-spell", on_plugin = "nvim-cmp", load = require("config.loader").with_after }
      '';
  };
}
