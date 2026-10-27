{
  local.nvim.plugins.gitsigns = {
    package = "gitsigns-nvim";
    lua =
      # lua
      ''
        {
          "gitsigns.nvim",
          event = { "BufReadPost", "BufNewFile" },
          main = "gitsigns",
          opts = {},
        }
      '';
  };
}
