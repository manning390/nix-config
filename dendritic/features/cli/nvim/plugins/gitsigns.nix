# Git change signs, hunk actions, and blame information; load when opening a buffer.
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
