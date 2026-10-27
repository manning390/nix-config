{
  local.nvim.plugins.cmp-nvim-lua = {
    package = "cmp-nvim-lua";
    lua =
      # lua
      ''
        { "cmp-nvim-lua", on_plugin = "nvim-cmp", load = require("config.loader").with_after }
      '';
  };
}
