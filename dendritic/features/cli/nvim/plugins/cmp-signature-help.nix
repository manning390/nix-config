{
  local.nvim.plugins.cmp-signature-help = {
    package = "cmp-nvim-lsp-signature-help";
    lua =
      # lua
      ''
        { "cmp-nvim-lsp-signature-help", on_plugin = "nvim-cmp", load = require("config.loader").with_after }
      '';
  };
}
