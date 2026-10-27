{
  local.nvim.plugins.lspconfig = {
    package = "nvim-lspconfig";
    lua =
      # lua
      ''
        {
          "nvim-lspconfig",
          priority = 60, -- Register servers before the first FileType event.
          after = function()
            require("config.lsp")
          end,
        }
      '';
  };
}
