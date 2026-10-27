{
  local.nvim.plugins.typescript-tools = {
    package = "typescript-tools-nvim";
    lua =
      # lua
      ''
        {
          "typescript-tools.nvim",
          ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
          main = "typescript-tools",
          opts = {},
        }
      '';
  };
}
