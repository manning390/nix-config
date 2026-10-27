{
  local.nvim.plugins.cmp-luasnip = {
    package = "cmp_luasnip";
    lua =
      # lua
      ''
        { "cmp_luasnip", on_plugin = "nvim-cmp", load = require("config.loader").with_after }
      '';
  };
}
